---
title: 重建TSI索引
description: >
  Use the `influxd_inspect buildtsi` command to rebuild your InfluxDB TSI index.
menu:
  influxdb_1_8:
    weight: 60
    parent: 管理
---

influx db[时间序列指数(TSI)](/influx db/v 1.8/概念/TSI-详细信息/) 索引或缓存测量和标记数据，以确保查询的性能。 在某些情况下，可能需要刷新和重建TSI索引。 使用以下步骤重建您的InfluxDB TSI索引:

## 1. Stop InfluxDB
通过停止Influxdb进行来停止influxdb

## 2. 删除所有`_series` 目录
删除所有“series”目录.
默认情况下 `_series` 目录存储在/data/<dbName>/_series`,
但是，应该在整个 “data”目录中检查并删除`_series`文件.

## 3. 删除所有索引目录
删除所有索引目录.
默认情况下，索引目录存储在 `/data/<dbName/<rpName>/<shardID>/index`.

## 4. 重建TSI索引
使用`influx_inspect` 检查命令客户端 [(CLI)](/influxdb/v1.8/tools/influx_inspect)
要重建TSI索引，请执行以下操作:

```sh
# Syntax
influx_inspect buildtsi -datadir <data_dir> -waldir <wal_dir>

# Example
influx_inspect buildtsi -datadir /data -waldir /wal
```

## 5. 重启 InfluxDB
重启InfluxDB 来重新加载`influxd`进程

---

{{% note %}}
## 在Influxdb企业集群中重建TSI索引
要想在 InfluxDB Enterprise 集群中重建TSI索引,执行这些步骤，在集群中的每个数据节点上余个接一个. 在数据节点上重新启动 `influxd`进程后, 允许
[hinted handoff queue (HHQ)](/{{< latest "enterprise_influxdb" >}}/concepts/clustering/#hinted-handoff)将所有丢失的数据写入最新的节点，然后再继续下一个节点
{{% /note %}}