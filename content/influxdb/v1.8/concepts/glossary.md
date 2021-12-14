---
title: InfluxDB 专业术语
description: Terms related to InfluxDB OSS.
menu:
  influxdb_1_8:
    name: 专业术语
    weight: 20
    parent: 概念
---

## aggregation

聚合，一个InfluxQL函数，能够返回一组数据点的聚合结果。想要获得现有的和即将支持的聚合函数的完整列表，请查看文档[InfluxQL函数](/influxdb/v1.8/query_language/functions/#aggregations)。

相关术语： [function](/influxdb/v1.8/concepts/glossary/#function), [selector](/influxdb/v1.8/concepts/glossary/#selector), [transformation](/influxdb/v1.8/concepts/glossary/#transformation)

## batch

批量，一个InfluxQL查询，在数据库中自动地、周期性地运行。连续查询要求在`SELECT`子句中有一个函数（function），并且必须包含一个`GROUP BY time()`子句。

相关术语: [InfluxDB line protocol](/influxdb/v1.8/concepts/glossary/#influxdb-line-protocol), [point](/influxdb/v1.8/concepts/glossary/#point)

## bucket

桶，存储桶是时间序列数据存储在InfluxDB 2.0中的命名位置。 在InfluxDB 1.8+中，数据库和保留策略（database/retention-policy）的每种组合都代表一个存储桶。 使用InfluxDB 1.8+附带的[InfluxDB 2.0 API兼容性端点](/influxdb/v1.8/tools/api#influxdb-2-0-api-compatibility-endpoints)与存储桶进行交互。

## continuous query (CQ)

连续查询，一个InfluxQL查询，在数据库中自动地、周期性地运行。连续查询要求在`SELECT`子句中有一个函数（function），并且必须包含一个`GROUP BY time()`子句。
请参考 [连续查询](/influxdb/v1.8/query_language/continuous_queries/).


相关术语: [function](/influxdb/v1.8/concepts/glossary/#function)

## database

数据库，用户（user）、保留策略（retention policy）、连续查询（continuous query）和时序数据的逻辑容器。

相关术语: [continuous query](/influxdb/v1.8/concepts/glossary/#continuous-query-cq), [retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp), [user](/influxdb/v1.8/concepts/glossary/#user)

## duration

持续时间，保留策略（retention policy）的一个属性，决定数据在InfluxDB中保留多长时间。早于duration的数据将自动从数据库中删除。
有关如何设置`duration`，请查看[数据库管理](/influxdb/v1.8/query_language/manage-database/#create-retention-policies-with-create-retention-policy)。

相关术语: [retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)

## field

InfluxDB数据结构中记录元数据和实际数据的key-value对。field是InfluxDB数据结构中必须要有的一部分，并且不会被建索引。如果将field value作为查询的过滤条件的话，那么就必须遍历所选时间范围内的所有数据点，所以，这种方式相对于以tag作为过滤条件的查询，其性能会差很多。

**查询提示**：跟field相比，数据库会对tag建索引。

相关术语: [field key](/influxdb/v1.8/concepts/glossary/#field-key), [field set](/influxdb/v1.8/concepts/glossary/#field-set), [field value](/influxdb/v1.8/concepts/glossary/#field-value), [tag](/influxdb/v1.8/concepts/glossary/#tag)

## field key

构成field的key-value对里面，关于key的部分。field key是字符串并且存的是元数据（metadata）。

相关术语: [field](/influxdb/v1.8/concepts/glossary/#field), [field set](/influxdb/v1.8/concepts/glossary/#field-set), [field value](/influxdb/v1.8/concepts/glossary/#field-value), [tag key](/influxdb/v1.8/concepts/glossary/#tag-key)

## field set

一个数据点（point）上field key和field value的集合。

相关术语: [field](/influxdb/v1.8/concepts/glossary/#field), [field key](/influxdb/v1.8/concepts/glossary/#field-key), [field value](/influxdb/v1.8/concepts/glossary/#field-value), [point](/influxdb/v1.8/concepts/glossary/#point)

## field value

构成field的key-value对里面，关于value的部分。field value是实际数据，可以是字符串、浮点数、整数或者布尔值。一个field value始终和一个时间戳（timestamp）相关联。

数据库不会对field value建索引，如果将field value作为查询过滤条件的话，就必须遍历所选时间范围内的所有数据点，所以，这种方式的查询性能并不好。

**查询提示**：跟field value相比，数据库会对tag value建索引。

相关术语: [field](/influxdb/v1.8/concepts/glossary/#field), [field key](/influxdb/v1.8/concepts/glossary/#field-key), [field set](/influxdb/v1.8/concepts/glossary/#field-set), [tag value](/influxdb/v1.8/concepts/glossary/#tag-value), [timestamp](/influxdb/v1.8/concepts/glossary/#timestamp)

## function

函数，InfluxQL中的聚合（aggregation）、选择（selector）和转换（transformation）。想要获得InfluxQL函数的完整列表，请查看文档[函数](/influxdb/v1.8/query_language/functions/)。

相关术语: [aggregation](/influxdb/v1.8/concepts/glossary/#aggregation), [selector](/influxdb/v1.8/concepts/glossary/#selector), [transformation](/influxdb/v1.8/concepts/glossary/#transformation)

## identifier

标识符，关于连续查询（continuous query）的名字、数据库（database）名、field key、measurement的名字、保留策略（retention policy）的名字、tag key和用户（user）名的标记。可查看文档[InfluxQL参考](/influxdb/v1.8/query_language/spec/#identifiers)获得更多关于identifier的介绍。

相关术语:
[database](/influxdb/v1.8/concepts/glossary/#database),
[field key](/influxdb/v1.8/concepts/glossary/#field-key),
[measurement](/influxdb/v1.8/concepts/glossary/#measurement),
[retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp),
[tag key](/influxdb/v1.8/concepts/glossary/#tag-key),
[user](/influxdb/v1.8/concepts/glossary/#user)

## InfluxDB line protocol

行协议，写入InfluxDB的数据点的文本格式。可查看文档[行协议参考](/influxdb/v1.8/write_protocols/)获得更多关于它的介绍。

## measurement

InfluxDB数据结构中的一部分，描述了存储在相关field中的数据的含义。measurement的值是字符串。

相关术语: [field](/influxdb/v1.8/concepts/glossary/#field), [series](/influxdb/v1.8/concepts/glossary/#series)

## metastore

包含了系统状态的内部信息。metastore包括用户（user）信息、数据库（database）、保留策略（retention policy）、shard元数据和连续查询（continuous query）。

相关术语: [database](/influxdb/v1.8/concepts/glossary/#database), [retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp), [user](/influxdb/v1.8/concepts/glossary/#user)

## node

节点，一个独立的`influxd`实例。

相关术语: [server](/influxdb/v1.8/concepts/glossary/#server)

## now()

本地服务器当前的纳秒级时间戳（timestamp）。

## point

数据点，在InfluxDB中，point表示单个数据记录，类似于SQL数据库表中的行。 每个point：

- 由measurement，一个tag set，一个field key，一个field value和一个timestamp组成
- 由series和timestame唯一标识。

不能在一个series中存储多个带有相同timestame的point。
如果将timestame写入具有与现有point相匹配的timestame的series，则该field set将成为新旧field set的并集，并且任何联系都将移至新field set。
有关重复point的更多信息，请查看[常见问题](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#how-does-influxdb-handle-duplicate-points)。

相关术语: [field set](/influxdb/v1.8/concepts/glossary/#field-set), [series](/influxdb/v1.8/concepts/glossary/#series), [timestamp](/influxdb/v1.8/concepts/glossary/#timestamp)

## points per second

这是一个现在已经弃用的术语，原来表示数据写入InfluxDB的速率，因为InfluxDB的数据模型（schema）允许甚至鼓励每个数据point记录多个测量值（metric），所以这个概念有歧义。

写入速率现在通常是按values per second这个指标来表示，这样更精确。

相关术语: [point](/influxdb/v1.8/concepts/glossary/#point), [schema](/influxdb/v1.8/concepts/glossary/#schema), [values per second](/influxdb/v1.8/concepts/glossary/#values-per-second)

## query

查询，从InfluxDB中获取数据的操作。可查看文档[数据探索](/influxdb/v1.8/query_language/explore-data/)、[Schema探索](/influxdb/v1.8/query_language/explore-schema/)和[数据库管理](/influxdb/v1.8/query_language/manage-database/)获得更多关于query的介绍。

## replication factor  

复制因子，保留策略（retention policy）的一个属性，决定存储在集群中的数据副本的个数。InfluxDB在`N`个data node上复制数据，其中`N`就是副本个数。

相关术语: [cluster](/influxdb/v0.10/concepts/glossary/#cluster), [duration](/influxdb/v1.8/concepts/glossary/#duration), [node](/influxdb/v1.8/concepts/glossary/#node),[retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)

## retention policy (RP)

保留策略，InfluxDB数据结构中的一部分，描述了InfluxDB保存数据的时间（duration）、存储在集群中的数据副本的个数（replication factor）以及shard group覆盖的时间范围（shard group duration）。在每个数据库（database）里面，RP是唯一的，RP、measurement和tag set定义了一个series。

在创建数据库的时候，InfluxDB会自动创建名为`autogen`的RP。
如需了解更多，请查看[保留策略管理](/influxdb/v1.8/query_language/manage-database/#retention-policy-management)。

相关术语: [duration](/influxdb/v1.8/concepts/glossary/#duration), [measurement](/influxdb/v1.8/concepts/glossary/#measurement), [replication factor](/influxdb/v1.8/concepts/glossary/#replication-factor), [series](/influxdb/v1.8/concepts/glossary/#series), [shard duration](/influxdb/v1.8/concepts/glossary/#shard-duration), [tag set](/influxdb/v1.8/concepts/glossary/#tag-set)

## schema

模式，描述了数据在InfluxDB中是如何组织的。InfluxDB schema的基础是数据库（database）、保留策略（retention policy）、series、measurement、tag key、tag value和field key。有关更多关于Schema的信息，请查看[Schema探索](/influxdb/v1.8/concepts/schema_and_data_layout/)

相关术语: [database](/influxdb/v1.8/concepts/glossary/#database), [field key](/influxdb/v1.8/concepts/glossary/#field-key), [measurement](/influxdb/v1.8/concepts/glossary/#measurement), [retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp), [series](/influxdb/v1.8/concepts/glossary/#series), [tag key](/influxdb/v1.8/concepts/glossary/#tag-key), [tag value](/influxdb/v1.8/concepts/glossary/#tag-value)

## selector

选择，一个InfluxQL函数，从特定范围的point中返回一个point。想要获得现有的和即将支持的selector函数的完整列表，请查看文档[InfluxQL函数](/influxdb/v1.8/query_language/functions/#selectors)。

相关术语: [aggregation](/influxdb/v1.8/concepts/glossary/#aggregation), [function](/influxdb/v1.8/concepts/glossary/#function), [transformation](/influxdb/v1.8/concepts/glossary/#transformation)

## series

系列（序列），InfluxDB数据结构中，有相同measurement、tag set和保留策略（retention policy）的数据集合。

相关术语: [field set](/influxdb/v1.8/concepts/glossary/#field-set), [measurement](/influxdb/v1.8/concepts/glossary/#measurement), [tag set](/influxdb/v1.8/concepts/glossary/#tag-set)

## series cardinality

系列基数，在一个InfluxDB实例中，不同数据库（database）、measurement、tag set和field key的组合的数量。

例如，假设一个InfluxDB实例有一个数据库和一个measurement，这个measurement有两个tag key：`email`和`status`。如果有三个不同的`email`，并且每个`email`地址关联两个不同的`status`，那么这个measurement的系列基数则为6（3 * 2 = 6）：

| email                 | status |
| :-------------------- | :----- |
| lorr@influxdata.com   | start  |
| lorr@influxdata.com   | finish |
| marv@influxdata.com   | start  |
| marv@influxdata.com   | finish |
| cliff@influxdata.com  | start  |
| cliff@influxdata.com  | finish |

请注意，在某些情况下，由于存在从属tag，所以简单地将这些数据相乘可能会高估了序列基数。从属tag指的是被另一个tag限定它的范围的tag，它的存在不会使序列基数变大。如果我们在上面的例子中增加一个tag：`firstname`，序列基数不会变成18（3 *2* 3 = 18），它将保持不变，依旧是6，因为`firstname`已经被`email`覆盖了：

| email                 | status | firstname |
| :-------------------- | :----- | :-------- |
| lorr@influxdata.com   | start  | lorraine  |
| lorr@influxdata.com   | finish | lorraine  |
| marv@influxdata.com   | start  | marvin    |
| marv@influxdata.com   | finish | marvin    |
| cliff@influxdata.com  | start  | clifford  |
| cliff@influxdata.com  | finish | clifford  |

可查看文档[InfluxQL参考](/influxdb/v1.8/query_language/spec/#show-cardinality)，了解如何通过InfluxQL语句来查询序列基数。

相关术语: [field key](#field-key),[measurement](#measurement), [tag key](#tag-key), [tag set](#tag-set)

## series key

series key是measurement，tag set和field key来标识的特定系列。

示例：

```
# measurement, tag set, field key
h2o_level, location=santa_monica, h2o_feet
```

相关术语: [series](/influxdb/v1.8/concepts/glossary/#series)

## server

服务器，运行InfluxDB的虚拟机或物理机。
每个server只能有一个InfluxDB进程。

相关术语: [node](/influxdb/v1.8/concepts/glossary/#node)

## shard

分片，一个shard包含真实数据和压缩数据，shard由磁盘中的TSM文件表示。每个shard只属于一个shard group，一个shard group可以有多个shard。每个shard包含一组特定的序列（series）。一个给定的shard group中的一个序列中的所有point都存储在磁盘中相同的shard（TSM文件）。

相关术语: [series](/influxdb/v1.8/concepts/glossary/#series), [shard duration](/influxdb/v1.8/concepts/glossary/#shard-duration), [shard group](/influxdb/v1.8/concepts/glossary/#shard-group), [tsm](/influxdb/v1.8/concepts/glossary/#tsm-time-structured-merge-tree)

## shard duration

shard duration决定了每个shard group跨越多长时间。具体时间间隔由保留策略（retention policy）中的`SHARD DURATION`决定。查看[保留策略管理](/influxdb/v1.8/query_language/manage-database/#retention-policy-management)获得更多信息。

例如，如果保留策略的`SHARD DURATION`设为`1w`，那么每个shard group将跨越一个星期，并包含时间戳在这个星期内的所有数据点（point）。

相关术语: [database](/influxdb/v1.8/concepts/glossary/#database), [retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp), [series](/influxdb/v1.8/concepts/glossary/#series), [shard](/influxdb/v1.8/concepts/glossary/#shard), [shard group](/influxdb/v1.8/concepts/glossary/#shard-group)

## shard group

shard group是shard的逻辑容器，按时间和RP组织。每个包含数据的RP至少包含一个关联的shard group。一个shard group里的所有shard包含了该shard group覆盖的时间间隔内的数据。每个shard跨越的时间间隔就是shard duration。

相关术语: [database](/influxdb/v1.8/concepts/glossary/#database), [retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp), [series](/influxdb/v1.8/concepts/glossary/#series), [shard](/influxdb/v1.8/concepts/glossary/#shard), [shard duration](/influxdb/v1.8/concepts/glossary/#shard-duration)

## subscription

订阅，订阅允许push而不是基于查询数据的pull模式从InfluxDB接收数据，当Kapacitor与InfluxDB一起使用时，订阅将自动将已订阅数据库的每次写入从InfluxDB推送到Kapacitor。
订阅可以使用TCP或UDP传输写操作。

## tag

InfluxDB数据结构中记录元数据的key-value对，tag在InfluxDB数据结构中是可选的。但是，用它们来存储经常被查询的元数据是非常有用的；因为数据库会对tag建索引，所以tag上的查询性能很高。
**查询提示**：跟tag相比，数据库不会对field建索引。

相关术语: [field](/influxdb/v1.8/concepts/glossary/#field), [tag key](/influxdb/v1.8/concepts/glossary/#tag-key), [tag set](/influxdb/v1.8/concepts/glossary/#tag-set), [tag value](/influxdb/v1.8/concepts/glossary/#tag-value)

## tag key

构成tag的key-value对里面，关于key的部分。tag key是字符串并且存的是元数据。因为数据库会对tag key建索引，所以tag key上的查询性能很高。

**查询提示**：跟tag key相比，数据库不会对field key建索引。

相关术语: [field key](/influxdb/v1.8/concepts/glossary/#field-key), [tag](/influxdb/v1.8/concepts/glossary/#tag), [tag set](/influxdb/v1.8/concepts/glossary/#tag-set), [tag value](/influxdb/v1.8/concepts/glossary/#tag-value)

## tag set

一个数据点（point）上tag key和tag value的集合。

相关术语: [point](/influxdb/v1.8/concepts/glossary/#point), [series](/influxdb/v1.8/concepts/glossary/#series), [tag](/influxdb/v1.8/concepts/glossary/#tag), [tag key](/influxdb/v1.8/concepts/glossary/#tag-key), [tag value](/influxdb/v1.8/concepts/glossary/#tag-value)

## tag value

构成tag的key-value对里面，关于value的部分。tag value是字符串并且存的是元数据。因为数据库会对tag value建索引，所以tag value上的查询性能很高。


相关术语: [tag](/influxdb/v1.8/concepts/glossary/#tag), [tag key](/influxdb/v1.8/concepts/glossary/#tag-key), [tag set](/influxdb/v1.8/concepts/glossary/#tag-set)

## timestamp

时间戳，与一个数据点（point）关联的日期和时间。InfluxDB中所有时间都是UTC。

关于如何指定数据写入的时间，可查看写协议。关于如何指定查询数据的时间，可查看文档[数据探索](/influxdb/v1.8/query_language/explore-data/#time-syntax)。

相关术语: [point](/influxdb/v1.8/concepts/glossary/#point)

## transformation

一个InfluxQL函数，从特定数据点计算后返回一个值或一组值，但不是返回这些数据点的聚合值。想要获得现有的和即将支持的聚合函数的完整列表，请查看文档[InfluxQL函数](/influxdb/v1.8/query_language/functions/#transformations)。

相关术语: [aggregation](/influxdb/v1.8/concepts/glossary/#aggregation), [function](/influxdb/v1.8/concepts/glossary/#function), [selector](/influxdb/v1.8/concepts/glossary/#selector)

## TSM (Time Structured Merge tree)

InfluxDB的专用数据存储格式。跟现有的B+树或LSM树实现相比，TSM有更好的压缩和更高的写入和读取吞吐量。请查看[存储引擎](/influxdb/v1.8/concepts/storage_engine/)获得更多关于底层存储的信息。

## user

InfluxDB中有两种类型的用户：

* **admin**用户对所有数据库都有`READ`和`WRITE`权限，并且有管理查询和管理用户的全部权限。
* **non-admin**用户有针对数据库的`READ`、`WRITE`、或者`ALL`（包含`READ`和`WRITE`）的权限

启用身份认证后，InfluxDB仅执行使用有效的用户名和密码发送的HTTP请求。
请参阅[认证和授权](/influxdb/v1.8/administration/authentication_and_authorization/)获取相关信息。

## values per second

数据写入到InfluxDB的速率，这是测量写入速率的首选方法。写入速度通常以values per second表示。

要计算values per second，请将每秒写入的数据点数乘以每个点存储的value的个数。例如，每秒写入10次包含5,000个点的batch，每个点有4个field，那么values per second = 每个点有4个field *每个batch有5,000个点* 每秒写入10次 = 每秒写入200,000个值

相关术语: [batch](/influxdb/v1.8/concepts/glossary/#batch), [field](/influxdb/v1.8/concepts/glossary/#field), [point](/influxdb/v1.8/concepts/glossary/#point), [points per second](/influxdb/v1.8/concepts/glossary/#points-per-second)

## WAL (Write Ahead Log)

最近写入数据点的临时缓存。为了降低访问永久存储文件的频率，InfluxDB在WAL中缓存最近写入的数据点，直到数据总量达到阈值或者数据写入的时间超过一定的期限，这时候InfluxDB会将WAL中的这些数据flush到可以保存更长时间数据的存储空间。使用WAL，可以有效地将写入的数据批量写进TSM。

可以查询WAL中的数据点，并且系统重启后，这些数据不会丢失。在InfluxDB进程启动时，必须在系统接受新的写入请求前，将WAL中的所有数据点flush到存储空间。

相关术语: [tsm](/influxdb/v1.8/concepts/glossary/#tsm-time-structured-merge-tree)
