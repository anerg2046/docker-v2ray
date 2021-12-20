# 一键docker部署V2ray
> Caddy自动证书申请，TLS+WebSocket

### 准备工作
+ 一个域名，并且将域名添加一条A记录到你的VPS
+ VPS安装`Docker`及`Docker Compose`

附上`CentOS7`的安装命令
```sh
yum update -y
yum install -y yum-utils device-mapper-persistent-data lvm2 epel-release gcc libffi-devel python-devel openssl-devel git net-tools
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum update -y
yum makecache fast
yum install -y docker-ce
service docker start
systemctl enable docker
yum install -y python-pip
pip install --upgrade pip
pip install docker-compose --ignore-installed requests
```

### 安装/使用
```sh
# 拉取代码&进入目录
git clone https://github.com/anerg2046/docker-v2ray.git
cd docker-v2ray
# 运行脚本生成配置文件
./gen-config.sh
# 请输入你的域名信息(eg:www.domain.com):(输入准备好的域名，可以是二级域名)
# 请输入邮箱地址(eg:user@mail.com):(输入一个邮箱，用于caddy申请证书用于加密)
# 请输入websocket端口(默认随机:1234~65535):(不想设定直接回车)
# 请输入alterId(默认随机:10~128):(不想设定直接回车)
# =================================================================
# 完成后你会看到相关配置信息及导入客户端用的字符串
# =================================================================
# 启动docker
./docker-v2ray.sh build
```
> 如果要停止，执行 `./docker-v2ray.sh stop`

> 如果要更新V2ray版本，执行 `git pull && ./docker-v2ray.sh build`

> 首次执行可能需要等两分钟，证书申请好了才能访问

### 宿主机已占用80 443端口的处理方式
+ 自行修改`build/docker-compose.yml`中的映射端口
+ `nginx`的话需要`ssl_preread`支持，具体可参考这篇博文 https://www.jianshu.com/p/70b500c07ccc
+ 已在`config/nginx`中给出了编译和配置范例

### 其他说明
+ 当前V2ray版本v4.44.0
+ `html`目录里我放的是个域名出售页面，邮箱是我的，在`index.html`里，烦请各自更改一下
+ 脚本不含`BBR`，请自行安装，因为我觉得装不装其实都差不多
+ 有特殊需求的人，请自行修改脚本or配置文件模板
+ 还有问题提交issue

### 相关
[JustHost.ru](https://justhost.ru/?ref=69692) 北方联通推荐使用，价格便宜不限量
