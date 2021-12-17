---
title: InfluxDB 关键概念
description: 对InfluxDB核心架构的关键概念作简要说明，对于初学者来说很重要。
menu:
  influxdb_1_8:
    name: 关键概念
    weight: 10
    parent: 概念
---

在深入研究InfluxDB之前，最好先熟悉一下InfluxDB关键概念，本文档对这些概念和常用术语进行了简要介绍。我们在下面提供了所有要涵盖的术语列表，但是建议您从头到尾阅读本文档，以更全面地了解时间序列数据库。

- [database](/influxdb/v1.8/concepts/glossary/#database)
- [field key](/influxdb/v1.8/concepts/glossary/#field-key)
- [field set](/influxdb/v1.8/concepts/glossary/#field-set)
- [field value](/influxdb/v1.8/concepts/glossary/#field-value)
- [measurement](/influxdb/v1.8/concepts/glossary/#measurement)
- [point](/influxdb/v1.8/concepts/glossary/#point)
- [retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)
- [series](/influxdb/v1.8/concepts/glossary/#series)
- [tag key](/influxdb/v1.8/concepts/glossary/#tag-key)
- [tag set](/influxdb/v1.8/concepts/glossary/#tag-set)
- [tag value](/influxdb/v1.8/concepts/glossary/#tag-value)
- [timestamp](/influxdb/v1.8/concepts/glossary/#timestamp)

### 样本数据

下一节将参考下面列出的数据。这些数据虽然都是虚构的，但代表了一个可信的数据库设置，主要显示了在2015年8月18日午夜至2015年8月18日上午6:12的时间段内，两名科学家`scientists`（`langstroth`和`perpetua`）在两个位置`location`（地点`1`和地点`2`）统计的蝴蝶(`butterflies`)和蜜蜂(`honeybees`)`的数量

假设数据位于一个名为`my_database`的数据库中，其保留策略是`autogen`（关于数据库和保留策略的更多内容将在后面介绍）。

*提示：*  将鼠标悬停在工具提示的链接上，可以熟悉InfluxDB术语和布局.

**name:** <span class="tooltip" data-tooltip-text="Measurement">census</span>  

| time                                                           | <span class ="tooltip" data-tooltip-text ="Field key">butterflies</span> | <span class ="tooltip" data-tooltip-text ="Field key">honeybees</span> | <span class ="tooltip" data-tooltip-text ="Tag key">location</span> | <span class ="tooltip" data-tooltip-text ="Tag key">scientist</span>  |
| ----                                                                            | ------------------------------------------------------------------------ | ---------------------------------------------------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------------  |
| 2015-08-18T00:00:00Z                                                            | 12                                                                       | 23                                                                     | 1                                                                   | langstroth                                                            |
| 2015-08-18T00:00:00Z                                                            | 1                                                                        | 30                                                                     | 1                                                                   | perpetua                                                              |
| 2015-08-18T00:06:00Z                                                            | 11                                                                       | 28                                                                     | 1                                                                   | langstroth                                                            |
| <span class="tooltip" data-tooltip-text="Timestamp">2015-08-18T00:06:00Z</span> | <span class ="tooltip" data-tooltip-text ="Field value">3</span>         | <span class ="tooltip" data-tooltip-text ="Field value">28</span>      | <span class ="tooltip" data-tooltip-text ="Tag value">1</span>      | <span class ="tooltip" data-tooltip-text ="Tag value">perpetua</span> |
| 2015-08-18T05:54:00Z                                                            | 2                                                                        | 11                                                                     | 2                                                                   | langstroth                                                            |
| 2015-08-18T06:00:00Z                                                            | 1                                                                        | 10                                                                     | 2                                                                   | langstroth                                                            |
| 2015-08-18T06:06:00Z                                                            | 8                                                                        | 23                                                                     | 2                                                                   | perpetua                                                              |
| 2015-08-18T06:12:00Z                                                            | 7                                                                        | 22                                                                     | 2                                                                   | perpetua                                                              |

其中census是`measurement`，butterflies和honeybees是`field key`，location和scientist是`tag key`。

### 讨论

现在已经在InfluxDB中看到了一些示例数据，本节将介绍所有含义：

InfluxDB是一个时间序列数据库。在上面的数据中，有一列称之为`time`。在InfluxDB中所有的数据都有这一列。time存储时间戳，这个时间戳以[RFC3339](https://www.ietf.org/rfc/rfc3339.txt)格式展示了与特定数据相关联的UTC日期和时间。

接下来的两列, 分别是 `butterflies` and `honeybees`这两个fields。
fields 是由 `field keys` 和 `field values`。

field key(`butterflies`和`honeybees`)都是字符串，他们存储元数据；field key `butterflies`告诉我们蝴蝶的计数从12到7；field key `honeybees`告诉我们蜜蜂的计数从23变到22。

field value就是你的数据，它们可以是字符串、浮点数、整数、布尔值，因为InfluxDB是时间序列数据库，所以field value总是和时间戳相关联。

样本数据中的字段field values为:

```
12   23
1    30
11   28
3    28
2    11
1    10
8    23
7    22
```

在上面的数据中, 每组field key和field value的集合构成了一个<a name="field-set"></a>_**field set**_。
以下是样本数据中的全部八个field set：

* `butterflies = 12   honeybees = 23`
* `butterflies = 1    honeybees = 30`
* `butterflies = 11   honeybees = 28`
* `butterflies = 3    honeybees = 28`
* `butterflies = 2    honeybees = 11`
* `butterflies = 1    honeybees = 10`
* `butterflies = 8    honeybees = 23`
* `butterflies = 7    honeybees = 22`

field是InfluxDB数据结构所必需的一部分，即在InfluxDB中不能没有field。还要注意，fields是没有索引的。如果使用field value作为过滤条件来[查询](/influxdb/v1.8/concepts/glossary/#query)，则必须扫描与查询中其他条件匹配的所有值。因此，这些查询相对于tag查询（下文会介绍tags）的性能不高。通常，field不应包含通常查询的元数据。

样本数据的最后两列为 `location` 和 `scientist`, 它们都是tags。
tags由 tag keys 和 tag values组成.
 <a name="tag-key"></a>_**tag keys**_ 和 <a name="tag-value"></a>_**tag values**_ 存储为字符串并记录在元数据中。
样本数据中 tag keys 是 `location` 和 `scientist`。
 tag key `location` 有两个 tag values: `1` and `2`。
 tag key `scientist`有两个 tag values: `langstroth` 和 `perpetua`。

在上面的数据中， <a name="tag-set"></a>_**tag set**_ 是所有不同tag key和 tag value键值对的集合。
样本数据中的四个tag set是 :

* `location = 1`, `scientist = langstroth`
* `location = 2`, `scientist = langstroth`
* `location = 1`, `scientist = perpetua`
* `location = 2`,  `scientist = perpetua`

tag不是必需的字段，但是在你的数据中使用tag总是大有裨益，因为不同于field，tag是索引起来的。这意味着对tag的查询更快，tag是存储常用元数据的最佳选择。

请避免使用以下保留关键字：

* `_field`
* `_measurement`
* `time`

如果保留的关键字作为tag或field的key值，则关联的point数据将被丢弃。

> **为什么索引重要: Schema研究案例**
>
> 如果大多数查询都集中在field value `honeybees` 和 `butterflies`:
>
> `SELECT * FROM "census" WHERE "butterflies" = 1`
> `SELECT * FROM "census" WHERE "honeybees" = 23`
>
> 由于未对field建立索引，因此InfluxDB在
在第一个查询里面InfluxDB会扫描所有的`butterflies`的值，第二个查询会扫描所有`honeybees`的值。这样会使请求时间很长，特别在规模很大时。
为了优化查询，您应该重新设计[模式](/influxdb/v1.8/concepts/glossary/#schema) ，把field(`butterflies`和`honeybees`)改为tag，而将tag（`location`和`scientist`）改为field：
>
> **name:** <span class="tooltip" data-tooltip-text="Measurement">census</span>  
>
| time                                                                            | <span class ="tooltip" data-tooltip-text ="Field key">location</span> | <span class ="tooltip" data-tooltip-text ="Field key">scientist</span>  | <span class ="tooltip" data-tooltip-text ="Tag key">butterflies</span> | <span class ="tooltip" data-tooltip-text ="Tag key">honeybees</span> |
| ----                                                                            | --------------------------------------------------------------------- | ----------------------------------------------------------------------  | ---------------------------------------------------------------------- | -------------------------------------------------------------------- |
| 2015-08-18T00:00:00Z                                                            | 1                                                                     | langstroth                                                              | 12                                                                     | 23                                                                   |
| 2015-08-18T00:00:00Z                                                            | 1                                                                     | perpetua                                                                | 1                                                                      | 30                                                                   |
| 2015-08-18T00:06:00Z                                                            | 1                                                                     | langstroth                                                              | 11                                                                     | 28                                                                   |
| <span class="tooltip" data-tooltip-text="Timestamp">2015-08-18T00:06:00Z</span> | <span class ="tooltip" data-tooltip-text ="Field value">1</span>      | <span class ="tooltip" data-tooltip-text ="Field value">perpetua</span> | <span class ="tooltip" data-tooltip-text ="Tag value">3</span>         | <span class ="tooltip" data-tooltip-text ="Tag value">28</span>      |
| 2015-08-18T05:54:00Z                                                            | 2                                                                     | langstroth                                                              | 2                                                                      | 11                                                                   |
| 2015-08-18T06:00:00Z                                                            | 2                                                                     | langstroth                                                              | 1                                                                      | 10                                                                   |
| 2015-08-18T06:06:00Z                                                            | 2                                                                     | perpetua                                                                | 8                                                                      | 23                                                                   |
| 2015-08-18T06:12:00Z                                                            | 2                                                                     | perpetua                                                                | 7                                                                      | 22                                                                   |
>
> 现在 `butterflies` 和 `honeybees` 都是tags, InfluxDB 在执行上面的查询时就不会扫描它们的每一个值，这样就意味着你的查询会更快。

 <a name=measurement></a>_**measurement**_ 充当 tags、fields 和  `time` 的容器, measurement的名字是存储在相关fields数据的描述measurement 名称是字符串, 对于 SQL 用户，measurement在概念上类似于table数据表。样本数据中唯一的 measurement 是`census`。

 `census` 告诉我们， field values 记录的是 `butterflies` 和 `honeybees` 的数量，而不是它们的大小、方向或者某种幸福指数。

单个 measurement 可以属于不同的 retention policy。
一个 <a name="retention-policy"></a>_**retention policy**_ 描述了 InfluxDB 保留数据多长时间 (`DURATION`) 以及该数据在集群中存储了多少副本 (`REPLICATION`)。
如果你有兴趣阅读有关 retention policy的更多信息，请查阅 [Database Management](/influxdb/v1.8/query_language/manage-database/#retention-policy-management)章节。

{{% warn %}} 注意：Replication factors不适用于单节点实例。
{{% /warn %}}

在样本数据中，measurement `census`中的所有内容都属于 `autogen` 的retention policy。InfluxDB 自动创建该retention policy; 它具有无限的持续保留时间，并且 replication factor 设置为1.

现在您已经熟悉 measurements、tag sets 和 retention policy, 下面我们讨论下series。
在InfluxDB中,  <a name=series></a>_**series**是共享同一套measurement、 tag set 和 field key 的数据点（point）的集合。
上面的数据包含八个series：

| Series number            | Measurement | Tag set                                 | Field key     |
|:------------------------ | ----------- | -------                                 | ---------     |
| series 1                 | `census`    | `location = 1`,`scientist = langstroth` | `butterflies` |
| series 2                 | `census`    | `location = 2`,`scientist = langstroth` | `butterflies` |
| series 3                 | `census`    | `location = 1`,`scientist = perpetua`   | `butterflies` |
| series 4                 | `census`    | `location = 2`,`scientist = perpetua`   | `butterflies` |
| series 5                 | `census`    | `location = 1`,`scientist = langstroth` | `honeybees`   |
| series 6                 | `census`    | `location = 2`,`scientist = langstroth` | `honeybees`   |
| series 7                 | `census`    | `location = 1`,`scientist = perpetua`   | `honeybees`   |
| series 8                 | `census`    | `location = 2`,`scientist = perpetua`   | `honeybees`   |

在设计[schema](/influxdb/v1.8/concepts/glossary/#schema) 以及在InfluxDB中处理数据时，了解series的概念至关重要。

一个 <a name="point"></a>_**point**_ 表示具有四个部分的单个数据记录:  measurement, tag set, field set 和一个 timestamp。每一个 point 是有其series 和 timestamp唯一标识。

例如，这是一个 point:
```
name: census
-----------------
time                    butterflies honeybees   location    scientist
2015-08-18T00:00:00Z    1           30          1           perpetua
```

本例中point隶属于上述的series 3 和7 ，其具体位置为measurement (`census`)、所述 tag set (`location = 1`, `scientist = perpetua`)、field set (`butterflies = 1`, `honeybees = 30`)以及 timestamp `2015-08-18T00:00:00Z`。

刚介绍的所有内容都存储在样本 `my_database`数据库中。InfluxDB <a name=database></a>_**database**_ 类似于传统的关系型数据库，并作为users、retention policy、 continuous queries以及point的逻辑上的容器。有关这些主题的更多信息，请参见
 [身份验证与授权](/influxdb/v1.8/administration/authentication_and_authorization/) 和 [连续查询](/influxdb/v1.8/query_language/continuous_queries/) 。

数据库可以有多个users、continuous queries、retention policies和 measurements。
InfluxDB 是 schemaless 数据库，这意味着可以随时轻松添加新的measurements、tags 和 fields。它旨在使时序数据的处理变得很优秀。

要想了解更多InfluxDB，建议阅读 [入门指南](/influxdb/v1.8/introduction/getting_started/) 和 [写入数据](/influxdb/v1.8/guides/writing_data/) 以及 [查询数据](/influxdb/v1.8/guides/querying_data/) 指南。