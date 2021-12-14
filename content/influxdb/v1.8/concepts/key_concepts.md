---
title: InfluxDB 关键概念
description: Covers key concepts to learn about InfluxDB.
menu:
  influxdb_1_8:
    name: 关键概念
    weight: 10
    parent: 概念
---

在深入研究InfluxDB之前，最好先熟悉一下Influxdb关键概念，本文档对这些概念和InfluxDB常用术语进行了简要介绍。我们在下面提供了所有要涵盖的术语列表，但是建议您从头到尾阅读本文档，以更全面地了解时间序列数据库

| field value      | field key   | field set |
| ---------------- | ----------- | --------- |
| Database         | measurement | point     |
| retention policy | series      | Tag key   |
| Tag set          | tag value   | Timestamp |

如果你向了解Influxdb,请查看 [词汇表](/influxdb/v1.8/concepts/glossary/)

### 样本数据

下面请参考以下数据，这些数据虽然都是虚构的，但代表了一个可信的数据库设置，主要显示了2015年8月18日午夜到2015年8月18日上午6:12的时间段内，由两个科学家在两个位置（location‘1’和locacltion‘2’)统计的`butterflies`和`honeybess`的数量

假设数据位于一个名为`my_database`的数据库中，并且受`autogen`保留策略的约束（关于数据库和保留策略的更多内容将在后面介绍）

*提示:*  将鼠标悬停在工具提示的链接上，以熟悉InfluxDB术语和布局.

**name:** <span class="tooltip" data-tooltip-text="Measurement">census</span>  

| time                                                                            | <span class ="tooltip" data-tooltip-text ="Field key">butterflies</span> | <span class ="tooltip" data-tooltip-text ="Field key">honeybees</span> | <span class ="tooltip" data-tooltip-text ="Tag key">location</span> | <span class ="tooltip" data-tooltip-text ="Tag key">scientist</span>  |
| ----                                                                            | ------------------------------------------------------------------------ | ---------------------------------------------------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------------  |
| 2015-08-18T00:00:00Z                                                            | 12                                                                       | 23                                                                     | 1                                                                   | langstroth                                                            |
| 2015-08-18T00:00:00Z                                                            | 1                                                                        | 30                                                                     | 1                                                                   | perpetua                                                              |
| 2015-08-18T00:06:00Z                                                            | 11                                                                       | 28                                                                     | 1                                                                   | langstroth                                                            |
| <span class="tooltip" data-tooltip-text="Timestamp">2015-08-18T00:06:00Z</span> | <span class ="tooltip" data-tooltip-text ="Field value">3</span>         | <span class ="tooltip" data-tooltip-text ="Field value">28</span>      | <span class ="tooltip" data-tooltip-text ="Tag value">1</span>      | <span class ="tooltip" data-tooltip-text ="Tag value">perpetua</span> |
| 2015-08-18T05:54:00Z                                                            | 2                                                                        | 11                                                                     | 2                                                                   | langstroth                                                            |
| 2015-08-18T06:00:00Z                                                            | 1                                                                        | 10                                                                     | 2                                                                   | langstroth                                                            |
| 2015-08-18T06:06:00Z                                                            | 8                                                                        | 23                                                                     | 2                                                                   | perpetua                                                              |
| 2015-08-18T06:12:00Z                                                            | 7                                                                        | 22                                                                     | 2                                                                   | perpetua                                                              |

### 讨论区

现在已经在Influxdb中看到了一些示例数据，本节将介绍所有含义：

