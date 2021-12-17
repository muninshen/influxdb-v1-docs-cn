---
title: InfluxDB VS SQL数据库
description: InfluxDB与传统SQL数据库比较
menu:
  influxdb_1_8:
    name: InfluxDB VS SQL数据库
    weight: 30
    parent: 概念
---

InfluxDB类似于一个SQL数据库，但在许多方面有所不同。
InfluxDB是专门为时间序列数据构建的。
关系数据库可以处理时间序列数据，但没有针对常见的时间序列工作负载进行优化。
InfluxDB旨在存储大量的时间序列数据，并快速的对这些数据进行实时分析。

### 时间就是一切

在InfluxDB中，时间戳标识任何给定的数据series中的单个点，这就像一个SQL数据库表，其中主键由系统预先设置，并且始终为时间。InfluxDB还认识到您的schema可能会随着时间而改变.在InfluxDB中，不必预先定义schema。数据点point可以含一个measurement中的一个字段field，也可以是含全部的字段fields，或者介于两者之间的任何数量。需要的话，也可以对该point添加一个新field。
有关measurement，tags和fields的含义，请查看一下部分，以便进一步了解SQL数据库和InfluxDB的异同。

## 术语

下表是一个叫foodships的SQL数据库的例子。其中`#_foodships`列未被索引，`park_id`、`planet`和`time`列被索引。

``` sql
+---------+---------+---------------------+--------------+
| park_id | planet  | time                | #_foodships  |
+---------+---------+---------------------+--------------+
|       1 | Earth   | 1429185600000000000 |            0 |
|       1 | Earth   | 1429185601000000000 |            3 |
|       1 | Earth   | 1429185602000000000 |           15 |
|       1 | Earth   | 1429185603000000000 |           15 |
|       2 | Saturn  | 1429185600000000000 |            5 |
|       2 | Saturn  | 1429185601000000000 |            9 |
|       2 | Saturn  | 1429185602000000000 |           10 |
|       2 | Saturn  | 1429185603000000000 |           14 |
|       3 | Jupiter | 1429185600000000000 |           20 |
|       3 | Jupiter | 1429185601000000000 |           21 |
|       3 | Jupiter | 1429185602000000000 |           21 |
|       3 | Jupiter | 1429185603000000000 |           20 |
|       4 | Saturn  | 1429185600000000000 |            5 |
|       4 | Saturn  | 1429185601000000000 |            5 |
|       4 | Saturn  | 1429185602000000000 |            6 |
|       4 | Saturn  | 1429185603000000000 |            5 |
+---------+---------+---------------------+--------------+
```

这些数据在InfluxDB中看来是这样:

```sql
name: foodships
tags: park_id=1, planet=Earth
time			               #_foodships
----			               ------------
2015-04-16T12:00:00Z	 0
2015-04-16T12:00:01Z	 3
2015-04-16T12:00:02Z	 15
2015-04-16T12:00:03Z	 15

name: foodships
tags: park_id=2, planet=Saturn
time			               #_foodships
----			               ------------
2015-04-16T12:00:00Z	 5
2015-04-16T12:00:01Z	 9
2015-04-16T12:00:02Z	 10
2015-04-16T12:00:03Z	 14

name: foodships
tags: park_id=3, planet=Jupiter
time			               #_foodships
----			               ------------
2015-04-16T12:00:00Z	 20
2015-04-16T12:00:01Z	 21
2015-04-16T12:00:02Z	 21
2015-04-16T12:00:03Z	 20

name: foodships
tags: park_id=4, planet=Saturn
time			               #_foodships
----			               ------------
2015-04-16T12:00:00Z	 5
2015-04-16T12:00:01Z	 5
2015-04-16T12:00:02Z	 6
2015-04-16T12:00:03Z	 5
```

参考上面的数据，一般可以这么说：

* InfluxDB measurement (`foodships`)类似于SQL数据库中的表。
* InfluxDB tag ( `park_id` 和 `planet`) 类似于SQL数据库中的索引列。
* InfluxDB field (`#_foodships`) 类似于SQL数据库中的未索引列。
* InfluxDB points (例如, `2015-04-16T12:00:00Z	5`) 类似于SQL数据库中的行。

基于这些数据库术语的比较，InfluxDB的连续查询（continuous query）和保留策略（retention policy）类似于SQL数据库中的存储过程。它们被指定一次，然后定期自动执行。

当然，SQL数据库和InfluxDB之间存在一些主要差异。
* InfluxDB不支持JOIN操作。
* InfluxDB中一个measurement就像一个SQL的table，其中主索引总是被预设为时间。
* InfluxDB中的时间戳必须要采用UNIX纪元（GMT）或格式化为日期时间RFC3339格式的字符串才有效。

## 查询语言
InfluxDB 支持多种查询语言:

