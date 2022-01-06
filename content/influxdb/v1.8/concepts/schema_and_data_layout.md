---
title: 模式设计和数据布局
description: InfluxDB时间序列数据结构的概述及其如何影响性能。
menu:
  influxdb_1_8:
    name: 模式设计和数据布局
    weight: 50
    parent: 概念
---

每个InfluxDB用例都是独一无二的，schema恰恰将反映出这种独特性。通常来讲，提前为查询优化设计的schema将使得查询更加简单及高校。我们建议参考下述最佳实践：

- [如何存储数据（tag及field）](#where-to-store-data-tag-or-field)
- [避免过多的序列series](#avoid-too-many-series)
- [使用推荐的命名规范](#use-recommended-naming-conventions)
- [合理的分片组持续期管理](#shard-group-duration-management)

## Where to store data (tag or field)
如何存储数据（tag及field）| 哪些情况下使用tag？哪些情况下使用field？

在设计时序数据库时，哪些属性使用tag，哪些属性使用field，比较难以区分。这里再次强调tag和field的区别，tag会自动加上索引，而field不会。tag value只能存储字符，field可以存储任何类型；

按照这个思路，一般来说你的查询可以指引你哪些数据放在tag中，哪些数据放在field中。只要查询中有的属性，建议你放在tag中：
- 把你经常查询的字段作为tag。
- 如果你要对其使用`GROUP BY()`，也要放在tag中。
- 如果你要对其使用InfluxQL函数，则将其放到field中，因为tag只能是字符串。大多数函数，如求和，对字符串是没有用的。
- 如果该数据点的值经常变化，应考虑将其放到field中。
- 如果你需要存储的值不是字符串，则需要放到field中，因为tag value只能是字符串。

## Avoid too many series
避免过多的序列series

InfluxDB会对[meansurement](/influxdb/v1.8/concepts/glossary/#meansurement)和[tags](/influxdb/v1.8/concepts/glossary/#tags)进行索引。

tags values会被索引但fields values不会，故基于tags的查询将比基于fields的查询更高效。但是，当索引过多时，写入和查询将被拖累。

InfluxDB会为每一组唯一的索引数据生成一个series key。当tags包含高度可变的信息，如UUID、哈希值和随机字符串时，这将导致数据库产生大量的[series](/influxdb/v1.8/concepts/glossary/#series)，即高series cardinality。series cardinality高是许多数据库使用过程中需要大量内存的主要原因。因此，为减少内存占用率，请考虑将高cardinality数据存储为field而不是tag。

> 如果InfluxDB中的查询和写入效率开始变慢，你可能遭遇到了高series cardinality（即过多的series）。此时，可参考[为什么series cardinality很重要](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#why-does-series-cardinality-matter)寻找解决思路。

## Use recommended naming conventions
使用推荐的命名规范

- [避免在tag和field的key中使用关键字](#avoid-reserved-keywords-in-tag-and-field-keys)
- [避免tag和field同名](#avoid-the-same-name-for-a-tag-and-a-field)
- [避免在measurements和keys中存储数据](#avoid-encoding-data-in-measurements-and-keys)
- [避免在一个独立的tag存储多个信息](#avoid-putting-more-than-one-piece-of-information-in-one-tag)

### Avoid reserved keywords in tag and field keys
避免在tag和field的key中使用关键字

应避免在tag和field的key中使用关键字，虽然这个不是必须的，但它将会简化查询语句的书写，因为你不必费心将这些关键字包裹在双引号中。其实其他数据库也有类似于这样的最佳实践。具体的关键字请参考[InfluxQL关键字](https://github.com/influxdata/influxql/blob/master/README.md#keywords)和[Flux关键字](https://docs.influxdata.com/flux/v0.x/spec/lexical-elements/#keywords)。

tag和field的key中如果包括除`[A-z,_]`的字符，你必须在书写InfluxQL语句时将它们放在双引号中，或在书写Flux语句时使用[括号记法](/flux/v0.x/data-types/composite/record/#bracket-notation)。

### Avoid the same name for a tag and a field
避免tag和field同名

应避免tag和field同名，否则会在查询数据时产生不可预知的结果。

如果你不慎插入了一条tag和field同名的数据，请参考[常见问题](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#tag-and-field-key-with-the-same-name)来查询相关数据并解决此问题。

### Avoid encoding data in measurements and keys
避免在measurements和keys中存储数据

数据应该存储在tag values或field values中，而非tag keys或field keys或measurements中。遵守上述最佳时间将使查询语句应该容易书写且高效执行。

同时，上述最佳实践也使得数据库的series cardinality保持在低水平。有关高series cardinality如何影响数据库的性能，请参考[如何定位并减少高series cardinality](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#why-does-series-cardinality-matter)。

#### shecma设计对比
下面我们举例对比下好的schema设计和差的schema设计。

**推荐的schema设计**: 下述schema将元数据分别存储在`crop`、`plot`和  `region` tags中。 `temp` 作为field存储可变数值。

#####  {id="good-measurements-schema"}
```
Good Measurements schema - Data encoded in tags (recommended)
-------------
weather_sensor,crop=blueberries,plot=1,region=north temp=50.1 1472515200000000000
weather_sensor,crop=blueberries,plot=2,region=midwest temp=49.8 1472515200000000000
```

**应避免的schema设计**: 下述schema将多种属性值（即`crop`、`plot`和  `region`）合并字符串后存在measurement中，类似Graphite的指标。

#####  {id="bad-measurements-schema"}
```
Bad Measurements schema - Data encoded in the measurement (not recommended)
-------------
blueberries.plot-1.north temp=50.1 1472515200000000000
blueberries.plot-2.midwest temp=49.8 1472515200000000000
```

blueberries.plot-1.north是measurement的名字。这个表是没有tag的。像`plot`，`region`这样的信息放在measurement名字里面将会使数据很难去查询。

**应避免的schema设计**: 下述schema将多种属性值（即`crop`、`plot`和  `region`）合并字符串后存在field key中。

#####  {id="bad-keys-schema"}
```
Bad Keys schema - Data encoded in field keys (not recommended)
-------------
weather_sensor blueberries.plot-1.north.temp=50.1 1472515200000000000
weather_sensor blueberries.plot-2.midwest.temp=49.8 1472515200000000000
```

blueberries.plot-1.north.temp是field key，这个表只有这一长长的field。像`plot`，`region`这样的信息放在field key中将会使数据很难去查询。

#### 不同的shecma设计之下的查询对比
下面我们对比下不同的shecma设计之下的查询情况。我们来计算下`region`为`north`的蓝莓平均`temp`（即温度）。

容易书写的查询语句：[_优秀的schema设计_](#good-measurements-schema) 下的数据可以直接使用`region`这个tag value作为过滤字段，如下：

```js
// Query *Good Measurements*, data stored in separate tag values (recommended)
from(bucket: "<database>/<retention_policy>")
  |> range(start:2016-08-30T00:00:00Z)
  |> filter(fn: (r) =>  r._measurement == "weather_sensor" and r.region == "north" and r._field == "temp")
  |> mean()
```

难于书写的查询语句：[_糟糕的schema设计_](#bad-measurements-schema) 下的数据需要使用到效率低的正则表达式，如下：

```js
// Query *Bad Measurements*, data encoded in the measurement (not recommended)
from(bucket: "<database>/<retention_policy>")
  |> range(start:2016-08-30T00:00:00Z)
  |> filter(fn: (r) =>  r._measurement =~ /\.north$/ and r._field == "temp")
  |> mean()
```
虽然可以查出结果，但查询使用的是field，而非tag，在大数量的情况下，效率并不高。

有时，复杂的measurements将使某些查询无法实现。譬如，计算两个plot1和plot2的平均`temp`，如下：

```
# Query *Bad Measurements*, data encoded in the measurement (not recommended)
> SELECT mean("temp") FROM /\.north$/

# Query *Good Measurements*, data stored in separate tag values (recommended)
> SELECT mean("temp") FROM "weather_sensor" WHERE "region" = 'north' AND "region" = 'midwest'
```

可见，上述第一个查询中，因为`region`信息嵌套在measurement中，导致无法一次性查询多个`region`的数据并最终取平均值。


### Avoid putting more than one piece of information in one tag
避免在一个独立的tag存储多个信息

将一个存储多个信息的tag简化为多个tag可以有效简化查询的书写并提高性能（至少减少了对正则表达式的需求）。如下：

```
Schema 1 - Multiple data encoded in a single tag
-------------
weather_sensor,crop=blueberries,location=plot-1.north temp=50.1 1472515200000000000
weather_sensor,crop=blueberries,location=plot-2.midwest temp=49.8 1472515200000000000
```

上述设计将多个参数即包括`plot`和`region`合并到一个较长的tag value (`plot-1.north`)。与之不同的下面这个例子：

```
Schema 2 - Data encoded in multiple tags
-------------
weather_sensor,crop=blueberries,plot=1,region=north temp=50.1 1472515200000000000
weather_sensor,crop=blueberries,plot=2,region=midwest temp=49.8 1472515200000000000
```

上述设计将多个参数即包括`plot`和`region`单独表示为独立的tag。

采用Flux或者InfluxSQL来计算下`region`为`north`的蓝莓平均`temp`（即温度），可见将数据混为一个tag来表示的设计将使得查询无法实现。

#### Flux语句查询平均值

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

#### InfluxQL语句查询平均值

```
# Schema 1 - Query for multiple data encoded in a single tag
> SELECT mean("temp") FROM "weather_sensor" WHERE location =~ /\.north$/

# Schema 2 - Query for data encoded in multiple tags
> SELECT mean("temp") FROM "weather_sensor" WHERE region = 'north'
```






## Shard group duration management
合理的分片组持续期管理

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