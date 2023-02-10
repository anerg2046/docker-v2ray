#!/bin/bash

VALID_ARGS=$(getopt -o '' --long sslisten:,ssport:,sspass:,ssmode:,ssmethod:,cftoken:,cfkey:,cfemail:,cfzone:,cfsubdomain:,cfipv4:,cfipv6: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi
eval set -- "$VALID_ARGS"

SSSERVER_LISTEN="${SS_LISTEN:-0.0.0.0}"
SSSERVER_PORT="${SS_PORT:-443}"
SSSERVER_PASSWORD="${SS_PASS:-yourpassword}"
SSSERVER_MODE="${SS_MODE:-tcp_only}"
SSSERVER_METHOD="${SS_METHOD:-chacha20-ietf-poly1305}"

CLOUDFLARE_API_TOKEN="${CF_API_TOKEN:-yourtoken}"
CLOUDFLARE_API_KEY="${CF_API_KEY:-yourkey}"
CLOUDFLARE_ACCOUNT_EMAIL="${CF_ACCOUNT_EMAIL:-youremail}"
CLOUDFLARE_ZONE_ID="{CF_ZONE_ID:-zoneid}"
CLOUDFLARE_SUBDOMAIN="${CF_SUBDOMAIN:-yoursubdomain}"
CLOUDFLARE_IPV4="${CF_IPV4:-true}"
CLOUDFLARE_IPV6="${CF_IPV6:-true}"


while true; do
  case "$1" in
    --sslisten)
        SSSERVER_LISTEN="$2"
        shift 2
        ;;
    --ssport)
        SSSERVER_PORT="$2"
        shift 2
        ;;
    --sspass)
        SSSERVER_PASSWORD="$2"
        shift 2
        ;;
    --ssmode)
        SSSERVER_MODE="$2"
        shift 2
        ;;
    --ssmethod)
        SSSERVER_METHOD="$2"
        shift 2
        ;;
    --cftoken)
        CLOUDFLARE_API_TOKEN="$2"
        shift 2
        ;;
    --cfkey)
        CLOUDFLARE_API_KEY="$2"
        shift 2
        ;;
    --cfemail)
        CLOUDFLARE_ACCOUNT_EMAIL="$2"
        shift 2
        ;;
    --cfzone)
        CLOUDFLARE_ZONE_ID="$2"
        shift 2
        ;;
    --cfsubdomain)
        CLOUDFLARE_SUBDOMAIN="$2"
        shift 2
        ;;
    --cfipv4)
        CLOUDFLARE_IPV4="$2"
        shift 2
        ;;
    --cfipv6)
        CLOUDFLARE_IPV6="$2"
        shift 2
        ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

echo """
SSSERVER_LISTEN is ${SSSERVER_LISTEN}
SSSERVER_PORT is ${SSSERVER_PORT}
SSSERVER_PASSWORD is ${SSSERVER_PASSWORD}
SSSERVER_MODE is ${SSSERVER_MODE}
SSSERVER_METHOD is ${SSSERVER_METHOD}

CLOUDFLARE_API_TOKEN is ${CLOUDFLARE_API_TOKEN}
CLOUDFLARE_API_KEY is ${CLOUDFLARE_API_KEY}
CLOUDFLARE_ACCOUNT_EMAIL is ${CLOUDFLARE_ACCOUNT_EMAIL}
CLOUDFLARE_ZONE_ID is ${CLOUDFLARE_ZONE_ID}
CLOUDFLARE_SUBDOMAIN is ${CLOUDFLARE_SUBDOMAIN}
CLOUDFLARE_IPV4 is ${CLOUDFLARE_IPV4}
CLOUDFLARE_IPV6 is ${CLOUDFLARE_IPV6}
"""

curl -fsSL https://get.docker.com |bash

if ! lsmod | grep bbr;then
    echo "net.core.default_qdisc=fq" |sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" |sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
fi

sudo mkdir -p /etc/docker

cat <<EOF |sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "live-restore": true,
  "max-concurrent-downloads": 10,
  "default-ulimit": ["nofile=1048576:1048576"],
  "selinux-enabled": false,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "30m",
    "max-file": "3"
  }
}
EOF

sudo systemctl enable docker
sudo systemctl restart docker

cat <<EOF |sudo tee ~/docker-compose.yml
version: "3.8"
services:
  ssserver:
    container_name: ssserver
    image: "ghcr.io/shadowsocks/ssserver-rust:latest"
    restart: always
    network_mode: "host"
    volumes:
      - ./ss-server.json:/etc/shadowsocks-rust/config.json
  cloudflare-ddns:
    image: wqferan/cloudflare-ddns:latest
    container_name: cloudflare-ddns
    security_opt:
      - no-new-privileges:true
    network_mode: "host"
    environment:
      - PUID=1000
      - PGID=1000
    volumes:
      - ./ddns-config.yml:/apps/config.yml
    restart: always
EOF

cat <<EOF |sudo tee ~/ss-server.json
{
  "server": "${SSSERVER_LISTEN}",
  "server_port": ${SSSERVER_PORT},
  "password": "${SSSERVER_PASSWORD}",
  "timeout": 5000,
  "mode": "${SSSERVER_MODE}",
  "method": "${SSSERVER_METHOD}",
  "fast_open": false,
  "workers": 100,
  "prefer_ipv6": true,
  "ipv6_first": true,
  "nameserver": "8.8.8.8,1.1.1.1"
}
EOF

cat <<EOF |sudo tee ~/ddns-config.yml
---
cloudflare:
- authentication:
    api_token: ${CLOUDFLARE_API_TOKEN}
    api_key: ${CLOUDFLARE_API_KEY}
    account_email: ${CLOUDFLARE_ACCOUNT_EMAIL}
  zone_id: ${CLOUDFLARE_ZONE_ID}
  subdomains:
  - name: ${CLOUDFLARE_SUBDOMAIN}
    proxied: false
a: ${CLOUDFLARE_IPV4}
aaaa: ${CLOUDFLARE_IPV6}
ttl: 60
repeat: 180d
timeoud: 10s
EOF

sudo docker compose up -d
