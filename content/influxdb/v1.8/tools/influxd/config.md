---
title: influxd config
description: The `influxd config` command displays the default configuration.
menu:
  influxdb_1_8:
    name: influxd config
    weight: 10
    parent: influxd
---
`influxd config` 命令可以显示默认配置。

## 用法

```
influxd config [选项]
```

## Flags

| 选项          | 描述                                                         | 映射                   |
| ------------- | ------------------------------------------------------------ | ---------------------- |
| `-config`     | 设置配置文件的路径。禁用使用空设备(`/dev/null`)自动加载配置文件的功能。 | `INFLUXDB_CONFIG_PATH` |
| `-h`, `-help` | `influxd config` 命令的帮助。                                |                        |
