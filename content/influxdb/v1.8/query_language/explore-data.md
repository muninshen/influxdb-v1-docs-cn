---
title: 使用InfluxQL探索数据
description: >
  Explore time series data using InfluxData's SQL-like query language. Understand how to use the SELECT statement to query data from measurements, tags, and fields.
menu:
  influxdb_1_8:
    name: 数据探索
    weight: 20
    parent: InfluxQL
aliases:
  - /influxdb/v1.8/query_language/data_exploration/
---

InfluxQL是一种类SQL的查询语言，用于与InfluxDB中的数据进行交互。下面将详细介绍InfluxQL的SELECT语句和实用的数据查询语法。

<table style="width:100%">
  <tr>
    <td><b>基础</b></td>
    <td><b>查询结果的配置</b></td>
    <td><b>有关查询语法的提示</b></td>
  </tr>
  <tr>
    <td><a href="#SELECT语句">SELECT语句</a></td>
    <td><a href="#order-by-time-desc">ORDER BY time DESC</a></td>
    <td><a href="#time-syntax">时间语法</a></td>
  </tr>
  <tr>
    <td><a href="#the-where-clause">WHERE子句</a></td>
    <td><a href="#the-limit-and-slimit-clauses">LIMIT和SLIMIT子句</a></td>
    <td><a href="#regular-expressions">正则表达式</a></td>
  </tr>
  <tr>
    <td><a href="#the-group-by-clause">GROUP BY子句</a></td>
    <td><a href="#the-offset-and-soffset-clauses">OFFSET和SOFFSET子句</a></td>
    <td><a href="#data-types-and-cast-operations">数据类型和转换</a></td>
  </tr>
  <tr>
    <td><a href="#the-into-clause">INTO子句</a></td>
    <td><a href="#the-time-zone-clause">时区子句</a></td>
    <td><a href="#merge-behavior">合并</a></td>
  </tr>
  <tr>
    <td><a href="#"></a></td>
    <td><a href="#"></a></td>
    <td><a href="#multiple-statements">多个语句</a></td>
  </tr>
  <tr>
    <td><a href="#"></a></td>
    <td><a href="#"></a></td>
    <td><a href="#subqueries">子查询</a></td>
  </tr>
</table>



### 示例数据

