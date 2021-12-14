---
title: influxd run
description: >
  The `influxd run` command starts and runs all the processes necessary for InfluxDB to function.
menu:
  influxdb_1_8:
    name: influxd run
    weight: 10
    parent: influxd
v2: /influxdb/v2.0/reference/cli/influxd/run/
---

`influxd run` 是 `influxd`的默认命令，是启动和运行InfluxDB所必须的过程。

## 用法

```
influxd run [选项]
```

因为`run`是`influxd`的默认命令，所以以下命令相同：

```bash
influxd
influxd run
```

## 标识

| 选项          | 描述                                                         |
| ------------- | ------------------------------------------------------------ |
| `-config`     | 配置文件路径，默认环境变量为 `INFLUXDB_CONFIG_PATH`, `~/.influxdb/influxdb.conf`, 或`/etc/influxdb/influxdb.conf` 。以上任何一个位置存在配置文件，则禁止使用空设备（例如`/dev/null`）自动加载配置文件。 |
| `-pidfile`    | 指定进程ID文件位置。                                         |
| `-cpuprofile` | 指定CPU配置信息文件位置。                                    |
| `-memprofile` | 指定内存使用信息文件位置。                                   |
