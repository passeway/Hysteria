#!/bin/bash

install_hysteria2() {
    curl -sS -o Hysteria1.sh https://raw.githubusercontent.com/passeway/Hysteria/main/Hysteria1.sh &&
    chmod +x Hysteria1.sh &&
    ./Hysteria1.sh
}

uninstall_hysteria2() {
    bash <(curl -fsSL https://get.hy2.sh/) --remove
}

check_hysteria2_status() {
    systemctl status hysteria-server.service
}

echo "请选择操作："
echo "1. 安装 Hysteria2"
echo "2. 卸载 Hysteria2"
echo "3. 查看 Hysteria2 运行状态"
read choice

case $choice in
    1)
        install_hysteria2
        ;;
    2)
        uninstall_hysteria2
        ;;
    3)
        check_hysteria2_status
        ;;
    *)
        echo "无效的选项"
        ;;
esac
