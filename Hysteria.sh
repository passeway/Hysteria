
#!/bin/bash

install_hysteria2() {
    curl -sS -o Hysteria2.sh https://raw.githubusercontent.com/passeway/Hysteria/main/Hysteria2.sh &&
    chmod +x Hysteria2.sh &&
    ./Hysteria2.sh
}

uninstall_hysteria2() {
    bash <(curl -fsSL https://get.hy2.sh/) --remove
}

echo "请选择操作："
echo "1. 安装 Hysteria2"
echo "2. 卸载 Hysteria2"
read -p "请输入选项编号: " choice


case $choice in
    1)
        install_hysteria2
        ;;
    2)
        uninstall_hysteria2
        ;;
    *)
        echo "无效的选项"
        ;;
esac
