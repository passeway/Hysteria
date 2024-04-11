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
install_dependencies() {
  echo "正在安装必要的软件包..."
  if ! $PACKAGE_INSTALL unzip wget curl; then
    echo "安装软件包失败"
    exit 1
  fi
}

# 安装Hysteria2
install_hysteria() {
  echo "正在一键安装Hysteria2..."
  if ! bash <(curl -fsSL https://get.hy2.sh/); then
    echo "安装Hysteria2失败"
    exit 1
  fi
}

# 卸载Hysteria2
uninstall_hysteria() {
  echo "正在卸载Hysteria2..."
  if ! bash <(curl -fsSL https://get.hy2.sh/) --remove; then
    echo "卸载Hysteria2失败"
    exit 1
  fi
}

# 生成自签证书
generate_certificate() {
  echo "正在生成自签证书..."
  if ! openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout /etc/hysteria/server.key -out /etc/hysteria/server.crt -subj "/CN=bing.com" -days 36500 && sudo chown hysteria /etc/hysteria/server.key && sudo chown hysteria /etc/hysteria/server.crt; then
    echo "生成自签证书失败"
    exit 1
  fi
}

# 随机生成端口和密码，生成配置文件
generate_config() {
  echo "正在生成配置文件..."
  RANDOM_PORT=$(shuf -i 2000-65000 -n 1)
  RANDOM_PSK=$(openssl rand -base64 12)
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
}

# 启动Hysteria2服务
start_hysteria_service() {
  echo "正在启动Hysteria2服务..."
  if ! systemctl start hysteria-server.service; then
    echo "启动Hysteria2服务失败"
    exit 1
  fi
}

# 设置Hysteria2服务开机自启
enable_hysteria_service() {
  echo "设置Hysteria2服务开机自启..."
  if ! systemctl enable hysteria-server.service; then
    echo "设置Hysteria2服务开机自启失败"
    exit 1
  fi
}

# 获取本机IP地址
get_host_ip() {
  HOST_IP=$(curl -s http://checkip.amazonaws.com)
}

# 获取IP所在国家
get_ip_country() {
  IP_COUNTRY=$(curl -s http://ipinfo.io/$HOST_IP/country)
}

# 输出所需信息，包含IP所在国家
print_info() {
  echo "Hysteria2已安装并启动。"
  echo "$IP_COUNTRY = hysteria2, $HOST_IP, $RANDOM_PORT, password = $RANDOM_PSK, skip-cert-verify=true, sni=bing.com"
}

# 根据用户选择的操作执行相应的函数
case $1 in
  "install")
    install_dependencies
    install_hysteria
    generate_certificate
    generate_config
    start_hysteria_service
    enable_hysteria_service
    get_host_ip
    get_ip_country
    print_info
    ;;
  "uninstall")
    uninstall_hysteria
    ;;
  *)
    echo "请选择正确的操作："
    echo "选项1：安装Hysteria2"
    echo "选项2：卸载Hysteria2"
    exit 1
    ;;
esac
