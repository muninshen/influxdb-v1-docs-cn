---
title: InfluxQL 查询管理
description: Show, kill, and manage queries in InfluxQL.
menu:
  influxdb_1_8:
    name: 查询管理
    weight: 20
    parent: 故障排除
---

使用以下方法管理您的Influxdb查询:

- [显示查询](#list-currently-running-queries-with-show-queries) to identify currently-running queries
- [终止查询](#stop-currently-running-queries-with-kill-query) to stop queries overloading your system
- [配置设置](#configuration-settings-for-query-management) to prevent and halt the execution of inefficient queries

> 本页上提供命令和配置仅适用于 **Influx查询语言 (InfluxQL) ** -- **当前没有等效的Flux命令和配置集**. 有关最新的 Flux文件档 请参阅, [ Flux入门](/influxdb/v1.8/flux/get-started/).

## list-currently-running-queries-with-show-queries `SHOW QUERIES`

`SHOW QUERIES` 列出查询ID、查询文本、相关数据库和持续时间在您的Influxdb实例上当前运行的所有查询

#### 语法

```sql
SHOW QUERIES
```

#### Example

```
> SHOW QUERIES
qid	  query                              database   duration   status
---   -----                              --------   --------   ------
37    SHOW QUERIES                                  100368u    running
36    SELECT mean(myfield) FROM mymeas   mydb       3s         running
```

##### 输出说明

- `qid`: 查询的ID号，将此值一起使用 [`KILL - QUERY`](/influxdb/v1.7/troubleshooting/query_management/#stop-currently-running-queries-with-kill-query).  
- `query`: 查询文本.  
- `database`: The database targeted by the query.  
- `duration`:查询所针对的数据库.
  有关Influxdb数据库中时间单位的说明，请参阅 [查询语言参考](/influxdb/v1.7/query_language/spec/#durations)
  
  {{% note %}}
  `SHOW QUERIES` 可能会输出被终止的查询，并继续增加其持续时间，直到从内存中清楚查询记录位置.
  {{% /note %}}

- `status`: 查询的当前状态.

## Stop currently-running queries with `KILL QUERY`

`KILL QUERY` 告诉InfluxDB 停止运行相关的查询.

#### 语法

#### qid查询ID在哪里，显示在 [`SHOW QUERIES`](/influxdb/v1.3/troubleshooting/query_management/#list-currently-running-queries-with-show-queries) 输出中:

```sql
KILL QUERY <qid>
```

***InfluxDB Enterprise clusters:*** 要终止集群上的查询,你需要指定查询的 ID (qid) 和  TCP host (例如, `myhost:8088`),该SHOW QUERIES
 `SHOW QUERIES` 输出中可用

```sql
KILL QUERY <qid> ON "<host>"
```

成功KILL QUERY` 查询不返回任何结果.

#### 例子

```sql
-- kill query with qid of 36 on the local host
> KILL QUERY 36
>
```

```sql
-- kill query on InfluxDB Enterprise cluster
> KILL QUERY 53 ON "myhost:8088"
>
```

## Configuration settings for query management

以下配置设置位于配置文件中的
[coordinator](/influxdb/v1.8/administration/config/#query-management-settings) 部分中

### `max-concurrent-queries`

您的实例上允许的最大查询数.
默认设置 (`0`)允许无线数量的查询.

如果超过 `max-concurrent-queries`, InfluxDB 将不执行查询，并输出一下错误:

```
ERR: max concurrent queries reached
```

### `query-timeout`

在 InfluxDB终止查询之前，查询可以在您的实例上运行的最长时间，默认设置 (`"0"`) 允许查询不受时间限制的运行，此设置是. [持续时间文字](/influxdb/v1.8/query_language/spec/#durations).

如果您的查询超时, InfluxDB 将终止查询并输出以下错误：

```
ERR: query timeout reached
```

### `log-queries-after`

查询可以运行的最长时间，之后Influxdb会在日志中记录一条Detected slow query消息.
默认设置 (`"0"`) 从不告诉Influxdb记录查询，此设置是 [持续时间文字](/influxdb/v1.8/query_language/spec/#durations).

`log-queries-after` 设置为的示例日志输出 `"1s"`:

```
[query] 2016/04/28 14:11:31 Detected slow query: SELECT mean(usage_idle) FROM cpu WHERE time >= 0 GROUP BY time(20s) (qid: 3, database: telegraf, threshold: 1s)
```

`qid` 是查询的ID号.
将此值与一起使用 [`KILL QUERY`](/influxdb/v1.8/troubleshooting/query_management/#stop-currently-running-queries-with-kill-query).

日志输出文件的默认位置是 `/var/log/influxdb/influxdb.log`. 但是，在使用systemd  (大多数现代Linux发行版) 系统上，这些日志输出到journalctl.您应该能够使用以下命令查看Influxdb日志：`journalctl -u influxdb`

### `max-select-point`

 最大[points](/influxdb/v1.8/concepts/glossary/#point) ，一个`SELECT`语句可以处理，默认设置（`0`）允许`SELECT`语句处理无限数量的Points

如果查询超过 `max-select-point`, InfluxDB 将终止查询并输出以下错误:

```
ERR: max number of points reached
```

### `max-select-series`

最大数量 [series](/influxdb/v1.8/concepts/glossary/#series),一个`SELECT`语句可以处理.
默认设置(`0`)允许 `SELECT`语句处理无限数量的序列.

如果查询超过 `max-select-series`, InfluxDB 将不执行查询，并输出以下错误:

```
ERR: max select series count exceeded: <query_series_count> series
```

### `max-select-buckets`

 `GROUP BY time()` 查询可以处理的最大存储桶数，默认设置(`0`) 允许查询处理无限数量的存储捅

如果查询 `max-select-buckets`, InfluxDB 将不执行查询，并输出一下错误:

```
ERR: max select bucket count exceeded: <query_bucket_count> buckets
```