Inf luxdb是一个时间序列数据库，在上面的数据中，有一列称之为`time` influxdb中的所有数据列，time存储时间戳，并且时间戳以[RFC3339](https://www.ietf.org/rfc/rfc3339.txt)UTC`格式`显示与特定数据相关联的日期与时间

接下来的两列, 分别是 `butterflies` and `honeybees`这两个fields;
Fields 是由 `field keys` and `field values`.
<a name="field-key"></a>_**Field keys**_ (`butterflies` and `honeybees`) 是字符串；field key `butterflies` 告诉我们field values `12`-`7` 指的是 butterflies ， field key `honeybees`告诉我们  field values `23`-`22`指的是`honeybees`.

<a name="field-value"></a>_**Field values**_; 是我们的数据；它们可以是字符串、浮点数、整数或者 Booleans, 而且，InfluxDB是一个时序数据库，所以 field value 总是与时间戳相关联。

样本数据中的字段field values 为:

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

在上面的数据中, field-key 和 field-value 的集合构成了一个 <a name="field-set"></a>_**field set**_.
以下是样本数据中的全部八个field set:

* `butterflies = 12   honeybees = 23`
* `butterflies = 1    honeybees = 30`
* `butterflies = 11   honeybees = 28`
* `butterflies = 3    honeybees = 28`
* `butterflies = 2    honeybees = 11`
* `butterflies = 1    honeybees = 10`
* `butterflies = 8    honeybees = 23`
* `butterflies = 7    honeybees = 22`

Fields 是导入数据库结构的必须部分-没有 fields.，就无法在InfluxDB中拥有数据。同样重要的是要注意fields没有被索引。
使用field value作为过滤器的查询必须扫描与查询中其他条件匹配的所有值。结果，这些查询相对于tag查询（以下更多有关tags）的性能不高。通常，field不应包含通常查询的meta数据。

样本数据的最后两列为 `location` 和 `scientist`, 它们 都是tags.
Tags 是由 tag keys 和 tag values组成.
 <a name="tag-key"></a>_**tag keys**_ 和 <a name="tag-value"></a>_**tag values**_ 存储为字符串并记录meta数据.
样本数据中 tag keys in 是 `location` 和 `scientist`.
 tag key `location` 具有两个 tag values: `1` and `2`.
 tag key `scientist`还具有两个tag values: `langstroth` 和 `perpetua`.

在上面的数据中,  <a name="tag-set"></a>_**tag set**_ 是所有tag key-value值对的不同组合.
样本数据中的四个tag set是 :

* `location = 1`, `scientist = langstroth`
* `location = 2`, `scientist = langstroth`
* `location = 1`, `scientist = perpetua`
* `location = 2`,  `scientist = perpetua`

Tags 是可选的
不需要在数据结构中包含 tags，但使用它们通常是一个好的方法,因为fields不同,对 tags进行索引.
这意味这对Tags的查询速度更快，并且tag非常适合存储常见的查询的meta数据.

避免使用以下保留 keys:

* `_field`
* `_measurement`
* `time`

如果保留的 keyswords作为tag或field key包含在内，则关联的 point将被丢弃.

> **为什么索引很重要: Schema研究案例**

> 假设注意到大多数查询都集中在field value `honeybees` 和 `butterflies`:

> `SELECT * FROM "census" WHERE "butterflies" = 1`
> `SELECT * FROM "census" WHERE "honeybees" = 23`

> 由于未对field 建立索引，因此Influxdb在提供响应之前会 `butterflies`  先扫描第一个查询中的每个值和 `honeybees` 第二个查询中的每个值。这种行为可能会损害查询响应时间，尤其是在更大的查询范围内，重新安排架构 [schema](/influxdb/v1.8/concepts/glossary/#schema) 使 fields (`butterflies` 和 `honeybees`)成为 tags ，而 tags (`location` 和 `scientist`) 成为 fields:

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

> 现在 `butterflies` 和 `honeybees` 都是tags, InfluxDB 在执行上面的查询时就不会扫描它们的每一个值，这样就意味着你的查询会更快.

 <a name=measurement></a>_**measurement**_ 充当 tags, fields, 和  `time` 的容器, 而 measurement 名称是存储在关联字段中的数据并描述，Measurement 名称是 是字符串, 对于 SQL 用户,  measurement在概念上类似于table数据表；
样本数据中唯一的 measurement 是`census`

 `census` 告诉我们， field values 记录的是 `butterflies` 和 `honeybees` 和的数量，而`honeybees`不是它们的大小，方向或者某种指数

单个 measurement 可以属于不同的 retention policies.
一个 <a name="retention-policy"></a>_**retention policy**_ 描述了 InfluxDB 保留数据多长时间 (`DURATION`) 以及该数据在鸡群中存储了多少副本 (`REPLICATION`).
如果你有兴趣的话阅读有关 retention policies, 请查阅 [Database Management](/influxdb/v1.8/query_language/manage-database/#retention-policy-management).

{{% warn %}} Replication factors 不适用于单节点实例.
{{% /warn %}}

在样本数据中， `census` measurement 中的所有内容都属于 `autogen` retention policy.
InfluxDB 自动创建 retention policy; 它具有无限的持续保留时间，并且 replication factor 设置为1.

现在已经熟悉了 measurements, tag sets, 和 retention policies, 下面讨论一下series.
在InfluxDB中,  <a name=series></a>_**series**是measurement, tag set, 和 field key的集合.
上面的数据包含八个 series:

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

在设计 [schema](/influxdb/v1.8/concepts/glossary/#schema) 以及在Influxdb中处理数据时，了解series的概念至关重要.

一个 <a name="point"></a>_**point**_ 表示具有四个部分的单个数据记录:  measurement, tag set, field set, 和一个 timestamp. 一个 point 是有其series 和 timestamp唯一标识.

例如, 这是一个 point:
```
name: census
-----------------
time                    butterflies honeybees   location    scientist
2015-08-18T00:00:00Z    1           30          1           perpetua
```

本例中point是f series 3 和7 ，并通过 measurement (`census`), 所述 tag set (`location = 1`, `scientist = perpetua`),  field set (`butterflies = 1`, `honeybees = 30`),以及 timestamp `2015-08-18T00:00:00Z`.

刚介绍的所有内容都存储在样本 `my_database`数据库中. InfluxDB <a name=database></a>_**database**_ 类似于传统的关系型数据库，并充当 users, retention policies, continuous queries,以及时间序列数据的逻辑容器.有关这些主题的更多信息，请参见
 [身份验证 和 授权](/influxdb/v1.8/administration/authentication_and_authorization/) 和 [连续查询](/influxdb/v1.8/query_language/continuous_queries/) .

数据库可以有多个 users, continuous queries, retention policies,和 measurements.
InfluxDB 是 schemaless 数据库，这意味着可以随时轻松添加新的measurements, tags, 和 fields 
旨在处理时许数据很优秀.

要想了解更多Influxdb,建议阅读 [入门指南](/influxdb/v1.8/introduction/getting_started/) and the [编写数据](/influxdb/v1.8/guides/writing_data/) 以及 [查询数据](/influxdb/v1.8/guides/querying_data/) 指南






