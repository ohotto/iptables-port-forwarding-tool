# iptables-port-forwarding-tool

一个基于iptables的端口转发管理脚本

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

- 脚本将端口转发规则存储在与脚本相同目录下的 `port_forwarding_rules.txt` 文件中。
- 确保您有修改 `iptables` 规则的必要权限，并以超级用户身份运行脚本。
