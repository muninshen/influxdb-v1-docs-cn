---
title: 模式设计和数据布局
description: >
  General guidelines for InfluxDB schema design and data layout.
menu:
  influxdb_1_8:
    name: 模式设计和数据布局
    weight: 50
    parent: 概念
---

1、哪些情况下使用tag

在设计时序数据库时，哪些属性使用tag，哪些属性使用field，比较难以区分，这里再次强调tag和field的区别，tag会自动加上索引，而field不会，tag value只能存储字符，field可以存储任何类型；

按照这个思路，一般来说你的查询可以指引你哪些数据放在tag中，哪些数据放在field中，只要查询中有的属性，建议你放在tag中：

- 把你经常查询的字段作为tag

- 如果你要对其使用`GROUP BY()`，也要放在tag中

- 如果你要对其使用InfluxQL函数，则将其放到field中，因为tag只能是字符串。大多数函数，如求和，对字符串是没有用的。是不是很好理解呢？

- 如果你需要存储的值不是字符串，则需要放到field中，因为tag value只能是字符串

  2、避免influxQL中关键字作为标识符名称

  避免influxQL中关键词作为标识符名称，这个不是必须的，但它只是简化了查询，不必将这标识符包装在双引号中，其实mysql也有类似于这样的最佳实践

  标识符有database名称，retention policy名称，user名称，measurement名称，tag key和field key。

  3、不要太多的序列series

  tags包含高度可变的信息，如UUID，哈希值和随机字符，这将导致数据库中大量的measurement，通俗地说，高序列数（series cardinality），序列数高会使内存急剧增加，所以设计时要小心；

  4、如何设计influxdb表measurement

  一般来说，谈论这一步可以简化你的查询，influxdb的查询会合并属于同一measurement范围内的数据，用tag区分数据比使用详细的measurement名字更好

```
Schema 1 - Data encoded in the measurement name
-------------
blueberries.plot-1.north temp=50.1 1472515200000000000
blueberries.plot-2.midwest temp=49.8 1472515200000000000
```

blueberries.plot-1.north是measurement的名字，这个表是没有tag的哦，像`plot`，`north`这样的信息放在measurement名字里面将会使数据很难去查询。

Ps:上面temp是温度的意思，对应的温度是华氏度，华氏度50度，只相对于摄氏度10度而已

使用上面的模式(schema 1)计算两个plot1和plot2的平均`temp`很困难，需要使用到效率低的正则表达式。如下

```
# Schema 1 - Query for data encoded in the measurement name
> SELECT mean("temp") FROM /\.north$/
```


```
我们队模式(schema 1)进行改造一下，变为模式2：
Schema 2 - Data encoded in tags
-------------
weather_sensor,crop=blueberries,plot=1,region=north temp=50.1 1472515200000000000
weather_sensor,crop=blueberries,plot=2,region=midwest temp=49.8 1472515200000000000
```

##### 以下查询计算了落在北部地区的蓝莓的平均`temp`，这种查询是不是很简单。但是，需要注意，它也有弱点，就是没有使用索引tag，使用的是field，大数量的情况下，效率并不高。

```js
// Schema 1 - Query for data encoded in the measurement name
from(bucket:"<database>/<retention_policy>")
  |> range(start:2016-08-30T00:00:00Z)
  |> filter(fn: (r) =>  r._measurement =~ /\.north$/ and r._field == "temp")
  |> mean()

// Schema 2 - Query for data encoded in tags
from(bucket:"<database>/<retention_policy>")
  |> range(start:2016-08-30T00:00:00Z)
  |> filter(fn: (r) =>  r._measurement == "weather_sensor" and r.region == "north" and r._field == "temp")
  |> mean()
```

##### InfluxQL

```
# Schema 1 - Query for data encoded in the measurement name
> SELECT mean("temp") FROM /\.north$/

# Schema 2 - Query for data encoded in tags
> SELECT mean("temp") FROM "weather_sensor" WHERE "region" = 'north'
```

\###避免在一个标签中放入多条信息 将单个标签和多个标签分割成单独的标签简化了查询，减少了对正则表达式的需求。 考虑下面由线路协议表示的模式。

```
Schema 1 - Multiple data encoded in a single tag
-------------
weather_sensor,crop=blueberries,location=plot-1.north temp=50.1 1472515200000000000
weather_sensor,crop=blueberries,location=plot-2.midwest temp=49.8 1472515200000000000
```

模式1数据将多个单独的参数“绘图”和“区域”编码成一个长标记值(“绘图-1 .北”)。 将它与下面的用线路协议表示的模式进行比较。

```
Schema 2 - Data encoded in multiple tags
-------------
weather_sensor,crop=blueberries,plot=1,region=north temp=50.1 1472515200000000000
weather_sensor,crop=blueberries,plot=2,region=midwest temp=49.8 1472515200000000000
```

Use Flux or InfluxQL to calculate the average `temp` for blueberries in the `north` region.
Schema 2 is preferable because using multiple tags, you don't need a regular expression.

