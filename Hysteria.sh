
#!/bin/bash

# 检查是否以 root 用户身份运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 用户身份运行此脚本"
  exit 1
fi

# 判断系统及定义系统安装依赖方式
REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "fedora")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Fedora")
PACKAGE_UPDATE=("apt-get update" "apt-get update" "yum -y update" "yum -y update" "yum -y update")
PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "yum -y install")
PACKAGE_REMOVE=("apt -y remove" "apt -y remove" "yum -y remove" "yum -y remove" "yum -y remove")
PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "yum -y autoremove" "yum -y autoremove")

# 安装必要的软件包
$PACKAGE_INSTALL unzip wget curl

# 一键安装Hysteria2
bash <(curl -fsSL https://get.hy2.sh/)

# 生成自签证书
openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout /etc/hysteria/server.key -out /etc/hysteria/server.crt -subj "/CN=bing.com" -days 36500 && sudo chown hysteria /etc/hysteria/server.key && sudo chown hysteria /etc/hysteria/server.crt

# 随机生成端口和密码
RANDOM_PORT=$(shuf -i 2000-65000 -n 1)
RANDOM_PSK=$(openssl rand -base64 12)

# 生成配置文件
cat << EOF > /etc/hysteria/config.yaml
listen: :$RANDOM_PORT # 监听随机端口

# 使用自签证书
tls:
  cert: /etc/hysteria/server.crt
  key: /etc/hysteria/server.key

auth:
  type: password
  password: "$RANDOM_PSK" # 设置随机密码
  
masquerade:
  type: proxy
  proxy:
    url: https://bing.com # 伪装网址
    rewriteHost: true
EOF

# 启动Hysteria2
systemctl start hysteria-server.service

# 设置开机自启
systemctl enable hysteria-server.service

# 获取本机IP地址
HOST_IP=$(curl -s http://checkip.amazonaws.com)

# 获取IP所在国家
IP_COUNTRY=$(curl -s http://ipinfo.io/$HOST_IP/country)

# 输出所需信息，包含IP所在国家
echo "Hysteria2已安装并启动,卸载请执行 bash <(curl -fsSL https://get.hy2.sh/) --remove"
echo "$IP_COUNTRY = hysteria2, $HOST_IP, $RANDOM_PORT, password = $RANDOM_PSK, skip-cert-verify=true, sni=www.bing.com"
