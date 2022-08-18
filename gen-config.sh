#!/bin/sh
SOURCE="$0"
while [ -h "$SOURCE"  ]; do
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"

cd $DIR

read -rp "请输入你的域名信息(eg:www.domain.com):" domain
if [ -z $domain ];then
    echo "没有输入域名，安装终止"
    exit 2
fi

read -rp "请输入邮箱地址(eg:user@mail.com):" email
if [ -z $email ];then
    echo "没有输入邮箱，安装终止"
    exit 2
fi

read -rp "请输入websocket端口(默认随机:1234~65535):" ws_port
uuid=$(uuidgen)

if [ -z $ws_port ];then
    ws_port=$(($RANDOM+1234))
    # echo $ws_port
fi

ws_path="`echo $RANDOM | md5sum | cut -c 3-11`"
# echo $path

cp -f config/caddy/default_Caddyfile config/caddy/Caddyfile
sed -i "s/example.domain/${domain}/" config/caddy/Caddyfile
sed -i "s/ws_path/${ws_path}/" config/caddy/Caddyfile
sed -i "s/1234/${ws_port}/" config/caddy/Caddyfile
sed -i "s/your@email.com/${email}/" config/caddy/Caddyfile

cp -f config/v2ray/default_config.json config/v2ray/config.json
sed -i "s/1234/${ws_port}/" config/v2ray/config.json
sed -i "s/uuid/${uuid}/" config/v2ray/config.json
sed -i "s/ws_path/${ws_path}/" config/v2ray/config.json

cp -f config/subweb/default_conf.js config/subweb/conf.js
sed -i "s/defaultbackendurl/${domain}/" config/subweb/conf.js

echo "====================================="
echo "V2ray 配置信息"
echo "地址（address）: ${domain}"
echo "端口（port）： 443"
echo "用户id（UUID）： ${uuid}"
echo "额外id（alterId）： 0"
echo "加密方式（security）： 自适应"
echo "传输协议（network）： ws"
echo "伪装类型（type）： none"
echo "路径（不要落下/）： /${ws_path}/"
echo "底层传输安全： tls"
echo "====================================="

cp -f config/v2ray/default_client.json config/v2ray/client.json
sed -i "s/hostname-placeholder/${domain}/" config/v2ray/client.json
sed -i "s/address-placeholder/${domain}/" config/v2ray/client.json
sed -i "s/uuid-placeholder/${uuid}/" config/v2ray/client.json
sed -i "s/ws_path-placeholder/${ws_path}/" config/v2ray/client.json

clientBase64="`cat config/v2ray/client.json | base64 -w 0`"
echo "vmess://"$clientBase64
