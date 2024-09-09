#!/bin/bash

# 存储端口转发规则的文件
RULES_FILE=".port_forwarding_rules.txt"

# 清除屏幕上方的行
clear_lines() {
    tput cuu $1  # Move cursor up by $1 lines
    tput ed      # Clear to end of screen
}

# 函数：添加端口转发
add_port_forward() {
    read -p "请输入远程服务器的IP: " remote_server_ip
    read -p "请输入远程服务器的端口: " remote_server_port
    read -p "请输入中转机的公网IP: " out_interface_ip
    read -p "请输入本地入端口: " ingress_port

    # 添加iptables规则
    iptables -t nat -A PREROUTING -p tcp -m tcp --dport ${ingress_port} -j DNAT --to-destination ${remote_server_ip}:${remote_server_port}
    iptables -t nat -A POSTROUTING -p tcp -d ${remote_server_ip}/32 -j SNAT --to-source ${out_interface_ip}
    iptables -A FORWARD -s ${remote_server_ip}/32 -j ACCEPT
    iptables -A FORWARD -d ${remote_server_ip}/32 -j ACCEPT

    # 保存规则到文件
    echo "${remote_server_ip},${remote_server_port},${out_interface_ip},${ingress_port}" >> ${RULES_FILE}
    echo "端口转发规则已添加。"
}

# 函数：查看端口转发
view_port_forward() {
    clear_lines 1
    if [[ ! -f ${RULES_FILE} ]]; then
        echo "没有找到任何端口转发规则。"
        return
    fi

    echo -e "                      已添加的端口转发规则                        "
    echo -e "--------------------------------------------------------------------"
    echo -e "序号 | 远程服务器IP  | 远程服务器端口 | 中转机公网IP  | 本地入端口     "
    echo -e "--------------------------------------------------------------------"
    
    i=1
    while IFS=, read -r remote_server_ip remote_server_port out_interface_ip ingress_port
    do
        printf " %-4s| %-14s| %-15s| %-14s| %-15s\n" "$i" "$remote_server_ip" "$remote_server_port" "$out_interface_ip" "$ingress_port"
        ((i++))
    done < ${RULES_FILE}
    echo -e "--------------------------------------------------------------------"
}

# 函数：删除端口转发
delete_port_forward() {
    view_port_forward

    if [[ ! -f ${RULES_FILE} ]]; then
        return
    fi

    read -p "请输入要删除的配置的序号: " rule_number

    if ! [[ ${rule_number} =~ ^[0-9]+$ ]]; then
        echo "无效的序号。"
        return
    fi

    # 临时文件
    TEMP_FILE=$(mktemp)

    i=1
    deleted=0
    while IFS=, read -r remote_server_ip remote_server_port out_interface_ip ingress_port
    do
        if [[ ${i} -eq ${rule_number} ]]; then
            # 删除iptables规则
            iptables -t nat -D PREROUTING -p tcp -m tcp --dport ${ingress_port} -j DNAT --to-destination ${remote_server_ip}:${remote_server_port}
            iptables -t nat -D POSTROUTING -p tcp -d ${remote_server_ip}/32 -j SNAT --to-source ${out_interface_ip}
            iptables -D FORWARD -s ${remote_server_ip}/32 -j ACCEPT
            iptables -D FORWARD -d ${remote_server_ip}/32 -j ACCEPT
            deleted=1
        else
            echo "${remote_server_ip},${remote_server_port},${out_interface_ip},${ingress_port}" >> ${TEMP_FILE}
        fi
        ((i++))
    done < ${RULES_FILE}

    mv ${TEMP_FILE} ${RULES_FILE}

    if [[ ${deleted} -eq 1 ]]; then
        echo "端口转发规则已删除。"
    else
        echo "未找到对应的端口转发规则。"
    fi
}

# 函数：卸载所有端口转发
uninstall_all() {
    if [[ ! -f ${RULES_FILE} ]]; then
        echo "没有找到任何端口转发规则。"
        return
    fi

    while IFS=, read -r remote_server_ip remote_server_port out_interface_ip ingress_port
    do
        # 删除iptables规则
        iptables -t nat -D PREROUTING -p tcp -m tcp --dport ${ingress_port} -j DNAT --to-destination ${remote_server_ip}:${remote_server_port}
        iptables -t nat -D POSTROUTING -p tcp -d ${remote_server_ip}/32 -j SNAT --to-source ${out_interface_ip}
        iptables -D FORWARD -s ${remote_server_ip}/32 -j ACCEPT
        iptables -D FORWARD -d ${remote_server_ip}/32 -j ACCEPT
    done < ${RULES_FILE}

    # 删除规则文件
    rm -f ${RULES_FILE}
    echo "所有端口转发规则已删除并卸载。"
}

while true; do
    clear
    echo "请选择功能："
    echo "1. 添加端口转发"
    echo "2. 查看端口转发"
    echo "3. 删除端口转发"
    echo "4. 卸载所有端口转发"
    echo "5. 退出"
    read -p "请输入选项: " choice

    case ${choice} in
        1)
            clear_lines 6
            add_port_forward
            ;;
        2)
            view_port_forward
            ;;
        3)
            clear_lines 6
            delete_port_forward
            ;;
        4)
            clear_lines 6
            uninstall_all
            ;;
        5)
            echo "退出脚本。"
            exit 0
            ;;
        *)
            clear_lines 1
            echo "无效选项，请重新输入。"
            ;;
    esac
    echo "按回车键继续..."
    read
done

