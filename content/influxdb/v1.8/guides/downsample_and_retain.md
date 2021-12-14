---
title: 下采样和数据保留
description: Downsample data to keep high precision while preserving storage.
menu:
  influxdb_1_8:
    weight: 30
    parent: 指南
aliases:
  - /influxdb/v1.8/guides/downsampling_and_retention/
---

InfluxDB每秒可以处理十万个Points，长时间使用大量的数据可能会引起存储问题，一个自然地解决方案可以对数据进行采样，仅在有限时间内保存高精度的原始数据，并将较低精度的汇总数据存储更长时间。本篇指南介绍了如何使用InfluxdbQL自动处理下采样数据和过期旧数据的过程，使用Flux和Influxdb2.0缩减采样和保留数据，请参考[处理具有Influxdb任务的数据](/influxdb/v2.0/process-data/).

### 定义

- **Continuous query**（CQ）是一个在数据库中自动定期运行的InfluxdbQL查询，CQ在`SELECT`语句中需要一个函数，并且必须包含一个`GROUP BY（）`语句

- **Retention policy** (RP) 是influxdb数据结构的一部分，描述了Influxdb保留数据多长时间，Influxdb将本地服务器的时间戳与数据戳进行比较，并删除了早于RP DURATION的数据，一个数据库可以有多个`RP`且每个数据库的`RP`是唯一的

