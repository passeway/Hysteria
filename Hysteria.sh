#!/bin/bash

# 检查是否以 root 用户身份运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 用户身份运行此脚本"
  exit 1
fi

# 判断系统及定义系统安装依赖方式
DISTRO=$(cat /etc/os-release | grep '^ID=' | awk -F '=' '{print $2}' | tr -d '"')
case $DISTRO in
  "debian"|"ubuntu")
    PACKAGE_UPDATE="apt-get update"
    PACKAGE_INSTALL="apt-get install -y"
    PACKAGE_REMOVE="apt-get remove -y"
    PACKAGE_UNINSTALL="apt-get autoremove -y"
    ;;
  "centos"|"fedora"|"rhel")
    PACKAGE_UPDATE="yum -y update"
    PACKAGE_INSTALL="yum -y install"
    PACKAGE_REMOVE="yum -y remove"
    PACKAGE_UNINSTALL="yum -y autoremove"
    ;;
  *)
    echo "不支持的 Linux 发行版"
    exit 1
    ;;
esac

# 安装必要的软件包
echo "正在安装必要的软件包..."
if ! $PACKAGE_INSTALL unzip wget curl; then
  echo "安装软件包失败"
  exit 1
fi

# 判断用户选择的操作
if [ "$1" == "install" ]; then
  # 一键安装Hysteria2
  echo "正在安装Hysteria2..."
  if ! bash <(curl -fsSL https://get.hy2.sh/); then
    echo "安装Hysteria2失败"
    exit 1
  fi
elif [ "$1" == "uninstall" ]; then
  # 卸载Hysteria2
  echo "正在卸载Hysteria2..."
  if ! bash <(curl -fsSL https://get.hy2.sh/) --remove; then
    echo "卸载Hysteria2失败"
    exit 1
  fi
else
  echo "请选择正确的操作："
  echo "选项1：安装Hysteria2"
  echo "选项2：卸载Hysteria2"
  exit 1
fi

# 以下是原始脚本中的其余部分，用于生成自签证书、随机生成端口和密码、生成配置文件、启动Hysteria2、设置开机自启、获取本机IP地址等等

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
echo "正在启动Hysteria2服务..."
if ! systemctl start hysteria-server.service; then
  echo "启动Hysteria2服务失败"
  exit 1
fi

# 设置开机自启
echo "设置Hysteria2服务开机自启..."
if ! systemctl enable hysteria-server.service; then
  echo "设置Hysteria2服务开机自启失败"
  exit 1
fi

# 获取本机IP地址
HOST_IP=$(curl -s http://checkip.amazonaws.com)

# 获取IP所在国家
IP_COUNTRY=$(curl -s http://ipinfo.io/$HOST_IP/country)

# 输出所需信息，包含IP所在国家
echo "Hysteria2已安装并启动。"
echo "$IP_COUNTRY = hysteria2, $HOST_IP, $RANDOM_PORT, password = $RANDOM_PSK, skip-cert-verify=true, sni=bing.com"
