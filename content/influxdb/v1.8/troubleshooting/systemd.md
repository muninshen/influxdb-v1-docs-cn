---
title: 解决系统错误
list_title: 系统权限错误
description: Troubleshoot errors with InfluxDB and systemd permissions
menu:
  influxdb_1_8:
    name: 系统错误
    weight: 1
    parent: 故障检测
---

使用systemd (Ubuntu, Debian, CentOS)运行Influxdb时，,可能会在 InfluxDB 日志中 (通过 `journalctl -u influxdb`) 遇到错误:例如

- `error msg="Unable to open series file"`

- `run: open server: open tsdb store: mkdir /var/lib/influxdb/data/_internal/_series/00: permission denied`

  当 InfluxDB 与 systemd一起安装时，将`influxdb`自动创建用户和组.
  如果用户 `influxd`直接从shell终端登录运行一个进程, 则会生成 `influxdb` 用户无法访问的新系列文件.
  在这种情况下,当systemd   (通过 `sudo systemctl start influxdb`)启动Influxdb 服务时，Influxdb进程讲退出,因为无法访问root用户拥有的剩余文件

要解决此问题，请将InfluxDB目录中的所有文件设置 `influxdb` 用户和组所拥有。运行以下命令：

```
sudo chown -R influxdb:influxdb /var/lib/influxdb/*
```

或者，如果数据不重要，请通过删除所有文件来重置数据库

```
sudo rm -rf /var/lib/influxdb/
```