- [Flux](#flux)
- [InfluxQL](#influxql)

### Flux

[Flux](/influxdb/v1.8/flux/) 是一种脚本语言。它旨在查询、分析时间序列数据并对其进行处理。从InfluxDB1.8.0开始，Flux可与InfluxdbQL一起用于生产环境。
对于熟悉InfluxQL的人，Flux旨在解决自引入InfluxDB 1.0以来我们已经收到的许多出色的功能请求。这里有[Flux与InfluxQL的对比](/influxdb/v1.8/flux/flux-vs-influxql/)。

Flux是在InfluxDB 2.0 OSS和InfluxDB Cloud 2.0中使用的主要语言，InfluxDB Cloud 2.0是可在多个云服务提供商之间使用的普遍使用的平台即服务（PaaS）。将Flux与InfluxDB 1.8+结合使用可使您熟悉Flux概念和语法，并简化向InfluxDB 2.0的过渡。

### InfluxQL

InfluxQL 是一种类似于SQL的查询语言，用于与InfluxDB进行交互。它旨在让来自其他SQL或类似SQL的环境的用户感到熟悉，同时还提供特定于存储和分析时间序列数据的功能。然而InfluxQL不是SQL，缺乏譬如UNION、JOIN、HAVING这些SQL用户常见的高级功能。Flux提供了这些高级功能。

InfluxQL的SELECT语句遵循SQL SELECT语句的形式:

```sql
SELECT <stuff> FROM <measurement_name> WHERE <some_conditions>
```

其中“where”是可选的

在InfluxDB里为了查询到上面数据，需要输入：

```sql
SELECT * FROM "foodships"
```

如果你仅仅想看planet为Saturn的数据：

```sql
SELECT * FROM "foodships" WHERE "planet" = 'Saturn'
```

如果你想看到planet为Saturn，并且在UTC时间为2015年4月16号12:00:01之后的数据：

```sql
SELECT * FROM "foodships" WHERE "planet" = 'Saturn' AND time > '2015-04-16 12:00:01'
```

如上例所示，InfluxQL允许您在“WHERE”子句中指定查询的时间范围。您可以使用单引号括起来的日期时间字符串格式` YYYY-MM-DD HH:MM:SS.mmm ' (` mmm '是毫秒，是可选的，您也可以指定微秒或纳秒)。您也可以将相对时间与“now()”一起使用，后者指的是服务器的当前时间戳：

```sql
SELECT * FROM "foodships" WHERE time > now() - 1h
```

该查询输出measurement为foodships中的数据，其中时间戳比服务器当前时间减1小时。与now()做计算来决定时间范围的可选单位有：

|字母|含义|
|:---:|:---:|
| ns | nanoseconds 纳秒 |
|u or µ|microseconds 微秒 |
| ms | milliseconds 毫秒 |
|s | seconds 秒 |
| m        | minutes 分钟 |
| h        | hours 小时 |
| d        | days 天 |
| w        | weeks 星期|

InfluxQL还支持正则表达式，表达式中的运算符，SHOW语句和GROUP BY语句。有关这些主题的深入讨论，请参阅我们的[数据探索](/influxdb/v1.8/query_language/explore-data/)页面。InfluxQL功能还包括COUNT，MIN，MAX，MEDIAN，DERIVATIVE等。 有关完整列表，请查看[函数](/influxdb/v1.8/query_language/functions/)页面。 

您已经对InfluxDB有了大致的了解，快来查看[入门指南](/influxdb/v1.8/introduction/get-started/)。

## InfluxDB 不是 CRUD

InfluxDB是一个针对时间序列数据进行了优化的数据库。这些数据通常来自分布式传感器组、大型网站的点击数据或金融交易列表。

这个数据有一个共同之处在于它只看一个点没什么用，总体上更有用。有人说，在星期二UTC时间为12:38:35时，您的电脑CPU利用率为12％。这个很难得出什么结论。只有跟其他的series结合并可视化时，它变得更加有用。随着时间的推移开始显现的趋势，是我们从这些数据里真正想要看到的。

另外，时间序列数据通常是一次写入，很少更新。

InfluxDB不是一个完整的CRUD数据库，更像是一个CR-ud，因为它优先考虑create和read数据的性能而不是update和delete，[减少一些更新和销毁行为](/influxdb/v1.8/concepts/insights_tradeoffs/)：

* 更新一个点时，插入一个带有[相同measurement、tag set和timestamp](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#how-does-influxdb-handle-duplicate-points)的点。

* 您可以[DROP或DELETE一个series](/v1.8/query_language/manage-database/#drop-series-from-the-index-with-drop-series)，但不能基于字段值删除单个点。作为折中办法，您可以搜索field value，查找到相应的time，然后[基于“time”字段删除](/v1.8/query_language/manage-database/#delete-series-with-delete)。

* 您还不能更新或重命名tag-有关更多信息，请参见GitHub问题[#4157](hhttps://github.com/influxdata/influxdb/issues/4157)。要修改一系列点的tag，请找到具有违规tag value的点，将该值更改为所需的值，写回这些点，然后删除具有旧tag value的系列。

* 您不能通过tag key(与tag value相对)删除tag-参见GitHub问题[#8604](https://github.com/influxdata/influxdb/issues/8604)。