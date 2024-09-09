# iptables-port-forwarding-tool

一个基于iptables的端口转发管理脚本
注意：本脚本只能管理本脚本添加的端口转发，脚本管理基于存储在脚本相同目录下的规则文件

## 功能

- **添加端口转发**：将本地端口的流量重定向到远程服务器。
- **查看端口转发**：显示所有当前配置的端口转发规则。
- **删除端口转发**：删除特定的端口转发规则。

## 前提条件

- 确保您的系统上已安装并配置了 `iptables`。
- 使用超级用户权限运行脚本（例如使用 `sudo`）。

## 使用方法

```sh
wget https://raw.githubusercontent.com/ohotto/iptables-port-forwarding-tool/main/ip-fw.sh && sudo chmod +x ./ip-fw.sh && sudo ./ip-fw.sh
```

## 注意事项

- 脚本将端口转发规则存储在与脚本相同目录下的 `.port_forwarding_rules.txt` 文件中。
- 确保您有修改 `iptables` 规则的必要权限，并以超级用户身份运行脚本。

## 脚本原理

```
export remote_server_ip=

export remote_server_port=

export out_interface_ip=

export ingress_port=

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -A PREROUTING -p tcp -m tcp --dport ${ingress_port} -j DNAT --to-destination ${remote_server_ip}:${remote_server_port}
iptables -t nat -A POSTROUTING -p tcp -d ${remote_server_ip}/32 -j SNAT --to-source ${out_interface_ip}
iptables -A FORWARD -s ${remote_server_ip}/32 -j ACCEPT
iptables -A FORWARD -d ${remote_server_ip}/32 -j ACCEPT
```

手动查看iptables配置命令：

```sh
sudo iptables -L -v
sudo iptables -t nat -L -v -n
```


