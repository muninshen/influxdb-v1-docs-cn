---
title: influxd restore
description: >
  The `influxd restore` command restores backup data and metadata from an InfluxDB backup directory.
menu:
  influxdb_1_8:
    name: influxd restore
    weight: 10
    parent: influxd
v2: /influxdb/v2.0/reference/cli/influxd/restore/
---
`influxd restore` 命令可以从备份目录恢复数据。

使用 `influxd` 恢复数据之前，请先停止服务。

## Usage

```
influxd restore [选项]
```

## Flags

| 选项      | 描述                                                         | 映射                   |
| ----------- | ------------------------------------------------------------ | ---------------------- |
| `-portable` | 激活可移植的还原模式，使用此模式可以包含企业改进兼容的文件。如果未指定，则使用旧式还原模式。 | `INFLUXDB_CONFIG_PATH` |
| `-host`     | InfluxDB OSS 主机连接到将要还原数据的位置。                  |                        |
| `-db`       | 要从备份还原的数据库的名称 (InfluxDB OSS 或 InfluxDB Enterprise)。 |                        |
| `-newdb`    | 要将Line protocol格式导入到InfluxDB OSS数据库的名称。可选项，如果未指定，则使用`-db <db_name>`，新的数据库名称对于目标系统必须是唯一的。 |                        |
| `-rp`       | 要恢复的保留策略的名称，可选项。                             |                        |
| `-newrp`    | 要还原到的保留策略的名称. 可选项。                           |                        |
| `-shard`    | 要还原的分片ID，可选项。 | |