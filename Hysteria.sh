#!/bin/bash

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# 检查 Hysteria 安装状态
check_hysteria_status() {
    if command -v hysteria &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 安装 Hysteria
install_hysteria() {
    echo -e "${CYAN}正在安装 Hysteria${RESET}"
    curl -sS -o Hysteria.sh https://gitlab.com/passeway/Hysteria/-/raw/main/Hysteria2.sh &&
    chmod +x Hysteria2.sh &&
    ./Hysteria2.sh
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Hysteria 安装成功${RESET}"
    else
        echo -e "${RED}Hysteria 安装失败${RESET}"
    fi
}

# 卸载 Hysteria
uninstall_hysteria() {
    echo -e "${CYAN}正在卸载 Hysteria${RESET}"
    bash <(curl -fsSL https://get.hy2.sh/) --remove
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Hysteria 卸载成功${RESET}"
    else
        echo -e "${RED}Hysteria 卸载失败${RESET}"
    fi
}

# 显示菜单
show_menu() {
    clear
    check_hysteria_status
    hysteria_status=$?
    echo -e "${GREEN}=== Hysteria 管理工具 ===${RESET}"
    echo -e "${GREEN}当前状态: $(if [ $hysteria_status -eq 0 ]; then echo "${GREEN}已安装${RESET}"; else echo "${RED}未安装${RESET}"; fi)${RESET}"
    echo "1. 安装 Hysteria2"
    echo "2. 卸载 Hysteria2"
    echo "0. 退出"
    echo -e "${GREEN}=========================${RESET}"
    read -p "请输入选项编号: " choice
    echo ""
}

# 捕获 Ctrl+C 信号
trap 'echo -e "${RED}已取消操作${RESET}"; exit' INT

# 主循环
while true; do
    show_menu
    case "$choice" in
        1)
            install_hysteria
            ;;
        2)
            uninstall_hysteria
            ;;
        0)
            echo -e "${GREEN}已退出 Hysteria${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效的选项${RESET}"
            ;;
    esac
    read -p "按 enter 键继续..."
done
