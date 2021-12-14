---
title: InfluxDB VS SQL数据库
description: Differences between InfluxDB and SQL databases.
menu:
  influxdb_1_8:
    name: InfluxDB VS SQL数据库
    weight: 30
    parent: 概念
---

Influxdb类似于一个SQL数据库，但在许多方面有所不同。
InfluxDB 是专门为时间序列数据构建的。
关系数据库可以处理时间序列数据，但没有针对常见的时间序列工作负载进行优化。
Influxdb旨在存储大量的时间序列数据，并快速的对这些数据进行实施分析。

### 时间就是一切

在Influxdb中，时间戳标识任何给定的数据库序列中的单个点，这就像一个SQL数据库表，其中主键由系统预先设置，并且始终为时间。Influxdb还认识到您的架构首选项可能会随着时间而改变，在Influxdb中，不必预先定义架构数据点可以具有度量中的一个字段，度量中的所有字段或者介于两者之间的任何数字，只需要为新字段编写一个点即可将新字段添加到测量中，您需要术语度量，请查看一下部分，了解SQL数据库和Influxdb属于交叉；

## 术语

下表是一个名为表的非常简单的例子foodships中与未索引列SQL数据库#_foodships和索引列park_id，planet以及time..

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

这些相同的数据在Influxdb中看来是这样:

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

通过参考上面的示例:

*  InfluxDB 度量 (`foodships`)类似于SQL数据库表.
* InfluxDB 标记 ( `park_id` 和 `planet`) 类似于SQL数据库中的索引.
* InfluxDB 字段 (`#_foodships`) 类似于SQL数据库中的未索引列.
* InfluxDB points (例如, `2015-04-16T12:00:00Z	5`) 类似于SQL行.

基于数据库术语的这种比较，Influxdb连续查询和保留策略类似于SQL数据库中存储过程，指定一次，然后定期执行,

当然，SQL数据库和Influxdb之间存在一些主要差异，SQL JSON无法用于influxdb测量，您的架构设计反映出这中差异，而且，正如我们上面提到的，度量就像一个SQL表，其中主要主索引 始终被预设为时间，Influxdb时间戳必须要采用UNIX纪元（GMT）或格式化为RFC399下有效的日期时间字符串

## 查询语言
InfluxDB 支持多种查询语言:

- [Flux](#flux)
- [InfluxQL](#influxql)

### Flux

[Flux](/influxdb/v1.8/flux/) i是一种脚本语言，旨在查询，分析时间序列数据并对其进行处理，从Influxdb1.8.0开始，Flux可与InfluxdbQL一起用于生产
对于熟悉InfluxQL的人，Flux旨在解决自引入InfluxDB 1.0以来我们已经收到的许多出色的功能请求

Flux是在InfluxDB 2.0 OSS
和InfluxDB Cloud 2.0中使用数据的主要语言，InfluxDB Cloud 2.0是可在多个云服务提供商之间使用的普遍使用的平台即服务（PaaS）。将Flux与InfluxDB 1.8+结合使用可使您熟悉Flux概念和语法，并简化向InfluxDB 2.0的过渡。

### InfluxQL

InfluxQL 是一种类似于SQL的查询语言，用于与Influxdb进行交互，它旨在让来自其他SQL或类似SQL的环境的用户感到熟悉，同时还提供特定于存储和分析时间序列数据的功能。然而InfluxQL不是SQL，缺乏像更高的操作支持UNION，JOIN并HAVING认为SQL电力用户习惯，Flu x提供了此功能；

InfluxQL的SELECT语句遵循SQLSELECT语句的形式:

```sql
SELECT <stuff> FROM <measurement_name> WHERE <some_conditions>
```

其中“where”是可选的

要获得上一节中Influxdb输出，需要输入:

```sql
SELECT * FROM "foodships"
```

如果你只想查看有关该行星的数据Sa turn,需要输入

```sql
SELECT * FROM "foodships" WHERE "planet" = 'Saturn'
```

如果您想查看2015年4月16日世界协调时12:00:01之后的行星数据，请输入:

```sql
SELECT * FROM "foodships" WHERE "planet" = 'Saturn' AND time > '2015-04-16 12:00:01'
```

如上例所示，InfluxQL允许您在“WHERE”子句中指定查询的时间范围。 您可以使用用单引号括起来的日期时间字符串 格式` YYYY-MM-DD HH:MM:SS.mmm ' (` mmm '是毫秒，是可选的，您也可以指定微秒或纳秒)。 您也可以将相对时间与“now()”一起使用，后者指的是服务器的当前时间戳

```sql
SELECT * FROM "foodships" WHERE time > now() - 1h
```

该查询以“foodships”度量输出数据，其中时间戳比服务器的当前时间减去一个小时要新。 用“now()”指定持续时间的选项有:

|Letter|Meaning|
|:---:|:---:|
| ns | nanoseconds |
|u or µ|microseconds|
| ms | milliseconds |
|s | seconds   		|
| m        | minutes   		|
| h        | hours   		|
| d        | days   		|
| w        | weeks   		|

InfluxQL还支持正则表达式、表达式中的算术运算、‘SHow’语句和‘group by’语句。 有关这些主题的深入讨论，请参见我们的[数据探索](/influx db/v 1.8/query _ language/explore-data/)页面。 InfluxQL函数包括“计数”、“最小”、“最大”、“中值”、“导数”等。 有关完整列表，请查看[函数](/influx db/v 1.8/query _ language/functions/)页面。 既然您已经有了大致的想法，请查看我们的[入门指南](/influx db/v 1.8/简介/入门/)。

## InfluxDB 不是 CRUD

InfluxDB是一个针对时间序列数据进行了优化的数据库。 这些数据通常来自分布式传感器组、大型网站的点击数据或金融交易列表。 这些数据有一个共同点，那就是总体上更有用。 有一篇文章说，在世界协调时周二12:38:35，您的计算机的CPU利用率为12%，很难从中得出结论。 当与系列的其余部分结合并可视化时，它变得更加有用。 这是随着时间的推移趋势开始显现的地方，并且可以从数据中得出可操作的见解。 另外，时间序列数据一般只写一次，很少更新

结果是，InfluxDB不是一个完整的CRUD数据库，而是更像一个CRUD，将创建和读取数据的性能优先于更新和销毁，并[防止一些更新和销毁行为](/Influxdb/v 1.8/concepts/insights _权衡/)使创建和读取更具性能:

```
*要更新一个点，请插入一个带有[相同测量值、标记集和时间戳](/influx db/v 1.8/故障排除/常见问题/# how-do-influx db-handle-replicate-points)的点。

*您可以[删除或删除系列](/influx db/v 1.8/query _ language/manage-database/# drop-series-from-the-index-with-drop-series)，但不能基于字段值删除单个点。作为一种解决方法，您可以搜索字段值，检索时间，然后[基于“时间”字段删除](/influx db/v 1.8/query _ language/manage-database/# DELETE-series-with-DELETE)。

*您还不能更新或重命名标签-有关更多信息，请参见GitHub问题[# 4157](https://GitHub . com/influx data/influx db/issues/4157)。要修改一系列点的标记，请找到具有违规标记值的点，将该值更改为所需的值，写回这些点，然后删除具有旧标记值的系列。

*您不能通过标记键(与值相对)删除标记-参见GitHub问题[# 8604](https://GitHub . com/influx data/influx db/issues/8604)。
```