##### Flux

```js
// Schema 1 -  Query for multiple data encoded in a single tag
from(bucket:"<database>/<retention_policy>")
  |> range(start:2016-08-30T00:00:00Z)
  |> filter(fn: (r) =>  r._measurement == "weather_sensor" and r.location =~ /\.north$/ and r._field == "temp")
  |> mean()

// Schema 2 - Query for data encoded in multiple tags
from(bucket:"<database>/<retention_policy>")
  |> range(start:2016-08-30T00:00:00Z)
  |> filter(fn: (r) =>  r._measurement == "weather_sensor" and r.region == "north" and r._field == "temp")
  |> mean()
```

##### InfluxQL

```
# Schema 1 - Query for multiple data encoded in a single tag
> SELECT mean("temp") FROM "weather_sensor" WHERE location =~ /\.north$/

# Schema 2 - Query for data encoded in multiple tags
> SELECT mean("temp") FROM "weather_sensor" WHERE region = 'north'
```

\##碎片组持续时间管理

 ###碎片组持续时间概述 

InfluxDB将数据存储在碎片组中。 分片组按[保留策略](/influx db/v 1.8/concepts/glossary/# retention-policy-RP)(RP)进行组织，并存储带有时间戳的数据，这些时间戳位于称为[分片持续时间](/influx db/v 1.8/concepts/glossary/#分片持续时间)的特定时间间隔内。 如果没有提供分片组持续时间，分片组持续时间由创建RP时的RP[持续时间](/influx db/v 1.8/concepts/glossary/# duration)决定。默认值为:

| RP Duration  | Shard Group Duration  |
|---|---|
| < 2 days  | 1 hour  |
| >= 2 days and <= 6 months  | 1 day  |
| > 6 months  | 7 days  |

碎片组的持续时间也可以根据RP进行配置。

 要配置碎片组持续时间，请参见[保留策略管理](/influx db/v 1.8/query _ language/manage-database/# Retention-Policy-Management)。

 ###碎片组持续时间权衡 确定最佳碎片组持续时间需要在以下各项之间找到平衡: -更长的碎片带来更好的整体性能 -较短的碎片提供了灵活性 

####长碎片组持续时间 更长的碎片组持续时间允许InfluxDB在同一逻辑位置存储更多数据。 这减少了数据重复，提高了压缩效率，并在某些情况下提高了查询速度。

 ####碎片组持续时间短 更短的碎片组持续时间允许系统更有效地删除数据和记录增量备份。 当InfluxDB强制实施一个RP时，它会丢弃整个碎片组，而不是单个数据点，即使这些点早于RP持续时间。 只有当碎片组的持续时间*结束时间*早于RP持续时间时，碎片组才会被删除。 例如，如果您的RP持续时间为一天，InfluxDB将每小时丢弃一小时的数据，并且始终有25个碎片组。一天中每一小时一个，还有一个额外的碎片组部分过期，但直到整个碎片组超过24小时后才会删除。 > **注意:*要考虑的一个特殊用例:按时间过滤对模式数据(如标签、序列、度量)的查询。例如，如果您想在一小时间隔内过滤模式数据，您必须将碎片组持续时间设置为1h。有关更多信息，请参见[按时间筛选架构数据](/influx db/v 1.8/query _ language/explore-schema/# filter-meta-query-by-time)。 

###碎片组持续时间建议 默认的碎片组持续时间在大多数情况下都很有效。但是，高吞吐量或长时间运行的实例将受益于使用更长的碎片组持续时间。 以下是一些延长碎片组持续时间的建议:

| RP Duration  | Shard Group Duration  |
|---|---|
| <= 1 day  | 6 hours  |
| > 1 day and <= 7 days  | 1 day  |
| > 7 days and <= 3 months  | 7 days  |
| > 3 months  | 30 days  |
| infinite  | 52 weeks or longer  |

> \> **注意:*注意，` INF `(无穷大)不是一个[有效的分片组持续时间](/influx db/v 1.8/query _ language/manage-database/# retention-policy-management)。
>
>  >在极端情况下，数据覆盖几十年并且永远不会被删除，像“1040瓦(20年)”这样的长碎片组持续时间是完全有效的。 设置分片组持续时间之前要考虑的其他因素: *碎片组应该是最频繁查询的最长时间范围的两倍 *每个分片组应包含超过100，000个[点](/influx db/v 1.8/概念/术语表/#点) *碎片组每个[系列]应包含1，000以上的分数(/influx db/v 1.8/概念/术语表/#系列) ####回填的碎片组持续时间 大量插入过去覆盖很大时间范围的历史数据会同时触发大量碎片的创建。 并发访问和写入数百或数千个碎片的开销会很快导致性能下降和内存耗尽。 当写入历史数据时，我们强烈建议临时设置更长的碎片组持续时间，以便创建更少的碎片。通常，52周的碎片组持续时间对于回填来说效果很好。
