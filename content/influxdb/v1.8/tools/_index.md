---
title: InfluxDB 工具
description: Tools and utilities for interacting with InfluxDB.
aliases:
    - /influxdb/v1.8/clients/
    - /influxdb/v1.8/write_protocols/json/
menu:
  influxdb_1_8:
    weight: 60
    identifier: Tools
---

本章节介绍了可以与InfluxDB进行交互的工具

## `influx` 命令行界面 (CLI)

[InfluxDB命令行界面 (`influx`)](/influxdb/v1.8/tools/influx-cli/)包括管理InfluxDB的诸多方面，包括数据库，组织，用户和任务的命令。

## `influxd` 命令

The [`influxd` command](/influxdb/v1.8/tools/influxd) starts and runs all the processes necessary for InfluxDB to function.

`influxd`命令包含InfluxDB启动和运行时所需的所有工具。

## InfluxDB API 客户端库

可以与InfluxDB API交互的[客户端库](/influxdb/v1.8/tools/api_client_libraries/)列表。

## Influx Inspect 磁盘分片程序

[Influx Inspect](/influxdb/v1.8/tools/influx_inspect/)是一个有关磁盘分片的工具，用于查看分片的详细信息，以及从分片导出行协议数据，这些数据可以插入回数据库中。

## InfluxDB inch 工具

使用[InfluxDB`inch`工具](/influxdb/v1.8/tools/inch/)测试InfluxDB性能。调整指标，例如批次大小，标签值和并发写入，以测试摄取不同的标签基数和指标如何影响性能。

## 图表和仪表板

使用 [Chronograf](/{{< latest "chronograf" >}}/) 或 [Grafana](https://grafana.com/docs/grafana/latest/features/datasources/influxdb/) 可视化时间序列数据

> **提示：** 在仪表板上使用模板变量可以按指定的时间段过滤查询结果 (请参考以下示例)。

### 使用模板变量过滤查询结果

以下示例显示了如何过滤最近一个小时内查询的主机。

##### 示例

```sh
# 创建一个保留测率
CREATE RETENTION POLICY "lookup" ON "prod" DURATION 1d REPLICATION 1

# 创建一个连续查询，对要在模板变量中使用的标记进行分组
CREATE CONTINUOUS QUERY "lookupquery" ON "prod" BEGIN SELECT mean(value) as value INTO "your.system"."host_info" FROM "cpuload"
WHERE time > now() - 1h GROUP BY time(1h), host, team, status, location END;

# 在Grafana或Chronograf模板中，用标签设置模板变量
SHOW TAG VALUES FROM "your.system"."host_info" WITH KEY = “host”
```

> **注意：** 在Chronograf中，可以通过[创建 `自定义查询` 的模板变量](/{{< latest "chronograf" >}}/guides/dashboard-template-variables/#create-custom-template-variables)并添加时间范围过滤器来过滤指定时间范围内的查询结果。