本文档使用[美国国家海洋和大气管理局(NOAA)业务海洋产品和服务中心](http://tidesandcurrents.noaa.gov/stations.html?type=Water+Levels)提供的公开数据。请参阅[示例数据](/influxdb/v1.8/query_language/data_download/)章节下载数据，并按照下面的例子进行查询。

首先，登录Influx CLI：

```bash
$ influx -precision rfc3339 -database NOAA_water_database
Connected to http://localhost:8086 version 1.8.x
InfluxDB shell 1.8.x
>
```

接着，熟悉以下`h2o_feet`中measurement的部分示例数据。

name: h2o_feet

| time                                                                            | <span class ="tooltip" data-tooltip-text ="Field Key">level description</span>      | <span class ="tooltip" data-tooltip-text ="Tag Key">location</span>       | <span class ="tooltip" data-tooltip-text ="Field Key">water_level</span> |
| ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| 2015-08-18T00:00:00Z                                                            | between 6 and 9 feet                                                                | coyote_creek                                                              | 8.12                                                                     |
| 2015-08-18T00:00:00Z                                                            | below 3 feet                                                                        | santa_monica                                                              | 2.064                                                                    |
| <span class="tooltip" data-tooltip-text="Timestamp">2015-08-18T00:06:00Z</span> | <span class ="tooltip" data-tooltip-text ="Field Value">between 6 and 9 feet</span> | <span class ="tooltip" data-tooltip-text ="Tag Value">coyote_creek</span> | <span class ="tooltip" data-tooltip-text ="Field Value">8.005</span>     |
| 2015-08-18T00:06:00Z                                                            | below 3 feet                                                                        | santa_monica                                                              | 2.116                                                                    |
| 2015-08-18T00:12:00Z                                                            | between 6 and 9 feet                                                                | coyote_creek                                                              | 7.887                                                                    |
| 2015-08-18T00:12:00Z                                                            | below 3 feet                                                                        | santa_monica                                                              | 2.028                                                                    |

`h2o_feet`中的数据以六分钟为间隔。`h2o_feet`有一个[tag key](/influxdb/v1.8/concepts/glossary/#tag-key)（`location`），它有两个[tag value](/influxdb/v1.8/concepts/glossary/#tag-value)：`coyote_creek`和`santa_monica`。`h2o_feet`还有两个[field](/influxdb/v1.8/concepts/glossary/#field)：`level description`存储字符串类型的[field value](/influxdb/v1.8/concepts/glossary/#field-value)，而`water_level`存储浮点类型的field value。所有这些数据都存在[数据库](/influxdb/v1.8/concepts/glossary/#database)`NOAA_water_database`中。

> **免责声明：**`level description`不是NOAA原始数据的一部分，我们在这里加入这个field是为了拥有具有特殊字符和特殊字符串的field value。

## SELECT语句

`SELECT`语句从一个或多个[measurement](/influxdb/v1.8/concepts/glossary/#measurement)中查询数据。

### 语法

```sql
SELECT <field_key>[,<field_key>,<tag_key>] FROM <measurement_name>[,<measurement_name>]
```

`SELECT`语句需要一个`SELECT`子句和一个`FROM`子句。

#### `SELECT`子句

`SELECT`
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;子句支持多种指定数据的格式：

`SELECT *`
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;返回所有的[fields](/influxdb/v1.8/concepts/glossary/#field)和[tags](/influxdb/v1.8/concepts/glossary/#tag)。

`SELECT "<field_key>"`
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;返回一个特定的field。

`SELECT "<field_key>","<field_key>"`
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;返回一个或多个field。

`SELECT "<field_key>","<tag_key>"`
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;返回一个特定的field和一个特定的tag，当`SELECT`子句包含tag时，它必须至少指定一个field。

`SELECT "<field_key>"::field,"<tag_key>"::tag`
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;返回一个特定的field和一个特定的tag。`::[field | tag]`语法指定了标识符的类型，使用这个语法是为了区分具有相同名字的field key和tag key。
The `::[field | tag]` 

​		 &nbsp;返回特定的field和tag。`::[field | tag]`语法指定的[标识符](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#identifier)的类型。使用此语法来区分具有相同名称的field key和tag key。

支持的其他功能：[数学运算符](/influxdb/v1.8/query_language/math_operators/)，[函数](/influxdb/v1.8/query_language/functions/)，[基本数据类型转换](#data-types-and-cast-operations)，[正则表达式](#regular-expressions)

> **注意：** SELECT语句不能包含聚合函数**和**非聚合函数，field key或tag key。有关更多信息，请参阅[有关混合聚合查询和非聚合查询的错误](https://docs.influxdata.com/influxdb/v1.8/troubleshooting/errors/#error-parsing-query-mixing-aggregate-and-non-aggregate-queries-is-not-supported)。

#### `FROM`子句

`FROM`子句支持多种指定[measurement](/influxdb/v1.8/concepts/glossary/#measurement)的格式：

`FROM <measurement_name>`从一个measurement中返回数据。如果您使用[CLI](/influxdb/v1.8/tools/shell/)查询数据，那么访问的measurement属于`USE`指定的数据库，并且使用的是默认保留策略。如果您使用的是[InfluxDB API](/influxdb/v1.8/tools/api/)，那么measurement属于参数`db`指定的数据库，同样，使用的是默认（`DEFAULT`）的保留策略。

`FROM <measurement_name>,<measurement_name>`从多个measurement中返回数据。

`FROM <database_name>.<retention_policy_name>.<measurement_name>`从一个被完全限定的measurement中返回数据。通过明确指定measurement的数据库和保留策略来完全限定一个measurement。

`FROM <database_name>..<measurement_name>`从用户指定的一个[数据库](/influxdb/v1.8/concepts/glossary/#database)并使用默认[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)的measurement中返回数据。

除此之外，`FROM`子句还支持的功能：[正则表达式](#regular-expressions)。

#### 引号

如果标识符包含除了[A-z，0-9，_]之外的字符，或者以数字开头，又或者是[InfluxQL关键字](https://github.com/influxdata/influxql/blob/master/README.md#keywords)，那么它们必须使用双引号。虽然并不总是需要，但是我们建议您为标识符加上双引号。

> **注意**：这里关于[引号的语法](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#when-should-i-single-quote-and-when-should-i-double-quote-in-queries)与[行协议](/influxdb/v1.8/concepts/glossary/#influxdb-line-protocol)中的不同。

### 示例

#### 查询单个measurement中的所有field和tag

```sql
> SELECT * FROM "h2o_feet"

name: h2o_feet
--------------
time                   level description      location       water_level
2015-08-18T00:00:00Z   below 3 feet           santa_monica   2.064
2015-08-18T00:00:00Z   between 6 and 9 feet   coyote_creek   8.12
[...]
2015-09-18T21:36:00Z   between 3 and 6 feet   santa_monica   5.066
2015-09-18T21:42:00Z   between 3 and 6 feet   santa_monica   4.938
```

该语句从`h2o_feet`这个[measurement](/influxdb/v1.8/concepts/glossary/#measurement)中查询所有的[field](/influxdb/v1.8/concepts/glossary/#field)和[tag](/influxdb/v1.8/concepts/glossary/#tag)。

如果您使用[CLI](/influxdb/v1.8/tools/shell/)，请确保在执行上面的查询前，先输入`USE NOAA_water_database`，CLI将查询被`USE`指定的数据库并且保留策略是默认的数据。如果您使用的是HTTP API，那么请确保将参数`db`设为`NOAA_water_database`，如果没有设置参数`rp`，那么HTTP API将自动使用该数据库的默认保留策略。

#### 查询单个measurement中的特定的field和tag

```sql
> SELECT "level description","location","water_level" FROM "h2o_feet"

name: h2o_feet
--------------
time                   level description      location       water_level
2015-08-18T00:00:00Z   below 3 feet           santa_monica   2.064
2015-08-18T00:00:00Z   between 6 and 9 feet   coyote_creek   8.12
[...]
2015-09-18T21:36:00Z   between 3 and 6 feet   santa_monica   5.066
2015-09-18T21:42:00Z   between 3 and 6 feet   santa_monica   4.938
```

该查询选择了两个field：`level description`和`water_level`，和一个tag：`location`。请注意，当`SELECT`子句包含tag时，它必须至少指定一个field。

#### 查询单个measurement中的带标识符类型的特定的field和tag

```sql
> SELECT "level description"::field,"location"::tag,"water_level"::field FROM "h2o_feet"

name: h2o_feet
--------------
time                   level description      location       water_level
2015-08-18T00:00:00Z   below 3 feet           santa_monica   2.064
2015-08-18T00:00:00Z   between 6 and 9 feet   coyote_creek   8.12
[...]
2015-09-18T21:36:00Z   between 3 and 6 feet   santa_monica   5.066
2015-09-18T21:42:00Z   between 3 and 6 feet   santa_monica   4.938
```

该查询选择了两个field：`level description`和`water_level`，和一个tag：`location`。`::[field | tag]`语法明确指出了该标识符是field还是tag。当field key和tag key的名字相同时，请使用`::[field | tag]`来区分它们。大多数情况下，并不需要使用该语法。

#### 查询单个measurement中的所有field

```sql
> SELECT *::field FROM "h2o_feet"

name: h2o_feet
--------------
time                   level description      water_level
2015-08-18T00:00:00Z   below 3 feet           2.064
2015-08-18T00:00:00Z   between 6 and 9 feet   8.12
[...]
2015-09-18T21:36:00Z   between 3 and 6 feet   5.066
2015-09-18T21:42:00Z   between 3 and 6 feet   4.938
```

该查询从`h2o_feet`中选择了所有的field。`SELECT`子句支持将`*`和`::`这两个语法结合使用。

#### 查询单个measurement中的特定的field并进行基本运算

```sql
> SELECT ("water_level" * 2) + 4 FROM "h2o_feet"

name: h2o_feet
--------------
time                   water_level
2015-08-18T00:00:00Z   20.24
2015-08-18T00:00:00Z   8.128
[...]
2015-09-18T21:36:00Z   14.132
2015-09-18T21:42:00Z   13.876
```

该查询将`water_level`中的每个值乘以2，然后再加上4。请注意，InfluxDB遵循标准的算术运算顺序。可查看[InfluxQL数学运算符](/influxdb/v1.8/query_language/math_operators/)章节了解更多相关信息。

#### 查询多个measurement中的所有数据

```sql
> SELECT * FROM "h2o_feet","h2o_pH"

name: h2o_feet
--------------
time                   level description      location       pH   water_level
2015-08-18T00:00:00Z   below 3 feet           santa_monica        2.064
2015-08-18T00:00:00Z   between 6 and 9 feet   coyote_creek        8.12
[...]
2015-09-18T21:36:00Z   between 3 and 6 feet   santa_monica        5.066
2015-09-18T21:42:00Z   between 3 and 6 feet   santa_monica        4.938

name: h2o_pH
------------
time                   level description   location       pH   water_level
2015-08-18T00:00:00Z                       santa_monica   6
2015-08-18T00:00:00Z                       coyote_creek   7
[...]
2015-09-18T21:36:00Z                       santa_monica   8
2015-09-18T21:42:00Z                       santa_monica   7
```

该查询从两个measurement（`h2o_feet`和`h2o_pH`）中选择所有的field和tag，多个measurement之间用逗号（`,`）隔开。

#### 查询完全限定的measurement中的所有数据

```sql
> SELECT * FROM "NOAA_water_database"."autogen"."h2o_feet"

name: h2o_feet
--------------
time                   level description      location       water_level
2015-08-18T00:00:00Z   below 3 feet           santa_monica   2.064
2015-08-18T00:00:00Z   between 6 and 9 feet   coyote_creek   8.12
[...]
2015-09-18T21:36:00Z   between 3 and 6 feet   santa_monica   5.066
2015-09-18T21:42:00Z   between 3 and 6 feet   santa_monica   4.938
```

该查询从`h2o_feet`中选择了所有数据，`h2o_feet`是属于数据库`NOAA_water_database`和保留策略`autogen`的measurement。

如果使用CLI，可以用这种完全限定measurement的方式来代替`USE`指定的数据库和指定`DEFAULT`之外的保留策略。如果使用HTTP API，可以通过完全限定measurement的方式，代替设置参数`db`和`rp`。

#### 查询特定数据库的measurement中的所有数据

```sql
> SELECT * FROM "NOAA_water_database".."h2o_feet"

name: h2o_feet
--------------
time                   level description      location       water_level
2015-08-18T00:00:00Z   below 3 feet           santa_monica   2.064
2015-08-18T00:00:00Z   between 6 and 9 feet   coyote_creek   8.12
[...]
2015-09-18T21:36:00Z   between 3 and 6 feet   santa_monica   5.066
2015-09-18T21:42:00Z   between 3 and 6 feet   santa_monica   4.938
```

该查询从`h2o_feet`中选择了所有数据，`h2o_feet`是属于数据库`NOAA_water_database`和默认（`DEFAULT`）保留策略的measurement。`..`表示指定数据库的默认保留策略。

如果使用CLI，可以这种指定数据库的方式来代替`USE`指定的数据库。如果使用HTTP API，同样可以通过指定数据库，代替设置参数`db`。

### `SELECT`语句的常见问题

#### 在`SELECT`子句中查询tag key

一个查询在`SELECT`子句中必须至少包含一个[field key](/influxdb/v1.8/concepts/glossary/#field-key)才能返回结果。如果`SELECT`子句中只包含一个或多个[tag key](/influxdb/v1.8/concepts/glossary/#tag-key)，那么该查询会返回一个空的结果。这种返回结果的要求是系统存储数据的方式导致的。

##### 示例

下面的查询不返回任何数据，因为它在`SELECT`子句中只给定了一个tag key（`location`）：

```sql
> SELECT "location" FROM "h2o_feet"
>
```

想要返回跟tag key `location`相关的数据，查询中的`SELECT`子句必须至少包含一个field key（`water_level`）：

```sql
> SELECT "water_level","location" FROM "h2o_feet"
name: h2o_feet
time                   water_level  location
----                   -----------  --------
2015-08-18T00:00:00Z   8.12         coyote_creek
2015-08-18T00:00:00Z   2.064        santa_monica
[...]
2015-09-18T21:36:00Z   5.066        santa_monica
2015-09-18T21:42:00Z   4.938        santa_monica
```

## `WHERE`语句

`WHERE`子句根据[field](/influxdb/v1.8/concepts/glossary/#field)、[tag](/influxdb/v1.8/concepts/glossary/#tag)和/或[timestamp](/influxdb/v1.8/concepts/glossary/#timestamp)来过滤数据。

### 语法

```
SELECT_clause FROM_clause WHERE <conditional_expression> [(AND|OR) <conditional_expression> [...]]
```

`WHERE`子句支持在field、tag和timestamp上的条件表达式（conditional_expression）。

>**注意** InfluxDB不支持在WHERE子句中使用OR来指定多个时间范围。 例如，InfluxDB对以下查询不返回任何数：

`> SELECT * FROM "absolutismus" WHERE time = '2016-07-31T20:07:00Z' OR time = '2016-07-31T23:07:17Z'`

#### Fields

```
field_key <operator> ['string' | boolean | float | integer]
```

`WHERE`子句支持对[field value](/influxdb/v1.8/concepts/glossary/#field-value)进行比较，field value可以是字符串、布尔值、浮点数或者整数。

在`WHERE`子句中，请对字符串类型的field value用单引号括起来。如果字符串类型的field value没有使用引号或者使用了双引号，那么不会返回任何查询结果，在大多数情况下，也不会[返回错误](#common-issues-with-the-where-clause)。

支持的操作符：

##### 支持的操作符：

| 操作符 | 含义     |
| :----: | :------- |
|  `=`   | 等于     |
|  `<>`  | 不等于   |
|  `!=`  | 不等于   |
|  `>`   | 大于     |
|  `>=`  | 大于等于 |
|  `<`   | 小于     |
|  `<=`  | 小于等于 |

除此之外，还支持的功能：[算术运算符](/influxdb/v1.8/query_language/math_operators/)和[正则表达式](#regular-expressions)。

#### Tags

```sql
tag_key <operator> ['tag_value']
```

在`WHERE`子句中，请对[tag value](/influxdb/v1.8/concepts/glossary/#tag-value)用单引号括起来。如果tag value没有使用引号或者使用了双引号，那么不会返回任何查询结果，在大多数情况下，也不会[返回错误](#common-issues-with-the-where-clause)。

##### 支持的操作符：

| 操作符 | 含义   |
| :----: | :----- |
|  `=`   | 等于   |
|  `<>`  | 不等于 |
|  `!=`  | 不等于 |

除此之外，还支持的功能：[正则表达式](#regular-expressions)。

#### Timestamps

对于大多数`SELECT`语句，默认的时间范围是从[`1677-09-21 00:12:43.145224194 UTC`到`2262-04-11T23:47:16.854775806Z UTC`](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#what-are-the-minimum-and-maximum-timestamps-that-influxdb-can-store)。对于带[`GROUP BY time()`子句](#group-by-time-intervals)的`SELECT`语句，默认的时间范围是从`1677-09-21 00:12:43.145224194 UTC`到[`now()`](/influxdb/v1.8/concepts/glossary/#now)。

本页面中的[时间语法](#time-syntax) 章节将详细介绍如何在WHERE子句中指定其它的时间范围。

### 示例

#### 查询field value满足一定条件的数据

```sql
> SELECT * FROM "h2o_feet" WHERE "water_level" > 8

name: h2o_feet
--------------
time                   level description      location       water_level
2015-08-18T00:00:00Z   between 6 and 9 feet   coyote_creek   8.12
2015-08-18T00:06:00Z   between 6 and 9 feet   coyote_creek   8.005
[...]
2015-09-18T00:12:00Z   between 6 and 9 feet   coyote_creek   8.189
2015-09-18T00:18:00Z   between 6 and 9 feet   coyote_creek   8.084
```

该查询返回`h2o_feet`中的数据，这些数据满足条件：field key `water_level`的值大于8。

#### 查询field value满足一定条件的数据（field value是字符串类型）

```sql
> SELECT * FROM "h2o_feet" WHERE "level description" = 'below 3 feet'

name: h2o_feet
--------------
time                   level description   location       water_level
2015-08-18T00:00:00Z   below 3 feet        santa_monica   2.064
2015-08-18T00:06:00Z   below 3 feet        santa_monica   2.116
[...]
2015-09-18T14:06:00Z   below 3 feet        santa_monica   2.999
2015-09-18T14:36:00Z   below 3 feet        santa_monica   2.907
```

该查询返回`h2o_feet`中的数据，这些数据满足条件：field key `level description`的值等于字符串`below 3 feet`。在`WHERE`子句中，需要用单引号将字符串类型的field value括起来。

#### 查询field value满足一定条件的数据（`WHERE`子句包含基本运算）

```sql
> SELECT * FROM "h2o_feet" WHERE "water_level" + 2 > 11.9

name: h2o_feet
--------------
time                   level description           location       water_level
2015-08-29T07:06:00Z   at or greater than 9 feet   coyote_creek   9.902
2015-08-29T07:12:00Z   at or greater than 9 feet   coyote_creek   9.938
2015-08-29T07:18:00Z   at or greater than 9 feet   coyote_creek   9.957
2015-08-29T07:24:00Z   at or greater than 9 feet   coyote_creek   9.964
2015-08-29T07:30:00Z   at or greater than 9 feet   coyote_creek   9.954
2015-08-29T07:36:00Z   at or greater than 9 feet   coyote_creek   9.941
2015-08-29T07:42:00Z   at or greater than 9 feet   coyote_creek   9.925
2015-08-29T07:48:00Z   at or greater than 9 feet   coyote_creek   9.902
2015-09-02T23:30:00Z   at or greater than 9 feet   coyote_creek   9.902
```

该查询返回`h2o_feet`中的数据，这些数据满足条件：field key `water_level`的值加上2大于11.9。请注意，TSDBInfluxDB遵循标准的算术运算顺序。可查看[数学运算符](/influxdb/v1.8/query_language/math_operators/)章节了解更多相关信息。

#### 查询tag value满足一定条件的数据

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica'

name: h2o_feet
--------------
time                   water_level
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
[...]
2015-09-18T21:36:00Z   5.066
2015-09-18T21:42:00Z   4.938
```

该查询返回`h2o_feet`中的数据，这些数据满足条件：[tag key](/influxdb/v1.8/concepts/glossary/#tag-key) `location`的值是`santa_monica`。在`WHERE`子句中，需要用单引号将字符串类型的tag value括起来。

#### 查询field value和tag value都满足一定条件的数据

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" <> 'santa_monica' AND (water_level < -0.59 OR water_level > 9.95)

name: h2o_feet
--------------
time                   water_level
2015-08-29T07:18:00Z   9.957
2015-08-29T07:24:00Z   9.964
2015-08-29T07:30:00Z   9.954
2015-08-29T14:30:00Z   -0.61
2015-08-29T14:36:00Z   -0.591
2015-08-30T15:18:00Z   -0.594
```

该查询返回`h2o_feet`中的数据，这些数据满足条件：tag key `location`的值不等于`santa_monica`，并且，field key `water_level`的值小于-0.59或大于9.95。`WHERE`子句支持操作符`AND`和`OR`，并支持用括号将它们的逻辑分开。

#### 查询timestamp满足一定条件的数据

```sql
> SELECT * FROM "h2o_feet" WHERE time > now() - 7d
```

该查询返回`h2o_feet`中的数据，这些数据满足条件：[timestamp](/influxdb/v1.8/concepts/glossary/#timestamp)在过去7天内。本页面中的[时间语法](#time-syntax)章节将详细介绍`WHERE`子句中支持的时间语法。

### `WHERE`子句的常见问题

#### `WHERE`子句出现异常则没有结果返回

在大多数情况下，引起这个问题的原因是[tag value](/influxdb/v1.8/concepts/glossary/#tag-value)或字符串类型的[field value](/influxdb/v1.8/concepts/glossary/#tag-value)缺少单引号。如果tag value或字符串类型的field value没有使用引号或者使用了双引号，那么不会返回任何查询结果，在大多数情况下，也不会返回错误。

下面的代码块中，前两个查询分别尝试没有用引号或者尝试用双引号来指定tag value：`santa_monica`，这两个查询不会返回任何结果。第三个查询使用了单引号将`santa_monica`括起来（这是支持的语法），返回了预期的结果。

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = santa_monica

> SELECT "water_level" FROM "h2o_feet" WHERE "location" = "santa_monica"

> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica'

name: h2o_feet
--------------
time                   water_level
2015-08-18T00:00:00Z   2.064
[...]
2015-09-18T21:42:00Z   4.938
```

下面的代码块中，前两个查询分别尝试没有用引号或者尝试用双引号来指定字符串类型的field value：`at or greater than 9 feet`。第一个查询返回错误，因为该field value包含空格。第二个查询没有返回任何结果。第三个查询使用了单引号将`at or greater than 9 feet`括起来（这是支持的语法），返回了预期的结果。																		

```sql
> SELECT "level description" FROM "h2o_feet" WHERE "level description" = at or greater than 9 feet

ERR: error parsing query: found than, expected ; at line 1, char 86

> SELECT "level description" FROM "h2o_feet" WHERE "level description" = "at or greater than 9 feet"

> SELECT "level description" FROM "h2o_feet" WHERE "level description" = 'at or greater than 9 feet'

name: h2o_feet
--------------
time                   level description
2015-08-26T04:00:00Z   at or greater than 9 feet
[...]
2015-09-15T22:42:00Z   at or greater than 9 feet
```

# GROUP BY子句

`GROUP BY`子句按用户指定的tag或者时间区间对查询结果进行分组。

`GROUP BY`子句按以下方式对查询结果进行分组：

- 一个或多个指定的[`tags`](/influxdb/v1.8/concepts/glossary/#tag)
- 指定的时间间隔

>**注意：**不能使用`GROUP BY`对`fields`进行分组

<table style="width:100%">
  <tr>
    <td><a href="#group-by-tags">按tags进行分组</a>
    <td></td>
    <td></td>
    <td></td>
    </td>
  </tr>
  <tr>
    <td><b>按时间间隔分组:
    <td><a href="#basic-group-by-time-syntax">基础语法</a></td>
    <td><a href="#advanced-group-by-time-syntax">高级语法</a></td>
    <td><a href="#group-by-time-intervals-and-fill">按时间间隔分组并回填数据</a></td>
    </b></td>
  </tr>
</table>


## GROUP BY tags

`GROUP BY <tag>`按一个或多个指定的[tags](/influxdb/v1.8/concepts/glossary/#tag)对查询结果进行分组

#### 语法

```sql
SELECT_clause FROM_clause [WHERE_clause] GROUP BY [* | <tag_key>[,<tag_key]]
```

`GROUP BY *`
&emsp;&emsp;&emsp;按所有[tags](/influxdb/v1.8/concepts/glossary/#tag)对查询结果进行分组。

`GROUP BY <tag_key>`
&emsp;&emsp;&emsp;按指定的一个tag对查询结果进行分组。

`GROUP BY <tag_key>,<tag_key>`
&emsp;&emsp;&emsp;按多个tag对查询结果进行分组， [tag keys](/influxdb/v1.8/concepts/glossary/#tag-key)的顺序对结果无影响。

如果查询语句中包含一个 [`WHERE` clause](#the-where-clause)子句，那么`GROUP BY`子句必须放在该`WHERE`子句后面。

除此之外，`GROUP BY`子句还支持的功能：[正则表达式](#regular-expressions)。

#### 示例

##### 按单个tag对查询结果进行分组

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" GROUP BY "location"

name: h2o_feet
tags: location=coyote_creek
time			               mean
----			               ----
1970-01-01T00:00:00Z	 5.359342451341401


name: h2o_feet
tags: location=santa_monica
time			               mean
----			               ----
1970-01-01T00:00:00Z	 3.530863470081006
```

该查询使用了InfluxQL中的一个 [函数](/influxdb/v1.8/query_language/functions/)计算[measurement](/influxdb/v1.8/concepts/glossary/#measurement)`h2o_feet`中每个`location`的`water_level`的平均值。InfluxDB返回两个[系列](/influxdb/v1.8/concepts/glossary/#series)的结果：每个`location`的值对应一个系列。

>**注意**：在InfluxDB中，[`epoch 0`](https://en.wikipedia.org/wiki/Unix_time)（`1970-01-01T00:00:00Z`）通常用作空时间戳。如果在您的请求结果中没有时间戳返回，例如您用了具有无限时间范围的聚合函数，InfluxDB将返回`epoch 0`作为时间戳。

##### 按多个tag对查询结果进行分组

```sql
> SELECT MEAN("index") FROM "h2o_quality" GROUP BY "location","randtag"

name: h2o_quality
tags: location=coyote_creek, randtag=1
time                  mean
----                  ----
1970-01-01T00:00:00Z  50.69033760186263

name: h2o_quality
tags: location=coyote_creek, randtag=2
time                   mean
----                   ----
1970-01-01T00:00:00Z   49.661867544220485

name: h2o_quality
tags: location=coyote_creek, randtag=3
time                   mean
----                   ----
1970-01-01T00:00:00Z   49.360939907550076

name: h2o_quality
tags: location=santa_monica, randtag=1
time                   mean
----                   ----
1970-01-01T00:00:00Z   49.132712456344585

name: h2o_quality
tags: location=santa_monica, randtag=2
time                   mean
----                   ----
1970-01-01T00:00:00Z   50.2937984496124

name: h2o_quality
tags: location=santa_monica, randtag=3
time                   mean
----                   ----
1970-01-01T00:00:00Z   49.99919903884662
```

该查询使用了InfluxQL中的一个 [函数](/influxdb/v1.8/query_language/functions/)计算measurement `h2o_quality`中每个`location`和`randtag`的组合的`index`的平均值，其中，`location`有2个不同的值，`randtag`有3个不同的值，总共有6个不同的组合。在`GROUP BY`子句中，用逗号将多个[tag](/influxdb/v1.8/concepts/glossary/#tag)隔开。

##### 按所有tag对查询结果进行分组

```sql
> SELECT MEAN("index") FROM "h2o_quality" GROUP BY *

name: h2o_quality
tags: location=coyote_creek, randtag=1
time			               mean
----			               ----
1970-01-01T00:00:00Z	 50.55405446521169


name: h2o_quality
tags: location=coyote_creek, randtag=2
time			               mean
----			               ----
1970-01-01T00:00:00Z	 50.49958856271162


name: h2o_quality
tags: location=coyote_creek, randtag=3
time			               mean
----			               ----
1970-01-01T00:00:00Z	 49.5164137518956


name: h2o_quality
tags: location=santa_monica, randtag=1
time			               mean
----			               ----
1970-01-01T00:00:00Z	 50.43829082296367


name: h2o_quality
tags: location=santa_monica, randtag=2
time			               mean
----			               ----
1970-01-01T00:00:00Z	 52.0688508894012


name: h2o_quality
tags: location=santa_monica, randtag=3
time			               mean
----			               ----
1970-01-01T00:00:00Z	 49.29386362086556
```

该查询使用了InfluxQL中的一个 [函数](/influxdb/v1.8/query_language/functions/)计算measurement `h2o_quality`中每个[tag](/influxdb/v1.8/concepts/glossary/#tag)的组合的`index`的平均值。

请注意，该查询的结果与上面[示例](#examples-2)中的查询结果相同，这是因为在`h2o_quality`中，只有两个tag key：`location`和`randtag`。

## GROUP BY time intervals

`GROUP BY time()`按用户指定的时间间隔对查询结果进行分组。

### 基本的`GROUP BY time()`语法

#### 语法

```sql
SELECT <function>(<field_key>) FROM_clause WHERE <time_range> GROUP BY time(<time_interval>),[tag_key] [fill(<fill_option>)]
```

基本的`GROUP BY time()`查询需要在[`SELECT`子句](#the-basic-select-statement)中包含一个InfluxQL [函数](/influxdb/v1.8/query_language/functions/)，并且在[`WHERE`子句](#the-where-clause)子句中包含时间范围。请注意，`GROUP BY`子句必须放在`WHERE`子句后面。

##### `time(time_interval)`

`GROUP BY time()`子句中的`time_interval`（时间间隔）是一个持续时间（duration），决定了InfluxDB按多大的时间间隔将查询结果进行分组。例如，当`time_interval`为`5m`时，那么在`WHERE`子句中指定的时间范围内，将查询结果按5分钟进行分组。

##### `fill(<fill_option>)`

`fill(<fill_option>)`是可选的，它会改变不含数据的时间间隔的返回值

**覆盖范围：**

基本的`GROUP BY time()`查询依赖`time_interval`和InfluxDB的预设时间边界来确定每个时间间隔内的原始数据和查询返回的时间戳。

#### 基本语法示例

下面的示例将使用如下数据：

```sql
> SELECT "water_level","location" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
--------------
time                   water_level   location
2015-08-18T00:00:00Z   8.12          coyote_creek
2015-08-18T00:00:00Z   2.064         santa_monica
2015-08-18T00:06:00Z   8.005         coyote_creek
2015-08-18T00:06:00Z   2.116         santa_monica
2015-08-18T00:12:00Z   7.887         coyote_creek
2015-08-18T00:12:00Z   2.028         santa_monica
2015-08-18T00:18:00Z   7.762         coyote_creek
2015-08-18T00:18:00Z   2.126         santa_monica
2015-08-18T00:24:00Z   7.635         coyote_creek
2015-08-18T00:24:00Z   2.041         santa_monica
2015-08-18T00:30:00Z   7.5           coyote_creek
2015-08-18T00:30:00Z   2.051         santa_monica
```

##### **将查询结果按12分钟的时间间隔进行分组**

```sql
> SELECT COUNT("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m)

name: h2o_feet
--------------
time                   count
2015-08-18T00:00:00Z   2
2015-08-18T00:12:00Z   2
2015-08-18T00:24:00Z   2
```

该查询使用了InfluxQL中的一个函数计算measurement `h2o_feet`中`location = coyote_creek`的`water_level`的数据点数，并将结果按12分钟为间隔进行分组。

每个时间戳所对应的结果代表一个12分钟间隔所对应的结果。第一个时间戳的计数（count）涵盖了从`2015-08-18T00:00:00Z`到`2015-08-18T00:12:00Z`的原始数据（不包括`2015-08-18T00:12:00Z`）。第二个时间戳的计数涵盖了从`2015-08-18T00:12:00Z`到`2015-08-18T00:24:00`的原始数据（不包括`2015-08-18T00:24:00`）。

##### **将查询结果按12分钟的时间间隔和一个tag key进行分组**

```sql
> SELECT COUNT("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m),"location"

name: h2o_feet
tags: location=coyote_creek
time                   count
----                   -----
2015-08-18T00:00:00Z   2
2015-08-18T00:12:00Z   2
2015-08-18T00:24:00Z   2

name: h2o_feet
tags: location=santa_monica
time                   count
----                   -----
2015-08-18T00:00:00Z   2
2015-08-18T00:12:00Z   2
2015-08-18T00:24:00Z   2
```

该查询使用了InfluxQL中的一个函数计算`water_level`的数据点数，并将结果按tag `location`和12分钟间隔进行分组。请注意，在`GROUP BY`子句中，用逗号将时间间隔和tag key隔开。

该查询返回两个序列：每个`location`的值对应一个序列。每个时间戳所对应的结果代表一个12分钟间隔所对应的结果。第一个时间戳的计数（count）涵盖了从`2015-08-18T00:00:00Z`到`2015-08-18T00:12:00Z`的原始数据（不包括`2015-08-18T00:12:00Z`）。第二个时间戳的计数涵盖了从`2015-08-18T00:12:00Z`到`2015-08-18T00:24:00`的原始数据（不包括`2015-08-18T00:24:00`）。

#### 基本语法的常见问题

##### **查询结果中出现意想不到的时间戳和值**

使用基本语法，InfluxDB依赖`GROUP BY time()`中的时间间隔和系统的预设时间边界来确定每个时间间隔内的原始数据和查询返回的时间戳。在某些情况下，这可能会导致意想不到的结果。

**示例**

原始数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:18:00Z'
name: h2o_feet
--------------
time                   water_level
2015-08-18T00:00:00Z   8.12
2015-08-18T00:06:00Z   8.005
2015-08-18T00:12:00Z   7.887
2015-08-18T00:18:00Z   7.762
```

查询和结果：

以下查询覆盖的时间范围是12分钟，并将结果按12分钟的间隔进行分组，但是它返回了两个结果：

```sql
> SELECT COUNT("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-08-18T00:06:00Z' AND time < '2015-08-18T00:18:00Z' GROUP BY time(12m)

name: h2o_feet
time                   count
----                   -----
2015-08-18T00:00:00Z   1        <----- Note that this timestamp occurs before the start of the query's time range
2015-08-18T00:12:00Z   1
```

说明：

InfluxDB对`GROUP BY`的时间间隔使用预设的四舍五入时间边界，不依赖于`WHERE`子句中任何时间条件。在计算结果的时候，所有返回数据的时间戳必须在查询中明确规定的时间范围内，但是`GROUP BY`的时间间隔将会基于预设的时间边界。

下面的表格展示了结果中预设的时间边界、相关的`GROUP BY time()`时间间隔、包含的数据点以及每个`GROUP BY time()`间隔所对应的实际返回的时间戳。

| 时间间隔序号 | 预设的时间边界                                               |`GROUP BY time()`时间间隔 | 包含的数据点 | 返回的时间戳 |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| 1 | `time >= 2015-08-18T00:00:00Z AND time < 2015-08-18T00:12:00Z` | `time >= 2015-08-18T00:06:00Z AND time < 2015-08-18T00:12:00Z` | `8.005` | `2015-08-18T00:00:00Z` |
| 2  | `time >= 2015-08-12T00:12:00Z AND time < 2015-08-18T00:24:00Z` | `time >= 2015-08-12T00:12:00Z AND time < 2015-08-18T00:18:00Z`  | `7.887` | `2015-08-18T00:12:00Z` |

第一个预设的12分钟时间边界从`00:00`开始，刚好在`12:00`前结束。只有一个数据点（`8.005`），同时落在查询的第一个`GROUP BY time()`时间间隔和第一个时间边界内。请注意，虽然返回的时间戳发生在查询的时间范围开始之前，但是查询结果排除了在查询时间范围之前发生的数据。

第二个预设的12分钟时间边界从`12:00`开始，刚好在`24:00`前结束。只有一个数据点（`7.887`），同时落在查询的第二个`GROUP BY time()`时间间隔和第二个时间边界内。

[高级`GROUP BY time()`语法](#advanced-group-by-time-syntax)允许用户修改 InfluxDB的预设时间边界的开始时间。在高级语法章节中的[示例](#examples-3)将继续这里展示的查询，它将预设的时间边界向前偏移6分钟，以便InfluxDB返回：

```sql
name: h2o_feet
time                   count
----                   -----
2015-08-18T00:06:00Z   2
```

### 高级GROUP BY time()语法

#### 语法

```sql
SELECT <function>(<field_key>) FROM_clause WHERE <time_range> GROUP BY time(<time_interval>,<offset_interval>),[tag_key] [fill(<fill_option>)]
```

高级`GROUP BY time()`语法查询需要在[`SELECT`子句](#the-basic-select-statement)中包含一个InfluxQL[函数](/influxdb/v1.8/query_language/functions/)，并且在[`WHERE`子句](#the-where-clause)中包含时间范围。请注意，`GROUP BY`子句必须放在`WHERE`子句后面。

##### `time(time_interval,offset_interval)`

关于`time_interval`的详情，请查看[基本GROUP BY time()语法](#basic-group-by-time-syntax)。

`offset_interval`（偏移间隔）是一个持续时间（duration），TSDB For InfluxDB的预设时间边界向前或向后偏移。`offset_interval`可以是正数或者负数。

##### `fill(<fill_option>)`

`fill(<fill_option>)`是可选的，它会改变不含数据的时间间隔的返回值。了解更多请参阅[按时间间隔分组和回填数据](#group-by-time-intervals-and-fill)

**覆盖范围：**

高级`GROUP BY time()`查询依赖`time_interval`、`offset_interval`和InfluxDB的预设时间边界来确定每个时间间隔内的原始数据和查询返回的时间戳。

#### 高级语法示例

下面的示例将使用如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:54:00Z'

name: h2o_feet
--------------
time                   water_level
2015-08-18T00:00:00Z   8.12
2015-08-18T00:06:00Z   8.005
2015-08-18T00:12:00Z   7.887
2015-08-18T00:18:00Z   7.762
2015-08-18T00:24:00Z   7.635
2015-08-18T00:30:00Z   7.5
2015-08-18T00:36:00Z   7.372
2015-08-18T00:42:00Z   7.234
2015-08-18T00:48:00Z   7.11
2015-08-18T00:54:00Z   6.982
```

##### 将查询结果按18分钟的时间间隔进行分组并将预设时间边界向前偏移

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-08-18T00:06:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(18m,6m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:06:00Z   7.884666666666667
2015-08-18T00:24:00Z   7.502333333333333
2015-08-18T00:42:00Z   7.108666666666667
```

该查询使用了InfluxQL中的一个[函数](/influxdb/v1.8/query_language/functions/)计算`water_level`的平均值，将结果按18分钟的时间间隔进行分组，并将预设时间边界向前偏移6分钟。

对于**没有**`offset_interval`的查询，时间边界和返回的时间戳依旧沿用TSDB For InfluxDB®预设的时间边界。我们先来看看没有`offset_interval`的查询结果：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-08-18T00:06:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(18m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   7.946
2015-08-18T00:18:00Z   7.6323333333333325
2015-08-18T00:36:00Z   7.238666666666667
2015-08-18T00:54:00Z   6.982
```

对于**没有**`offset_interval`的查询，时间边界和返回的时间戳依旧沿用InfluxDB预设的时间边界：

| 时间间隔序号 | 预设的时间边界 |`GROUP BY time()`时间间隔 | 包含的数据点 | 返回的时间戳 |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| 1  | `time >= 2015-08-18T00:00:00Z AND time < 2015-08-18T00:18:00Z` | `time >= 2015-08-18T00:06:00Z AND time < 2015-08-18T00:18:00Z` | `8.005`,`7.887` | `2015-08-18T00:00:00Z` |
| 2  | `time >= 2015-08-18T00:18:00Z AND time < 2015-08-18T00:36:00Z` | <--- same | `7.762`,`7.635`,`7.5` | `2015-08-18T00:18:00Z` |
| 3  | `time >= 2015-08-18T00:36:00Z AND time < 2015-08-18T00:54:00Z` | <--- same | `7.372`,`7.234`,`7.11` | `2015-08-18T00:36:00Z` |
| 4  | `time >= 2015-08-18T00:54:00Z AND time < 2015-08-18T01:12:00Z` | `time = 2015-08-18T00:54:00Z` | `6.982` | `2015-08-18T00:54:00Z` |

第一个预设的18分钟时间边界从`00:00`开始，刚好在`18:00`前结束。有两个数据点（`8.005`和`7.887`），同时落在查询的第一个`GROUP BY time()`时间间隔和第一个时间边界内。请注意，虽然返回的时间戳发生在查询的时间范围开始之前，但是查询结果排除了在查询时间范围之前发生的数据。

第二个预设的18分钟时间边界从`18:00`开始，刚好在`36:00`前结束。有三个数据点（`7.762`，`7.635`和`7.5`），同时落在查询的第二个`GROUP BY time()`时间间隔和第二个时间边界内。在这种情况下，边界时间范围和间隔时间范围是相同的。

第四个预设的18分钟时间边界从`54:00`开始，刚好在`01:12:00`前结束。只有一个数据点（`6.982`），同时落在查询的第四个`GROUP BY time()`时间间隔和第四个时间边界内。

对于**有**`offset_interval`的查询，时间边界和返回的时间戳符合指定的偏移时间边界：

| 时间间隔序号 | 预设的时间边界 |`GROUP BY time()`时间间隔 | 包含的数据点 | 返回的时间戳 |
| :------------- | :------------- | :------------- | :------------- | ------------- |
| 1  | `time >= 2015-08-18T00:06:00Z AND time < 2015-08-18T00:24:00Z` | <--- same | `8.005`,`7.887`,`7.762` | `2015-08-18T00:06:00Z` |
| 2  | `time >= 2015-08-18T00:24:00Z AND time < 2015-08-18T00:42:00Z` | <--- same | `7.635`,`7.5`,`7.372` | `2015-08-18T00:24:00Z` |
| 3  | `time >= 2015-08-18T00:42:00Z AND time < 2015-08-18T01:00:00Z` | <--- same | `7.234`,`7.11`,`6.982` | `2015-08-18T00:42:00Z` |
| 4  | `time >= 2015-08-18T01:00:00Z AND time < 2015-08-18T01:18:00Z` | NA | NA | NA |

这个6分钟的偏移间隔将预设边界的时间范围向前偏移6分钟，使得边界的时间范围跟相关的`GROUP BY time()`间隔的时间范围始终相同。使用偏移间隔，每个时间间隔对三个数据点进行计算，并且返回的时间戳与边界时间范围的开始和`GROUP BY time()`时间范围的开始都相匹配。

请注意，`offset_interval`强制使第四个时间边界超过该查询的时间范围，因此，该查询不会返回最后一个时间间隔的数据。

##### 将查询结果按18分钟的时间间隔进行分组并将预设时间边界向后偏移

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-08-18T00:06:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(18m,-12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:06:00Z   7.884666666666667
2015-08-18T00:24:00Z   7.502333333333333
2015-08-18T00:42:00Z   7.108666666666667
```

该查询使用了InfluxQL中的一个[函数](/influxdb/v1.8/query_language/functions/)计算`water_level`的平均值，将结果按18分钟的时间间隔进行分组，并将预设时间边界向后偏移12分钟。

> **注意：**：该示例与前面第一个例子（将查询结果按18分钟的时间间隔进行分组并将预设时间边界向前偏移）的查询结果相同，但是，在该示例中，使用了一个负数的`offset_interval`，而在前面的示例中`offset_interval`是一个正数。这两个查询之间没有性能差异。在选择没有正负`offset_interval`时，请选择最直观的数值。

对于**没有**`offset_interval`的查询，时间边界和返回的时间戳依旧沿用TSDB For InfluxDB®预设的时间边界。我们先来看看没有`offset_interval`的查询结果：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-08-18T00:06:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(18m)

name: h2o_feet
time                    mean
----                    ----
2015-08-18T00:00:00Z    7.946
2015-08-18T00:18:00Z    7.6323333333333325
2015-08-18T00:36:00Z    7.238666666666667
2015-08-18T00:54:00Z    6.982
```

对于**没有**`offset_interval`的查询，时间边界和返回的时间戳依旧沿用InfluxDB预设的时间边界：

| 时间间隔序号 | 预设的时间边界 |`GROUP BY time()`时间间隔 | 包含的数据点           | 返回的时间戳 |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| 1  | `time >= 2015-08-18T00:00:00Z AND time < 2015-08-18T00:18:00Z` | `time >= 2015-08-18T00:06:00Z AND time < 2015-08-18T00:18:00Z` | `8.005`,`7.887` | `2015-08-18T00:00:00Z` |
| 2  | `time >= 2015-08-18T00:18:00Z AND time < 2015-08-18T00:36:00Z` | <--- same | `7.762`,`7.635`,`7.5` | `2015-08-18T00:18:00Z` |
| 3  | `time >= 2015-08-18T00:36:00Z AND time < 2015-08-18T00:54:00Z` | <--- same | `7.372`,`7.234`,`7.11` | `2015-08-18T00:36:00Z` |
| 4  | `time >= 2015-08-18T00:54:00Z AND time < 2015-08-18T01:12:00Z` | `time = 2015-08-18T00:54:00Z` | `6.982` | `2015-08-18T00:54:00Z` |

第一个预设的18分钟时间边界从`00:00`开始，刚好在`18:00`前结束。有两个数据点（`8.005`和`7.887`），同时落在查询的第一个`GROUP BY time()`时间间隔和第一个时间边界内。请注意，虽然返回的时间戳发生在查询的时间范围开始之前，但是查询结果排除了在查询时间范围之前发生的数据。

第二个预设的18分钟时间边界从`18:00`开始，刚好在`36:00`前结束。有三个数据点（`7.762`，`7.635`和`7.5`），同时落在查询的第二个`GROUP BY time()`时间间隔和第二个时间边界内。在这种情况下，边界时间范围和间隔时间范围是相同的。

第四个预设的18分钟时间边界从`54:00`开始，刚好在`01:12:00`前结束。只有一个数据点（`6.982`），同时落在查询的第四个`GROUP BY time()`时间间隔和第四个时间边界内。

对于**有**`offset_interval`的查询，时间边界和返回的时间戳符合指定的偏移时间边界：

| 时间间隔序号 | 预设的时间边界                                               |`GROUP BY time()` 时间间隔 | 包含的数据点            | 返回的时间戳 |
| :------------- | :------------- | :------------- | :------------- | ------------- |
| 1  | `time >= 2015-08-17T23:48:00Z AND time < 2015-08-18T00:06:00Z` | NA | NA | NA |
| 2  | `time >= 2015-08-18T00:06:00Z AND time < 2015-08-18T00:24:00Z` | <--- same | `8.005`,`7.887`,`7.762` | `2015-08-18T00:06:00Z` |
| 3  | `time >= 2015-08-18T00:24:00Z AND time < 2015-08-18T00:42:00Z` | <--- same | `7.635`,`7.5`,`7.372` | `2015-08-18T00:24:00Z` |
| 4  | `time >= 2015-08-18T00:42:00Z AND time < 2015-08-18T01:00:00Z` | <--- same | `7.234`,`7.11`,`6.982` | `2015-08-18T00:42:00Z` |

这个负12分钟的偏移间隔将预设边界的时间范围向后偏移12分钟，使得边界的时间范围跟相关的`GROUP BY time()`间隔的时间范围始终相同。使用偏移间隔，每个时间间隔对三个数据点进行计算，并且返回的时间戳与边界时间范围的开始和`GROUP BY time()`时间范围的开始都相匹配。

请注意，`offset_interval`强制使第一个时间边界超过该查询的时间范围，因此，该查询不会返回第一个时间间隔的数据。

##### 将查询结果按12分钟的时间间隔进行分组并将预设时间边界向前偏移

这个例子是[基本语法常见问题](#common-issues-with-basic-syntax)章节中示例的延续。

```sql
> SELECT COUNT("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-08-18T00:06:00Z' AND time < '2015-08-18T00:18:00Z' GROUP BY time(12m,6m)

name: h2o_feet
time                   count
----                   -----
2015-08-18T00:06:00Z   2
```

该查询使用了InfluxQL中的一个[函数](/influxdb/v1.8/query_language/functions/)计算`water_level`的数据点数，将结果按12分钟的时间间隔进行分组，并将预设时间边界向前偏移6分钟。

对于**没有**`offset_interval`的查询，时间边界和返回的时间戳依旧沿用TSDB For InfluxDB®预设的时间边界。我们先来看看没有`offset_interval`的查询结果：

```sql
> SELECT COUNT("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-08-18T00:06:00Z' AND time < '2015-08-18T00:18:00Z' GROUP BY time(12m)

name: h2o_feet
time                   count
----                   -----
2015-08-18T00:00:00Z   1
2015-08-18T00:12:00Z   1
```

对于**没有**`offset_interval`的查询，时间边界和返回的时间戳依旧沿用InfluxDB预设的时间边界：

| 时间间隔序号 | 预设的时间边界 |`GROUP BY time()`时间间隔 | 包含的数据点 | 返回的时间戳 |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| 1  | `time >= 2015-08-18T00:00:00Z AND time < 2015-08-18T00:12:00Z` | `time >= 2015-08-18T00:06:00Z AND time < 2015-08-18T00:12:00Z` | `8.005` | `2015-08-18T00:00:00Z` |
| 2  | `time >= 2015-08-12T00:12:00Z AND time < 2015-08-18T00:24:00Z` | `time >= 2015-08-12T00:12:00Z AND time < 2015-08-18T00:18:00Z`  | `7.887` | `2015-08-18T00:12:00Z` |

第一个预设的12分钟时间边界从`00:00`开始，刚好在`12:00`前结束。只有一个数据点（`8.005`），同时落在查询的第一个`GROUP BY time()`时间间隔和第一个时间边界内。请注意，虽然返回的时间戳发生在查询的时间范围开始之前，但是查询结果排除了在查询时间范围之前发生的数据。

第二个预设的12分钟时间边界从`12:00`开始，刚好在`24:00`前结束。只有一个数据点（`7.887`），同时落在查询的第二个`GROUP BY time()`时间间隔和第二个时间边界内。

对于**有**`offset_interval`的查询，时间边界和返回的时间戳符合指定的偏移时间边界：

| 时间间隔序号 | 预设的时间边界 |`GROUP BY time()`时间间隔 | 包含的数据点 | 返回的时间戳 |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| 1  | `time >= 2015-08-18T00:06:00Z AND time < 2015-08-18T00:18:00Z` | <--- same | `8.005`,`7.887` | `2015-08-18T00:06:00Z` |
| 2  | `time >= 2015-08-18T00:18:00Z AND time < 2015-08-18T00:30:00Z` | NA | NA | NA |

这个6分钟的偏移间隔将预设边界的时间范围向前偏移6分钟，使得边界的时间范围跟相关的`GROUP BY time()`间隔的时间范围始终相同。

使用偏移间隔，该查询返回一个结果，并且返回的时间戳与边界时间范围的开始和`GROUP BY time()`时间范围的开始都相匹配。

请注意，`offset_interval`强制使第二个时间边界超过该查询的时间范围，因此，该查询不会返回第二个时间间隔的数据。

## `GROUP BY time()` 时间间隔和数据回填 `fill()`

`fill()`(回填函数)改变不包含数据的时间间隔的返回值。

#### 语法

```sql
SELECT <function>(<field_key>) FROM_clause WHERE <time_range> GROUP BY time(time_interval,[<offset_interval])[,tag_key] [fill(<fill_option>)]
```

对于不包含数据的`GROUP BY time()`时间间隔，默认将`null`作为它在输出列中的返回值。如果想要改变不包含数据的时间间隔的返回值，可以使用`fill()`。

请注意，如果您`GROUP BY`多个对象（例如，[tags](/influxdb/v1.8/concepts/glossary/#tag) 和时间间隔），那么`fill()`必须放在GROUP BY子句后面。

##### fill_option

- 任意数值：对于没有数据点的时间间隔，返回这个给定的数值
- `linear`：对于没有数据点的时间间隔，返回[线性插值](https://en.wikipedia.org/wiki/Linear_interpolation)的结果
- `none`：对于没有数据点的时间间隔，不返回任何时间戳和值
- `null`：对于没有数据点的时间间隔，返回时间戳，并且返回`null`作为该时间戳所对应的值，这跟默认的情况相同
- `previous`：对于没有数据点的时间间隔，返回前一个时间间隔的值

#### 示例

{{< tabs-wrapper >}}
{{% tabs %}}
[示例 1: fill(100)](#)
[示例 2: fill(linear)](#)
[示例 3: fill(none)](#)
[示例 4: fill(null)](#)
[示例 5: fill(previous)](#)
{{% /tabs %}}
{{% tab-content %}}

Without `fill(100)`:

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-09-18T16:00:00Z' AND time <= '2015-09-18T16:42:00Z' GROUP BY time(12m)

name: h2o_feet
--------------
time                   max
2015-09-18T16:00:00Z   3.599
2015-09-18T16:12:00Z   3.402
2015-09-18T16:24:00Z   3.235
2015-09-18T16:36:00Z
```

With `fill(100)`:

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-09-18T16:00:00Z' AND time <= '2015-09-18T16:42:00Z' GROUP BY time(12m) fill(100)

name: h2o_feet
--------------
time                   max
2015-09-18T16:00:00Z   3.599
2015-09-18T16:12:00Z   3.402
2015-09-18T16:24:00Z   3.235
2015-09-18T16:36:00Z   100
```

`fill(100)` changes the value reported for the time interval with no data to `100`.

{{% /tab-content %}}

{{% tab-content %}}

Without `fill(linear)`:

```sql
> SELECT MEAN("tadpoles") FROM "pond" WHERE time >= '2016-11-11T21:00:00Z' AND time <= '2016-11-11T22:06:00Z' GROUP BY time(12m)

name: pond
time                   mean
----                   ----
2016-11-11T21:00:00Z   1
2016-11-11T21:12:00Z
2016-11-11T21:24:00Z   3
2016-11-11T21:36:00Z
2016-11-11T21:48:00Z
2016-11-11T22:00:00Z   6
```

With `fill(linear)`:

```sql
> SELECT MEAN("tadpoles") FROM "pond" WHERE time >= '2016-11-11T21:00:00Z' AND time <= '2016-11-11T22:06:00Z' GROUP BY time(12m) fill(linear)

name: pond
time                   mean
----                   ----
2016-11-11T21:00:00Z   1
2016-11-11T21:12:00Z   2
2016-11-11T21:24:00Z   3
2016-11-11T21:36:00Z   4
2016-11-11T21:48:00Z   5
2016-11-11T22:00:00Z   6
```

`fill(linear)`将没有数据点的时间间隔的返回值更改为[线性插值](https://en.wikipedia.org/wiki/Linear_interpolation)的结果

> **注意：**：示例二中的数据并不在数据库`NOAA_water_database`中。为了可以使用`fill(linear)`，我们创建了一个有更少常规数据的数据集。

{{% /tab-content %}}

{{% tab-content %}}

Without `fill(none)`:

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-09-18T16:00:00Z' AND time <= '2015-09-18T16:42:00Z' GROUP BY time(12m)

name: h2o_feet
--------------
time                   max
2015-09-18T16:00:00Z   3.599
2015-09-18T16:12:00Z   3.402
2015-09-18T16:24:00Z   3.235
2015-09-18T16:36:00Z
```

With `fill(none)`:

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-09-18T16:00:00Z' AND time <= '2015-09-18T16:42:00Z' GROUP BY time(12m) fill(none)

name: h2o_feet
--------------
time                   max
2015-09-18T16:00:00Z   3.599
2015-09-18T16:12:00Z   3.402
2015-09-18T16:24:00Z   3.235
```

`fill(none)` reports no value and no timestamp for the time interval with no data.

{{% /tab-content %}}

{{% tab-content %}}

Without `fill(null)`:

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-09-18T16:00:00Z' AND time <= '2015-09-18T16:42:00Z' GROUP BY time(12m)

name: h2o_feet
--------------
time                   max
2015-09-18T16:00:00Z   3.599
2015-09-18T16:12:00Z   3.402
2015-09-18T16:24:00Z   3.235
2015-09-18T16:36:00Z
```

With `fill(null)`:

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-09-18T16:00:00Z' AND time <= '2015-09-18T16:42:00Z' GROUP BY time(12m) fill(null)

name: h2o_feet
--------------
time                   max
2015-09-18T16:00:00Z   3.599
2015-09-18T16:12:00Z   3.402
2015-09-18T16:24:00Z   3.235
2015-09-18T16:36:00Z
```

`fill(null)`对于没有数据点的时间间隔，返回`null`作为它的值。使用`fill(null)`的查询结果跟没有使用`fill(null)`的结果一样。

{{% /tab-content %}}

{{% tab-content %}}

Without `fill(previous)`:

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-09-18T16:00:00Z' AND time <= '2015-09-18T16:42:00Z' GROUP BY time(12m)

name: h2o_feet
--------------
time                   max
2015-09-18T16:00:00Z   3.599
2015-09-18T16:12:00Z   3.402
2015-09-18T16:24:00Z   3.235
2015-09-18T16:36:00Z
```

With `fill(previous)`:

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE "location"='coyote_creek' AND time >= '2015-09-18T16:00:00Z' AND time <= '2015-09-18T16:42:00Z' GROUP BY time(12m) fill(previous)

name: h2o_feet
--------------
time                   max
2015-09-18T16:00:00Z   3.599
2015-09-18T16:12:00Z   3.402
2015-09-18T16:24:00Z   3.235
2015-09-18T16:36:00Z   3.235
```

`fill(previous)` changes the value reported for the time interval with no data to `3.235`,
the value from the previous time interval.

{{% /tab-content %}}
{{< /tabs-wrapper >}}

#### `fill()`常见问题

##### 在查询时间范围内没有数据的情况下使用`fill()`

目前，如果在查询的时间范围内没有数据，那么查询会忽略`fill()`。这是符合预期的结果。

**示例**

以下查询不会返回任何数据，因为`water_level`在查询的时间范围内没有任何数据点。请注意，`fill(800)`对以下查询结果无影响。

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location" = 'coyote_creek' AND time >= '2015-09-18T22:00:00Z' AND time <= '2015-09-18T22:18:00Z' GROUP BY time(12m) fill(800)
>
```

##### 在前一个结果不在查询时间范围内的情况下使用`fill(previous)`

如果前一个时间间隔超出查询的时间范围，那么`fill(previous)`不会填充该时间间隔所对应的值。

**示例**

以下查询覆盖的时间范围是从`2015-09-18T16:24:00Z`到`2015-09-18T16:54:00Z`。请注意，`fill(previous)`**使用**`2015-09-18T16:24:00Z`的结果来填充`2015-09-18T16:36:00Z`对应的值。

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE location = 'coyote_creek' AND time >= '2015-09-18T16:24:00Z' AND time <= '2015-09-18T16:54:00Z' GROUP BY time(12m) fill(previous)

name: h2o_feet
--------------
time                   max
2015-09-18T16:24:00Z   3.235
2015-09-18T16:36:00Z   3.235
2015-09-18T16:48:00Z   4
```

下一个查询将缩短以上查询的时间范围，现在，查询覆盖的时间范围变为从`2015-09-18T16:36:00Z`到`2015-09-18T16:54:00Z`。请注意，`fill(previous)`**不会使用**`2015-09-18T16:24:00Z`的结果来填充`2015-09-18T16:36:00Z`对应的值，因为`2015-09-18T16:24:00Z`不在查询较短的时间范围内。

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE location = 'coyote_creek' AND time >= '2015-09-18T16:36:00Z' AND time <= '2015-09-18T16:54:00Z' GROUP BY time(12m) fill(previous)

name: h2o_feet
--------------
time                   max
2015-09-18T16:36:00Z
2015-09-18T16:48:00Z   4
```

##### 在前一个或后一个结果不在查询时间范围内的情况下使用`fill(linear)`

如果前一个或后一个时间间隔超出查询的时间范围，那么`fill(linear)`不会填充(fill)该时间间隔所对应的值。

**示例**

以下查询覆盖的时间范围是从`2016-11-11T21:24:00Z`到`2016-11-11T22:06:00Z`。请注意，`fill(linear)`**使用**`2016-11-11T21:24:00Z`和`2016-11-11T22:00:00Z`这两个时间间隔的值来填充`2016-11-11T21:36:00Z`和`2016-11-11T21:48:00Z`分别所对应的值。

```sql
> SELECT MEAN("tadpoles") FROM "pond" WHERE time > '2016-11-11T21:24:00Z' AND time <= '2016-11-11T22:06:00Z' GROUP BY time(12m) fill(linear)

name: pond
time                   mean
----                   ----
2016-11-11T21:24:00Z   3
2016-11-11T21:36:00Z   4
2016-11-11T21:48:00Z   5
2016-11-11T22:00:00Z   6
```

下一个查询将缩短以上查询的时间范围，现在，查询覆盖的时间范围变为从`2016-11-11T21:36:00Z`到`2016-11-11T22:06:00Z`。请注意，`fill(linear)`**不会**填充`2016-11-11T21:36:00Z`和`2016-11-11T21:48:00Z`所对应的值，因为`2016-11-11T21:24:00Z`不在查询较短的时间范围内，InfluxDB无法进行线性插值计算。

```sql
> SELECT MEAN("tadpoles") FROM "pond" WHERE time >= '2016-11-11T21:36:00Z' AND time <= '2016-11-11T22:06:00Z' GROUP BY time(12m) fill(linear)
name: pond
time                   mean
----                   ----
2016-11-11T21:36:00Z
2016-11-11T21:48:00Z
2016-11-11T22:00:00Z   6
```

> **注释**：以上示例数据并不在数据库*`NOAA_water_database`*中。为了可以使用*`fill(linear)`*，我们创建了一个有更少常规数据的数据集。

# INTO子句

`INTO`子句将查询结果写入到用户指定的[measurement](/influxdb/v1.8/concepts/glossary/#measurement)中。

### 语法

```sql
SELECT_clause INTO <measurement_name> FROM_clause [WHERE_clause] [GROUP_BY_clause]
```

`INTO`子句支持多种指定[measurement](/influxdb/v1.8/concepts/glossary/#measurement)的格式：

**`INTO <measurement_name>`**

将数据写入到一个指定的measurement。如果您使用[CLI](/influxdb/v1.8/tools/shell/)写入数据，那么写入数据的measurement属于指定的[数据库](/influxdb/v1.8/concepts/glossary/#database)，并且使用的是默认（`DEFAULT`）的[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)。如果您使用的是[InfluxDB API](/influxdb/v1.8/tools/api/)，那么写入数据的measurement属于参数`db`指定的数据库，同样，使用的是默认（`DEFAULT`）的[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)。



**`INTO <database_name>.<retention_policy_name>.<measurement_name>`**
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
将数据写入到一个完全限定的measurement。通过明确指定measurement的数据库和保留策略来完全限定一个measurement。

**`INTO <database_name>..<measurement_name>`**
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
将数据写入到一个measurement，这个measurement属于一个用户指定的数据库并使用默认保留策略。

**`INTO <database_name>.<retention_policy_name>.:MEASUREMENT FROM /<regular_expression>/`**

将数据写入到与`FROM`子句中[正则表达式](#regular-expressions)相匹配的所有在用户指定的数据库和保留策略中的measurement。`:MEASUREMENT`是`FROM`子句中每个匹配的measurement的反向引用（backreference）。

### 示例

#### 重命名数据库

```sql
> SELECT * INTO "copy_NOAA_water_database"."autogen".:MEASUREMENT FROM "NOAA_water_database"."autogen"./.*/ GROUP BY *

name: result
time written
---- -------
0    76290
```

在InfluxDB中不能直接重命名数据库，所以`INTO`子句的一个常见用例是将数据从一个数据库移动到另外一个数据库。以上查询将数据库`NOAA_water_database`的保留策略`autogen`中的所有数据写入到数据库`copy_NOAA_water_database`的保留策略`autogen`中。

[反向应用](#examples-5)语法（`:MEASUREMENT`）将源数据库中measurement的名字维持在目标数据库中不变。请注意，在执行`INTO`查询之前，数据库`NOAA_water_database`及其保留策略`autogen`都必须已经存在。有关如何管理数据库和保留策略，请查看[数据库管理](/influxdb/v1.8/query_language/manage-database/)章节。

`GROUP BY *`子句将源数据库中的tag保留在目标数据库中。以下查询并不为tag维护序列的上下文，tag将作为field保存在目标数据库（`copy_NOAA_water_database`）中：

```sql
SELECT * INTO "copy_NOAA_water_database"."autogen".:MEASUREMENT FROM "NOAA_water_database"."autogen"./.*/
```

当移动大量数据时，我们建议按顺序对不同的measurement运行`INTO`查询，并且使用[`WHERE`子句](#time-syntax)中的时间边界。这样可以防止系统内存不足。下面的代码块提供了这类查询的示例语法：

```
SELECT *
INTO <destination_database>.<retention_policy_name>.<measurement_name>
FROM <source_database>.<retention_policy_name>.<measurement_name>
WHERE time > now() - 100w AND time < now() - 90w GROUP BY *

SELECT *
INTO <destination_database>.<retention_policy_name>.<measurement_name>
FROM <source_database>.<retention_policy_name>.<measurement_name>}
WHERE time > now() - 90w AND < now() - 80w GROUP BY *

SELECT *
INTO <destination_database>.<retention_policy_name>.<measurement_name>
FROM <source_database>.<retention_policy_name>.<measurement_name>
WHERE time > now() - 80w AND time < now() - 70w GROUP BY *
```

#### 将查询结果写入measurement

```sql
> SELECT "water_level" INTO "h2o_feet_copy_1" FROM "h2o_feet" WHERE "location" = 'coyote_creek'

name: result
------------
time                   written
1970-01-01T00:00:00Z   7604

> SELECT * FROM "h2o_feet_copy_1"

name: h2o_feet_copy_1
---------------------
time                   water_level
2015-08-18T00:00:00Z   8.12
[...]
2015-09-18T16:48:00Z   4
```

该查询将它的结果写入到一个新的[measurement](/influxdb/v1.8/concepts/glossary/#measurement)：`h2o_feet_copy_1`。如果您使用[CLI](/influxdb/v1.8/tools/shell/)写入数据，那么数据会写入到`USE`指定的[数据库](/influxdb/v1.8/concepts/glossary/#database)，并且使用的是默认（`DEFAULT`）的[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)。如果您使用的是[InfluxDB API](/influxdb/v1.8/tools/api/)，那么数据会写入到参数`db`指定的数据库，并且使用参数`rp`指定的保留策略。如果没有设置参数`rp`，HTTP API自动将数据写入到数据库的默认保留策略中。

返回结果显示InfluxDB写入到`h2o_feet_copy_1`中的数据点个数(`7604`)。返回结果中的时间戳是没有意义的，InfluxDB使用`epoch 0`（即`1970-01-01T00:00:00Z`)作为空时间戳。

#### 将查询结果写入完全限定的measurement

```sql
> SELECT "water_level" INTO "where_else"."autogen"."h2o_feet_copy_2" FROM "h2o_feet" WHERE "location" = 'coyote_creek'

name: result
------------
time                   written
1970-01-01T00:00:00Z   7604

> SELECT * FROM "where_else"."autogen"."h2o_feet_copy_2"

name: h2o_feet_copy_2
---------------------
time                   water_level
2015-08-18T00:00:00Z   8.12
[...]
2015-09-18T16:48:00Z   4
```

该查询将它的结果写入到一个新的measurement：`h2o_feet_copy_2`。TSDB For InfluxDB®将数据写入到数据库`where_else`的保留策略`autogen`中。请注意，在执行`INTO`查询前，数据库`where_else`及其保留策略`autogen`都必须已经存在。有关如何管理数据库和保留策略，请查看[数据库管理](/influxdb/v1.8/query_language/manage-database/)章节。

返回结果显示InfluxDB写入到`h2o_feet_copy_2`中的数据点个数（`7604`）。返回结果中的时间戳是没有意义的，InfluxDB使用`epoch 0`（即`1970-01-01T00:00:00Z`）作为空时间戳。

#### 将聚合结果写入measurement（降采样）

```sql
> SELECT MEAN("water_level") INTO "all_my_averages" FROM "h2o_feet" WHERE "location" = 'coyote_creek' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m)

name: result
------------
time                   written
1970-01-01T00:00:00Z   3

> SELECT * FROM "all_my_averages"

name: all_my_averages
---------------------
time                   mean
2015-08-18T00:00:00Z   8.0625
2015-08-18T00:12:00Z   7.8245
2015-08-18T00:24:00Z   7.5675
```

该查询使用了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions)和一个[`GROUP BY time()`子句](#group-by-time-intervals)将数据进行聚合，并且将结果写入到measurement `all_my_averages`。

返回结果显示TSDB For InfluxDB®写入到`all_my_averages`中的数据点个数(`3`)。返回结果中的时间戳是没有意义的，TSDB For InfluxDB®使用`epoch 0`（即`1970-01-01T00:00:00Z`）作为空时间戳。

该查询是降采样（downsampling）的一个示例：获取更高精度的数据并将这些数据聚合到较低精度，然后将较低精度的数据存储到数据库。降采样是`INTO`子句的一个常见用例。

#### 将多个measurement的聚合结果写入一个不同的数据库（使用反向引用进行降采样）

```sql
> SELECT MEAN(*) INTO "where_else"."autogen".:MEASUREMENT FROM /.*/ WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:06:00Z' GROUP BY time(12m)

name: result
time                   written
----                   -------
1970-01-01T00:00:00Z   5

> SELECT * FROM "where_else"."autogen"./.*/

name: average_temperature
time                   mean_degrees   mean_index   mean_pH   mean_water_level
----                   ------------   ----------   -------   ----------------
2015-08-18T00:00:00Z   78.5

name: h2o_feet
time                   mean_degrees   mean_index   mean_pH   mean_water_level
----                   ------------   ----------   -------   ----------------
2015-08-18T00:00:00Z                                         5.07625

name: h2o_pH
time                   mean_degrees   mean_index   mean_pH   mean_water_level
----                   ------------   ----------   -------   ----------------
2015-08-18T00:00:00Z                               6.75

name: h2o_quality
time                   mean_degrees   mean_index   mean_pH   mean_water_level
----                   ------------   ----------   -------   ----------------
2015-08-18T00:00:00Z                  51.75

name: h2o_temperature
time                   mean_degrees   mean_index   mean_pH   mean_water_level
----                   ------------   ----------   -------   ----------------
2015-08-18T00:00:00Z   63.75
```

该查询使用了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions)和一个[`GROUP BY time()`子句](#group-by-time-intervals)将数据进行聚合，它将与`FROM`子句中[正则表达式](#regular-expressions)匹配的所有measurement中的数据进行聚合，并将结果写入到数据库`where_else`和查询策略`autogen`中有相同名字的measurement。请注意，在执行`INTO`查询前，数据库`where_else`及其保留策略`autogen`都必须已经存在。

返回结果显示 InfluxDB写入到数据库`where_else`和查询策略`autogen`中的数据点个数（`5`）。返回结果中的时间戳是没有意义的，InfluxDB使用`epoch 0`（即`1970-01-01T00:00:00Z`）作为空时间戳。

该查询是使用反向引用进行降采样（downsampling with backreferencing）的一个示例：从多个measurement中获取更高精度的数据并将这些数据聚合到较低精度，然后将较低精度的数据存储到数据库。使用反向引用进行降采样是`INTO`子句的一个常见用例。

### `INTO`子句常见问题

#### 数据丢失

如果一个`INTO`查询在[`SELECT`子句](#the-basic-select-statement)中包含[tag key](/influxdb/v1.8/concepts/glossary#tag-key)，那么查询将当前measurement中的tag转换为目标measurement的field，这可能会导致InfluxDB覆盖以前由tag value区分的数据点。请注意，此行为不适用于使用[`TOP()`](/influxdb/v1.8/query_language/functions/#top)或[`BOTTOM()`](/influxdb/v1.8/query_language/functions/#bottom)函数的查询。

为了将当前measurement中的tag保留为目标measurement中的tag，可以在`INTO`查询中加上`GROUP BY`子句：`GROUP BY`相关的tag key或者`GROUP BY *`。

#### 使用`INTO`子句自动查询

本文档中的`INTO`子句章节展示了如何使用`INTO`子句手动实现查询。通过[连续查询（CQ）](/influxdb/v1.8/query_language/continuous_queries/)，可以使`INTO`子句自动查询实时数据。连续查询其中一个用途就是使降采样的过程自动化。

## ORDER BY time DESC

InfluxDB默认按递增的时间顺序返回结果。第一个返回的数据点，其时间戳是最早的，而最后一个返回的[数据点](/influxdb/v1.8/concepts/glossary/#point)，其[时间戳](/influxdb/v1.8/concepts/glossary/#timestamp)是最新的。`ORDER BY time DESC`将默认的时间顺序调转，使得TSDB For InfluxDB®首先返回有最新时间戳的数据点，也就是说，按递减的时间顺序返回结果。

### 语法

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] ORDER BY time DESC
```

如果查询语句中包含[`GROUP BY`子句](#the-group-by-clause)，那么`ORDER BY time DESC`必须放在`GROUP BY`子句后面。如果查询语句中包含[`WHERE`子句](#the-where-clause)并且没有`GROUP BY`子句，那么`ORDER BY time DESC`必须放在`WHERE`子句后面。

### 示例

#### 首先返回最新的点

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica' ORDER BY time DESC

name: h2o_feet
time                   water_level
----                   -----------
2015-09-18T21:42:00Z   4.938
2015-09-18T21:36:00Z   5.066
[...]
2015-08-18T00:06:00Z   2.116
2015-08-18T00:00:00Z   2.064
```

该查询首先从[measurement](/influxdb/v1.8/concepts/glossary/#measurement) `h2o_feet`中返回具有最新时间戳的数据点。如果以上查询语句中没有`ORDER by time DESC`，那么会首先返回时间戳为`2015-08-18T00:00:00Z`的数据点，最后返回时间戳为`2015-09-18T21:42:00Z`的数据点。

#### 首先返回最新的点并且包含`GROUP BY time()`子句

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:42:00Z' GROUP BY time(12m) ORDER BY time DESC

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:36:00Z   4.6825
2015-08-18T00:24:00Z   4.80675
2015-08-18T00:12:00Z   4.950749999999999
2015-08-18T00:00:00Z   5.07625
```

该查询使用了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions)和[`GROUP BY`子句](#group-by-time-intervals)中的时间间隔，计算查询时间范围内每12分钟的`water_level`的平均值。`ORDER BY time DESC`语句使得最新12分钟间隔的结果会首先返回。如果以上查询语句中没有`ORDER by time DESC`，那么会首先返回时间戳为`2015-08-18T00:00:00Z`的数据点，最后返回时间戳为`2015-08-18T00:36:00Z`的数据点。

# LIMIT和SLIMIT子句

`LIMIT`和`SLIMIT`分别限制每个查询返回的[数据点](/influxdb/v1.8/concepts/glossary/#point)个数和[系列](/influxdb/v1.8/concepts/glossary/#series)个数。

## LIMIT子句

`LIMIT <N>` 返回指定[measurement](/influxdb/v1.8/concepts/glossary/#measurement)中的前`N`个[数据点](/influxdb/v1.8/concepts/glossary/#point)。

### 语法

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] LIMIT <N>
```

`N`表示从指定measurement中返回的[数据点](/influxdb/v1.8/concepts/glossary/#point)个数。如果`N`大于[measurement](/influxdb/v1.8/concepts/glossary/#measurement)中所有数据点的个数，InfluxDB将返回该measurement中的所有数据点。

请注意，`LIMIT`子句必须按照上述语法中的顺序使用。

### 示例

#### 限制返回的数据点个数

```sql
> SELECT "water_level","location" FROM "h2o_feet" LIMIT 3

name: h2o_feet
time                   water_level   location
----                   -----------   --------
2015-08-18T00:00:00Z   8.12          coyote_creek
2015-08-18T00:00:00Z   2.064         santa_monica
2015-08-18T00:06:00Z   8.005         coyote_creek
```

该查询从[measurement](/influxdb/v1.8/concepts/glossary/#measurement) `h2o_feet`中返回前三个[数据点](/influxdb/v1.8/concepts/glossary/#point)（由时间戳决定）。

#### 限制返回的数据点个数并且包含GROUP BY子句

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:42:00Z' GROUP BY *,time(12m) LIMIT 2

name: h2o_feet
tags: location=coyote_creek
time                   mean
----                   ----
2015-08-18T00:00:00Z   8.0625
2015-08-18T00:12:00Z   7.8245

name: h2o_feet
tags: location=santa_monica
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
```

该查询使用了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions)和一个[`GROUP BY`子句](#group-by-time-intervals)，计算每个[tag](/influxdb/v1.8/concepts/glossary/#tag)以及查询时间范围内每12分钟的`water_level`的平均值。`LIMIT 2`表示该查询请求的是两个最早的12分钟间隔的平均值（由时间戳决定）。

请注意，如果以上查询语句中没有使用`LIMIT 2`，那么每个[系列](/influxdb/v1.8/concepts/glossary/#series)会返回四个数据点：在查询的时间范围内每隔十二分钟有一个数据点。

## `SLIMIT`子句

`SLIMIT <N>` 返回指定[measurement](/influxdb/v1.8/concepts/glossary/#measurement)的前`N`个[系列](/influxdb/v1.8/concepts/glossary/#series)中的每一个[数据点](/influxdb/v1.8/concepts/glossary/#point)。

### 语法

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] GROUP BY *[,time(<time_interval>)] [ORDER_BY_clause] SLIMIT <N>
```

`N`表示从指定measurement中返回的[系列](/influxdb/v1.8/concepts/glossary/#series)个数。如果`N`大于measurement中所有系列的个数，InfluxDB将返回该[measurement](/influxdb/v1.8/concepts/glossary/#measurement)中的所有系列列。请注意，`SLIMIT`子句必须按照上述语法中的顺序使用。

### 示例

#### 限制返回的序列个数

```sql
> SELECT "water_level" FROM "h2o_feet" GROUP BY * SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   water_level
----                   -----
2015-08-18T00:00:00Z   8.12
2015-08-18T00:06:00Z   8.005
2015-08-18T00:12:00Z   7.887
[...]
2015-09-18T16:12:00Z   3.402
2015-09-18T16:18:00Z   3.314
2015-09-18T16:24:00Z   3.235
```

该查询从[measurement](/influxdb/v1.8/concepts/glossary/#measurement) `h2o_feet`的一个[系列](/influxdb/v1.8/concepts/glossary/#series)中返回所有`water_level`[数据点](/influxdb/v1.8/concepts/glossary/#point)。

#### 限制返回的序列个数并且包含`GROUP BY time()`子句

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:42:00Z' GROUP BY *,time(12m) SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   mean
----                   ----
2015-08-18T00:00:00Z   8.0625
2015-08-18T00:12:00Z   7.8245
2015-08-18T00:24:00Z   7.5675
2015-08-18T00:36:00Z   7.303
```

该查询使用了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions)和[`GROUP BY`子句](#group-by-time-intervals)中的时间间隔，计算查询时间范围内每12分钟的`water_level`的平均值。`SLIMIT 1`表示该查询请求的是measurement `h2o_feet`中的一个序列。

请注意，如果以上查询语句中没有使用`SLIMIT 1`，那么查询将返回measurement `h2o_feet`中的两个序列：`location=coyote_creek`和`location=santa_monica`。

## LIMIT和SLIMIT

将`SLIMIT <N>`放在`LIMIT <N>`的后面，则返回指定measurement的`N`个[系列](/influxdb/v1.8/concepts/glossary/#series)中的前`N`个[数据点](/influxdb/v1.8/concepts/glossary/#point)。

### 语法

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] GROUP BY *[,time(<time_interval>)] [ORDER_BY_clause] LIMIT <N1> SLIMIT <N2>
```

`N1`表示从measurement中返回的[数据点](/influxdb/v1.8/concepts/glossary/#point)个数。如果`N1`大于[measurement](/influxdb/v1.8/concepts/glossary/#measurement)中所有数据点的个数，InfluxDB将返回该[measurement](/influxdb/v1.8/concepts/glossary/#measurement)中的所有数据点。

`N2`表示从指定measurement中返回的系列个数。如果`N2`大于measurement中所有系列的个数，InfluxDB将返回该measurement中的所有系列。

请注意，`LIMIT`和`SLIMIT`子句必须按照上述语法中的顺序使用。

### 示例

#### 限制返回的数据点个数和序列个数

```sql
> SELECT "water_level" FROM "h2o_feet" GROUP BY * LIMIT 3 SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   8.12
2015-08-18T00:06:00Z   8.005
2015-08-18T00:12:00Z   7.887
```

该查询从[measurement](/influxdb/v1.8/concepts/glossary/#measurement) `h2o_feet`的一个[系列](/influxdb/v1.8/concepts/glossary/#series)中返回三个最早的[数据点](/influxdb/v1.8/concepts/glossary/#point)。

#### 限制返回的数据点个数和序列个数，并且包含`GROUP BY time()`子句

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:42:00Z' GROUP BY *,time(12m) LIMIT 2 SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   mean
----                   ----
2015-08-18T00:00:00Z   8.0625
2015-08-18T00:12:00Z   7.8245
```

该查询使用了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions)和[`GROUP BY`子句](#group-by-time-intervals)中的时间间隔，计算查询时间范围内每12分钟的`water_level`的平均值。`LIMIT 2`请求两个最早的12分钟间隔的平均值（由时间戳决定），`SLIMIT 1`请求measurement `h2o_feet`中的一个序列。

**注意：**如果以上查询语句中没有使用`LIMIT 2 SLIMIT 1`，那么查询将返回measurement `h2o_feet`中的两个序列，并且，每个序列返回四个数据点。

## OFFSET及SOFFSET子句

`OFFSET`和`SOFFSET`分别标记[数据点](/influxdb/v1.8/concepts/glossary/#point)和[系列](/influxdb/v1.8/concepts/glossary/#series)返回的位置。

<table style="width:100%">
  <tr>
    <td><a href="#the-offset-clause">OFFSET子句</a></td>
    <td><a href="#the-soffset-clause">SOFFSET子句</a></td>
  </tr>
</table>


## `OFFSET`子句

`OFFSET <N>`表示从查询结果中的第`N`个[数据点](/influxdb/v1.8/concepts/glossary/#point)开始返回。

### 语法

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] LIMIT_clause OFFSET <N> [SLIMIT_clause]
```

`N`表示从第`N`个[数据点](/influxdb/v1.8/concepts/glossary/#point)开始返回。使用`OFFSET`子句需要先使用[`LIMIT`子句](#the-limit-clause)，在没有`LIMIT`子句的情况下使用`OFFSET`子句，可能会导致出现[不一致的查询结果](https://github.com/influxdata/influxdb/issues/7577)。

> **注意：**：如果*`WHERE`*子句包含时间范围，InfluxDB将不会返回任何结果，*`OFFSET`*子句可能会导致InfluxDB返回时间戳不在该时间范围内的数据点。

### 示例

#### 标记数据点返回的位置

```sql
> SELECT "water_level","location" FROM "h2o_feet" LIMIT 3 OFFSET 3

name: h2o_feet
time                   water_level   location
----                   -----------   --------
2015-08-18T00:06:00Z   2.116         santa_monica
2015-08-18T00:12:00Z   7.887         coyote_creek
2015-08-18T00:12:00Z   2.028         santa_monica
```

该查询从[measurement](/influxdb/v1.8/concepts/glossary/#measurement) `h2o_feet`中返回第四、第五和第六个[数据点](/influxdb/v1.8/concepts/glossary/#point)。如果以上查询语句中没有使用`OFFSET 3`，那么查询将返回该measurement的第一、第二和第三个数据点。

#### 标记数据点返回的位置并且包含多个子句

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:42:00Z' GROUP BY *,time(12m) ORDER BY time DESC LIMIT 2 OFFSET 2 SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   mean
----                   ----
2015-08-18T00:12:00Z   7.8245
2015-08-18T00:00:00Z   8.0625
```

这个例子非常复杂，所以我们逐个子句来分析：

- [`SELECT`子句](#the-basic-select-statement)指定了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions)；
- [`FROM`子句](#the-basic-select-statement)指定了measurement；
- [`WHERE`子句](#the-where-clause)指定了查询的时间范围；
- [`GROUP BY`子句](#the-group-by-clause)将查询结果按所有tag（`*`）和12分钟的时间间隔进行分组；
- [`ORDER BY time DESC`子句](#order-by-time-desc)按递减的时间顺序返回结果；
- [`LIMIT 2`子句](#the-limit-clause)将返回的数据点个数限制为2；
- `OFFSET 2`子句使查询结果的前两个平均值不返回；
- [`SLIMIT 1`子句](#the-slimit-clause)将返回的序列个数限制为1。

如果以上查询语句中没有使用`OFFSET 2`，那么查询将返回结果中的前两个平均值：

```sql
name: h2o_feet
tags: location=coyote_creek
time                   mean
----                   ----
2015-08-18T00:36:00Z   7.303
2015-08-18T00:24:00Z   7.5675
```

## `SOFFSET`子句

`SOFFSET <N>`表示从查询结果中的第`N`个[系列](/influxdb/v1.8/concepts/glossary/#series)开始返回。

### 语法

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] GROUP BY *[,time(time_interval)] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] SLIMIT_clause SOFFSET <N>
```

`N`表示从第`N`个[系列](/influxdb/v1.8/concepts/glossary/#series)开始返回。使用`SOFFSET`子句需要先使用[`SLIMIT`子句](#the-slimit-clause)，在没有`SLIMIT`子句的情况下使用`SOFFSET`子句，可能会导致出现[不一致的查询结果](https://github.com/influxdata/influxdb/issues/7578)。

> **Note:** InfluxDB returns no results if the `SOFFSET` clause paginates
> through more than the total number of series.
>
> **注意：**：如果*`N`*大于系列的个数，InfluxDB将不会返回任何结果。

### 示例

#### 标记系列返回的位置

```sql
> SELECT "water_level" FROM "h2o_feet" GROUP BY * SLIMIT 1 SOFFSET 1

name: h2o_feet
tags: location=santa_monica
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
[...]
2015-09-18T21:36:00Z   5.066
2015-09-18T21:42:00Z   4.938
```

该查询返回[measurement](/influxdb/v1.8/concepts/glossary/#measurement)为`h2o_feet`、[tag](/influxdb/v1.8/concepts/glossary/#tag)为`location = santa_monica`的[系列](/influxdb/v1.8/concepts/glossary/#series)中的数据。如果以上查询语句中没有使用`SOFFSET 1`，那么查询将返回measurement为`h2o_feet`、tag为`location = coyote_creek`的系列中的数据。

#### 标记序列返回的位置并且包含多个子句

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:42:00Z' GROUP BY *,time(12m) ORDER BY time DESC LIMIT 2 OFFSET 2 SLIMIT 1 SOFFSET 1

name: h2o_feet
tags: location=santa_monica
time                   mean
----                   ----
2015-08-18T00:12:00Z   2.077
2015-08-18T00:00:00Z   2.09
```

这个例子非常复杂，所以我们逐个子句来分析：

- [`SELECT`子句](#the-basic-select-statement)指定了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions)；
- [`FROM`子句](#the-basic-select-statement)指定了measurement；
- [`WHERE`子句](#the-where-clause)指定了查询的时间范围；
- [`GROUP BY`子句](#the-group-by-clause)将查询结果按所有tag(`*`)和12分钟的时间间隔进行分组；
- [`ORDER BY time DESC`子句](#order-by-time-desc)按递减的时间顺序返回结果；
- [`LIMIT 2`子句](#the-limit-clause)将返回的数据点个数限制为2；
- [`OFFSET 2`子句](#the-offset-clause)使查询结果的前两个平均值不返回；
- [`SLIMIT 1`子句](#the-slimit-clause)将返回的系列个数限制为1；
- `SOFFSET 1`子句使查询结果中第一个系列的数据不返回。

如果以上查询语句中没有使用`SOFFSET 1`，那么查询将返回另外一个系列的结果：

```sql
name: h2o_feet
tags: location=coyote_creek
time                   mean
----                   ----
2015-08-18T00:12:00Z   7.8245
2015-08-18T00:00:00Z   8.0625
```

## The Time Zone clause

`tz()`子句返回指定时区的UTC偏移量。

### 语法

```sql
SELECT_clause [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause] tz('<time_zone>')
```

InfluxDB默认以UTC格式存储和返回时间戳。`tz()`子句包含UTC偏移量，或者UTC夏令时（Daylight Savings Time，简称DST）偏移量（如果适用的话），在查询返回的时间戳中。返回的时间戳必须是RFC3339格式才能显示UTC偏移量或者UTC夏令时偏移量。参数`time_zone`遵循[Internet Assigned Numbers Authority time zone database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List)（互联网号码分配局时区数据库）的TZ语法，需要用单引号将它括起来。

### 示例

#### 返回芝加哥时区的UTC偏移量

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:18:00Z' tz('America/Chicago')

name: h2o_feet
time                       water_level
----                       -----------
2015-08-17T19:00:00-05:00  2.064
2015-08-17T19:06:00-05:00  2.116
2015-08-17T19:12:00-05:00  2.028
2015-08-17T19:18:00-05:00  2.126
```

该查询结果中，时间戳包含了美国/芝加哥（`America/Chicago`）的时区的UTC偏移量（`-05:00`）。

## 时间语法

对于大多数`SELECT`语句，默认的时间范围是从[`1677-09-21 00:12:43.145224194 UTC`到`2262-04-11T23:47:16.854775806Z UTC`](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#what-are-the-minimum-and-maximum-timestamps-that-influxdb-can-store)。对于包含[`GROUP BY time()`子句](#group-by-time-intervals)的`SELECT`语句，默认的时间范围是从`1677-09-21 00:12:43.145224194 UTC`到[`now()`](/influxdb/v1.8/concepts/glossary/#now)。以下章节将详细介绍如何在`SELECT`语句的`WHERE`子句中指定其它的时间范围。

以下详细介绍了如何在`SELECT`中指定替代时间范围语句的[`WHERE`子句](#the-where-clause)。

<table style="width:100%">
  <tr>
    <td><a href="#absolute-time">绝对时间</a></td>
    <td><a href="#relative-time">相对时间</a></td>
    <td><a href="#common-issues-with-time-syntax">时间语法常见问题</a></td>
  </tr>
</table>

## 绝对时间

使用日期-时间字符串(date-time string)和epoch时间来指定绝对时间。

### 语法

```sql
SELECT_clause FROM_clause WHERE time <operator> ['<rfc3339_date_time_string>' | '<rfc3339_like_date_time_string>' | <epoch_time>] [AND ['<rfc3339_date_time_string>' | '<rfc3339_like_date_time_string>' | <epoch_time>] [...]]
```

#### 支持的操作符

| 操作符 | 含义     |
| :----: | :------- |
|  `=`   | 等于     |
|  `<>`  | 不等于   |
|  `!=`  | 不等于   |
|  `>`   | 大于     |
|  `>=`  | 大于等于 |
|  `<`   | 小于     |
|  `<=`  | 小于等于 |

目前，InfluxDB不支持在WHERE子句中的绝对时间使用`OR`，请查看[FAQ](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#why-is-my-query-with-a-where-or-time-clause-returning-empty-results)文档和[GitHub问题](https://github.com/influxdata/influxdb/issues/7530)获得更多相关信息。

#### `rfc3339_date_time_string`

```sql
'YYYY-MM-DDTHH:MM:SS.nnnnnnnnnZ'
```

`.nnnnnnnnn`是可选的，如果没有指定的话，默认设为`.000000000`。[RFC3339](https://www.ietf.org/rfc/rfc3339.txt)格式的日期-时间字符串（RFC3339 date-time string）需要用单引号括起来。

#### `rfc3339_like_date_time_string`

```sql
'YYYY-MM-DD HH:MM:SS.nnnnnnnnn'
```

`HH:MM:SS.nnnnnnnnn.nnnnnnnnn`是可选的，如果没有指定的话，默认设为`00:00:00.000000000`。类似RFC3339格式的日期-时间字符串（RFC3339-like date-time string）需要用单引号括起来。

#### `epoch_time`

epoch时间是自1970年1月1日星期四00:00:00（UTC）以来所经过的时间。在默认情况下，InfluxDB假设所有epoch格式的时间戳都是以纳秒为单位。通过在epoch格式的时间戳末尾加上一个表示时间精度的字符，可以表示除纳秒外的时间精度。

#### 基本运算

所有时间戳格式支持基本的算术运算。可以将带有时间精度的时间戳加上（`+`）或者减去（`-`）一个时间。请注意，InfluxQL需要用一个空格将`+`或`-`和时间戳隔开。

### 示例

#### 用RFC3339格式的日期-时间字符串指定一个时间范围

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00.000000000Z' AND time <= '2015-08-18T00:12:00Z'

name: h2o_feet
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
2015-08-18T00:12:00Z   2.028
```

该查询返回时间戳在`2015年8月18日00:00:00.000000000`和`2015年8月18日00:12:00`之间的数据。第一个时间戳的纳米精度（`.000000000`）是可选的。

请注意，RFC3339格式的日期-时间字符串需要用单引号括起来。

#### 用类似RFC3339格式的日期-时间字符串指定一个时间范围

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18' AND time <= '2015-08-18 00:12:00'

name: h2o_feet
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
2015-08-18T00:12:00Z   2.028
```

该查询返回时间戳在`2015年8月18日00:00:00`和`2015年8月18日00:12:00`之间的数据。第一个日期-时间字符串没有包含时间，InfluxDB会假设时间是`00:00:00`。

请注意，类似RFC3339格式的日期-时间字符串需要用单引号括起来。

#### 用epoch格式的时间戳指定一个时间范围

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= 1439856000000000000 AND time <= 1439856720000000000

name: h2o_feet
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
2015-08-18T00:12:00Z   2.028
```

该查询返回时间戳在`2015年8月18日00:00:00`和`2015年8月18日00:12:00`之间的数据。在默认情况下，InfluxDB假设epoch格式的时间戳以纳秒为单位。

#### 用其它时间精度的epoch格式的时间戳指定一个时间范围

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= 1439856000s AND time <= 1439856720s

name: h2o_feet
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
2015-08-18T00:12:00Z   2.028
```

该查询返回时间戳在`2015年8月18日00:00:00`和`2015年8月18日00:12:00`之间的数据。时间戳末尾的`s`表示该时间戳以秒为单位。

#### 对类似RFC3339格式的日期-时间字符串进行基本运算

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time > '2015-09-18T21:24:00Z' + 6m

name: h2o_feet
time                   water_level
----                   -----------
2015-09-18T21:36:00Z   5.066
2015-09-18T21:42:00Z   4.938
```

该查询返回时间戳在`2015年8月18日21:24:00`后6分钟之后的数据，即在`2015年8月18日21:30:00`之后的数据。请注意，需要用空格分别将时间戳和`+`、`+`和`6m`隔开。

#### 对epoch格式的时间戳进行基本运算

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time > 24043524m - 6m

name: h2o_feet
time                   water_level
----                   -----------
2015-09-18T21:24:00Z   5.013
2015-09-18T21:30:00Z   5.01
2015-09-18T21:36:00Z   5.066
2015-09-18T21:42:00Z   4.938
```

该查询返回时间戳在`2015年8月18日21:24:00`前6分钟之后的数据，即在`2015年8月18日21:18:00`之后的数据。请注意，需要用空格分别将时间戳和`-`、`-`和`6m`隔开。

## 相对时间

使用[`now()`](/influxdb/v1.8/concepts/glossary/#now)查询[时间戳](/influxdb/v1.8/concepts/glossary/#timestamp)相对于服务器本地时间戳的数据。

### 语法

```sql
SELECT_clause FROM_clause WHERE time <operator> now() [[ - | + ] <duration_literal>] [(AND|OR) now() [...]]
```

`now()`是在服务器上执行查询时该服务器的Unix时间。`-`或`+`和`duration_literal`之间必须要用空格隔开。

#### 支持的操作符
| 操作符 | 含义     |
| :----: | :------- |
|  `=`   | 等于     |
|  `<>`  | 不等于   |
|  `!=`  | 不等于   |
|  `>`   | 大于     |
|  `>=`  | 大于等于 |
|  `<`   | 小于     |
|  `<=`  | 小于等于 |

#### `duration_literal`

| 单位 | 含义 |
|:----:|:----:|
|`u`或`µ`|微秒|
|`ms`|毫秒|
|`s`|秒|
|`m`|分钟|
|`h`|小时|
|`d`|天|
|`w`|周|
### 示例

#### 用相对时间指定时间范围

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time > now() - 1h
```

该查询返回过去一个小时内的数据。需要用空格分别将`now()`和`-`、`-`和`1h`隔开。

#### 用绝对时间和相对时间指定时间范围

```sql
> SELECT "level description" FROM "h2o_feet" WHERE time > '2015-09-18T21:18:00Z' AND time < now() + 1000d

name: h2o_feet
time                   level description
----                   -----------------
2015-09-18T21:24:00Z   between 3 and 6 feet
2015-09-18T21:30:00Z   between 3 and 6 feet
2015-09-18T21:36:00Z   between 3 and 6 feet
2015-09-18T21:42:00Z   between 3 and 6 feet
```

该查询返回时间戳在`2015年9月18日21:18:00`和`now()`之后的1000天之间的数据。需要用空格分别将`now()`和`+`、`+`和`1000d`隔开。

## 时间语法常见问题

### 使用`OR`选择多个时间间隔

InfluxDB不支持在`WHERE`子句中使用`OR`来指定多个时间间隔。若想获得更多相关信息，请查阅[FAQ](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#why-is-my-query-with-a-where-or-time-clause-returning-empty-results)相关章节。

### 在带有`GROUP BY time()`的查询语句中，查询发生在`now()`之后的数据

对于大多数`SELECT`语句，默认的时间范围是从[`1677-09-21 00:12:43.145224194 UTC`到`2262-04-11T23:47:16.854775806Z UTC`](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#what-are-the-minimum-and-maximum-timestamps-that-influxdb-can-store)。对于包含[`GROUP BY time()`](#group-by-time-intervals)子句的`SELECT`语句，默认的时间范围是从`1677-09-21 00:12:43.145224194 UTC`到[`now()`](/influxdb/v1.8/concepts/glossary/#now)。

若想查询发生在`now()`之后的数据，包含`GROUP BY time()`子句的`SELECT`语句必须在`WHERE`子句中提供一个时间上限（upper bound）

#### 示例

使用[CLI](/influxdb/v1.8/tools/shell/)向数据库`NOAA_water_database`中写入一个发生在`now()`之后的数据点：

```sql
> INSERT h2o_feet,location=santa_monica water_level=3.1 1587074400000000000
```

运行一个带有`GROUP BY time()`的查询，涵盖时间戳在`2015-09-18T21:30:00Z`和`now()`之间的数据：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location"='santa_monica' AND time >= '2015-09-18T21:30:00Z' GROUP BY time(12m) fill(none)

name: h2o_feet
time                   mean
----                   ----
2015-09-18T21:24:00Z   5.01
2015-09-18T21:36:00Z   5.002
```

运行一个带有`GROUP BY time()`的查询，涵盖时间戳在`2015-09-18T21:30:00Z`和`now()`之后的180个星期之间的数据：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location"='santa_monica' AND time >= '2015-09-18T21:30:00Z' AND time <= now() + 180w GROUP BY time(12m) fill(none)

name: h2o_feet
time                   mean
----                   ----
2015-09-18T21:24:00Z   5.01
2015-09-18T21:36:00Z   5.002
2020-04-16T22:00:00Z   3.1
```

> **注意：**`WHERE`子句必须提供一个时间上限来覆盖默认的`now()`上限。以下查询仅仅是将时间下限（lower bound）重新设置为`now()`，使得查询的时间范围在`now()`和`now()`之间，所以没有返回任何数据

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location"='santa_monica' AND time >= now() GROUP BY time(12m) fill(none)
>
```

### 配置返回的时间戳

[CLI](/influxdb/v1.8/tools/shell/)默认返回epoch格式的时间戳，并且精确到纳秒，可通过[命令`precision <format>`](/influxdb/v1.8/tools/shell/#influx-commands) 来指定其它的时间格式。[InfluxDB API](/influxdb/v1.8/tools/api/)默认返回[RFC3339](https://www.ietf.org/rfc/rfc3339.txt)格式的时间戳，可通过参数`epoch`来指定其它的时间格式。

## 正则表达式

在以下指定内容中，InfluxQL支持使用正则表达式：

* [`SELECT子句`](#the-basic-select-statement)中的[field key](/influxdb/v1.8/concepts/glossary/#field-key)和[tag key](/influxdb/v1.8/concepts/glossary/#tag-key)
* [`FROM`子句](#the-basic-select-statement)中的[measurement](/influxdb/v1.8/concepts/glossary/#measurement)
* [`WHERE`子句](#the-where-clause)中的[tag value](/influxdb/v1.8/concepts/glossary/#tag-value)和[field value](/influxdb/v1.8/concepts/glossary/#field-value)
* [`GROUP BY`子句](#group-by-tags)中的[tag key](/influxdb/v1.8/concepts/glossary/#tag-key)

目前，InfluxQL不支持在`WHERE`子句、[数据库](/influxdb/v1.8/concepts/glossary/#database)和[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)中使用正则表达式去匹配非字符串类型的field value。

> **注意：**正则表达式比较比字符串比较更加消耗计算资源；带有正则表达式的查询比那些不带的性能要低一些。

### 语法

```sql
SELECT /<regular_expression_field_key>/ FROM /<regular_expression_measurement>/ WHERE [<tag_key> <operator> /<regular_expression_tag_value>/ | <field_key> <operator> /<regular_expression_field_value>/] GROUP BY /<regular_expression_tag_key>/
```

正则表达式被字符`/`包围，并使用[Golang的正则表达式语法](http://golang.org/pkg/regexp/syntax/)。

#### 支持的操作符

| 操作符 | 含义   |
| ------ | ------ |
| `=~`   | 匹配   |
| `!=`   | 不匹配 |

### 示例

#### 在`SELECT`子句中使用正则表达式指定`field key`和`tag key`

```sql
> SELECT /l/ FROM "h2o_feet" LIMIT 1

name: h2o_feet
time                   level description      location       water_level
----                   -----------------      --------       -----------
2015-08-18T00:00:00Z   between 6 and 9 feet   coyote_creek   8.12
```

该查询返回所有包含字符`l`的[field key](/influxdb/v1.8/concepts/glossary/#field-key)和[tag key](/influxdb/v1.8/concepts/glossary/#tag-key)。请注意，在`SELECT`子句中的正则表达式必须至少匹配一个field key，才能返回与正则表达式匹配的tag key所对应的结果。

目前，没有语法可以区分`SELECT`子句中field key的正则表达式和tag key的正则表达式，不支持语法`/<regular_expression>/::[field | tag]`。

#### 在`FROM`子句中使用正则表达式指定`measurement`

```sql
> SELECT MEAN("degrees") FROM /temperature/

name: average_temperature
time			mean
----			----
1970-01-01T00:00:00Z   79.98472932232272

name: h2o_temperature
time			mean
----			----
1970-01-01T00:00:00Z   64.98872722506226
```

该查询使用了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions/)，计算[数据库](/influxdb/v1.8/concepts/glossary#database)`NOAA_water_database`中每个名字包含`temperature`的[measurement](/influxdb/v1.8/concepts/glossary#measurement)的`degrees`的平均值

#### 在`WHERE`子句中使用正则表达式指定tag value

```sql
> SELECT MEAN(water_level) FROM "h2o_feet" WHERE "location" =~ /[m]/ AND "water_level" > 3

name: h2o_feet
time                   mean
----                   ----
1970-01-01T00:00:00Z   4.47155532049926
```

该查询使用了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions/)，计算满足条件的`water_level`的平均值，需满足的条件是：`location`的[tag value](/influxdb/v1.8/concepts/glossary#tag-value)包含`m`并且`water_level`大于3。

#### 在`WHERE`子句中使用正则表达式指定没有值的`tag`

```sql
> SELECT * FROM "h2o_feet" WHERE "location" !~ /./
>
```

该查询从measurement `h2o_feet`中选择数据，这些数据需满足条件：[tag](/influxdb/v1.8/concepts/glossary#tag) `location`中不包含数据。因为数据库`NOAA_water_database`里面每个[数据点](/influxdb/v1.8/concepts/glossary#point)都有`location`对应的tag value，所以该查询不返回任何结果。

#### 在`WHERE`子句中使用正则表达式指定具有值的tag

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location" =~ /./

name: h2o_feet
time                   mean
----                   ----
1970-01-01T00:00:00Z   4.442107025822523
```

该查询使用了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions/)，计算满足条件的`water_level`的平均值，需满足的条件是：`location`不为空。

#### 在`WHERE`子句中使用正则表达式指定field value

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location" = 'santa_monica' AND "level description" =~ /between/

name: h2o_feet
time                   mean
----                   ----
1970-01-01T00:00:00Z   4.47155532049926
```

该查询使用了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions/)，计算满足条件的`water_level`的平均值，需满足的条件是：`level description`的field value包含`between`。

#### 在`GROUP BY`子句中使用正则表达式指定tag key

```sql
> SELECT FIRST("index") FROM "h2o_quality" GROUP BY /l/

name: h2o_quality
tags: location=coyote_creek
time                   first
----                   -----
2015-08-18T00:00:00Z   41

name: h2o_quality
tags: location=santa_monica
time                   first
----                   -----
2015-08-18T00:00:00Z   99
```

该查询使用了一个InfluxQL[函数](/influxdb/v1.8/query_language/functions/)，查询每个tag key包含`l`的tag所对应的`index`的第一个值。

## 数据类型和转换

[`SELECT`子句](#the-basic-select-statement)支持使用语法`::`指定[field](/influxdb/v1.8/concepts/glossary/#field)的类型和基本的类型转换操作。

<table style="width:100%">
  <tr>
    <td><a href="#data-types">数据类型</a></td>
    <td><a href="#cast-operations">转换</a></td>
  </tr>
</table>


## 数据类型

[field value](/influxdb/v1.8/concepts/glossary/#field-value)可以是浮点数、整数、字符串或者布尔值。语法`::`允许用户在查询中指定field value的数据类型。

> **注意：**通常，不需要在[`SELECT`子句]()指定[field value](/influxdb/v1.8/concepts/glossary/#field-value)的数据类型。在大多数情况下，InfluxDB拒绝任何尝试将field value写入到之前接受不同数据类型field value的field。在不同的[shard group](/influxdb/v1.8/concepts/glossary/#shard-group)中，field value的数据类型可能不同，在这些情况下，可能需要在`SELECT`子句中指定field value的数据类型。

### 语法

```sql
SELECT_clause <field_key>::<type> FROM_clause
```

`type`可以是`float`，`integer`，`string`或`boolean`。在大多数情况下，如果`field_key`没有存储指定`type`的数据，那么 InfluxDB将不会返回任何数据。请参见[转换](#cast-operations)获得更多相关信息。

### 示例

```sql
> SELECT "water_level"::float FROM "h2o_feet" LIMIT 4

name: h2o_feet
--------------
time                   water_level
2015-08-18T00:00:00Z   8.12
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   8.005
2015-08-18T00:06:00Z   2.116
```

该查询返回field key `water_level`为浮点型的数据。

## 转换

语法`::`允许用户在查询中执行基本的类型转换。目前，InfluxDB支持[field value](/influxdb/v1.8/concepts/glossary/#field-value)从整数转换成浮点数，或者从浮点数转换成整数。

### 语法

```sql
SELECT_clause <field_key>::<type> FROM_clause
```

`type`可以是`float`或`integer`。如果查询试图把整数或浮点数转换成字符串或布尔值，那么InfluxDB将不会返回任何数据。

### 示例

#### 将浮点型的field value转换成整型

```sql
> SELECT "water_level"::integer FROM "h2o_feet" LIMIT 4

name: h2o_feet
--------------
time                   water_level
2015-08-18T00:00:00Z   8
2015-08-18T00:00:00Z   2
2015-08-18T00:06:00Z   8
2015-08-18T00:06:00Z   2
```

该查询将浮点型的`water_level`转换成整型，然后返回。

#### 将浮点型的field value转换成字符串（不支持该功能）

```sql
> SELECT "water_level"::string FROM "h2o_feet" LIMIT 4
>
```

The query returns no data as casting a float field value to a string is not
yet supported.

因为不支持将浮点型的field value转换成字符串，所以该查询不返回任何数据。

## 合并

在InfluxDB中，查询自动将[系列](/influxdb/v1.8/concepts/glossary/#series)合并。

### 示例

数据库`NOAA_water_database`中的[measurement](/influxdb/v1.8/concepts/glossary/#measurement)的`h2o_feet`是两个[系列](/influxdb/v1.8/concepts/glossary/#series)的一部分。第一个系列由measurement `h2o_feet`和[tag](/influxdb/v1.8/concepts/glossary/#tag) `location = coyote_creek`组成。第二个系列由measurement `h2o_feet`和tag `location = santa_monica`组成。

以下查询在计算`water_level`的[平均值](/influxdb/v1.8/query_language/functions/#mean)时自动将这两个系列合并：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet"

name: h2o_feet
--------------
time                   mean
1970-01-01T00:00:00Z   4.442107025822521
```

如果您只想要计算第一个系列的`water_level`的平均值，请在[`WHERE`子句](#the-where-clause)中指定相关的tag：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location" = 'coyote_creek'

name: h2o_feet
--------------
time                   mean
1970-01-01T00:00:00Z   5.359342451341401
```

如果您想要计算每个系列的`water_level`的平均值，请加上[`GROUP BY`子句](#group-by-tags)：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" GROUP BY "location"

name: h2o_feet
tags: location=coyote_creek
time                   mean
----                   ----
1970-01-01T00:00:00Z   5.359342451341401

name: h2o_feet
tags: location=santa_monica
time                   mean
----                   ----
1970-01-01T00:00:00Z   3.530863470081006
```

## 多个语句

在查询中请使用分号(`;`)将多个[`SELECT`语句](#the-basic-select-statement)隔开。

### 示例

{{< tabs-wrapper >}}
{{% tabs %}}
[Example 1: CLI](#)
[Example 2: InfluxDB API](#)
{{% /tabs %}}

{{% tab-content %}}

在InfluxDB [CLI](/influxdb/v1.8/tools/shell/)中：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet"; SELECT "water_level" FROM "h2o_feet" LIMIT 2

name: h2o_feet
time                   mean
----                   ----
1970-01-01T00:00:00Z   4.442107025822522

name: h2o_feet
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   8.12
2015-08-18T00:00:00Z   2.064
```

{{% /tab-content %}}

{{% tab-content %}}

在[InfluxDB API](/influxdb/v1.8/tools/api/)中：

```json
{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "h2o_feet",
                    "columns": [
                        "time",
                        "mean"
                    ],
                    "values": [
                        [
                            "1970-01-01T00:00:00Z",
                            4.442107025822522
                        ]
                    ]
                }
            ]
        },
        {
            "statement_id": 1,
            "series": [
                {
                    "name": "h2o_feet",
                    "columns": [
                        "time",
                        "water_level"
                    ],
                    "values": [
                        [
                            "2015-08-18T00:00:00Z",
                            8.12
                        ],
                        [
                            "2015-08-18T00:00:00Z",
                            2.064
                        ]
                    ]
                }
            ]
        }
    ]
}
```

{{% /tab-content %}}
{{< /tabs-wrapper >}}

## 子查询

子查询是嵌套在另一个查询的`FROM`子句中的查询。使用子查询将查询作为条件应用在另一个查询中。子查询提供类似嵌套函数和SQL [`HAVING`子句](https://en.wikipedia.org/wiki/Having_%28SQL%29)的功能。

### 语法

```sql
SELECT_clause FROM ( SELECT_statement ) [...]
```

InfluxDB首先执行子查询，然后执行主查询。

主查询包含着子查询，至少需要[`SELECT`子句](#the-basic-select-statement)和[`FROM`子句](#the-basic-select-statement)。主查询支持本文档中列出的所有子句。

子查询在主查询的`FROM`子句中，需要用括号将子查询括起来。子查询支持本文档中列出的所有子句。

InfluxQL支持在主查询中有多个嵌套的子查询，示例语法如下：

```sql
SELECT_clause FROM ( SELECT_clause FROM ( SELECT_statement ) [...] ) [...]
```

### 示例

#### 计算多个[`MAX()`](/influxdb/v1.8/query_language/functions/#max)值的[`SUM()`](/influxdb/v1.8/query_language/functions/#sum)

```sql
> SELECT SUM("max") FROM (SELECT MAX("water_level") FROM "h2o_feet" GROUP BY "location")

name: h2o_feet
time                   sum
----                   ---
1970-01-01T00:00:00Z   17.169
```

该查询返回每个`location`中`water_level`的最大值的总和。

InfluxDB首先执行子查询，计算每个`location`的`water_level`的最大值：

```sql
> SELECT MAX("water_level") FROM "h2o_feet" GROUP BY "location"
name: h2o_feet

tags: location=coyote_creek
time                   max
----                   ---
2015-08-29T07:24:00Z   9.964

name: h2o_feet
tags: location=santa_monica
time                   max
----                   ---
2015-08-29T03:54:00Z   7.205
```

然后，InfluxDB执行主查询，计算这些最大值的总和：9.964 + 7.205 = 17.169。请注意，该主查询指定`max`（而不是`water_level`）作为`SUM()`函数中的field key。

#### 计算两个field的差值的[`MEAN()`](/influxdb/v1.8/query_language/functions/#mean)

```sql
> SELECT MEAN("difference") FROM (SELECT "cats" - "dogs" AS "difference" FROM "pet_daycare")

name: pet_daycare
time                   mean
----                   ----
1970-01-01T00:00:00Z   1.75
```

该查询返回measurement `pet_daycare`中`cats`数量和`dogs`数量的差异的平均值。

InfluxDB首先执行子查询，计算field `cats`中的值和field `dogs`中的值的差异，并将输出列命名为`difference`：

```sql
> SELECT "cats" - "dogs" AS "difference" FROM "pet_daycare"

name: pet_daycare
time                   difference
----                   ----------
2017-01-20T00:55:56Z   -1
2017-01-21T00:55:56Z   -49
2017-01-22T00:55:56Z   66
2017-01-23T00:55:56Z   -9
```

然后，InfluxDB执行主查询，计算这些差值的平均值。请注意，该主查询指定`difference`作为`MEAN()`函数中的field key。

#### 计算多个[`MEAN()`](/influxdb/v1.8/query_language/functions/#mean)值并在这些值上加上条件

```sql
> SELECT "all_the_means" FROM (SELECT MEAN("water_level") AS "all_the_means" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m) ) WHERE "all_the_means" > 5

name: h2o_feet
time                   all_the_means
----                   -------------
2015-08-18T00:00:00Z   5.07625
```

该查询返回`water_level`的所有大于5的平均值。

InfluxDB首先执行子查询，计算从`2015-08-18T00:00:00Z`到`2015-08-18T00:30:00Z` `water_level`的平均值，并将结果按12分钟的时间间隔进行分组，同时将输出列命名为`all_the_means`：

```sql
> SELECT MEAN("water_level") AS "all_the_means" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m)

name: h2o_feet
time                   all_the_means
----                   -------------
2015-08-18T00:00:00Z   5.07625
2015-08-18T00:12:00Z   4.950749999999999
2015-08-18T00:24:00Z   4.80675
```

然后，InfluxDB执行主查询，只返回那些大于5的平均值。请注意，该主查询指定`all_the_means`作为SELECT子句中的field key。

#### 计算多个[`DERIVATIVE()`](/influxdb/v1.8/query_language/functions/#derivative)值的[`SUM()`](/influxdb/v1.8/query_language/functions/#sum)

```sql
> SELECT SUM("water_level_derivative") AS "sum_derivative" FROM (SELECT DERIVATIVE(MEAN("water_level")) AS "water_level_derivative" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m),"location") GROUP BY "location"

name: h2o_feet
tags: location=coyote_creek
time                   sum_derivative
----                   --------------
1970-01-01T00:00:00Z   -0.4950000000000001

name: h2o_feet
tags: location=santa_monica
time                   sum_derivative
----                   --------------
1970-01-01T00:00:00Z   -0.043999999999999595
```

该查询返回每个`location`中`water_level`的平均值的导数之和。

InfluxDB首先执行子查询，计算以12分钟为间隔获取的`water_level`的平均值的导数，它对每个`location`都进行了计算，并将输出列命名为`water_level_derivative`：

```sql
> SELECT DERIVATIVE(MEAN("water_level")) AS "water_level_derivative" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m),"location"

name: h2o_feet
tags: location=coyote_creek
time                   water_level_derivative
----                   ----------------------
2015-08-18T00:12:00Z   -0.23800000000000043
2015-08-18T00:24:00Z   -0.2569999999999997

name: h2o_feet
tags: location=santa_monica
time                   water_level_derivative
----                   ----------------------
2015-08-18T00:12:00Z   -0.0129999999999999
2015-08-18T00:24:00Z   -0.030999999999999694
```

然后，InfluxDB执行主查询，计算每个`location`的`water_level_derivative`的总和。请注意，该主查询指定`water_level_derivative`（而不是`water_level`或`derivative`）作为`SUM()`函数中的field key。

### 子查询的常见问题

#### 在子查询中有多个`SELECT`语句

InfluxQL支持在主查询中有多个嵌套的子查询：

```sql
SELECT_clause FROM ( SELECT_clause FROM ( SELECT_statement ) [...] ) [...]
                     ------------------   ----------------
                         Subquery 1          Subquery 2
```

InfluxQL不支持在子查询中有多个[`SELECT`语句](#the-basic-select-statement)：

```sql
SELECT_clause FROM (SELECT_statement; SELECT_statement) [...]
```

如果在子查询中有多个`SELECT`语句，那么系统会返回解析错误。
