---
title: influxd backup
description: >
  The `influxd backup` command restores backup data and metadata from an InfluxDB backup directory.
menu:
  influxdb_1_8:
    name: influxd backup
    weight: 10
    parent: influxd
v2: /influxdb/v2.0/reference/cli/influx/backup/
---

`influxd backup`命令创建指定InfluxDB OSS数据库的备份副本，并将与企业兼容的文件格式保存到PATH（保存备份的目录）中。

## 用法

```
influxd backup [选项] PATH
```

## 参数

| 选项        | 描述                                                                                                                                                   |
|---------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-portable`   | 以可移植的格式生成备份文件，该文件可以还原到InfluxDB OSS或InfluxDB Enterprise。 |
| `-host`       | 从InfluxDB OSS主机进行备份。可选项，默认为：127.0.0.1:8088                                          |
| `-db`         | 需要备份的InfluxDB OSS数据库名称。可选项，如果未指定，则使用“-portable”时将备份所有数据库 |
| `-rp`         | 需要备份的保留策略名称。可选项，如果未指定，则默认使用所有保留策略 |
| `-shard`      | 要备份的分片标识符。可选项，如果指定，则需要“-rp”。                                           |
| `-start`      | 指定开始时间（RFC3339格式），不兼容'-since'。                    |
| `-end`        | 指定结束时间（RFC3339格式）， 不兼容'-since'。                                        |
| `-since`      | 在时间戳（RFC3339格式）之后的所有点上创建增量备份。可选项，建议改用'start'。 |
| `-skip-errors` | 跳过无法备份的分片。                                                     |