这里没有详细的介绍创建和管理CQs和QPs的语法，如果不熟悉这些概念，建议回顾以下内容：
- [CQ documentation](/influxdb/v1.8/query_language/continuous_queries/) 
- [RP documentation](/influxdb/v1.8/query_language/manage-database/#retention-policy-management).

### 样本数据

本部分使用虚拟的实时数据来跟踪食品订单的数量，每隔10s通过电话或者网站去一家餐馆，将这些数据存储在名为`food_data`的数据库的`orders`中；

Sample:

```bash
name: orders
------------
time                   phone   website
2016-05-10T23:18:00Z   10      30
2016-05-10T23:18:10Z   12      39
2016-05-10T23:18:20Z   11      56
```

### 目标

假设从长远来看，仅对通过电话和网站每20分钟间隔的平均订单数感兴趣，在接下来的步骤，将使用RP和CQ来：

* 自动将10秒分辨率数据汇总为30分钟分辨率数据
* 自动删除早于两个小时的原始十秒分辨率数据
* 自动删除超过52周的30分钟分辨率数据

### 数据库准备

在将数据写入数据库之前，我们执行以下步骤`food_data`，我们在插入任何数据之前先执行此操作，因为CQ仅对最新数据运行；也就是说，时间戳记的数据不早于`now（）`减去`FOR`  CQ子句`now（）GROUP BY time（）`时间，如果CQ没有`FOR`子句，则减去时间间隔的数据

#### 1. 创建数据库

```sql
> CREATE DATABASE "food_data"
```

#### 2. 创建两个小时的默认保留策略

在以下情况下，如果不提供明确的保留策略，inflxudb会写入默认的保留策略。我们使用`DEFAULT` RP将数据保留两个小时，因为我们希望inflxudb自动将传入的10秒分辨率数据写入保护

使用该[`CREATE RETENTION POLICY`](/influxdb/v1.8/query_language/manage-database/#create-retention-policies-with-create-retention-policy)
语句创建一个`默认` RP：

```sql
> CREATE RETENTION POLICY "two_hours" ON "food_data" DURATION 2h REPLICATION 1 DEFAULT
```
该查询在数据库中创建了一个名为`two_hours`的保留策略，`two_hours`会将数据保存2小时，这是默认的`food_data`数据库中的`RP`

Replication factor (`REPLICATION 1`) 是必须的参数，但必须始终对单节点实例设置为1

> **Note:** 在步骤1中创建`food_data`数据库时，Influxdb自动生成一个名为RP`autogen`，并将其设置DEFAULT为数据库的RP, `autogen` RP具有无限保留期，通过上面的查询，RP `two_hours`替换`autogen`成为`food_data`数据库的新`RP` 。

#### 3. 指定52周的保留策略

接下来，我们希望创建另一个保留策略，将数据保留52周，而不是数据库的默认保留策略。
最终，30分钟的汇总数据将存储在该RP中。

使用该[`CREATE RETENTION POLICY`](/influxdb/v1.8/query_language/manage-database/#create-retention-policies-with-create-retention-policy)语句创建非默认保留策略

```sql
> CREATE RETENTION POLICY "a_year" ON "food_data" DURATION 52w REPLICATION 1
```
此操作将为`food_data`数据库创建一个名为`a_year`的保留策略，`a_year`设置将数据保留52周，省略`DEFAULT`参数可确保`_year`不是`food_data`数据库默认RP，也就是说，针对`food_data`该操作未指定RP的的写入和读取操作仍将转到`two_hours`RP(`DEFAULT`RP);
#### 4. 创建连续查询

现在我们已经建立了我们的`RPs`，我们想创建一个连续的查询(CQ)，它将自动并且周期性地将10分辨率数据下采样到30分钟分辨率，然后用不同的保留政策。

使用[`CREATE CONTINUOUS QUERY`](/influxdb/v1.8/query_language/continuous_queries/)语句可生成CQ


```sql
> CREATE CONTINUOUS QUERY "cq_30m" ON "food_data" BEGIN
  SELECT mean("website") AS "mean_website",mean("phone") AS "mean_phone"
  INTO "a_year"."downsampled_orders"
  FROM "orders"
  GROUP BY time(30m)
END
```
该查询在数据库`food_data`中创建一个名为`cq_30m`的CQ；`cq_30m`告诉Influxdb计算这两个field的30分钟的平均值。`website`和`phone`在测量订单和默认RP中两小时；
还会声明Influxdb使用field key和将这些结果写入`downsampled_orders`measurement中的保留策略.。Influxdb将在之前30分钟内，Influxdb将每30分钟运行一次此查询；

> **Note:** 完全限定（即使用语法
`"<retention_policy>"."<measurement>"`)`INTO`子句中的度量，Inflxudb要求使用该语法将数据写入RP意外的DEFAULT RP。

结果

有了新的CQ和两个新RP，`foo_data`就可以开始接受数据了，将数据写入我们的数据库并让其运行一会字后，我们可以看到两个measurement: `orders`和`downsampled_orders`

```sql
> SELECT * FROM "orders" LIMIT 5
name: orders
---------
time                    phone  website
2016-05-13T23:00:00Z    10     30
2016-05-13T23:00:10Z    12     39
2016-05-13T23:00:20Z    11     56
2016-05-13T23:00:30Z    8      34
2016-05-13T23:00:40Z    17     32

> SELECT * FROM "a_year"."downsampled_orders" LIMIT 5
name: downsampled_orders
---------------------
time                    mean_phone  mean_website
2016-05-13T15:00:00Z    12          23
2016-05-13T15:30:00Z    13          32
2016-05-13T16:00:00Z    19          21
2016-05-13T16:30:00Z    3           26
2016-05-13T17:00:00Z    4           23
```

向`orders`插入的是保留在两小时RP中的原始十秒分辨率数据，`downsampled_orders`中的数据是受52周RP限制的30分钟汇总分辨率数据



> **笔记:**
>
> - 请注意，我们在第二条语句中完全限定了 (即使用语法
>   `"<retention_policy>"."<measurement>"`) `downsampled_orders` 第二个
>    `SELECT`语句.我们必须在要选择的查询中指定RP 驻留在除默认RP之外的RP中的数据
> - 默认情况下, InfluxDB 每隔30分钟检查一次，以强制执行一次更新.在两次检查之间， `orders` 中的数据可以能超过两个小时. TInfluxDB检查执行RP的速率是可配置的设置
>   请参阅[数据库配置](/influxdb/v1.8/administration/config#check-interval-30m0s).




通过结合使用`RPs`和`CQs`，我们成功地建立了我们的数据库 在有限的时间内自动保存高精度的原始数据 精度数据，并将较低精度数据存储更长时间.。现在，您已经对这些功能如何协同工作有了大致的了解，请查看有关[CQs](/influxdb/v1.8/query_language/continuous_queries/)和[RPs](/influxdb/v1.8/query_language/manage-database/#retention-policy-management)的详细文档;