---
title: InfluxQL 函数
description: >
  Aggregate, select, transform, and predict data with InfluxQL functions.
menu:
  influxdb_1_8:
    name: 函数
    weight: 60
    parent: InfluxQL
---

InfluxQL函数可以用来聚合(aggregate)、选择(select)、转换(transform)和预测(predict)数据。

#### Content

* [Aggregations](#aggregations)
  * [COUNT()](#count)
  * [DISTINCT()](#distinct)
  * [INTEGRAL()](#integral)
  * [MEAN()](#mean)
  * [MEDIAN()](#median)
  * [MODE()](#mode)
  * [SPREAD()](#spread)
  * [STDDEV()](#stddev)
  * [SUM()](#sum)
* [Selectors](#selectors)
  * [BOTTOM()](#bottom)
  * [FIRST()](#first)
  * [LAST()](#last)
  * [MAX()](#max)
  * [MIN()](#min)
  * [PERCENTILE()](#percentile)
  * [SAMPLE()](#sample)
  * [TOP()](#top)
* [Transformations](#transformations)
  * [ABS()](#abs)
  * [ACOS()](#acos)
  * [ASIN()](#asin)
  * [ATAN()](#atan)
  * [ATAN2()](#atan2)
  * [CEIL()](#ceil)
  * [COS()](#cos)
  * [CUMULATIVE_SUM()](#cumulative-sum)
  * [DERIVATIVE()](#derivative)
  * [DIFFERENCE()](#difference)
  * [ELAPSED()](#elapsed)
  * [EXP()](#exp)
  * [FLOOR()](#floor)
  * [HISTOGRAM()](#histogram)
  * [LN()](#ln)
  * [LOG()](#log)
  * [LOG2()](#log2)
  * [LOG10()](#log10)
  * [MOVING_AVERAGE()](#moving-average)
  * [NON_NEGATIVE_DERIVATIVE()](#non-negative-derivative)
  * [NON_NEGATIVE_DIFFERENCE()](#non-negative-difference)
  * [POW()](#pow)
  * [ROUND()](#round)
  * [SIN()](#sin)
  * [SQRT()](#sqrt)
  * [TAN()](#tan)
* [Predictors](#predictors)
  * [HOLT_WINTERS()](#holt-winters)
* [Technical Analysis](#technical-analysis)
  * [CHANDE_MOMENTUM_OSCILLATOR()](#chande-momentum-oscillator)
  * [EXPONENTIAL_MOVING_AVERAGE()](#exponential-moving-average)
  * [DOUBLE_EXPONENTIAL_MOVING_AVERAGE()](#double-exponential-moving-average)
  * [KAUFMANS_EFFICIENCY_RATIO()](#kaufmans-efficiency-ratio)
  * [KAUFMANS_ADAPTIVE_MOVING_AVERAGE()](#kaufmans-adaptive-moving-average)
  * [TRIPLE_EXPONENTIAL_MOVING_AVERAGE()](#triple-exponential-moving-average)
  * [TRIPLE_EXPONENTIAL_DERIVATIVE()](#triple-exponential-derivative)
  * [RELATIVE_STRENGTH_INDEX()](#relative-strength-index)
* [Other](#other)
  * [Sample Data](#sample-data)
  * [General Syntax for Functions](#general-syntax-for-functions)
    * [Specify Multiple Functions in the SELECT clause](#specify-multiple-functions-in-the-select-clause)
    * [Rename the Output Field Key](#rename-the-output-field-key)
    * [Change the Values Reported for Intervals with no Data](#change-the-values-reported-for-intervals-with-no-data)
  * [Common Issues with Functions](#common-issues-with-functions)

## Aggregations

### COUNT()

返回非空值 [field values](/influxdb/v1.8/concepts/glossary/#field-value).数量

#### 语法

```
SELECT COUNT( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

##### 嵌套语法

```
SELECT COUNT(DISTINCT( [ * | <field_key> | /<regular_expression>/ ] )) [...]
```

`COUNT(field_key)`  
返回[field key](/influxdb/v1.8/concepts/glossary/#field-key)对应的field value的个数。

`COUNT(/regular_expression/)`  
返回与[正则表达式](/influxdb/v1.8/query_language/explore-data/#regular-expressions)匹配的每个field key对应的field value的个数。

`COUNT(*)`  
返回在[measurement](/influxdb/v1.8/concepts/glossary/#measurement)中每个field key对应的field value的个数。

`COUNT()` 
支持所有[数据类型](/influxdb/v1.8/write_protocols/line_protocol_reference/#data-types)的field value。InfluxQL支持将[`DISTINCT()`](#distinct)函数嵌套在`COUNT()`函数里。

#### 示例

##### 计算指定field key的field value的数目

```sql
> SELECT COUNT("water_level") FROM "h2o_feet"

name: h2o_feet
time                   count
----                   -----
1970-01-01T00:00:00Z   15258
```

该查询返回measurement`h2o_feet`中的`water_level`的非空field value的数量。

##### 计数measurement中每个field key关联的field value的数量

```sql
> SELECT COUNT(*) FROM "h2o_feet"

name: h2o_feet
time                   count_level description   count_water_level
----                   -----------------------   -----------------
1970-01-01T00:00:00Z   15258                     15258
```

该查询返回与measurement`h2o_feet`相关联的每个field key的非空field value的数量。`h2o_feet`有两个field keys：`level_description`和`water_level`

##### 计算匹配一个正则表达式的每个field key关联的field value的数目

```sql
> SELECT COUNT(/water/) FROM "h2o_feet"

name: h2o_feet
time                   count_water_level
----                   -----------------
1970-01-01T00:00:00Z   15258
```

该查询返回measurement`h2o_feet`中包含`water`单词的每个field key的非空字段值的数量。

##### 计数包括多个子句的field key的field value的数目

```sql
> SELECT COUNT("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* fill(200) LIMIT 7 SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   count
----                   -----
2015-08-17T23:48:00Z   200
2015-08-18T00:00:00Z   2
2015-08-18T00:12:00Z   2
2015-08-18T00:24:00Z   2
2015-08-18T00:36:00Z   2
2015-08-18T00:48:00Z   2
```

该查询返回`water_level`field key中的非空field value的数量。它涵盖`2015-08-17T23：48：00Z`和`2015-08-18T00：54：00Z`之间的`时间段`，并将结果分组为12分钟的时间间隔和每个tag。并用`200`填充空的时间间隔，并返回7个数据point，表格返回1。

##### 计算一个field key的distinct的field value的数量

```sql
> SELECT COUNT(DISTINCT("level description")) FROM "h2o_feet"

name: h2o_feet
time                   count
----                   -----
1970-01-01T00:00:00Z   4
```

查询返回measurement为`h2o_feet`field ke`为`level description`的唯一field value的数量。

### `COUNT()`的常见问题

#### `COUNT()`和`fill()`

大多数InfluxQL函数对于没有数据的时间间隔返回`null`值，[`fill(<fill_option>)`](/influxdb/v1.8/query_language/explore-data/#group-by-time-intervals-and-fill)将该`null`值替换为`fill_option`。 `COUNT()`针对没有数据的时间间隔返回`0`，`fill(<fill_option>)`用`fill_option`替换0值。

##### 示例

下面的代码块中的第一个查询不包括`fill()`。最后一个时间间隔没有数据，因此该时间间隔的值返回为零。第二个查询包括`fill(800000)`; 它将最后一个间隔中的零替换为`800000`。

```sql
> SELECT COUNT("water_level") FROM "h2o_feet" WHERE time >= '2015-09-18T21:24:00Z' AND time <= '2015-09-18T21:54:00Z' GROUP BY time(12m)

name: h2o_feet
time                   count
----                   -----
2015-09-18T21:24:00Z   2
2015-09-18T21:36:00Z   2
2015-09-18T21:48:00Z   0

> SELECT COUNT("water_level") FROM "h2o_feet" WHERE time >= '2015-09-18T21:24:00Z' AND time <= '2015-09-18T21:54:00Z' GROUP BY time(12m) fill(800000)

name: h2o_feet
time                   count
----                   -----
2015-09-18T21:24:00Z   2
2015-09-18T21:36:00Z   2
2015-09-18T21:48:00Z   800000
```

### `DISTINCT()`

返回[field value](/influxdb/v1.8/concepts/glossary/#field-value)的不重复值列表。

#### 语法

```
SELECT DISTINCT( [ <field_key> | /<regular_expression>/ ] ) FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

##### 嵌套语法

```
SELECT COUNT(DISTINCT( [ <field_key> | /<regular_expression>/ ] )) [...]
```

##### 语法描述

`DISTINCT(field_key)`  
返回[field key](/influxdb/v1.8/concepts/glossary/#field-key)对应的不同field values。

`DISTINCT()` 
支持所有[数据类型](/influxdb/v1.8/write_protocols/line_protocol_reference/#data-types)的field value，InfluxQL支持[`COUNT()`](#count)嵌套`DISTINCT()`。

#### 示例

##### 列出一个`field key`的不同的`field value`

```sql
> SELECT DISTINCT("level description") FROM "h2o_feet"

name: h2o_feet
time                   distinct
----                   --------
1970-01-01T00:00:00Z   between 6 and 9 feet
1970-01-01T00:00:00Z   below 3 feet
1970-01-01T00:00:00Z   between 3 and 6 feet
1970-01-01T00:00:00Z   at or greater than 9 feet
```

该查询返回`h2o_feet` measurement中`level description`filed 关键字中唯一field values的列表

##### 列出一个measurement中每个field key的不同的值

```sql
> SELECT DISTINCT(*) FROM "h2o_feet"

name: h2o_feet
time                   distinct_level description   distinct_water_level
----                   --------------------------   --------------------
1970-01-01T00:00:00Z   between 6 and 9 feet         8.12
1970-01-01T00:00:00Z   between 3 and 6 feet         8.005
1970-01-01T00:00:00Z   at or greater than 9 feet    7.887
1970-01-01T00:00:00Z   below 3 feet                 7.762
[...]
```

查询返回`h2o_feet`中每个字段的唯一字段值的列表。`h2o_feet`有两个字段：`description`和`water_level`。

##### 列出包含多个子句的field key关联的不同值的列表

```sql
>  SELECT DISTINCT("level description") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   distinct
----                   --------
2015-08-18T00:00:00Z   between 6 and 9 feet
2015-08-18T00:12:00Z   between 6 and 9 feet
2015-08-18T00:24:00Z   between 6 and 9 feet
2015-08-18T00:36:00Z   between 6 and 9 feet
2015-08-18T00:48:00Z   between 6 and 9 feet
```

该查询返回`level description`field key中不同field value的列表。它涵盖`2015-08-17T23：48：00Z`和`2015-08-18T00：54：00Z`之间的时间段，并将结果按12分钟的时间间隔和每个tag分组。查询限制返回一个series。

##### 对一个字段的不同值进行计算

```sql
> SELECT COUNT(DISTINCT("level description")) FROM "h2o_feet"

name: h2o_feet
time                   count
----                   -----
1970-01-01T00:00:00Z   4
```

查询返回`h2o_feet`这个measurement中字段`level description`的不同值的数目。

### `DISTINCT()`的常见问题

#### `DISTINCT()` 和 `INTO` 子句

在`INTO`子句中使用`DISTINCT()`可能会导致InfluxDB覆盖目标measurement中的数据Points。`DISTINCT()`通常返回多个具有相同时间戳的结果；InfluxDB假设在相同series中并具有相同时间戳的数据Point是重复数据points，并简单地用目标measurement中最新的数据point 覆盖重复数据Points。

##### 示例

下面代码块中的第一个查询使用了`DISTINCT()`，并返回四个结果。请注意，每个结果都有相同的时间戳。第二个查询将`INTO`子句添加到查询中，并将查询结果写入measurement `distincts`。最后一个查询选择measurement `distincts`中所有数据。
因为原来的四个结果是重复的(它们在相同的series，有相同的时间戳)，所以最后一个查询只返回一个数据point。当系统遇到重复数据points时，它会用最近的数据points覆盖之前的数据points。

```sql
>  SELECT DISTINCT("level description") FROM "h2o_feet"

name: h2o_feet
time                   distinct
----                   --------
1970-01-01T00:00:00Z   below 3 feet
1970-01-01T00:00:00Z   between 6 and 9 feet
1970-01-01T00:00:00Z   between 3 and 6 feet
1970-01-01T00:00:00Z   at or greater than 9 feet

>  SELECT DISTINCT("level description") INTO "distincts" FROM "h2o_feet"

name: result
time                   written
----                   -------
1970-01-01T00:00:00Z   4

> SELECT * FROM "distincts"

name: distincts
time                   distinct
----                   --------
1970-01-01T00:00:00Z   at or greater than 9 feet
```

### `INTEGRAL()`

返回field value曲线下的面积，即关于field value的积分。

#### 语法

```
SELECT INTEGRAL( [ * | <field_key> | /<regular_expression>/ ] [ , <unit> ]  ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

#### 语法描述

InfluxDB计算field value曲线下的面积，并将这些结果转换为每个`unit`的总面积。参数`unit`的值是一个整数，后跟一个时间单位。这个参数是可选的，不是必须要有的。如果查询没有指定`unit`的值，那么`unit`默认为一秒(`1s`)。

`INTEGRAL(field_key)`  
返回field key关联的值之下的面积。

`INTEGRAL(/regular_expression/)`  
返回满足正则表达式的每个field key关联的值之下的面积。

`INTEGRAL(*)`  
返回measurement中每个field key关联的值之下的面积。

`INTEGRAL()`不支持`fill()`，`INTEGRAL()`支持int64和float64两个数据类型。

#### 示例

下面的五个例子，使用数据库[`NOAA_water_database`中的数据](/influxdb/v1.8/query_language/data_download/)：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
2015-08-18T00:12:00Z   2.028
2015-08-18T00:18:00Z   2.126
2015-08-18T00:24:00Z   2.041
2015-08-18T00:30:00Z   2.051
```

##### 计算指定的field key的值得积分

```sql
> SELECT INTEGRAL("water_level") FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time                 integral
----                 --------
1970-01-01T00:00:00Z 3732.66
```

该查询返回`h2o_feet`中的字段`water_level`的曲线下的面积（以秒为单位）。

##### 计算指定的field key和时间单位的值得积分

```sql
> SELECT INTEGRAL("water_level",1m) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time                 integral
----                 --------
1970-01-01T00:00:00Z 62.211
```

该查询返回`h2o_feet`中的字段`water_level`的曲线下的面积（以分钟为单位）。

##### 计算measurement中每个field key在指定时间单位的值得积分

```sql
> SELECT INTEGRAL(*,1m) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time                 integral_water_level
----                 --------------------
1970-01-01T00:00:00Z 62.211
```

查询返回measurement`h2o_feet`中存储的每个数值字段相关的字段值的曲线下面积（以分钟为单位）。 `h2o_feet`的数值字段为`water_level`。

##### 计算measurement中匹配正则表达式的field key在指定时间单位的值得积分

```sql
> SELECT INTEGRAL(/water/,1m) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time                 integral_water_level
----                 --------------------
1970-01-01T00:00:00Z 62.211
```

查询返回field key包括单词`water`的每个数值类型的字段相关联的字段值的曲线下的区域（以分钟为单位）。

##### 在含有多个子句中计算指定字段的积分

```sql
> SELECT INTEGRAL("water_level",1m) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m) LIMIT 1

name: h2o_feet
time                 integral
----                 --------
2015-08-18T00:00:00Z 24.972
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value曲线下的面积(以分钟为单位)，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并将查询结果按12分钟的时间间隔进行分组，同时，该查询将返回的数据point个数限制为1。

### `MEAN()`

返回field value的平均值。

#### 语法

```
SELECT MEAN( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`MEAN(field_key)`  
返回field key对应的field value的平均值。

`MEAN(/regular_expression/)`  
返回与正则表达式匹配的每个field key对应的field value的平均值。

`MEAN(*)`  
返回在measurement中每个field key对应的field value的平均值。

`MEAN()` 
支持数据类型为int64和float64的field value。

#### 示例

##### 计算指定field key对应的field value的平均值

```sql
> SELECT MEAN("water_level") FROM "h2o_feet"

name: h2o_feet
time                   mean
----                   ----
1970-01-01T00:00:00Z   4.442107025822522
```
该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的平均值。

##### 计算measurement中每个field key对应的field value的平均值

```sql
> SELECT MEAN(*) FROM "h2o_feet"

name: h2o_feet
time                   mean_water_level
----                   ----------------
1970-01-01T00:00:00Z   4.442107025822522
```
该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的平均值。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

##### 计算与正则表达式匹配的每个field key对应的field value的平均值

```sql
> SELECT MEAN(/water/) FROM "h2o_feet"

name: h2o_feet
time                   mean_water_level
----                   ----------------
1970-01-01T00:00:00Z   4.442107025822523
```

该查询返回measurement `h2o_feet`中每个存储数值并包含单词`water`的field key对应的field value的平均值。

##### 计算指定field key对应的field value的平均值并包含多个子句

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* fill(9.01) LIMIT 7 SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   mean
----                   ----
2015-08-17T23:48:00Z   9.01
2015-08-18T00:00:00Z   8.0625
2015-08-18T00:12:00Z   7.8245
2015-08-18T00:24:00Z   7.5675
2015-08-18T00:36:00Z   7.303
2015-08-18T00:48:00Z   7.046
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的平均值，它涵盖的时间范围在`2015-08-17T23:48:00Z`和`2015-08-18T00:30:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`9.01`填充没有数据的时间间隔，并将返回的数据point个数和series个数分别限制为7和1。

### MEDIAN()

返回field value的计算平均值。

#### 语法

```
SELECT MEDIAN( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

#### 语法描述

`MEDIAN(field_key)`  
返回与field key对应的field value的平均值。

`MEDIAN(/regular_expression/)`  
返回与正则表达式匹配的每个field key对应的field value的平均值。

`MEDIAN(*)`  
返回在measurement中每个field key对应的field value的平均值。

`MEDIAN()` 支持数据类型为int64和float64的field value。

> 
>
> **注意：**`MEDIAN()`近似于`PERCENTILE(field_key, 50)`，除非field key包含的field value有偶数个，那么这时候*`MEDIAN()`*将返回两个中间值的平均数。

#### 示例

##### 计算指定field key对应的field value的平均数

```sql
> SELECT MEDIAN("water_level") FROM "h2o_feet"

name: h2o_feet
time                   median
----                   ------
1970-01-01T00:00:00Z   4.124
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的平均数。

##### 计算measurement中每个field key对应的field value的平均数

```sql
> SELECT MEDIAN(*) FROM "h2o_feet"

name: h2o_feet
time                   median_water_level
----                   ------------------
1970-01-01T00:00:00Z   4.124
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的平均数。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

##### 计算与正则表达式匹配的每个field key对应的field value的平均数

```sql
> SELECT MEDIAN(/water/) FROM "h2o_feet"

name: h2o_feet
time                   median_water_level
----                   ------------------
1970-01-01T00:00:00Z   4.124
```
该查询返回measurement `h2o_feet`中每个存储数值并包含单词`water`的field key对应的field value的平均数。

##### 计算指定field key对应的field value的平均数并包含多个子句

```sql
> SELECT MEDIAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* fill(700) LIMIT 7 SLIMIT 1 SOFFSET 1

name: h2o_feet
tags: location=santa_monica
time                   median
----                   ------
2015-08-17T23:48:00Z   700
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
2015-08-18T00:36:00Z   2.0620000000000003
2015-08-18T00:48:00Z   700
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的平均数，它涵盖的时间范围在`2015-08-17T23:48:00Z`和`2015-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`700`填充没有数据的时间间隔，将返回的数据point个数和series个数分别限制为7和1，并将返回的series偏移一个（即第一个series的数据不返回）。

### MODE()

返回field value中出现频率最高的值。

#### 语法

```
SELECT MODE( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`MODE(field_key)`  
返回field key对应的field value中出现频率最高的值。

`MODE(/regular_expression/)`  
返回与正则表达式匹配的每个field key对应的field value中出现频率最高的值。

`MODE(*)`  
返回在measurement中每个field key对应的field value中出现频率最高的值。

`MODE()` 支持所有数据类型的field value。

> **注意：**如果出现频率最高的值有两个或多个并且它们之间有关联，那么`MODE()`返回具有最早时间戳的field value。

#### 示例

##### 计算指定field key对应的field value中出现频率最高的值

```sql
> SELECT MODE("level description") FROM "h2o_feet"

name: h2o_feet
time                   mode
----                   ----
1970-01-01T00:00:00Z   between 3 and 6 feet
```

该查询返回measurement `h2o_feet`中每个field key对应的field value中出现频率最高的值。measurement `h2o_feet`中有两个field key：`level description`和`water_level`。

##### 计算measurement中每个field key对应的field value中出现频率最高的值

```sql
> SELECT MODE(*) FROM "h2o_feet"

name: h2o_feet
time                   mode_level description   mode_water_level
----                   ----------------------   ----------------
1970-01-01T00:00:00Z   between 3 and 6 feet     2.69
```

该查询返回measurement `h2o_feet`中每个field key对应的field value中出现频率最高的值。measurement `h2o_feet`中有两个field key：`level description`和`water_level`。

##### 计算与正则表达式匹配的每个field key对应的field value中出现频率最高的值

```sql
> SELECT MODE(/water/) FROM "h2o_feet"

name: h2o_feet
time                   mode_water_level
----                   ----------------
1970-01-01T00:00:00Z   2.69
```

该查询返回measurement `h2o_feet`中每个包含单词`water`的field key对应的field value中出现频率最高的值。

##### 计算指定field key对应的field value中出现频率最高的值并包含多个子句

```sql
> SELECT MODE("level description") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* LIMIT 3 SLIMIT 1 SOFFSET 1

name: h2o_feet
tags: location=santa_monica
time                   mode
----                   ----
2015-08-17T23:48:00Z
2015-08-18T00:00:00Z   below 3 feet
2015-08-18T00:12:00Z   below 3 feet
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value中出现频率最高的值，它涵盖的时间范围在`2015-08-17T23:48:00Z`和`2015-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询将返回的数据point个数和series个数分别限制为3和1，并将返回的series偏移一个（即第一个series的数据不返回）。

### SPREAD()

返回field value中最大值和最小值之差。

#### 语法

```
SELECT SPREAD( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

#### 语法描述

`SPREAD(field_key)`  
返回field key对应的field value中最大值和最小值之差。

`SPREAD(/regular_expression/)`  
返回与正则表达式匹配的每个field key对应的field value中最大值和最小值之差。

`SPREAD(*)`  
返回在measurement中每个field key对应的field value中最大值和最小值之差。

`SPREAD()` 
支持数据类型为int64和float64的field value。

#### 示例

##### 计算指定field key对应的field value中最大值和最小值之差

```sql
> SELECT SPREAD("water_level") FROM "h2o_feet"

name: h2o_feet
time                   spread
----                   ------
1970-01-01T00:00:00Z   10.574
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value中最大值和最小值之差。

##### 计算measurement中每个field key对应的field value中最大值和最小值之差

```sql
> SELECT SPREAD(*) FROM "h2o_feet"

name: h2o_feet
time                   spread_water_level
----                   ------------------
1970-01-01T00:00:00Z   10.574
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value中最大值和最小值之差。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

##### 计算与正则表达式匹配的每个field key对应的field value中最大值和最小值之差

```sql
> SELECT SPREAD(/water/) FROM "h2o_feet"

name: h2o_feet
time                   spread_water_level
----                   ------------------
1970-01-01T00:00:00Z   10.574
```

该查询返回measurement `h2o_feet`中每个存储数值并包含单词`water`的field key对应的field value中最大值和最小值之差。

##### 计算指定field key对应的field value中最大值和最小值之差并包含多个子句

```sql
> SELECT SPREAD("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* fill(18) LIMIT 3 SLIMIT 1 SOFFSET 1

name: h2o_feet
tags: location=santa_monica
time                   spread
----                   ------
2015-08-17T23:48:00Z   18
2015-08-18T00:00:00Z   0.052000000000000046
2015-08-18T00:12:00Z   0.09799999999999986
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value中最大值和最小值之差，它涵盖的时间范围在`2015-08-17T23:48:00Z`和`2015-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`18`填充没有数据的时间间隔，将返回的数据point个数和series个数分别限制为3和1，并将返回的series偏移一个（即第一个series的数据不返回）

### STDDEV()

返回field value的标准差。

#### 语法

```
SELECT STDDEV( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`STDDEV(field_key)`  
返回field key对应的field value的标准差。

`STDDEV(/regular_expression/)`  
返回与正则表达式匹配的每个field key对应的field value的标准差。

`STDDEV(*)`  
返回在measurement中每个field key对应的field value的标准差。

`STDDEV()`
支持数据类型为int64和float64的field value。

#### 示例

##### 计算指定field key对应的field value的标准差

```sql
> SELECT STDDEV("water_level") FROM "h2o_feet"

name: h2o_feet
time                   stddev
----                   ------
1970-01-01T00:00:00Z   2.279144584196141
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的标准差。

##### 计算measurement中每个field key对应的field value的标准差

```sql
> SELECT STDDEV(*) FROM "h2o_feet"

name: h2o_feet
time                   stddev_water_level
----                   ------------------
1970-01-01T00:00:00Z   2.279144584196141
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的标准差。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

##### 计算与正则表达式匹配的每个field key对应的field value的标准差

```sql
> SELECT STDDEV(/water/) FROM "h2o_feet"

name: h2o_feet
time                   stddev_water_level
----                   ------------------
1970-01-01T00:00:00Z   2.279144584196141
```

该查询返回measurement `h2o_feet`中每个存储数值并包含单词`water`的field key对应的field value的标准差。

##### 计算指定field key对应的field value的标准差并包含多个子句

```sql
> SELECT STDDEV("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* fill(18000) LIMIT 2 SLIMIT 1 SOFFSET 1

name: h2o_feet
tags: location=santa_monica
time                   stddev
----                   ------
2015-08-17T23:48:00Z   18000
2015-08-18T00:00:00Z   0.03676955262170051
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的标准差，它涵盖的时间范围在`2015-08-17T23:48:00Z`和`2015-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`18000`填充没有数据的时间间隔，将返回的数据point个数和series个数分别限制为2和1，并将返回的series偏移一个（即第一个series的数据不返回）。

### SUM()

返回field value的总和。

#### 语法

```
SELECT SUM( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

#### 语法描述

`SUM(field_key)`  
返回field key对应的field value的总和。

`SUM(/regular_expression/)`  
返回与正则表达式匹配的每个field key对应的field value的总和。

`SUM(*)`  
返回在measurement中每个field key对应的field value的总和。

`SUM()`
支持数据类型为int64和float64的field value。

#### 示例

##### 计算指定field key对应的field value的总和

```sql
> SELECT SUM("water_level") FROM "h2o_feet"

name: h2o_feet
time                   sum
----                   ---
1970-01-01T00:00:00Z   67777.66900000004
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的总和。

##### 计算measurement中每个field key对应的field value的总和

```sql
> SELECT SUM(*) FROM "h2o_feet"

name: h2o_feet
time                   sum_water_level
----                   ---------------
1970-01-01T00:00:00Z   67777.66900000004
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的总和。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

##### 计算与正则表达式匹配的每个field key对应的field value的总和

```sql
> SELECT SUM(/water/) FROM "h2o_feet"

name: h2o_feet
time                   sum_water_level
----                   ---------------
1970-01-01T00:00:00Z   67777.66900000004
```

该查询返回measurement `h2o_feet`中每个存储数值并包含单词`water`的field key对应的field value的总和。

##### 计算指定field key对应的field value的总和并包含多个子句

```sql
> SELECT SUM("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* fill(18000) LIMIT 4 SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   sum
----                   ---
2015-08-17T23:48:00Z   18000
2015-08-18T00:00:00Z   16.125
2015-08-18T00:12:00Z   15.649
2015-08-18T00:24:00Z   15.135
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的总和，它涵盖的时间范围在`2015-08-17T23:48:00Z`和`2015-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`18000`填充没有数据的时间间隔，并将返回的数据point个数和series个数分别限制为4和1。

## Selectors

### BOTTOM()

返回最小的N个field value。

#### 语法

```
SELECT BOTTOM(<field_key>[,<tag_key(s)>],<N> )[,<tag_key(s)>|<field_key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

#### 语法描述

`BOTTOM(field_key,N)`  
返回field key对应的最小的N个值。

`BOTTOM(field_key,tag_key(s),N)`  
返回tag key的N个tag value对应的field key的最小值。

`BOTTOM(field_key,N),tag_key(s),field_key(s)`  
返回括号中的field key对应的最小的N个值，以及相关的tag和/或field。

`BOTTOM()` 
支持数据类型为int64和float64的field value。

> **注意：**
>
> * 如果最小值有两个或多个相等的值，`BOTTOM()`返回具有最早时间戳的field value。
> * 当`BOTTOM()`函数与`INTO`子句一起使用时，`BOTTOM()`与其它InfluxQL函数不同。请查看`BOTTOM()`的常见问题章节获得更多信息。
#### 示例

##### 选择指定field key对应的最小的三个值

```sql
> SELECT BOTTOM("water_level",3) FROM "h2o_feet"

name: h2o_feet
time                   bottom
----                   ------
2015-08-29T14:30:00Z   -0.61
2015-08-29T14:36:00Z   -0.591
2015-08-30T15:18:00Z   -0.594
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的最小的三个值。

##### 选择两个tag对应的field key的最小值

```sql
> SELECT BOTTOM("water_level","location",2) FROM "h2o_feet"

name: h2o_feet
time                   bottom   location
----                   ------   --------
2015-08-29T10:36:00Z   -0.243   santa_monica
2015-08-29T14:30:00Z   -0.61    coyote_creek
```

该查询返回tag key `location`的两个tag value对应的field key `water_level`的最小值。

##### 选择指定field key对应的最小的四个值以及相关的tag和field

```sql
> SELECT BOTTOM("water_level",4),"location","level description" FROM "h2o_feet"

name: h2o_feet
time                  bottom  location      level description
----                  ------  --------      -----------------
2015-08-29T14:24:00Z  -0.587  coyote_creek  below 3 feet
2015-08-29T14:30:00Z  -0.61   coyote_creek  below 3 feet
2015-08-29T14:36:00Z  -0.591  coyote_creek  below 3 feet
2015-08-30T15:18:00Z  -0.594  coyote_creek  below 3 feet
```

该查询返回field key `water_level`对应的最小的四个值，以及相关的tag key `location`和field key `level description`的值。

##### 选择指定field key对应的最小的三个值并包含多个子句

```sql
> SELECT BOTTOM("water_level",3),"location" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(24m) ORDER BY time DESC

name: h2o_feet
time                  bottom  location
----                  ------  --------
2015-08-18T00:48:00Z  1.991   santa_monica
2015-08-18T00:54:00Z  2.054   santa_monica
2015-08-18T00:54:00Z  6.982   coyote_creek
2015-08-18T00:24:00Z  2.041   santa_monica
2015-08-18T00:30:00Z  2.051   santa_monica
2015-08-18T00:42:00Z  2.057   santa_monica
2015-08-18T00:00:00Z  2.064   santa_monica
2015-08-18T00:06:00Z  2.116   santa_monica
2015-08-18T00:12:00Z  2.028   santa_monica
```

该查询返回在`2015-08-18T00:00:00Z`和`2015-08-18T00:54:00Z`之间的每个24分钟间隔内，field key `water_level`对应的最小的三个值，并且以递减的时间戳顺序返回结果。

请注意，`GROUP BY time()`子句不会覆盖数据point的原始时间戳。请查看下面章节获得更详细的说明。

#### `BOTTOM()`的常见问题

##### `BOTTOM()`和`GROUP BY time()`子句同时使用

对于同时带有`BOTTOM()`和`GROUP BY time()`子句的查询，将返回每个`GROUP BY time()`时间间隔的指定个数的数据point。对于大多数`GROUP BY time()`查询，返回的时间戳表示`GROUP BY time()`时间间隔的开始时间，但是，带有`BOTTOM()`函数的`GROUP BY time()`查询则不一样，它们保留原始数据point的时间戳。

###### 示例

以下查询返回每18分钟`GROUP BY time()`间隔对应的两个数据point。请注意，返回的时间戳是数据point的原始时间戳；它们不会被强制要求必须匹配`GROUP BY time()`间隔的开始时间。

```sql
> SELECT BOTTOM("water_level",2) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(18m)

name: h2o_feet
time                   bottom
----                   ------
                           __
2015-08-18T00:00:00Z  2.064 |
2015-08-18T00:12:00Z  2.028 | <------- Smallest points for the first time interval
                           --
                           __
2015-08-18T00:24:00Z  2.041 |
2015-08-18T00:30:00Z  2.051 | <------- Smallest points for the second time interval                      --
```

##### `BOTTOM()`和具有少于N个tag value的tag key

使用语法`SELECT BOTTOM(<field_key>,<tag_key>,<N>)`的查询可以返回比预期少的数据point。如果tag key有`X`个tag value，但是查询指定的是`N`个tag value，如果`X`小于`N`，那么查询将返回`X`个数据point。

###### 示例

以下查询请求的是tag key `location`的三个tag value对于的`water_level`的最小值。因为tag key `location`只有两个tag value(`santa_monica`和`coyote_creek`)，所以该查询返回两个数据point而不是三个。

```sql
> SELECT BOTTOM("water_level","location",3) FROM "h2o_feet"

name: h2o_feet
time                   bottom   location
----                   ------   --------
2015-08-29T10:36:00Z   -0.243   santa_monica
2015-08-29T14:30:00Z   -0.61    coyote_creek
```

##### `BOTTOM()`、tag和`INTO`子句

当使用`INTO`子句但没有使用`GROUP BY tag`子句时，大多数InfluxQL函数将原始数据中的tag转换为新写入数据中的field。这种行为同样适用于`BOTTOM()`函数除非`BOTTOM()`中包含tag key作为参数：`BOTTOM(field_key,tag_key(s),N)`。在这些情况下，系统会将指定的tag保留为新写入数据中的tag。

###### 示例

下面代码块中的第一个查询返回tag key `location`的两个tag value对应的field key `water_level`的最小值，并且，它这些结果写入measurement `bottom_water_levels`中。第二个查询展示了InfluxDB将tag `location`保留为measurement `bottom_water_levels`中的tag。

```sql
> SELECT BOTTOM("water_level","location",2) INTO "bottom_water_levels" FROM "h2o_feet"

name: result
time                 written
----                 -------
1970-01-01T00:00:00Z 2

> SHOW TAG KEYS FROM "bottom_water_levels"

name: bottom_water_levels
tagKey
------
location
```

### FIRST()

返回具有最早时间戳的field value。

#### 语法

```
SELECT FIRST(<field_key>)[,<tag_key(s)>|<field_key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

#### 语法描述

`FIRST(field_key)`  
返回field key对应的具有最早时间戳的field value。

`FIRST(/regular_expression/)`  
返回与正则表达式匹配的每个field key对应的具有最早时间戳的field value。

`FIRST(*)`  
返回在measurement中每个field key对应的具有最早时间戳的field value。

`FIRST(field_key),tag_key(s),field_key(s)`  
返回括号中的field key对应的具有最早时间戳的field value，以及相关的tag或field。

`FIRST()` 
支持所有数据类型的field value。

#### 示例

##### 选择指定field key对应的具有最早时间戳的field value

```sql
> SELECT FIRST("level description") FROM "h2o_feet"

name: h2o_feet
time                   first
----                   -----
2015-08-18T00:00:00Z   between 6 and 9 feet
```

该查询返回measurement `h2o_feet`中field key `level description`对应的具有最早时间戳的field value。

##### 选择measurement中每个field key对应的具有最早时间戳的field value

```sql
> SELECT FIRST(*) FROM "h2o_feet"

name: h2o_feet
time                   first_level description   first_water_level
----                   -----------------------   -----------------
1970-01-01T00:00:00Z   between 6 and 9 feet      8.12
```

该查询返回measurement `h2o_feet`中每个field key对应的具有最早时间戳的field value。measurement `h2o_feet`中有两个field key：`level description`和`water_level`。

##### 选择与正则表达式匹配的每个field key对应的具有最早时间戳的field value

```sql
> SELECT FIRST(/level/) FROM "h2o_feet"

name: h2o_feet
time                   first_level description   first_water_level
----                   -----------------------   -----------------
1970-01-01T00:00:00Z   between 6 and 9 feet      8.12
```

该查询返回measurement `h2o_feet`中每个包含单词`level`的field key对应的具有最早时间戳的field value。

##### 选择指定field key对应的具有最早时间戳的field value以及相关的tag和field

```sql
> SELECT FIRST("level description"),"location","water_level" FROM "h2o_feet"

name: h2o_feet
time                  first                 location      water_level
----                  -----                 --------      -----------
2015-08-18T00:00:00Z  between 6 and 9 feet  coyote_creek  8.12
```

该查询返回measurement `h2o_feet`中field key `level description`对应的具有最早时间戳的field value，以及相关的tag key `location`和field key `water_level`的值。

##### 选择指定field key对应的具有最早时间戳的field value并包含多个子句

```sql
> SELECT FIRST("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* fill(9.01) LIMIT 4 SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   first
----                   -----
2015-08-17T23:48:00Z   9.01
2015-08-18T00:00:00Z   8.12
2015-08-18T00:12:00Z   7.887
2015-08-18T00:24:00Z   7.635
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的具有最早时间戳的field value，它涵盖的时间范围在`2015-08-17T23:48:00Z`和`2015-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`9.01`填充没有数据的时间间隔，并将返回的数据point个数和series个数分别限制为4和1。

请注意，`GROUP BY time()`子句会覆盖数据point的原始时间戳。查询结果中的时间戳表示每12分钟时间间隔的开始时间，其中，第一个数据point涵盖的时间间隔在`2015-08-17T23:48:00Z`和`2015-08-18T00:00:00Z`之间，最后一个数据point涵盖的时间间隔在`2015-08-18T00:24:00Z`和`2015-08-18T00:36:00Z`之间。

### LAST()

返回具有最新时间戳的field value。

#### 语法

```sql
SELECT LAST(<field_key>)[,<tag_key(s)>|<field_keys(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`LAST(field_key)`  
返回field key对应的具有最新时间戳的field value。

`LAST(/regular_expression/)`  
返回与正则表达式匹配的每个field key对应的具有最新时间戳的field value。

`LAST(*)`  
返回在measurement中每个field key对应的具有最新时间戳的field value。

`LAST(field_key),tag_key(s),field_key(s)`  
返回括号中的field key对应的具有最新时间戳的field value，以及相关的tag或field。

`LAST()`
支持所有数据类型的field value。

#### 示例

##### 选择指定field key对应的具有最新时间戳的field value

```sql
> SELECT LAST("level description") FROM "h2o_feet"

name: h2o_feet
time                   last
----                   ----
2015-09-18T21:42:00Z   between 3 and 6 feet
```

该查询返回measurement `h2o_feet`中field key `level description`对应的具有最新时间戳的field value。

##### 选择measurement中每个field key对应的具有最新时间戳的field value

```sql
> SELECT LAST(*) FROM "h2o_feet"

name: h2o_feet
time                   last_level description   last_water_level
----                   -----------------------   -----------------
1970-01-01T00:00:00Z   between 3 and 6 feet      4.938
```

该查询返回measurement `h2o_feet`中每个field key对应的具有最新时间戳的field value。measurement `h2o_feet`中有两个field key：`level description`和`water_level`。

##### 选择与正则表达式匹配的每个field key对应的具有最新时间戳的field value

```sql
> SELECT LAST(/level/) FROM "h2o_feet"

name: h2o_feet
time                   last_level description   last_water_level
----                   -----------------------   -----------------
1970-01-01T00:00:00Z   between 3 and 6 feet      4.938
```

该查询返回measurement `h2o_feet`中每个包含单词`level`的field key对应的具有最新时间戳的field value。

##### 选择指定field key对应的具有最新时间戳的field value以及相关的tag和field

```sql
> SELECT LAST("level description"),"location","water_level" FROM "h2o_feet"

name: h2o_feet
time                  last                  location      water_level
----                  ----                  --------      -----------
2015-09-18T21:42:00Z  between 3 and 6 feet  santa_monica  4.938
```

该查询返回measurement `h2o_feet`中field key `level description`对应的具有最新时间戳的field value，以及相关的tag key `location`和field key `water_level`的值。

##### 选择指定field key对应的具有最新时间戳的field value并包含多个子句

```sql
> SELECT LAST("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* fill(9.01) LIMIT 4 SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   last
----                   ----
2015-08-17T23:48:00Z   9.01
2015-08-18T00:00:00Z   8.005
2015-08-18T00:12:00Z   7.762
2015-08-18T00:24:00Z   7.5
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的具有最新时间戳的field value，它涵盖的时间范围在`2015-08-17T23:48:00Z`和`2015-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`9.01`填充没有数据的时间间隔，并将返回的数据point个数和series个数分别限制为4和1。

请注意，`GROUP BY time()`子句会覆盖数据point的原始时间戳。查询结果中的时间戳表示每12分钟时间间隔的开始时间，其中，第一个数据point涵盖的时间间隔在`2015-08-17T23:48:00Z`和`2015-08-18T00:00:00Z`之间，最后一个数据point涵盖的时间间隔在`2015-08-18T00:24:00Z`和`2015-08-18T00:36:00Z`之间。

### MAX()

返回field value的最大值。

#### 语法

```
SELECT MAX(<field_key>)[,<tag_key(s)>|<field__key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`MAX(field_key)`  
返回field key对应的field value的最大值。

`MAX(/regular_expression/)`  
返回与正则表达式匹配的每个field key对应的field value的最大值。

`MAX(*)`  
返回在measurement中每个field key对应的field value的最大值。

`MAX(field_key),tag_key(s),field_key(s)`  
返回括号中的field key对应的field value的最大值，以及相关的tag或field。

`MAX()` 支持数据类型为int64和float64的field value。

#### 示例

##### 选择指定field key对应的field value的最大值

```sql
> SELECT MAX("water_level") FROM "h2o_feet"

name: h2o_feet
time                   max
----                   ---
2015-08-29T07:24:00Z   9.964
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的最大值。

##### 选择measurement中每个field key对应的field value的最大值

```sql
> SELECT MAX(*) FROM "h2o_feet"

name: h2o_feet
time                   max_water_level
----                   ---------------
2015-08-29T07:24:00Z   9.964
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的最大值。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

##### 选择与正则表达式匹配的每个field key对应的field value的最大值

```sql
> SELECT MAX(/level/) FROM "h2o_feet"

name: h2o_feet
time                   max_water_level
----                   ---------------
2015-08-29T07:24:00Z   9.964
```

该查询返回measurement `h2o_feet`中每个存储数值并包含单词`water`的field key对应的field value的最大值。

##### 选择指定field key对应的field value的最大值以及相关的tag和field

```sql
> SELECT MAX("water_level"),"location","level description" FROM "h2o_feet"

name: h2o_feet
time                  max    location      level description
----                  ---    --------      -----------------
2015-08-29T07:24:00Z  9.964  coyote_creek  at or greater than 9 feet
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的最大值，以及相关的tag key `location`和field key `level description`的值。

##### 选择指定field key对应的field value的最大值并包含多个子句

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* fill(9.01) LIMIT 4 SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   max
----                   ---
2015-08-17T23:48:00Z   9.01
2015-08-18T00:00:00Z   8.12
2015-08-18T00:12:00Z   7.887
2015-08-18T00:24:00Z   7.635
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的最大值，它涵盖的时间范围在`2015-08-17T23:48:00Z`和`2015-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`9.01`填充没有数据的时间间隔，并将返回的数据point个数和series个数分别限制为4和1。

请注意，`GROUP BY time()`子句会覆盖数据point的原始时间戳。查询结果中的时间戳表示每12分钟时间间隔的开始时间，其中，第一个数据point涵盖的时间间隔在`2015-08-17T23:48:00Z`和`2015-08-18T00:00:00Z`之间，最后一个数据point涵盖的时间间隔在`2015-08-18T00:24:00Z`和`2015-08-18T00:36:00Z`之间。

### MIN()

返回field value的最小值。

#### 语法

```
SELECT MIN(<field_key>)[,<tag_key(s)>|<field_key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`MIN(field_key)`
返回field key对应的field value的最小值。

`MIN(/regular_expression/)`
返回与正则表达式匹配的每个field key对应的field value的最小值。

`MIN(*)`
返回在measurement中每个field key对应的field value的最小值。

`MIN(field_key),tag_key(s),field_key(s)`
返回括号中的field key对应的field value的最小值，以及相关的tag和/或field。

`MIN()`支持数据类型为int64和float64的field value。

#### 示例

##### 选择指定field key对应的field value的最小值

```sql
> SELECT MIN("water_level") FROM "h2o_feet"

name: h2o_feet
time                   min
----                   ---
2015-08-29T14:30:00Z   -0.61
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的最小值。

##### 选择measurement中每个field key对应的field value的最小值

```sql
> SELECT MIN(*) FROM "h2o_feet"

name: h2o_feet
time                   min_water_level
----                   ---------------
2015-08-29T14:30:00Z   -0.61
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的最小值。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

##### 选择与正则表达式匹配的每个field key对应的field value的最小值

```sql
> SELECT MIN(/level/) FROM "h2o_feet"

name: h2o_feet
time                   min_water_level
----                   ---------------
2015-08-29T14:30:00Z   -0.61
```

该查询返回measurement `h2o_feet`中每个存储数值并包含单词`water`的field key对应的field value的最小值。

##### 选择指定field key对应的field value的最小值以及相关的tag和field

```sql
> SELECT MIN("water_level"),"location","level description" FROM "h2o_feet"

name: h2o_feet
time                  min    location      level description
----                  ---    --------      -----------------
2015-08-29T14:30:00Z  -0.61  coyote_creek  below 3 feet
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的最小值，以及相关的tag key `location`和field key `level description`的值。

##### 选择指定field key对应的field value的最小值并包含多个子句

```sql
> SELECT MIN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* fill(9.01) LIMIT 4 SLIMIT 1

name: h2o_feet
tags: location=coyote_creek
time                   min
----                   ---
2015-08-17T23:48:00Z   9.01
2015-08-18T00:00:00Z   8.005
2015-08-18T00:12:00Z   7.762
2015-08-18T00:24:00Z   7.5
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的最小值，它涵盖的时间范围在`2015-08-17T23:48:00Z`和`2015-08-18T00:54:00Z`之间，并将查询结果按12分钟的时间间隔和每个tag进行分组，同时，该查询用`9.01`填充没有数据的时间间隔，并将返回的数据point个数和series个数分别限制为4和1。

请注意，`GROUP BY time()`子句会覆盖数据point的原始时间戳。查询结果中的时间戳表示每12分钟时间间隔的开始时间，其中，第一个数据point涵盖的时间间隔在`2015-08-17T23:48:00Z`和`2015-08-18T00:00:00Z`之间，最后一个数据point涵盖的时间间隔在`2015-08-18T00:24:00Z`和`2015-08-18T00:36:00Z`之间。

### PERCENTILE()

返回第N个百分位数的`field value`

#### 语法

```
SELECT PERCENTILE(<field_key>, <N>)[,<tag_key(s)>|<field_key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`PERCENTILE(field_key,N)`
返回指定field key对应的第N个百分位数的field value。

`PERCENTILE(/regular_expression/,N)`
返回与正则表达式匹配的每个field key对应的第N个百分位数的field value。

`PERCENTILE(*,N)`
返回在measurement中每个field key对应的第N个百分位数的field value。

`PERCENTILE(field_key,N),tag_key(s),field_key(s)`
返回括号中的field key对应的第N个百分位数的field value，以及相关的tag和/或field。

`N`必须是0到100之间的整数或浮点数。`PERCENTILE()`支持数据类型为int64和float64的field value。

#### 示例

##### 选择指定field key对应的第五个百分位数的field value

```sql
> SELECT PERCENTILE("water_level",5) FROM "h2o_feet"

name: h2o_feet
time                   percentile
----                   ----------
2015-08-31T03:42:00Z   1.122
```

该查询返回的field value大于measurement `h2o_feet`中field key `water_level`对应的所有field value中的百分之五。

##### 选择measurement中每个field key对应的第五个百分位数的field value

```sql
> SELECT PERCENTILE(*,5) FROM "h2o_feet"

name: h2o_feet
time                   percentile_water_level
----                   ----------------------
2015-08-31T03:42:00Z   1.122
```

该查询返回的field value大于measurement `h2o_feet`中每个存储数值的field key对应的所有field value中的百分之五。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

##### 选择与正则表达式匹配的每个field key对应的第五个百分位数的field value

```sql
> SELECT PERCENTILE(/level/,5) FROM "h2o_feet"

name: h2o_feet
time                   percentile_water_level
----                   ----------------------
2015-08-31T03:42:00Z   1.122
```

该查询返回的field value大于measurement `h2o_feet`中每个存储数值并包含单词`water`的field key对应的所有field value中的百分之五。

##### 选择指定field key对应的第五个百分位数的field value以及相关的tag和field

```sql
> SELECT PERCENTILE("water_level",5),"location","level description" FROM "h2o_feet"

name: h2o_feet
time                  percentile  location      level description
----                  ----------  --------      -----------------
2015-08-31T03:42:00Z  1.122       coyote_creek  below 3 feet
```

该查询返回的field value大于measurement `h2o_feet`中field key `water_level`对应的所有field value中的百分之五，以及相关的tag key `location`和field key `level description`的值。

##### 选择指定field key对应的第20个百分位数的field value并包含多个子句

```sql
> SELECT PERCENTILE("water_level",20) FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(24m) fill(15) LIMIT 2

name: h2o_feet
time                   percentile
----                   ----------
2015-08-17T23:36:00Z   15
2015-08-18T00:00:00Z   2.064
```

该查询返回的field value大于measurement `h2o_feet`中field key `water_level`对应的所有field value中的百分之二十，它涵盖的时间范围在`2015-08-17T23:48:00Z`和`2015-08-18T00:54:00Z`之间，并将查询结果按24分钟的时间间隔进行分组，同时，该查询用`15`填充没有数据的时间间隔，并将返回的数据point个数限制为2。

请注意，`GROUP BY time()`子句会覆盖数据point的原始时间戳。查询结果中的时间戳表示每24分钟时间间隔的开始时间，其中，第一个数据point涵盖的时间间隔在`2015-08-17T23:36:00Z`和`2015-08-18T00:00:00Z`之间，最后一个数据point涵盖的时间间隔在`2015-08-18T00:00:00Z`和`2015-08-18T00:24:00Z`之间。

#### `PERCENTILE()`的常见问题

##### `PERCENTILE()` vs 其它InfluxQL函数

* `PERCENTILE(<field_key>,100)`相当于`MAX(<field_key>)`。
* `PERCENTILE(<field_key>, 50)`近似于`MEDIAN(<field_key>)`，除非field key包含的field value有偶数个，那么这时候`MEDIAN()`将返回两个中间值的平均数。
* `PERCENTILE(<field_key>,0)`不等于`MIN(<field_key>)`，`PERCENTILE(<field_key>,0)`会返回`null`。

### SAMPLE()

返回包含N个field value的随机样本。`SAMPLE()`使用[reservoir sampling](https://en.wikipedia.org/wiki/Reservoir_sampling)来生成随机数据point。

#### 语法

```
SELECT SAMPLE(<field_key>, <N>)[,<tag_key(s)>|<field_key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`SAMPLE(field_key,N)`
返回指定field key对应的N个随机选择的field value。

`SAMPLE(/regular_expression/,N)`
返回与正则表达式匹配的每个field key对应的N个随机选择的field value。

`SAMPLE(*,N)`
返回在measurement中每个field key对应的N个随机选择的field value。

`SAMPLE(field_key,N),tag_key(s),field_key(s)`
返回括号中的field key对应的N个随机选择的field value，以及相关的tag和/或field。

`N`必须是整数。`SAMPLE()`支持所有数据类型的field value。

#### 示例

##### 选择指定field key对应的field value的随机样本

```sql
> SELECT SAMPLE("water_level",2) FROM "h2o_feet"

name: h2o_feet
time                   sample
----                   ------
2015-09-09T21:48:00Z   5.659
2015-09-18T10:00:00Z   6.939
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的两个随机选择的数据point。

##### 选择measurement中每个field key对应的field value的随机样本

```sql
> SELECT SAMPLE(*,2) FROM "h2o_feet"

name: h2o_feet
time                   sample_level description   sample_water_level
----                   ------------------------   ------------------
2015-08-25T17:06:00Z                              3.284
2015-09-03T04:30:00Z   below 3 feet
2015-09-03T20:06:00Z   between 3 and 6 feet
2015-09-08T21:54:00Z                              3.412
```

该查询返回measurement `h2o_feet`中每个field key对应的两个随机选择的数据point。measurement `h2o_feet`中有两个field key：`level description`和`water_level`。

##### 选择与正则表达式匹配的每个field key对应的field value的随机样本

```sql
> SELECT SAMPLE(/level/,2) FROM "h2o_feet"

name: h2o_feet
time                   sample_level description   sample_water_level
----                   ------------------------   ------------------
2015-08-30T05:54:00Z   between 6 and 9 feet
2015-09-07T01:18:00Z                              7.854
2015-09-09T20:30:00Z                              7.32
2015-09-13T19:18:00Z   between 3 and 6 feet
```

该查询返回measurement `h2o_feet`中每个包含单词`level`的field key对应的两个随机选择的数据point。

##### 选择指定field key对应的field value的随机样本以及相关的tag和field

```sql
> SELECT SAMPLE("water_level",2),"location","level description" FROM "h2o_feet"

name: h2o_feet
time                  sample  location      level description
----                  ------  --------      -----------------
2015-08-29T10:54:00Z  5.689   coyote_creek  between 3 and 6 feet
2015-09-08T15:48:00Z  6.391   coyote_creek  between 6 and 9 feet
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的两个随机选择的数据point，以及相关的tag key `location`和field key `level description`的值。

##### 选择指定field key对应field value的随机样本并包含多个子句

```sql
> SELECT SAMPLE("water_level",1) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(18m)

name: h2o_feet
time                   sample
----                   ------
2015-08-18T00:12:00Z   2.028
2015-08-18T00:30:00Z   2.051
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的一个随机选择的数据point，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并将查询结果按18分钟的时间间隔进行分组。

请注意，`GROUP BY time()`子句不会覆盖数据point的原始时间戳。请查看下面章节获得更详细的说明。

#### `SAMPLE()`的常见问题

##### `SAMPLE()`和`GROUP BY time()`子句同时使用

对于同时带有`SAMPLE()`和`GROUP BY time()`子句的查询，将返回每个`GROUP BY time()`时间间隔的指定个数(`N`)的数据point。对于大多数`GROUP BY time()`查询，返回的时间戳表示`GROUP BY time()`时间间隔的开始时间，但是，带有`SAMPLE()`函数的`GROUP BY time()`查询则不一样，它们保留原始数据point的时间戳。

###### 示例

以下查询返回每18分钟`GROUP BY time()`间隔对应的两个随机选择的数据point。请注意，返回的时间戳是数据point的原始时间戳；它们不会被强制要求必须匹配`GROUP BY time()`间隔的开始时间。

```sql
> SELECT SAMPLE("water_level",2) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(18m)

name: h2o_feet
time                   sample
----                   ------
                           __
2015-08-18T00:06:00Z   2.116 |
2015-08-18T00:12:00Z   2.028 | <------- Randomly-selected points for the first time interval
                           --
                           __
2015-08-18T00:18:00Z   2.126 |
2015-08-18T00:30:00Z   2.051 | <------- Randomly-selected points for the second time interval
                           --
```

### TOP()

返回最大的N个field value

#### 语法

```
SELECT TOP( <field_key>[,<tag_key(s)>],<N> )[,<tag_key(s)>|<field_key(s)>] [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`TOP(field_key,N)`
返回field key对应的最大的N个值。

`TOP(field_key,tag_key(s),N)`
返回tag key的N个tag value对应的field key的最大值。

`TOP(field_key,N),tag_key(s),field_key(s)`
返回括号中的field key对应的最大的N个值，以及相关的tag和/或field。

`TOP()`支持数据类型为int64和float64的field value。

> **注意：**
>
> * 如果最大值有两个或多个并且它们之间有关联，`TOP()`返回具有最早时间戳的field value。
> * 当`TOP()`函数与`INTO`子句一起使用时，`TOP()`与其它InfluxQL函数不同。请查看TOP()的[常见问题](#common-issues-with-top)章节获得更多信息。
#### 示例

##### 选择指定field key对应的最大的三个值

```sql
> SELECT TOP("water_level",3) FROM "h2o_feet"

name: h2o_feet
time                   top
----                   ---
2015-08-29T07:18:00Z   9.957
2015-08-29T07:24:00Z   9.964
2015-08-29T07:30:00Z   9.954
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的最大的三个值。

##### 选择两个tag对应的field key的最大值

```sql
> SELECT TOP("water_level","location",2) FROM "h2o_feet"

name: h2o_feet
time                   top     location
----                   ---     --------
2015-08-29T03:54:00Z   7.205   santa_monica
2015-08-29T07:24:00Z   9.964   coyote_creek
```

该查询返回tag key `location`的两个tag value对应的field key `water_level`的最大值。

##### 选择指定field key对应的最大的四个值以及相关的tag和field

```sql
> SELECT TOP("water_level",4),"location","level description" FROM "h2o_feet"

name: h2o_feet
time                  top    location      level description
----                  ---    --------      -----------------
2015-08-29T07:18:00Z  9.957  coyote_creek  at or greater than 9 feet
2015-08-29T07:24:00Z  9.964  coyote_creek  at or greater than 9 feet
2015-08-29T07:30:00Z  9.954  coyote_creek  at or greater than 9 feet
2015-08-29T07:36:00Z  9.941  coyote_creek  at or greater than 9 feet
```

该查询返回field key `water_level`对应的最大的四个值，以及相关的tag key `location`和field key `level description`的值。

##### 选择指定field key对应的最大的三个值并包含多个子句

```sql
> SELECT TOP("water_level",3),"location" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(24m) ORDER BY time DESC

name: h2o_feet
time                  top    location
----                  ---    --------
2015-08-18T00:48:00Z  7.11   coyote_creek
2015-08-18T00:54:00Z  6.982  coyote_creek
2015-08-18T00:54:00Z  2.054  santa_monica
2015-08-18T00:24:00Z  7.635  coyote_creek
2015-08-18T00:30:00Z  7.5    coyote_creek
2015-08-18T00:36:00Z  7.372  coyote_creek
2015-08-18T00:00:00Z  8.12   coyote_creek
2015-08-18T00:06:00Z  8.005  coyote_creek
2015-08-18T00:12:00Z  7.887  coyote_creek
```

该查询返回在`2015-08-18T00:00:00Z`和`2015-08-18T00:54:00Z`之间的每个24分钟间隔内，field key `water_level`对应的最大的三个值，并且以递减的时间戳顺序返回结果。

请注意，`GROUP BY time()`子句不会覆盖数据point的原始时间戳。请查看下面章节获得更详细的说明。

#### `TOP()`的常见问题

##### `TOP()`和`GROUP BY time()`子句同时使用

对于同时带有`TOP()`和`GROUP BY time()`子句的查询，将返回每个`GROUP BY time()`时间间隔的指定个数的数据point。对于大多数`GROUP BY time()`查询，返回的时间戳表示`GROUP BY time()`时间间隔的开始时间，但是，带有`TOP()`函数的`GROUP BY time()`查询则不一样，它们保留原始数据point的时间戳。

###### 示例

以下查询返回每18分钟`GROUP BY time()`间隔对应的两个数据point。请注意，返回的时间戳是数据point的原始时间戳；它们不会被强制要求必须匹配`GROUP BY time()`间隔的开始时间。

```sql
> SELECT TOP("water_level",2) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(18m)

name: h2o_feet
time                   top
----                   ------
                           __
2015-08-18T00:00:00Z  2.064 |
2015-08-18T00:06:00Z  2.116 | <------- Greatest points for the first time interval
                           --
                           __
2015-08-18T00:18:00Z  2.126 |
2015-08-18T00:30:00Z  2.051 | <------- Greatest points for the second time interval
                           --
```

##### `TOP()`和具有少于N个tag value的tag key

使用语法`SELECT TOP(<field_key>,<tag_key>,<N>)`的查询可以返回比预期少的数据point。如果tag key有`X`个tag value，但是查询指定的是`N`个tag value，如果`X`小于`N`，那么查询将返回`X`个数据point。

###### 示例

以下查询请求的是tag key `location`的三个tag value对于的`water_level`的最大值。因为tag key `location`只有两个tag value(`santa_monica`和`coyote_creek`)，所以该查询返回两个数据point而不是三个。

```sql
> SELECT TOP("water_level","location",3) FROM "h2o_feet"

name: h2o_feet
time                  top    location
----                  ---    --------
2015-08-29T03:54:00Z  7.205  santa_monica
2015-08-29T07:24:00Z  9.964  coyote_creek
```

##### `TOP()`、tag和`INTO`子句

当使用`INTO`子句但没有使用`GROUP BY tag`子句时，大多数InfluxQL函数将原始数据中的tag转换为新写入数据中的field。这种行为同样适用于`TOP()`函数，除非`TOP()`中包含tag key作为参数：`TOP(field_key,tag_key(s),N)`。在这些情况下，系统会将指定的tag保留为新写入数据中的tag。

###### 示例

下面代码块中的第一个查询返回tag key `location`的两个tag value对应的field key `water_level`的最大值，并且，它这些结果写入measurement `top_water_levels`中。第二个查询展示了InfluxDB将tag `location`保留为measurement `top_water_levels`中的tag。

```sql
> SELECT TOP("water_level","location",2) INTO "top_water_levels" FROM "h2o_feet"

name: result
time                 written
----                 -------
1970-01-01T00:00:00Z 2

> SHOW TAG KEYS FROM "top_water_levels"

name: top_water_levels
tagKey
------
location
```

## Transformations

### ABS()

返回field value的绝对值

#### 基本语法

```
SELECT ABS( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`ABS(field_key)`
返回field key对应的field value的绝对值。

`ABS(*)`
返回在measurement中每个field key对应的field value的绝对值。

`ABS()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`ABS()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea)中的如下数据：

```sql
> SELECT * FROM "data" WHERE time >= '2018-06-24T12:00:00Z' AND time <= '2018-06-24T12:05:00Z'

name: data
time                 a                   b
----                 -                   -
1529841600000000000  1.33909108671076    -0.163643058925645
1529841660000000000  -0.774984088561186  0.137034364053949
1529841720000000000  -0.921037167720451  -0.482943221384294
1529841780000000000  -1.73880754843378   -0.0729732928756677
1529841840000000000  -0.905980032168252  1.77857552719844
1529841900000000000  -0.891164752631417  0.741147445214238
```

###### 计算指定field key对应的field value的绝对值

```sql
> SELECT ABS("a") FROM "data" WHERE time >= '2018-06-24T12:00:00Z' AND time <= '2018-06-24T12:05:00Z'

name: data
time                 abs
----                 ---
1529841600000000000  1.33909108671076
1529841660000000000  0.774984088561186
1529841720000000000  0.921037167720451
1529841780000000000  1.73880754843378
1529841840000000000  0.905980032168252
1529841900000000000  0.891164752631417
```

该查询返回measurement `data`中field key `a`对应的field value的绝对值。

###### 计算measurement中每个field key对应的field value的绝对值

```sql
> SELECT ABS(*) FROM "data" WHERE time >= '2018-06-24T12:00:00Z' AND time <= '2018-06-24T12:05:00Z'

name: data
time                 abs_a              abs_b
----                 -----              -----
1529841600000000000  1.33909108671076   0.163643058925645
1529841660000000000  0.774984088561186  0.137034364053949
1529841720000000000  0.921037167720451  0.482943221384294
1529841780000000000  1.73880754843378   0.0729732928756677
1529841840000000000  0.905980032168252  1.77857552719844
1529841900000000000  0.891164752631417  0.741147445214238
```

该查询返回measurement `data`中每个存储数值的field key对应的field value的绝对值。measurement `data`中有两个数值类型的field：`a`和`b`。

<!-- ##### Calculate the absolute values of field values associated with each field key that matches a regular expression

```
> SELECT ABS(/a/) FROM "h2o_feet" WHERE time >= '2018-06-24T12:00:00Z' AND time <= '2018-06-24T12:05:00Z' AND "location" = 'santa_monica'

name: data
time                 abs
----                 ---
1529841600000000000  1.33909108671076
1529841660000000000  0.774984088561186
1529841720000000000  0.921037167720451
1529841780000000000  1.73880754843378
1529841840000000000  0.905980032168252
1529841900000000000  0.891164752631417
```

The query returns the absolute values of field values for each field key that stores numerical values and includes `a` in the `data` measurement. -->

###### 计算指定field key对应的field value的绝对值并包含多个子句

```sql
> SELECT ABS("a") FROM "data" WHERE time >= '2018-06-24T12:00:00Z' AND time <= '2018-06-24T12:05:00Z' ORDER BY time DESC LIMIT 4 OFFSET 2

name: data
time                 abs
----                 ---
1529841780000000000  1.73880754843378
1529841720000000000  0.921037167720451
1529841660000000000  0.774984088561186
1529841600000000000  1.33909108671076
```

该查询返回measurement `data`中field key `a`对应的field value的绝对值，它涵盖的时间范围在`2018-06-24T12:00:00Z`和`2018-06-24T12:05:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个（即前两个数据point不返回）。

#### 高级语法

```
SELECT ABS(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的绝对值。

`ABS()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值的绝对值

```sql
> SELECT ABS(MEAN("a")) FROM "data" WHERE time >= '2018-06-24T12:00:00Z' AND time <= '2018-06-24T13:00:00Z' GROUP BY time(12m)

name: data
time                 abs
----                 ---
1529841600000000000  0.3960977256302787
1529842320000000000  0.0010541018316373302
1529843040000000000  0.04494733240283668
1529843760000000000  0.2553594777104415
1529844480000000000  0.20382988543108413
1529845200000000000  0.790836070736962
```

该查询返回field key `a`对应的每12分钟的时间间隔的field value的平均值的绝对值。

为了得到这些结果，InfluxDB首先计算field key `a`对应的每12分钟的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`ABS()`的情形一样：

```sql
> SELECT MEAN("a") FROM "data" WHERE time >= '2018-06-24T12:00:00Z' AND time <= '2018-06-24T13:00:00Z' GROUP BY time(12m)

name: data
time                 mean
----                 ----
1529841600000000000  -0.3960977256302787
1529842320000000000  0.0010541018316373302
1529843040000000000  0.04494733240283668
1529843760000000000  0.2553594777104415
1529844480000000000  0.20382988543108413
1529845200000000000  -0.790836070736962
```

然后，InfluxDB计算这些平均值的绝对值。

### ACOS()

返回field value的反余弦(以弧度表示)。field value必须在-1和1之间。

#### 基本语法

```
SELECT ACOS( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`ACOS(field_key)`
返回field key对应的field value的反余弦。

`ACOS(*)`
返回在measurement中每个field key对应的field value的反余弦。

`ACOS()`支持数据类型为int64和float64的field value，并且field value必须在-1和1之间。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`ACOS()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用如下模拟的公园占有率(相对于总空间)的数据。需要注意的重要事项是，所有的field value都在`ACOS()`函数的可计算范围里(-1到1)：

```sql
> SELECT "of_capacity" FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z'

name: park_occupancy
time                  capacity
----                  --------
2017-05-01T00:00:00Z  0.83
2017-05-02T00:00:00Z  0.3
2017-05-03T00:00:00Z  0.84
2017-05-04T00:00:00Z  0.22
2017-05-05T00:00:00Z  0.17
2017-05-06T00:00:00Z  0.77
2017-05-07T00:00:00Z  0.64
2017-05-08T00:00:00Z  0.72
2017-05-09T00:00:00Z  0.16
```

###### 计算指定field key对应的field value的反余弦

```sql
> SELECT ACOS("of_capacity") FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z'

name: park_occupancy
time                  acos
----                  ----
2017-05-01T00:00:00Z  0.591688642426544
2017-05-02T00:00:00Z  1.266103672779499
2017-05-03T00:00:00Z  0.5735131044230969
2017-05-04T00:00:00Z  1.3489818562981022
2017-05-05T00:00:00Z  1.399966657665792
2017-05-06T00:00:00Z  0.6919551751263169
2017-05-07T00:00:00Z  0.8762980611683406
2017-05-08T00:00:00Z  0.7669940078618667
2017-05-09T00:00:00Z  1.410105673842986
```

该查询返回measurement `park_occupancy`中field key `of_capacity`对应的field value的反余弦。

###### 计算measurement中每个field key对应的field value的反余弦

```sql
> SELECT ACOS(*) FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z'

name: park_occupancy
time                  acos_of_capacity
----                  -------------
2017-05-01T00:00:00Z  0.591688642426544
2017-05-02T00:00:00Z  1.266103672779499
2017-05-03T00:00:00Z  0.5735131044230969
2017-05-04T00:00:00Z  1.3489818562981022
2017-05-05T00:00:00Z  1.399966657665792
2017-05-06T00:00:00Z  0.6919551751263169
2017-05-07T00:00:00Z  0.8762980611683406
2017-05-08T00:00:00Z  0.7669940078618667
2017-05-09T00:00:00Z  1.410105673842986
```

该查询返回measurement `park_occupancy`中每个存储数值的field key对应的field value的反余弦。measurement `park_occupancy`中只有一个数值类型的field：`of_capacity`。

<!-- ##### Calculate the arccosine of field values associated with each field key that matches a regular expression
```
> SELECT ACOS(/capacity/) FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z'

name: park_occupancy
time                  acos_of_capacity
----                  ----------------
2017-05-01T00:00:00Z  0.591688642426544
2017-05-02T00:00:00Z  1.266103672779499
2017-05-03T00:00:00Z  0.5735131044230969
2017-05-04T00:00:00Z  1.3489818562981022
2017-05-05T00:00:00Z  1.399966657665792
2017-05-06T00:00:00Z  0.6919551751263169
2017-05-07T00:00:00Z  0.8762980611683406
2017-05-08T00:00:00Z  0.7669940078618667
2017-05-09T00:00:00Z  1.410105673842986
```

The query returns arccosine of field values for each field key that stores numerical values and includes the word `capacity` in the `park_occupancy` measurement. -->

###### 计算指定field key对应的field value的反余弦并包含多个子句

```sql
> SELECT ACOS("of_capacity") FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z' ORDER BY time DESC LIMIT 4 OFFSET 2

name: park_occupancy
time                  acos
----                  ----
2017-05-07T00:00:00Z  0.8762980611683406
2017-05-06T00:00:00Z  0.6919551751263169
2017-05-05T00:00:00Z  1.399966657665792
2017-05-04T00:00:00Z  1.3489818562981022
```

该查询返回measurement `park_occupancy`中field key `of_capacity`对应的field value的反余弦，它涵盖的时间范围在`2017-05-01T00:00:00Z`和`2017-05-09T00:00:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个（即前两个数据point不返回）。

#### 高级语法

```
SELECT ACOS(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的反余弦。

`ACOS()支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值的反余弦

```sql
> SELECT ACOS(MEAN("of_capacity")) FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z' GROUP BY time(3d)

name: park_occupancy
time                  acos
----                  ----
2017-04-30T00:00:00Z  0.9703630732143733
2017-05-03T00:00:00Z  1.1483422646081407
2017-05-06T00:00:00Z  0.7812981174487247
2017-05-09T00:00:00Z  1.410105673842986
```

该查询返回field key `of_capacity`对应的每三天的时间间隔的field value的平均值的反余弦。

为了得到这些结果，InfluxDB首先计算field key `of_capacity`对应的每三天的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`ACOS()`的情形一样：

```sql
> SELECT MEAN("of_capacity") FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z' GROUP BY time(3d)

name: park_occupancy
time                  mean
----                  ----
2017-04-30T00:00:00Z  0.565
2017-05-03T00:00:00Z  0.41
2017-05-06T00:00:00Z  0.71
2017-05-09T00:00:00Z  0.16
```

然后，InfluxDB计算这些平均值的反余弦。

### ASIN()

返回field value的反正弦(以弧度表示)。field value必须在-1和1之间。

#### 基本语法

```
SELECT ASIN( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`ASIN(field_key)`
返回field key对应的field value的反正弦。

`ASIN(*)`
返回在measurement中每个field key对应的field value的反正弦。

`ASIN()`支持数据类型为int64和float64的field value，并且field value必须在-1和1之间。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`ASIN()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用如下模拟的公园占有率(相对于总空间)的数据。需要注意的重要事项是，所有的field value都在`ASIN()`函数的可计算范围里(-1到1)：

```sql
> SELECT "of_capacity" FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z'

name: park_occupancy
time                  capacity
----                  --------
2017-05-01T00:00:00Z  0.83
2017-05-02T00:00:00Z  0.3
2017-05-03T00:00:00Z  0.84
2017-05-04T00:00:00Z  0.22
2017-05-05T00:00:00Z  0.17
2017-05-06T00:00:00Z  0.77
2017-05-07T00:00:00Z  0.64
2017-05-08T00:00:00Z  0.72
2017-05-09T00:00:00Z  0.16
```

###### 计算指定field key对应的field value的反正弦

```sql
> SELECT ASIN("of_capacity") FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z'

name: park_occupancy
time                  asin
----                  ----
2017-05-01T00:00:00Z  0.9791076843683526
2017-05-02T00:00:00Z  0.3046926540153975
2017-05-03T00:00:00Z  0.9972832223717997
2017-05-04T00:00:00Z  0.22181447049679442
2017-05-05T00:00:00Z  0.1708296691291045
2017-05-06T00:00:00Z  0.8788411516685797
2017-05-07T00:00:00Z  0.6944982656265559
2017-05-08T00:00:00Z  0.8038023189330299
2017-05-09T00:00:00Z  0.1606906529519106
```

该查询返回measurement `park_occupancy`中field key `of_capacity`对应的field value的反正弦。

###### 计算measurement中每个field key对应的field value的反正弦

```sql
> SELECT ASIN(*) FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z'

name: park_occupancy
time                  asin_of_capacity
----                  -------------
2017-05-01T00:00:00Z  0.9791076843683526
2017-05-02T00:00:00Z  0.3046926540153975
2017-05-03T00:00:00Z  0.9972832223717997
2017-05-04T00:00:00Z  0.22181447049679442
2017-05-05T00:00:00Z  0.1708296691291045
2017-05-06T00:00:00Z  0.8788411516685797
2017-05-07T00:00:00Z  0.6944982656265559
2017-05-08T00:00:00Z  0.8038023189330299
2017-05-09T00:00:00Z  0.1606906529519106
```

该查询返回measurement `park_occupancy`中每个存储数值的field key对应的field value的反正弦。measurement `park_occupancy`中只有一个数值类型的field：`of_capacity`。

<!-- ##### Calculate the arcsine of field values associated with each field key that matches a regular expression
```
> SELECT ASIN(/capacity/) FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z'

name: park_occupancy
time                  asin
----                  ----
2017-05-01T00:00:00Z  0.9791076843683526
2017-05-02T00:00:00Z  0.3046926540153975
2017-05-03T00:00:00Z  0.9972832223717997
2017-05-04T00:00:00Z  0.22181447049679442
2017-05-05T00:00:00Z  0.1708296691291045
2017-05-06T00:00:00Z  0.8788411516685797
2017-05-07T00:00:00Z  0.6944982656265559
2017-05-08T00:00:00Z  0.8038023189330299
2017-05-09T00:00:00Z  0.1606906529519106
```

该查询将为每个field key 返回field value的反正弦值，该键将数值存储在`park_capacity`measurement中。该h2o_feetmeasurement具有一个数字字段：`of_capacity`

###### 计算指定field key对应的field value的反正弦并包含多个子句

```sql
> SELECT ASIN("of_capacity") FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z' ORDER BY time DESC LIMIT 4 OFFSET 2

name: park_occupancy
time                  asin
----                  ----
2017-05-07T00:00:00Z  0.6944982656265559
2017-05-06T00:00:00Z  0.8788411516685797
2017-05-05T00:00:00Z  0.1708296691291045
2017-05-04T00:00:00Z  0.22181447049679442
```

该查询返回measurement `park_occupancy`中field key `of_capacity`对应的field value的反正弦，它涵盖的时间范围在`2017-05-01T00:00:00Z`和`2017-05-09T00:00:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个（即前两个数据point不返回）。

#### 高级语法

```
SELECT ASIN(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的反正弦。

ASIN()支持以下嵌套函数：

[`COUNT()`](#count),
[`MEAN()`](#mean),
[`MEDIAN()`](#median),
[`MODE()`](#mode),
[`SUM()`](#sum),
[`FIRST()`](#first),
[`LAST()`](#last),
[`MIN()`](#min),
[`MAX()`](#max), and
[`PERCENTILE()`](#percentile).

##### 示例

###### 计算平均值的反正弦

```sql
> SELECT ASIN(MEAN("of_capacity")) FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z' GROUP BY time(3d)

name: park_occupancy
time                  asin
----                  ----
2017-04-30T00:00:00Z  0.6004332535805232
2017-05-03T00:00:00Z  0.42245406218675574
2017-05-06T00:00:00Z  0.7894982093461719
2017-05-09T00:00:00Z  0.1606906529519106
```

该查询返回field key `of_capacity`对应的每三天的时间间隔的field value的平均值的反正弦。

为了得到这些结果，InfluxDB首先计算field key `of_capacity`对应的每三天的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`ASIN()`的情形一样：

```sql
> SELECT MEAN("of_capacity") FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z' GROUP BY time(3d)

name: park_occupancy
time                  mean
----                  ----
2017-04-30T00:00:00Z  0.565
2017-05-03T00:00:00Z  0.41
2017-05-06T00:00:00Z  0.71
2017-05-09T00:00:00Z  0.16
```

然后，InfluxDB计算这些平均值的反正弦。

### ATAN()

返回field value的反正切（以弧度表示)。field value必须在-1和1之间。

#### Basic syntax

```sql
SELECT ATAN( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`ATAN(field_key)`
返回field key对应的field value的反正切。

`ATAN(*)`
返回在measurement中每个field key对应的field value的反正切。

`ATAN()`支持数据类型为int64和float64的field value，并且field value必须在-1和1之间。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`ATAN()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用如下模拟的公园占有率(相对于总空间)的数据。需要注意的重要事项是，所有的field value都在`ATAN()`函数的可计算范围里(-1到1)：

```sql
> SELECT "of_capacity" FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z'

name: park_occupancy
time                  capacity
----                  --------
2017-05-01T00:00:00Z  0.83
2017-05-02T00:00:00Z  0.3
2017-05-03T00:00:00Z  0.84
2017-05-04T00:00:00Z  0.22
2017-05-05T00:00:00Z  0.17
2017-05-06T00:00:00Z  0.77
2017-05-07T00:00:00Z  0.64
2017-05-08T00:00:00Z  0.72
2017-05-09T00:00:00Z  0.16
```

###### 计算指定field key对应的field value的反正切

```sql
> SELECT ATAN("of_capacity") FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z'

name: park_occupancy
time                  atan
----                  ----
2017-05-01T00:00:00Z  0.6927678353971222
2017-05-02T00:00:00Z  0.2914567944778671
2017-05-03T00:00:00Z  0.6986598247214632
2017-05-04T00:00:00Z  0.2165503049760893
2017-05-05T00:00:00Z  0.16839015714752992
2017-05-06T00:00:00Z  0.6561787179913948
2017-05-07T00:00:00Z  0.5693131911006619
2017-05-08T00:00:00Z  0.6240230529767568
2017-05-09T00:00:00Z  0.1586552621864014
```

该查询返回measurement `park_occupancy`中field key `of_capacity`对应的field value的反正切。

###### 计算measurement中每个field key对应的field value的反正切

```sql
> SELECT ATAN(*) FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z'

name: park_occupancy
time                  atan_of_capacity
----                  -------------
2017-05-01T00:00:00Z  0.6927678353971222
2017-05-02T00:00:00Z  0.2914567944778671
2017-05-03T00:00:00Z  0.6986598247214632
2017-05-04T00:00:00Z  0.2165503049760893
2017-05-05T00:00:00Z  0.16839015714752992
2017-05-06T00:00:00Z  0.6561787179913948
2017-05-07T00:00:00Z  0.5693131911006619
2017-05-08T00:00:00Z  0.6240230529767568
2017-05-09T00:00:00Z  0.1586552621864014
```

该查询返回measurement `park_occupancy`中每个存储数值的field key对应的field value的反正切。measurement `park_occupancy`中只有一个数值类型的field：`of_capacity`。

<!-- ##### Calculate the arctangent of field values associated with each field key that matches a regular expression
```
> SELECT ATAN(/capacity/) FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z'

name: park_occupancy
time                  atan_of_capacity
----                  -------------
2017-05-01T00:00:00Z  0.6927678353971222
2017-05-02T00:00:00Z  0.2914567944778671
2017-05-03T00:00:00Z  0.6986598247214632
2017-05-04T00:00:00Z  0.2165503049760893
2017-05-05T00:00:00Z  0.16839015714752992
2017-05-06T00:00:00Z  0.6561787179913948
2017-05-07T00:00:00Z  0.5693131911006619
2017-05-08T00:00:00Z  0.6240230529767568
2017-05-09T00:00:00Z  0.1586552621864014
```

The query returns arctangent of field values for each field key that stores numerical values and includes the word `capacity` in the `park_occupancy` measurement. -->

###### 计算指定field key对应的field value的反正切并包含多个子句

```sql
> SELECT ATAN("of_capacity") FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z' ORDER BY time DESC LIMIT 4 OFFSET 2

name: park_occupancy
time                  atan
----                  ----
2017-05-07T00:00:00Z  0.5693131911006619
2017-05-06T00:00:00Z  0.6561787179913948
2017-05-05T00:00:00Z  0.16839015714752992
2017-05-04T00:00:00Z  0.2165503049760893
```

该查询返回measurement `park_occupancy`中field key `of_capacity`对应的field value的反正切，它涵盖的时间范围在`2017-05-01T00:00:00Z`和`2017-05-09T00:00:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个（即前两个数据point不返回）。

#### 高级语法

```
SELECT ATAN(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的反正切。

`ATAN()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值的反正切

```sql
> SELECT ATAN(MEAN("of_capacity")) FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z' GROUP BY time(3d)

name: park_occupancy
time                 atan
----                 ----
2017-04-30T00:00:00Z 0.5142865412694495
2017-05-03T00:00:00Z 0.3890972310552784
2017-05-06T00:00:00Z 0.6174058917515726
2017-05-09T00:00:00Z 0.1586552621864014
```

该查询返回field key `of_capacity`对应的每三天的时间间隔的field value的平均值的反正切。

为了得到这些结果，InfluxDB首先计算field key `of_capacity`对应的每三天的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`ATAN()`的情形一样：

```sql
> SELECT MEAN("of_capacity") FROM "park_occupancy" WHERE time >= '2017-05-01T00:00:00Z' AND time <= '2017-05-09T00:00:00Z' GROUP BY time(3d)

name: park_occupancy
time                  mean
----                  ----
2017-04-30T00:00:00Z  0.565
2017-05-03T00:00:00Z  0.41
2017-05-06T00:00:00Z  0.71
2017-05-09T00:00:00Z  0.16
```

然后，InfluxDB计算这些平均值的反正切。

### ATAN2()

返回以弧度表示的`y/x`的反正切。

#### 基本语法

```
SELECT ATAN2( [ * | <field_key> | num ], [ <field_key> | num ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`ATAN2(field_key_y, field_key_x)`
返回field key “field_key_y”对应的field value除以field key “field_key_x”对应的field value的反正切。

`ATAN2(*, field_key_x)<br />`返回在measurement中每个field key对应的field value除以field key “field_key_x”对应的field value的反正切。

`ATAN2()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`ATAN2()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用如下模拟的飞行数据：

```sql
> SELECT "altitude_ft", "distance_ft" FROM "flight_data" WHERE time >= '2018-05-16T12:01:00Z' AND time <= '2018-05-16T12:10:00Z'

name: flight_data
time                  altitude_ft  distance_ft
----                  -----------  -----------
2018-05-16T12:01:00Z  1026         50094
2018-05-16T12:02:00Z  2549         53576
2018-05-16T12:03:00Z  4033         55208
2018-05-16T12:04:00Z  5579         58579
2018-05-16T12:05:00Z  7065         61213
2018-05-16T12:06:00Z  8589         64807
2018-05-16T12:07:00Z  10180        67707
2018-05-16T12:08:00Z  11777        69819
2018-05-16T12:09:00Z  13321        72452
2018-05-16T12:10:00Z  14885        75881
```

###### 计算field_key_y除以field_key_x的反正切

```sql
> SELECT ATAN2("altitude_ft", "distance_ft") FROM "flight_data" WHERE time >= '2018-05-16T12:01:00Z' AND time <= '2018-05-16T12:10:00Z'

name: flight_data
time                  atan2
----                  -----
2018-05-16T12:01:00Z  0.020478631571881498
2018-05-16T12:02:00Z  0.04754142349303296
2018-05-16T12:03:00Z  0.07292147724575364
2018-05-16T12:04:00Z  0.09495251193874832
2018-05-16T12:05:00Z  0.11490822875441563
2018-05-16T12:06:00Z  0.13176409347584003
2018-05-16T12:07:00Z  0.14923587589682233
2018-05-16T12:08:00Z  0.1671059946640312
2018-05-16T12:09:00Z  0.18182893717409565
2018-05-16T12:10:00Z  0.1937028631495223
```

该查询返回field key `altitude_ft`对应的field value除以field key `distance_ft`对应的field value的反正切。这两个field key都在measurement `flight_data`中。

###### 计算measurement中每个field key除以field_key_x的反正切

```sql
> SELECT ATAN2(*, "distance_ft") FROM "flight_data" WHERE time >= '2018-05-16T12:01:00Z' AND time <= '2018-05-16T12:10:00Z'

name: flight_data
time                  atan2_altitude_ft     atan2_distance_ft
----                  -----------------     -----------------
2018-05-16T12:01:00Z  0.020478631571881498  0.7853981633974483
2018-05-16T12:02:00Z  0.04754142349303296   0.7853981633974483
2018-05-16T12:03:00Z  0.07292147724575364   0.7853981633974483
2018-05-16T12:04:00Z  0.09495251193874832   0.7853981633974483
2018-05-16T12:05:00Z  0.11490822875441563   0.7853981633974483
2018-05-16T12:06:00Z  0.13176409347584003   0.7853981633974483
2018-05-16T12:07:00Z  0.14923587589682233   0.7853981633974483
2018-05-16T12:08:00Z  0.1671059946640312    0.7853981633974483
2018-05-16T12:09:00Z  0.18182893717409565   0.7853981633974483
2018-05-16T12:10:00Z  0.19370286314952234   0.7853981633974483
```

该查询返回measurement `flight_data`中每个存储数值的field key对应的field value除以field key `distance_ft`对应的field value的反正切。measurement `flight_data`中有两个数值类型的field：`altitude_ft`和`distance_ft`。

<!-- ##### Calculate the arctangent of values associated with each field key matching a regular expression divided by field_key_x
```
> SELECT ATAN2(/ft/, "distance_ft") FROM "flight_data" WHERE time >= '2018-05-16T12:01:00Z' AND time <= '2018-05-16T12:10:00Z'

name: flight_data
time                  atan2_altitude_ft     atan2_distance_ft
----                  -----------------     -----------------
2018-05-16T12:01:00Z  0.020478631571881498  0.7853981633974483
2018-05-16T12:02:00Z  0.04754142349303296   0.7853981633974483
2018-05-16T12:03:00Z  0.07292147724575364   0.7853981633974483
2018-05-16T12:04:00Z  0.09495251193874832   0.7853981633974483
2018-05-16T12:05:00Z  0.11490822875441563   0.7853981633974483
2018-05-16T12:06:00Z  0.13176409347584003   0.7853981633974483
2018-05-16T12:07:00Z  0.14923587589682233   0.7853981633974483
2018-05-16T12:08:00Z  0.1671059946640312    0.7853981633974483
2018-05-16T12:09:00Z  0.18182893717409565   0.7853981633974483
2018-05-16T12:10:00Z  0.19370286314952234   0.7853981633974483
```

The query returns the arctangents of all numeric field values in the `flight_data` measurement that match the `/ft/` regular expression divided by values in the `distance_ft` field key.
The `flight_data` measurement has two matching numeric fields: `altitude_ft` and `distance_ft`.
-->

###### 计算field value的反正切并包含多个子句

```sql
> SELECT ATAN2("altitude_ft", "distance_ft") FROM "flight_data" WHERE time >= '2018-05-16T12:01:00Z' AND time <= '2018-05-16T12:10:00Z' ORDER BY time DESC LIMIT 4 OFFSET 2

name: flight_data
time                  atan2
----                  -----
2018-05-16T12:08:00Z  0.1671059946640312
2018-05-16T12:07:00Z  0.14923587589682233
2018-05-16T12:06:00Z  0.13176409347584003
2018-05-16T12:05:00Z  0.11490822875441563
```

该查询返回field key `altitude_ft`对应的field value除以field key `distance_ft`对应的field value的反正切，它涵盖的时间范围在`2018-05-16T12:10:00Z`和`2018-05-16T12:10:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个(即前两个数据point不返回）。

#### 高级语法

```
SELECT ATAN2(<function()>, <function()>) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的反正切(`ATAN2()`)。

ATAN2()支持以下嵌套函数：

- COUNT()
- MEAN()
- MEDIAN()
- MODE()
- SUM()
- FIRST()
- LAST()
- MIN()
- MAX()
- PERCENTILE()

##### 示例

###### 计算平均值的反正切

```sql
> SELECT ATAN2(MEAN("altitude_ft"), MEAN("distance_ft")) FROM "flight_data" WHERE time >= '2018-05-16T12:01:00Z' AND time <= '2018-05-16T13:01:00Z' GROUP BY time(12m)

name: flight_data
time                  atan2
----                  -----
2018-05-16T12:00:00Z  0.133815587896842
2018-05-16T12:12:00Z  0.2662716308351908
2018-05-16T12:24:00Z  0.2958845306108965
2018-05-16T12:36:00Z  0.23783439588429497
2018-05-16T12:48:00Z  0.1906803720242831
2018-05-16T13:00:00Z  0.17291511946158172
```

该查询返回field key `altitude_ft`对应的field value的平均值除以field key `distance_ft`对应的field value的平均值的反正切。平均值是按每12分钟的时间间隔计算的。

为了得到这些结果，InfluxDB首先计算field key `altitude_ft`和`distance_ft`对应的每12分钟的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`ATAN2()`的情形一样：

```sql
> SELECT MEAN("altitude_ft"), MEAN("distance_ft") FROM "flight_data" WHERE time >= '2018-05-16T12:01:00Z' AND time <= '2018-05-16T13:01:00Z' GROUP BY time(12m)

name: flight_data
time                  mean                mean_1
----                  ----                ------
2018-05-16T12:00:00Z  8674                64433.181818181816
2018-05-16T12:12:00Z  26419.833333333332  96865.25
2018-05-16T12:24:00Z  40337.416666666664  132326.41666666666
2018-05-16T12:36:00Z  41149.583333333336  169743.16666666666
2018-05-16T12:48:00Z  41230.416666666664  213600.91666666666
2018-05-16T13:00:00Z  41184.5             235799
```

然后，InfluxDB计算这些平均值的反正切。

### CEIL()

返回大于指定值的最小整数。

#### 基本语法

```
SELECT CEIL( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`CEIL(field_key)`
返回field key对应的大于field value的最小整数。

`CEIL(*)`
返回在measurement中每个field key对应的大于field value的最小整数。

`CEIL()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`CEIL()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用[`NOAA_water_database`数据集](/influxdb/v1.8/query_language/data_download/)的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的大于field value的最小整数

```sql
> SELECT CEIL("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  ceil
----                  ----
2015-08-18T00:00:00Z  3
2015-08-18T00:06:00Z  3
2015-08-18T00:12:00Z  3
2015-08-18T00:18:00Z  3
2015-08-18T00:24:00Z  3
2015-08-18T00:30:00Z  3
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的大于field value的最小整数。

###### 计算measurement中每个field key对应的大于field value的最小整数

```sql
> SELECT CEIL(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  ceil_water_level
----                  ----------------
2015-08-18T00:00:00Z  3
2015-08-18T00:06:00Z  3
2015-08-18T00:12:00Z  3
2015-08-18T00:18:00Z  3
2015-08-18T00:24:00Z  3
2015-08-18T00:30:00Z  3
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的大于field value的最小整数。measurement `h2o_feet`只有一个数值类型的field：`water_level`。

<!-- ##### Calculate the ceiling of the field values associated with each field key that matches a regular expression
```
> SELECT CEIL(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                   ceil_water_level
----                   ----------------
2015-08-18T00:00:00Z   3
2015-08-18T00:06:00Z   3
2015-08-18T00:12:00Z   3
2015-08-18T00:18:00Z   3
2015-08-18T00:24:00Z   3
2015-08-18T00:30:00Z   3
```

The query returns field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement rounded up to the nearest integer. -->

###### 计算指定field key对应的大于field value的最小整数并包含多个子句

```sql
> SELECT CEIL("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  ceil
----                  ----
2015-08-18T00:18:00Z  3
2015-08-18T00:12:00Z  3
2015-08-18T00:06:00Z  3
2015-08-18T00:00:00Z  3
```

该查询返回field key `water_level`对应的大于field value的最小整数，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个（即前两个数据point不返回)。

#### 高级语法

```
SELECT CEIL(<function>( [ * | <field_key> | /<regular_expression>/ ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后将`CEIL()`应用于这些结果。

`CEIL()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算大于平均值的最小整数

```sql
> SELECT CEIL(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  ceil
----                  ----
2015-08-18T00:00:00Z  3
2015-08-18T00:12:00Z  3
2015-08-18T00:24:00Z  3
```

该查询返回每12分钟的时间间隔对应的大于`water_level`平均值的最小整数。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的大于`water_level`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`CEIL()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算大于这些平均值的最小整数。

### COS()

返回field value的余弦值。

#### 基本语法

```
SELECT COS( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`COS(field_key)`
返回field key对应的field value的余弦值。

`COS(*)`
返回在measurement中每个field key对应的field value的余弦值。

`COS()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`COS()`和`GROUP BY time()`子句。

##### 示例

###### 下面的示例将使用`NOAA_water_database`数据集的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的field value的余弦值

```sql
> SELECT COS("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  cos
----                  ---
2015-08-18T00:00:00Z  -0.47345017433543124
2015-08-18T00:06:00Z  -0.5185922462666872
2015-08-18T00:12:00Z  -0.4414407189100776
2015-08-18T00:18:00Z  -0.5271163912192579
2015-08-18T00:24:00Z  -0.45306786455514825
2015-08-18T00:30:00Z  -0.4619598230611262
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的余弦值。

###### 计算measurement中每个field key对应的field value的余弦值

```sql
> SELECT COS(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  cos_water_level
----                  ---------------
2015-08-18T00:00:00Z  -0.47345017433543124
2015-08-18T00:06:00Z  -0.5185922462666872
2015-08-18T00:12:00Z  -0.4414407189100776
2015-08-18T00:18:00Z  -0.5271163912192579
2015-08-18T00:24:00Z  -0.45306786455514825
2015-08-18T00:30:00Z  -0.4619598230611262
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的余弦值。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

<!-- ##### Calculate the cosine of field values associated with each field key that matches a regular expression
```
> SELECT COS(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  cos
----                  ---
2015-08-18T00:00:00Z  -0.47345017433543124
2015-08-18T00:06:00Z  -0.5185922462666872
2015-08-18T00:12:00Z  -0.4414407189100776
2015-08-18T00:18:00Z  -0.5271163912192579
2015-08-18T00:24:00Z  -0.45306786455514825
2015-08-18T00:30:00Z  -0.4619598230611262
```

The query returns cosine of field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement. -->

###### 计算指定field key对应的field value的余弦值并包含多个子句

```sql
> SELECT COS("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  cos
----                  ---
2015-08-18T00:18:00Z  -0.5271163912192579
2015-08-18T00:12:00Z  -0.4414407189100776
2015-08-18T00:06:00Z  -0.5185922462666872
2015-08-18T00:00:00Z  -0.47345017433543124
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的余弦值，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个（即前两个数据point不返回）。

#### 高级语法

```
SELECT COS(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的余弦值。

`COS()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

#### 示例

###### 计算平均值的余弦值

```sql
> SELECT COS(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  cos
----                  ---
2015-08-18T00:00:00Z  -0.49618891270599885
2015-08-18T00:12:00Z  -0.4848605136571181
2015-08-18T00:24:00Z  -0.4575195627907578
```

该查询返回field key `water_level`对应的每12分钟的时间间隔的field value的平均值的余弦值。

为了得到这些结果，InfluxDB首先计算field key `water_level`对应的每12分钟的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`COS()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值的余弦值。

### CUMULATIVE_SUM()

返回field value的累积总和。

#### 基本语法

```
SELECT CUMULATIVE_SUM( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`CUMULATIVE_SUM(field_key)`
返回field key对应的field value的累积总和。

`CUMULATIVE_SUM(/regular_expression/)`
返回与正则表达式匹配的每个field key对应的field value的累积总和。

`CUMULATIVE_SUM(*)`
返回在measurement中每个field key对应的field value的累积总和。

`CUMULATIVE_SUM()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`CUMULATIVE_SUM()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用`NOAA_water_database`数据集的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
2015-08-18T00:12:00Z   2.028
2015-08-18T00:18:00Z   2.126
2015-08-18T00:24:00Z   2.041
2015-08-18T00:30:00Z   2.051
```

###### 计算指定field key对应的field value的累积总和

```sql
> SELECT CUMULATIVE_SUM("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                   cumulative_sum
----                   --------------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   4.18
2015-08-18T00:12:00Z   6.208
2015-08-18T00:18:00Z   8.334
2015-08-18T00:24:00Z   10.375
2015-08-18T00:30:00Z   12.426
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的累积总和。

###### 计算measurement中每个field key对应的field value的累积总和

```sql
> SELECT CUMULATIVE_SUM(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                   cumulative_sum_water_level
----                   --------------------------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   4.18
2015-08-18T00:12:00Z   6.208
2015-08-18T00:18:00Z   8.334
2015-08-18T00:24:00Z   10.375
2015-08-18T00:30:00Z   12.426
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的累积总和。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

###### 计算与正则表达式匹配的每个field key对应的field value的累积总和

```sql
> SELECT CUMULATIVE_SUM(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                   cumulative_sum_water_level
----                   --------------------------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   4.18
2015-08-18T00:12:00Z   6.208
2015-08-18T00:18:00Z   8.334
2015-08-18T00:24:00Z   10.375
2015-08-18T00:30:00Z   12.426
```

该查询返回measurement `h2o_feet`中每个存储数值并包含单词`water`的field key对应的field value的累积总和。

###### 计算指定field key对应的field value的累积总和并包含多个子句

```sql
> SELECT CUMULATIVE_SUM("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  cumulative_sum
----                  --------------
2015-08-18T00:18:00Z  6.218
2015-08-18T00:12:00Z  8.246
2015-08-18T00:06:00Z  10.362
2015-08-18T00:00:00Z  12.426
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的累积总和，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个（即前两个数据point不返回）。

#### 高级语法

```
SELECT CUMULATIVE_SUM(<function>( [ * | <field_key> | /<regular_expression>/ ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的累积总和。

`CUMULATIVE_SUM()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值的累积总和

```sql
> SELECT CUMULATIVE_SUM(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   cumulative_sum
----                   --------------
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   4.167
2015-08-18T00:24:00Z   6.213
```

该查询返回field key `water_level`对应的每12分钟的时间间隔的field value的平均值的累积总和。

为了得到这些结果，InfluxDB首先计算field key `water_level`对应的每12分钟的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`CUMULATIVE_SUM()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值的累积总和。最终查询结果中的第二个数据point(`4.167`)是`2.09`和`2.077`的总和，第三个数据point(`6.213`)是`2.09`、`2.077`和`2.0460000000000003`的总和。

### DERIVATIVE()

返回field value之间的变化率，即导数。

#### 基本语法

```
SELECT DERIVATIVE( [ * | <field_key> | /<regular_expression>/ ] [ , <unit> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

InfluxDB计算field value之间的差值，并将这些结果转换为每个`unit`的变化率。参数`unit`的值是一个整数，后跟一个时间单位。这个参数是可选的，不是必须要有的。如果查询没有指定`unit`的值，那么`unit`默认为一秒(`1s`)。

`DERIVATIVE(field_key)`
返回field key对应的field value的变化率。

`DERIVATIVE(/regular_expression/)`
返回与正则表达式匹配的每个field key对应的field value的变化率。

`DERIVATIVE(*)`
返回在measurement中每个field key对应的field value的变化率。

`DERIVATIVE()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`DERIVATIVE()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用`NOAA_water_database`数据集的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
2015-08-18T00:12:00Z   2.028
2015-08-18T00:18:00Z   2.126
2015-08-18T00:24:00Z   2.041
2015-08-18T00:30:00Z   2.051
```

###### 计算指定field key对应的field value的导数

```sql
> SELECT DERIVATIVE("water_level") FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time                   derivative
----                   ----------
2015-08-18T00:06:00Z   0.00014444444444444457
2015-08-18T00:12:00Z   -0.00024444444444444465
2015-08-18T00:18:00Z   0.0002722222222222218
2015-08-18T00:24:00Z   -0.000236111111111111
2015-08-18T00:30:00Z   2.777777777777842e-05
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的每秒变化率。

第一个结果(`0.00014444444444444457`)是原始数据中前两个field value在一秒内的变化率。InfluxDB计算两个field value之间的差值，并将该值标准化为一秒的变化率：

```
(2.116 - 2.064) / (360s / 1s)
--------------    ----------
       |               |
       |          the difference between the field values' timestamps / the default unit
second field value - first field value
```

###### 计算指定field key对应的field value的导数并指定`unit`

```sql
> SELECT DERIVATIVE("water_level",6m) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time			derivative
----			----------
2015-08-18T00:06:00Z	0.052000000000000046
2015-08-18T00:12:00Z	-0.08800000000000008
2015-08-18T00:18:00Z	0.09799999999999986
2015-08-18T00:24:00Z	-0.08499999999999996
2015-08-18T00:30:00Z	0.010000000000000231
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的每六分钟的变化率。

第一个结果(`0.052000000000000046`)是原始数据中前两个field value在六分钟内的变化率。InfluxDB计算两个field value之间的差值，并将该值标准化为六分钟的变化率：

```
(2.116 - 2.064) / (6m / 6m)
--------------    ----------
       |              |
       |          the difference between the field values' timestamps / the specified unit
second field value - first field value
```

###### 计算measurement中每个field key对应的field value的导数并指定`unit`

```sql
> SELECT DERIVATIVE(*,3m) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'


name: h2o_feet
time                   derivative_water_level
----                   ----------------------
2015-08-18T00:06:00Z   0.026000000000000023
2015-08-18T00:12:00Z   -0.04400000000000004
2015-08-18T00:18:00Z   0.04899999999999993
2015-08-18T00:24:00Z   -0.04249999999999998
2015-08-18T00:30:00Z   0.0050000000000001155
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的每三分钟的变化率。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

第一个结果(`0.026000000000000023`)是原始数据中前两个field value在三分钟内的变化率。InfluxDB计算两个field value之间的差值，并将该值标准化为三分钟的变化率：

```
(2.116 - 2.064) / (6m / 3m)
--------------    ----------
       |              |
       |          the difference between the field values' timestamps / the specified unit
second field value - first field value
```

###### 计算与正则表达式匹配的每个field key对应的field value的导数并指定`unit`

```sql
> SELECT DERIVATIVE(/water/,2m) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time                   derivative_water_level
----                   ----------------------
2015-08-18T00:06:00Z   0.01733333333333335
2015-08-18T00:12:00Z   -0.02933333333333336
2015-08-18T00:18:00Z   0.03266666666666662
2015-08-18T00:24:00Z   -0.02833333333333332
2015-08-18T00:30:00Z   0.0033333333333334103
```

该查询返回measurement `h2o_feet`中每个存储数值并包含单词`water`的field key对应的field value的每两分钟的变化率。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

第一个结果(`0.01733333333333335`)是原始数据中前两个field value在两分钟内的变化率。InfluxDB计算两个field value之间的差值，并将该值标准化为两分钟的变化率：

```
(2.116 - 2.064) / (6m / 2m)
--------------    ----------
       |              |
       |          the difference between the field values' timestamps / the specified unit
second field value - first field value
```

###### 计算指定field key对应的field value的导数并包含多个子句

```sql
> SELECT DERIVATIVE("water_level") FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' ORDER BY time DESC LIMIT 1 OFFSET 2

name: h2o_feet
time                   derivative
----                   ----------
2015-08-18T00:12:00Z   -0.0002722222222222218
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的每秒变化率，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为1，并将返回的数据point偏移两个(即前两个数据point不返回）。

唯一的结果(`-0.0002722222222222218`)是原始数据中前两个field value在一秒内的变化率。InfluxDB计算两个field value之间的差值，并将该值标准化为一秒的变化率：

```
(2.126 - 2.028) / (360s / 1s)
--------------    ----------
       |              |
       |          the difference between the field values' timestamps / the default unit
second field value - first field value
```

#### 高级语法

```
SELECT DERIVATIVE(<function> ([ * | <field_key> | /<regular_expression>/ ]) [ , <unit> ] ) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的导数。

参数`unit`的值是一个整数，后跟一个时间单位。这个参数是可选的，不是必须要有的。如果查询没有指定`unit`的值，那么`unit`默认为`GROUP BY time()`的时间间隔。请注意，这里`unit`的默认值跟基本语法中`unit`的默认值不一样。

`DERIVATIVE()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值的导数

```sql
> SELECT DERIVATIVE(MEAN("water_level")) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m)

name: h2o_feet
time                   derivative
----                   ----------
2015-08-18T00:12:00Z   -0.0129999999999999
2015-08-18T00:24:00Z   -0.030999999999999694
```

该查询返回field key `water_level`对应的每12分钟的时间间隔的field value的平均值的每12分钟变化率。

为了得到这些结果，InfluxDB首先计算field key `water_level`对应的每12分钟的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`DERIVATIVE()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值的每12分钟的变化率。第一个结果(`-0.0129999999999999`)是原始数据中前两个field value在12分钟内的变化率。InfluxDB计算两个field value之间的差值，并将该值标准化为12分钟的变化率：

```
(2.077 - 2.09) / (12m / 12m)
-------------    ----------
       |               |
       |          the difference between the field values' timestamps / the default unit
second field value - first field value
```

###### 计算平均值的导数并指定`unit`

```sql
> SELECT DERIVATIVE(MEAN("water_level"),6m) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m)

name: h2o_feet
time                   derivative
----                   ----------
2015-08-18T00:12:00Z   -0.00649999999999995
2015-08-18T00:24:00Z   -0.015499999999999847
```

该查询返回field key `water_level`对应的每12分钟的时间间隔的field value的平均值的每六分钟变化率。

为了得到这些结果，InfluxDB首先计算field key `water_level`对应的每12分钟的时间间隔的field value的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`DERIVATIVE()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值的每六分钟的变化率。第一个结果(`-0.00649999999999995`)是原始数据中前两个field value在六分钟内的变化率。InfluxDB计算两个field value之间的差值，并将该值标准化为六分钟的变化率：

```
(2.077 - 2.09) / (12m / 6m)
-------------    ----------
       |               |
       |          the difference between the field values' timestamps / the specified unit
second field value - first field value
```

### DIFFERENCE()

返回field value之间的差值。

#### 基本语法

```
SELECT DIFFERENCE( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`DIFFERENCE(field_key)`
返回field key对应的field value的差值。

`DIFFERENCE(/regular_expression/)`
返回与正则表达式匹配的每个field key对应的field value的差值。

`DIFFERENCE(*)`
返回在measurement中每个field key对应的field value的差值。

`DIFFERENCE()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`DIFFERENCE()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用`NOAA_water_database`数据集的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
2015-08-18T00:12:00Z   2.028
2015-08-18T00:18:00Z   2.126
2015-08-18T00:24:00Z   2.041
2015-08-18T00:30:00Z   2.051
```

###### 计算指定field key对应的field value的差值

```sql
> SELECT DIFFERENCE("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                   difference
----                   ----------
2015-08-18T00:06:00Z   0.052000000000000046
2015-08-18T00:12:00Z   -0.08800000000000008
2015-08-18T00:18:00Z   0.09799999999999986
2015-08-18T00:24:00Z   -0.08499999999999996
2015-08-18T00:30:00Z   0.010000000000000231
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value之间的差值。

###### 计算measurement中每个field key对应的field value的差值

```sql
> SELECT DIFFERENCE(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                   difference_water_level
----                   ----------------------
2015-08-18T00:06:00Z   0.052000000000000046
2015-08-18T00:12:00Z   -0.08800000000000008
2015-08-18T00:18:00Z   0.09799999999999986
2015-08-18T00:24:00Z   -0.08499999999999996
2015-08-18T00:30:00Z   0.010000000000000231
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value之间的差值。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

###### 计算与正则表达式匹配的每个field key对应的field value的差值

```sql
> SELECT DIFFERENCE(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                   difference_water_level
----                   ----------------------
2015-08-18T00:06:00Z   0.052000000000000046
2015-08-18T00:12:00Z   -0.08800000000000008
2015-08-18T00:18:00Z   0.09799999999999986
2015-08-18T00:24:00Z   -0.08499999999999996
2015-08-18T00:30:00Z   0.010000000000000231
```

该查询返回measurement `h2o_feet`中每个存储数值并包含单词`water`的field key对应的field value之间的差值。

###### 计算指定field key对应的field value的差值并包含多个子句

```sql
> SELECT DIFFERENCE("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 2 OFFSET 2

name: h2o_feet
time                   difference
----                   ----------
2015-08-18T00:12:00Z   -0.09799999999999986
2015-08-18T00:06:00Z   0.08800000000000008
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value之间的差值，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为2，并将返回的数据point偏移两个（即前两个数据point不返回）。

#### 高级语法

```
SELECT DIFFERENCE(<function>( [ * | <field_key> | /<regular_expression>/ ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果之间的差值。

DIFFERENCE()支持以下嵌套函数：
[`COUNT()`](#count),
[`MEAN()`](#mean),
[`MEDIAN()`](#median),
[`MODE()`](#mode),
[`SUM()`](#sum),
[`FIRST()`](#first),
[`LAST()`](#last),
[`MIN()`](#min),
[`MAX()`](#max), and
[`PERCENTILE()`](#percentile).

##### 示例

###### 计算最大值之间的差值

```sql
> SELECT DIFFERENCE(MAX("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   difference
----                   ----------
2015-08-18T00:12:00Z   0.009999999999999787
2015-08-18T00:24:00Z   -0.07499999999999973
```

该查询返回field key `water_level`对应的每12分钟的时间间隔的field value的最大值之间的差值。

为了得到这些结果，InfluxDB首先计算field key `water_level`对应的每12分钟的时间间隔的field value的最大值。这一步跟同时使用`MAX()`函数和`GROUP BY time()`子句、但不使用`DIFFERENCE()`的情形一样：

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   max
----                   ---
2015-08-18T00:00:00Z   2.116
2015-08-18T00:12:00Z   2.126
2015-08-18T00:24:00Z   2.051
```

然后，InfluxDB计算这些最大值之间的差值。最终查询结果中的第一个数据point(`0.009999999999999787`)是`2.126`和`2.116`的差，第二个数据point(`-0.07499999999999973`)是`2.051`和`2.126`的差。

### ELAPSED()

返回field value的时间戳之间的差值。

#### 语法

```
SELECT ELAPSED( [ * | <field_key> | /<regular_expression>/ ] [ , <unit> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

InfluxDB计算时间戳之间的差值。参数`unit`的值是一个整数，后跟一个时间单位，它决定了返回的差值的单位。这个参数是可选的，不是必须要有的。如果没有指定`unit`的值，那么查询将返回以纳秒为单位的两个时间戳之间的差值。

`ELAPSED(field_key)`
返回field key对应的时间戳之间的差值。

`ELAPSED(/regular_expression/)`
返回与正则表达式匹配的每个field key对应的时间戳之间的差值。

`ELAPSED(*)`
返回在measurement中每个field key对应的时间戳之间的差值。

`ELAPSED()`支持所有数据类型的field value。

#### 示例

下面的示例将使用`NOAA_water_database`数据集的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:12:00Z'

name: h2o_feet
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
2015-08-18T00:12:00Z   2.028
```

##### 计算指定field key对应的field value之间的时间间隔

```sql
> SELECT ELAPSED("water_level") FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:12:00Z'

name: h2o_feet
time                   elapsed
----                   -------
2015-08-18T00:06:00Z   360000000000
2015-08-18T00:12:00Z   360000000000
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的时间戳之间的差值(以纳秒为单位)。

##### 计算指定field key对应的field value之间的时间间隔并指定`unit`

```sql
> SELECT ELAPSED("water_level",1m) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:12:00Z'

name: h2o_feet
time                   elapsed
----                   -------
2015-08-18T00:06:00Z   6
2015-08-18T00:12:00Z   6
```

该查询返回measurement `h2o_feet`中每个field key对应的时间戳之间的差值(以分钟为单位)。measurement `h2o_feet`中有两个field key：`level description`和`water_level`。

##### 计算与正则表达式匹配的每个field key对应的field value之间的时间间隔并指定`unit`

```sql
> SELECT ELAPSED(*,1m) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:12:00Z'

name: h2o_feet
time                   elapsed_level description   elapsed_water_level
----                   -------------------------   -------------------
2015-08-18T00:06:00Z   6                           6
2015-08-18T00:12:00Z   6                           6
```

该查询返回measurement `h2o_feet`中每个包含单词`level`的field key对应的时间戳之间的差值(以秒为单位)。

##### 计算与正则表达式匹配的每个field key对应的field value之间的时间间隔并指定`unit`

```sql
> SELECT ELAPSED(/level/,1s) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:12:00Z'

name: h2o_feet
time                   elapsed_level description   elapsed_water_level
----                   -------------------------   -------------------
2015-08-18T00:06:00Z   360                         360
2015-08-18T00:12:00Z   360                         360
```

该查询返回measurement `h2o_feet`中每个包含单词`level`的field key对应的时间戳之间的差值(以秒为单位)。

##### 计算指定field key对应的field value之间的时间间隔并包含多个子句

```sql
> SELECT ELAPSED("water_level",1ms) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:12:00Z' ORDER BY time DESC LIMIT 1 OFFSET 1

name: h2o_feet
time                   elapsed
----                   -------
2015-08-18T00:00:00Z   -360000
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的时间戳之间的差值(以毫秒为单位)，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:12:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为1，并将返回的数据point偏移一个（即前一个数据point不返回）。

请注意，查询结果是负数；因为`ORDER BY time DESC`子句按递减的顺序对时间戳进行排序，所以`ELAPSED()`以相反的顺序计算时间戳的差值。

### `ELAPSED()`的常见问题

#### `ELAPSED()`和大于经过时间的单位

I如果`unit`的值大于时间戳之间的差值，那么InfluxDB将会返回`0`。

##### 示例

measurement `h2o_feet`中每六分钟有一个数据point。如果查询将`unit`设置为一小时，InfluxDB将会返回`0`：

```sql
> SELECT ELAPSED("water_level",1h) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:12:00Z'

name: h2o_feet
time                   elapsed
----                   -------
2015-08-18T00:06:00Z   0
2015-08-18T00:12:00Z   0
```

#### `ELAPSED()`和`GROUP BY time()`子句同时使用

`ELAPSED()`函数支持`GROUP BY time()`子句，但是查询结果不是特别有用。目前，如果`ELAPSED()`查询包含一个嵌套的InfluxQL函数和一个`GROUP BY time()`子句，那么只会返回指定`GROUP BY time()`子句中的时间间隔。

`GROUP BY time()`子句决定了查询结果中的时间戳：每个时间戳表示时间间隔的开始时间。该行为也适用于嵌套的selector函数(例如`FIRST()`或`MAX()`)，而在其它的所有情况下，这些函数返回的是原始数据的特定时间戳。因为`GROUP BY time()`子句会覆盖原始时间戳，所以`ELAPSED()`始终返回与`GROUP BY time()`的时间间隔相同的时间戳。

##### 示例

下面代码块中的第一个查询尝试使用`ELAPSED()`和`GROUP BY time()`子句来查找最小的`water_level`的值之间经过的时间(以分钟为单位)。查询的两个时间间隔都返回了12分钟。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔的`water_level`的最小值。代码块中的第二个查询展示了这一步的结果。这一步跟同时使用`MIN()`函数和`GROUP BY time()`子句、但不使用`ELAPSED()`的情形一样。请注意，第二个查询返回的时间戳间隔12分钟。在原始数据中，第一个结果(`2.057`)发生在`2015-08-18T00:42:00Z`，但是`GROUP BY time()`子句覆盖了原始的时间戳。因为时间戳由`GROUP BY time()`的时间间隔(而不是原始数据)决定，所以`ELAPSED()`始终返回与GROUP BY time()的时间间隔相同的时间戳。

```sql
> SELECT ELAPSED(MIN("water_level"),1m) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:36:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m)

name: h2o_feet
time                   elapsed
----                   -------
2015-08-18T00:36:00Z   12
2015-08-18T00:48:00Z   12

> SELECT MIN("water_level") FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:36:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m)

name: h2o_feet
time                   min
----                   ---
2015-08-18T00:36:00Z   2.057    <--- Actually occurs at 2015-08-18T00:42:00Z
2015-08-18T00:48:00Z   1.991
```

### EXP()

返回field value的指数。

#### 基本语法

```
SELECT EXP( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`EXP(field_key)`
返回field key对应的field value的指数。

`EXP(*)`
返回在measurement中每个field key对应的field value的指数。

`EXP()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`EXP()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.85.41fc3ee27HC1R6)中的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的field value的指数

```sql
> SELECT EXP("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  exp
----                  ---
2015-08-18T00:00:00Z  7.877416541092307
2015-08-18T00:06:00Z  8.297879498060171
2015-08-18T00:12:00Z  7.598873404088091
2015-08-18T00:18:00Z  8.381274573459967
2015-08-18T00:24:00Z  7.6983036546645645
2015-08-18T00:30:00Z  7.775672892658607
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的指数。

###### 计算measurement中每个field key对应的field value的指数

```sql
> SELECT EXP(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  exp_water_level
----                  ---------------
2015-08-18T00:00:00Z  7.877416541092307
2015-08-18T00:06:00Z  8.297879498060171
2015-08-18T00:12:00Z  7.598873404088091
2015-08-18T00:18:00Z  8.381274573459967
2015-08-18T00:24:00Z  7.6983036546645645
2015-08-18T00:30:00Z  7.775672892658607
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的指数。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

<!-- ##### Calculate the exponential of field values associated with each field key that matches a regular expression
```
> SELECT EXP(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  exp_water_level
----                  ---------------
2015-08-18T00:00:00Z  7.877416541092307
2015-08-18T00:06:00Z  8.297879498060171
2015-08-18T00:12:00Z  7.598873404088091
2015-08-18T00:18:00Z  8.381274573459967
2015-08-18T00:24:00Z  7.6983036546645645
2015-08-18T00:30:00Z  7.775672892658607
```

The query returns the exponential of field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement.
-->

###### 计算指定field key对应的field value的指数并包含多个子句

```sql
> SELECT EXP("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  exp
----                  ---
2015-08-18T00:18:00Z  8.381274573459967
2015-08-18T00:12:00Z  7.598873404088091
2015-08-18T00:06:00Z  8.297879498060171
2015-08-18T00:00:00Z  7.877416541092307
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的指数，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个(即前两个数据point不返回)。

#### 高级语法

```
SELECT EXP(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的指数。

EXP()支持以下嵌套函数：

[`COUNT()`](#count),
[`MEAN()`](#mean),
[`MEDIAN()`](#median),
[`MODE()`](#mode),
[`SUM()`](#sum),
[`FIRST()`](#first),
[`LAST()`](#last),
[`MIN()`](#min),
[`MAX()`](#max), and
[`PERCENTILE()`](#percentile).

##### 示例

###### 计算平均值的指数

```sql
> SELECT EXP(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  exp
----                  ---
2015-08-18T00:00:00Z  8.084915164305059
2015-08-18T00:12:00Z  7.980491491670466
2015-08-18T00:24:00Z  7.736891562315577
```

该查询返回每12分钟的时间间隔对应的`water_level`的平均值的绝对值。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的`water_level`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`EXP()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

.然后，InfluxDB计算这些平均值的指数。

### FLOOR()

返回小于指定值的最大整数。

#### 基本语法

```
SELECT FLOOR( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`FLOOR(field_key)`
返回field key对应的小于field value的最大整数。

`FLOOR(*)`
返回在measurement中每个field key对应的小于field value的最大整数。

`FLOOR()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`FLOOR()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用`NOAA_water_database`数据集的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的小于field value的最大整数

```sql
> SELECT FLOOR("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  floor
----                  -----
2015-08-18T00:00:00Z  2
2015-08-18T00:06:00Z  2
2015-08-18T00:12:00Z  2
2015-08-18T00:18:00Z  2
2015-08-18T00:24:00Z  2
2015-08-18T00:30:00Z  2
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的小于field value的最大整数。

###### 计算measurement中每个field key对应的小于field value的最大整数

```sql
> SELECT FLOOR(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  floor_water_level
----                  -----------------
2015-08-18T00:00:00Z  2
2015-08-18T00:06:00Z  2
2015-08-18T00:12:00Z  2
2015-08-18T00:18:00Z  2
2015-08-18T00:24:00Z  2
2015-08-18T00:30:00Z  2
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的小于field value的最大整数。measurement `h2o_feet`只有一个数值类型的field：`water_level`。

<!-- ##### Calculate the floor of the field values associated with each field key that matches a regular expression
```
> SELECT FLOOR(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                   floor_water_level
----                   -----------------
2015-08-18T00:00:00Z   2
2015-08-18T00:06:00Z   2
2015-08-18T00:12:00Z   2
2015-08-18T00:18:00Z   2
2015-08-18T00:24:00Z   2
2015-08-18T00:30:00Z   2
```

The query returns field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement rounded down to the nearest integer. -->

###### 计算指定field key对应的小于field value的最大整数并包含多个子句

```sql
> SELECT FLOOR("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  floor
----                  -----
2015-08-18T00:18:00Z  2
2015-08-18T00:12:00Z  2
2015-08-18T00:06:00Z  2
2015-08-18T00:00:00Z  2
```

该查询返回field key `water_level`对应的小于field value的最大整数，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个(即前两个数据point不返回)。

#### 高级语法

```
SELECT FLOOR(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后将`FLOOR()`应用于这些结果。

`FLOOR()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算小于平均值的最大整数

```sql
> SELECT FLOOR(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  floor
----                  -----
2015-08-18T00:00:00Z  2
2015-08-18T00:12:00Z  2
2015-08-18T00:24:00Z  2
```

该查询返回每12分钟的时间间隔对应的小于`water_level`平均值的最大整数。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的`water_level`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`FLOOR()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算小于这些平均值的最大整数。

### LN()

返回field value的自然对数。

#### 基本语法

```
SELECT LN( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`LN(field_key)`
返回field key对应的field value的自然对数。

`LN(*)`
返回在measurement中每个field key对应的field value的自然对数。

`LN()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`LN()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.86.41fc3ee27HC1R6)中的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的field value的自然对数

```sql
> SELECT LN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  ln
----                  --
2015-08-18T00:00:00Z  0.7246458476193163
2015-08-18T00:06:00Z  0.749527513996053
2015-08-18T00:12:00Z  0.7070500857289368
2015-08-18T00:18:00Z  0.7542422799197561
2015-08-18T00:24:00Z  0.7134398838277077
2015-08-18T00:30:00Z  0.7183274790902436
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的自然对数。

###### 计算measurement中每个field key对应的field value的自然对数

```sql
> SELECT LN(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  ln_water_level
----                  --------------
2015-08-18T00:00:00Z  0.7246458476193163
2015-08-18T00:06:00Z  0.749527513996053
2015-08-18T00:12:00Z  0.7070500857289368
2015-08-18T00:18:00Z  0.7542422799197561
2015-08-18T00:24:00Z  0.7134398838277077
2015-08-18T00:30:00Z  0.7183274790902436
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的自然对数。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

<!-- ##### Calculate the natural logarithm of field values associated with each field key that matches a regular expression
```
> SELECT LN(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  ln_water_level
----                  --------------
2015-08-18T00:00:00Z  0.7246458476193163
2015-08-18T00:06:00Z  0.749527513996053
2015-08-18T00:12:00Z  0.7070500857289368
2015-08-18T00:18:00Z  0.7542422799197561
2015-08-18T00:24:00Z  0.7134398838277077
2015-08-18T00:30:00Z  0.7183274790902436
```

The query returns the natural logarithm of field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement. 
-->

###### 计算指定field key对应的field value的自然对数并包含多个子句

```sql
> SELECT LN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  ln
----                  --
2015-08-18T00:18:00Z  0.7542422799197561
2015-08-18T00:12:00Z  0.7070500857289368
2015-08-18T00:06:00Z  0.749527513996053
2015-08-18T00:00:00Z  0.7246458476193163
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的自然对数，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个(即前两个数据point不返回）。

#### 高级语法

```
SELECT LN(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个 [`GROUP BY time() ` clause](/influxdb/v1.8/query_language/explore-data/#group-by-time-intervals) 和一个嵌套的InfluxQL 函数.
该查询受限以指定 `GROUP BY time()`间隔计算嵌套函数的结果 `LN()` .

LN()支持以下嵌套函数：

[`COUNT()`](#count),
[`MEAN()`](#mean),
[`MEDIAN()`](#median),
[`MODE()`](#mode),
[`SUM()`](#sum),
[`FIRST()`](#first),
[`LAST()`](#last),
[`MIN()`](#min),
[`MAX()`](#max), and
[`PERCENTILE()`](#percentile).


##### 示例

###### 计算平均值的自然对数

```sql
> SELECT LN(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  ln
----                  --
2015-08-18T00:00:00Z  0.7371640659767196
2015-08-18T00:12:00Z  0.7309245448939752
2015-08-18T00:24:00Z  0.7158866675294349
```

该查询返回每12分钟的时间间隔对应的`water_level`的平均值的自然对数。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的`water_level`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`LN()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值的自然对数。

### LOG()

返回field value的以`b`为底数的对数。

#### 基本语法

```
SELECT LOG( [ * | <field_key> ], <b> ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`LOG(field_key, b)`
返回field key对应的field value的以`b`为底数的对数。

`LOG(*, b)`
返回在measurement中每个field key对应的field value的以`b`为底数的对数。

`LOG()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`LOG()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.87.41fc3ee27HC1R6)中的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的field value的以4为底数的对数

```sql
> SELECT LOG("water_level", 4) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  log
----                  ---
2015-08-18T00:00:00Z  0.5227214853805835
2015-08-18T00:06:00Z  0.5406698137259695
2015-08-18T00:12:00Z  0.5100288261706268
2015-08-18T00:18:00Z  0.5440707984345088
2015-08-18T00:24:00Z  0.5146380911853161
2015-08-18T00:30:00Z  0.5181637459088826
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的以4为底数的对数。

###### 计算measurement中每个field key对应的field value的以4为底数的对数
```sql
> SELECT LOG(*, 4) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  log_water_level
----                  ---------------
2015-08-18T00:00:00Z  0.5227214853805835
2015-08-18T00:06:00Z  0.5406698137259695
2015-08-18T00:12:00Z  0.5100288261706268
2015-08-18T00:18:00Z  0.5440707984345088
2015-08-18T00:24:00Z  0.5146380911853161
2015-08-18T00:30:00Z  0.5181637459088826
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的以4为底数的对数。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

<!-- ##### Calculate the logarithm base 4 of field values associated with each field key that matches a regular expression
```
> SELECT LOG(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  log
----                  ---
2015-08-18T00:00:00Z  0.5227214853805835
2015-08-18T00:06:00Z  0.5406698137259695
2015-08-18T00:12:00Z  0.5100288261706268
2015-08-18T00:18:00Z  0.5440707984345088
2015-08-18T00:24:00Z  0.5146380911853161
2015-08-18T00:30:00Z  0.5181637459088826
```

The query returns the logarithm base 4 of field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement. 
-->

###### 计算指定field key对应的field value的以4为底数的对数并包含多个子句

```sql
> SELECT LOG("water_level", 4) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  log
----                  ---
2015-08-18T00:18:00Z  0.5440707984345088
2015-08-18T00:12:00Z  0.5100288261706268
2015-08-18T00:06:00Z  0.5406698137259695
2015-08-18T00:00:00Z  0.5227214853805835
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的以4为底数的对数，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个(即前两个数据point不返回）。

#### 高级语法

```
SELECT LOG(<function>( [ * | <field_key> ] ), <b>) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的对数。

`LOG()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值的以4为底数的对数

```sql
> SELECT LOG(MEAN("water_level"), 4) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  log
----                  ---
2015-08-18T00:00:00Z  0.531751471153079
2015-08-18T00:12:00Z  0.5272506080912802
2015-08-18T00:24:00Z  0.5164030725416209
```

该查询返回每12分钟的时间间隔对应的`water_level`的平均值的以4为底数的对数。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的`water_level`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`LOG()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值的以4为底数的对数。

### LOG2()

返回field value的以2为底数的对数。

#### 基本语法

```
SELECT LOG2( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`LOG2(field_key)`
返回field key对应的field value的以2为底数的对数。

`LOG2(*)`
返回在measurement中每个field key对应的field value的以2为底数的对数。

`LOG2()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`LOG2()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.88.41fc3ee27HC1R6)中的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的field value的以2为底数的对数

```sql
> SELECT LOG2("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  log2
----                  ----
2015-08-18T00:00:00Z  1.045442970761167
2015-08-18T00:06:00Z  1.081339627451939
2015-08-18T00:12:00Z  1.0200576523412537
2015-08-18T00:18:00Z  1.0881415968690176
2015-08-18T00:24:00Z  1.0292761823706322
2015-08-18T00:30:00Z  1.0363274918177652
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的以2为底数的对数。

###### 计算measurement中每个field key对应的field value的以2为底数的对数

```sql
> SELECT LOG2(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  log2_water_level
----                  ----------------
2015-08-18T00:00:00Z  1.045442970761167
2015-08-18T00:06:00Z  1.081339627451939
2015-08-18T00:12:00Z  1.0200576523412537
2015-08-18T00:18:00Z  1.0881415968690176
2015-08-18T00:24:00Z  1.0292761823706322
2015-08-18T00:30:00Z  1.0363274918177652
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的以2为底数的对数。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

<!-- ##### Calculate the logarithm base 2 of field values associated with each field key that matches a regular expression
```
> SELECT LOG2(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  log2
----                  ----
2015-08-18T00:00:00Z  1.045442970761167
2015-08-18T00:06:00Z  1.081339627451939
2015-08-18T00:12:00Z  1.0200576523412537
2015-08-18T00:18:00Z  1.0881415968690176
2015-08-18T00:24:00Z  1.0292761823706322
2015-08-18T00:30:00Z  1.0363274918177652
```

The query returns the logarithm base 2 of field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement. 
-->

###### 计算指定field key对应的field value的以2为底数的对数并包含多个子句

```sql
> SELECT LOG2("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  log2
----                  ----
2015-08-18T00:18:00Z  1.0881415968690176
2015-08-18T00:12:00Z  1.0200576523412537
2015-08-18T00:06:00Z  1.081339627451939
2015-08-18T00:00:00Z  1.045442970761167
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的以2为底数的对数，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个(即前两个数据point不返回）。

#### 高级语法

```sql
SELECT LOG2(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的以2为底数的对数。

`LOG2()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值的以2为底数的对数

```sql
> SELECT LOG2(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  log2
----                  ----
2015-08-18T00:00:00Z  1.063502942306158
2015-08-18T00:12:00Z  1.0545012161825604
2015-08-18T00:24:00Z  1.0328061450832418
```

该查询返回每12分钟的时间间隔对应的`water_level`的平均值的以2为底数的对数。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的`water_level`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`LOG2()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值的以2为底数的对数。

### LOG10()

返回field value的以10为底数的对数。

#### 基本语法

```
SELECT LOG10( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`LOG10(field_key)`
返回field key对应的field value的以10为底数的对数。

`LOG10(*)`
返回在measurement中每个field key对应的field value的以10为底数的对数。

`LOG10()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`LOG10()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.89.41fc3ee27HC1R6)中的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的field value的以10为底数的对数

```sql
> SELECT LOG10("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  log10
----                  -----
2015-08-18T00:00:00Z  0.3147096929551737
2015-08-18T00:06:00Z  0.32551566336314813
2015-08-18T00:12:00Z  0.3070679506612984
2015-08-18T00:18:00Z  0.32756326018727794
2015-08-18T00:24:00Z  0.3098430047160705
2015-08-18T00:30:00Z  0.3119656603683663
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的以10为底数的对数。

###### 计算measurement中每个field key对应的field value的以10为底数的对数

```sql
> SELECT LOG10(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  log10_water_level
----                  -----------------
2015-08-18T00:00:00Z  0.3147096929551737
2015-08-18T00:06:00Z  0.32551566336314813
2015-08-18T00:12:00Z  0.3070679506612984
2015-08-18T00:18:00Z  0.32756326018727794
2015-08-18T00:24:00Z  0.3098430047160705
2015-08-18T00:30:00Z  0.3119656603683663
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的以10为底数的对数。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

<!-- ##### Calculate the logarithm base 10 of field values associated with each field key that matches a regular expression
```
> SELECT LOG10(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  log10
----                  -----
2015-08-18T00:00:00Z  0.3147096929551737
2015-08-18T00:06:00Z  0.32551566336314813
2015-08-18T00:12:00Z  0.3070679506612984
2015-08-18T00:18:00Z  0.32756326018727794
2015-08-18T00:24:00Z  0.3098430047160705
2015-08-18T00:30:00Z  0.3119656603683663
```

The query returns the logarithm base 10 of field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement. -->

###### 计算指定field key对应的field value的以10为底数的对数并包含多个子句

```sql
> SELECT LOG10("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  log10
----                  -----
2015-08-18T00:18:00Z  0.32756326018727794
2015-08-18T00:12:00Z  0.3070679506612984
2015-08-18T00:06:00Z  0.32551566336314813
2015-08-18T00:00:00Z  0.3147096929551737
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的以10为底数的对数，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个(即前两个数据point不返回）。

#### 高级语法

```
SELECT LOG10(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的以10为底数的对数。

`LOG10()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值的以10为底数的对数

```sql
> SELECT LOG10(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  log10
----                  -----
2015-08-18T00:00:00Z  0.32014628611105395
2015-08-18T00:12:00Z  0.3174364965350991
2015-08-18T00:24:00Z  0.3109056293761414
```

该查询返回每12分钟的时间间隔对应的`water_level`的平均值的以10为底数的对数。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的`water_level`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`LOG10()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值的以10为底数的对数。

### MOVING_AVERAGE()

返回field value窗口的滚动平均值。

#### 基本语法

```
SELECT MOVING_AVERAGE( [ * | <field_key> | /<regular_expression>/ ] , <N> ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`MOVING_AVERAGE()`计算包含`N`个连续field value的窗口的滚动平均值。参数`N`是一个整数，并且它是必须的。

`MOVING_AVERAGE(field_key,N)`
返回field key对应的N个field value的滚动平均值。

`MOVING_AVERAGE(/regular_expression/,N)`
返回与正则表达式匹配的每个field key对应的N个field value的滚动平均值。

`MOVING_AVERAGE(*,N)`
返回在measurement中每个field key对应的N个field value的滚动平均值。

`MOVING_AVERAGE()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`MOVING_AVERAGE()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用`NOAA_water_database`数据集的如下数据：


```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
2015-08-18T00:12:00Z   2.028
2015-08-18T00:18:00Z   2.126
2015-08-18T00:24:00Z   2.041
2015-08-18T00:30:00Z   2.051
```

###### 计算指定field key对应的field value的滚动平均值

```
> SELECT MOVING_AVERAGE("water_level",2) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time                   moving_average
----                   --------------
2015-08-18T00:06:00Z   2.09
2015-08-18T00:12:00Z   2.072
2015-08-18T00:18:00Z   2.077
2015-08-18T00:24:00Z   2.0835
2015-08-18T00:30:00Z   2.0460000000000003
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的窗口大小为两个field value的滚动平均值。第一个结果(`2.09`)是原始数据中前两个field value的平均值：(2.064 + 2.116) / 2。第二个结果(`2.072`)是原始数据中第二和第三个field value的平均值：(2.116 + 2.028) / 2。

###### 计算measurement中每个field key对应的field value的滚动平均值

```sql
> SELECT MOVING_AVERAGE(*,3) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time                   moving_average_water_level
----                   --------------------------
2015-08-18T00:12:00Z   2.0693333333333332
2015-08-18T00:18:00Z   2.09
2015-08-18T00:24:00Z   2.065
2015-08-18T00:30:00Z   2.0726666666666667
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的窗口大小为三个field value的滚动平均值。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

###### 计算与正则表达式匹配的每个field key对应的field value的滚动平均值

```
> SELECT MOVING_AVERAGE(/level/,4) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z'

name: h2o_feet
time                    moving_average_water_level
----                    --------------------------
2015-08-18T00:18:00Z    2.0835
2015-08-18T00:24:00Z    2.07775
2015-08-18T00:30:00Z    2.0615
```

该查询返回measurement `h2o_feet`中每个存储数值并包含单词`level`的field key对应的窗口大小为四个field value的滚动平均值。

###### 计算指定field key对应的field value的滚动平均值并包含多个子句

```sql
> SELECT MOVING_AVERAGE("water_level",2) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' ORDER BY time DESC LIMIT 2 OFFSET 3

name: h2o_feet
time                   moving_average
----                   --------------
2015-08-18T00:06:00Z   2.072
2015-08-18T00:00:00Z   2.09
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的窗口大小为两个field value的滚动平均值，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为2，并将返回的数据point偏移三个(即前三个数据point不返回）。

#### 高级语法

```
SELECT MOVING_AVERAGE(<function> ([ * | <field_key> | /<regular_expression>/ ]) , N ) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果之间的滚动平均值。

`MOVING_AVERAGE()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算最大值的滚动平均值

```sql
> SELECT MOVING_AVERAGE(MAX("water_level"),2) FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m)

name: h2o_feet
time                   moving_average
----                   --------------
2015-08-18T00:12:00Z   2.121
2015-08-18T00:24:00Z   2.0885
```

该查询返回每12分钟的时间间隔对应的`water_level`的最大值的窗口大小为两个值的滚动平均值。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的`water_level`的最大值。这一步跟同时使用`MAX()`函数和`GROUP BY time()`子句、但不使用`MOVING_AVERAGE()`的情形一样：

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' GROUP BY time(12m)

name: h2o_feet
time                   max
----                   ---
2015-08-18T00:00:00Z   2.116
2015-08-18T00:12:00Z   2.126
2015-08-18T00:24:00Z   2.051
```

然后，InfluxDB计算这些最大值的窗口大小为两个值的滚动平均值。最终查询结果中的第一个数据point(`2.121`)是前两个最大值的平均值(`(2.116 + 2.126) / 2`)。

### NON_NEGATIVE_DERIVATIVE()

返回field value之间的非负变化率。非负变化率包括正的变化率和等于0的变化率。

#### 基本语法

```
SELECT NON_NEGATIVE_DERIVATIVE( [ * | <field_key> | /<regular_expression>/ ] [ , <unit> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

InfluxDB计算field value之间的差值，并将这些结果转换为每个`unit`的变化率。参数`unit`的值是一个整数，后跟一个时间单位。这个参数是可选的，不是必须要有的。如果查询没有指定`unit`的值，那么`unit`默认为一秒(`1s`)。`NON_NEGATIVE_DERIVATIVE()`只返回正的变化率和等于0的变化率。

`NON_NEGATIVE_DERIVATIVE(field_key)`
返回field key对应的field value的非负变化率。

`NON_NEGATIVE_DERIVATIVE(/regular_expression/)`
返回与正则表达式匹配的每个field key对应的field value的非负变化率。

`NON_NEGATIVE_DERIVATIVE(*)`
返回在measurement中每个field key对应的field value的非负变化率。

`NON_NEGATIVE_DERIVATIVE()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`NON_NEGATIVE_DERIVATIVE()`和`GROUP BY time()`子句。

##### 示例

请查看`DERIVATIVE()`文档中的示例，`NON_NEGATIVE_DERIVATIVE()`跟`DERIVATIVE()`的运行方式相同，但是`NON_NEGATIVE_DERIVATIVE()`只返回查询结果中正的变化率和等于0的变化率。

#### 高级语法

```
SELECT NON_NEGATIVE_DERIVATIVE(<function> ([ * | <field_key> | /<regular_expression>/ ]) [ , <unit> ] ) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的非负导数。

参数`unit`的值是一个整数，后跟一个时间单位。这个参数是可选的，不是必须要有的。如果查询没有指定`unit`的值，那么`unit`默认为`GROUP BY time()`的时间间隔。请注意，这里`unit`的默认值跟基本语法中`unit`的默认值不一样。`NON_NEGATIVE_DERIVATIVE()`只返回正的变化率和等于0的变化率。

`NON_NEGATIVE_DERIVATIVE()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)
##### 示例

请查看`DERIVATIVE()`文档中的示例，`NON_NEGATIVE_DERIVATIVE()`跟`DERIVATIVE()`的运行方式相同，但是`NON_NEGATIVE_DERIVATIVE()`只返回查询结果中正的变化率和等于0的变化率。

### NON_NEGATIVE_DIFFERENCE()

返回field value之间的非负差值。非负差值包括正的差值和等于0的差值。

#### 基本语法

```
SELECT NON_NEGATIVE_DIFFERENCE( [ * | <field_key> | /<regular_expression>/ ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`NON_NEGATIVE_DIFFERENCE(field_key)`
返回field key对应的field value的非负差值。

`NON_NEGATIVE_DIFFERENCE(/regular_expression/)`
返回与正则表达式匹配的每个field key对应的field value的非负差值。

`NON_NEGATIVE_DIFFERENCE(*)`
返回在measurement中每个field key对应的field value的非负差值。

`NON_NEGATIVE_DIFFERENCE()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`NON_NEGATIVE_DIFFERENCE()`和`GROUP BY time()`子句。

##### 示例

请查看`DIFFERENCE()`文档中的示例，`NON_NEGATIVE_DIFFERENCE()`跟`DIFFERENCE()`的运行方式相同，但是`NON_NEGATIVE_DIFFERENCE()`只返回查询结果中正的差值和等于0的差值。

#### 高级语法

```
SELECT NON_NEGATIVE_DIFFERENCE(<function>( [ * | <field_key> | /<regular_expression>/ ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果之间的非负差值。

`NON_NEGATIVE_DIFFERENCE()支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

请查看`DIFFERENCE()`文档中的示例，`NON_NEGATIVE_DIFFERENCE()`跟`DIFFERENCE()`的运行方式相同，但是`NON_NEGATIVE_DIFFERENCE()`只返回查询结果中正的差值和等于0的差值。

### POW()

返回field value的`x`次方。

#### 基本语法

```
SELECT POW( [ * | <field_key> ], <x> ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`POW(field_key, x)`
返回field key对应的field value的`x`次方。

`POW(*, x)`
返回在measurement中每个field key对应的field value的`x`次方。

`POW()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`POW()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.90.41fc3ee27HC1R6)中的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的field value的4次方

```sql
> SELECT POW("water_level", 4) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  pow
----                  ---
2015-08-18T00:00:00Z  18.148417929216
2015-08-18T00:06:00Z  20.047612231936
2015-08-18T00:12:00Z  16.914992230656004
2015-08-18T00:18:00Z  20.429279055375993
2015-08-18T00:24:00Z  17.352898193760993
2015-08-18T00:30:00Z  17.69549197320101
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的4次方。

###### 计算measurement中每个field key对应的field value的4次方

```sql
> SELECT POW(*, 4) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  pow_water_level
----                  ---------------
2015-08-18T00:00:00Z  18.148417929216
2015-08-18T00:06:00Z  20.047612231936
2015-08-18T00:12:00Z  16.914992230656004
2015-08-18T00:18:00Z  20.429279055375993
2015-08-18T00:24:00Z  17.352898193760993
2015-08-18T00:30:00Z  17.69549197320101
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的4次方。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

<!-- ##### Calculate field values associated with each field key that matches a regular expression to the power of 4
```
> SELECT POW(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  pow
----                  ---
2015-08-18T00:00:00Z  18.148417929216
2015-08-18T00:06:00Z  20.047612231936
2015-08-18T00:12:00Z  16.914992230656004
2015-08-18T00:18:00Z  20.429279055375993
2015-08-18T00:24:00Z  17.352898193760993
2015-08-18T00:30:00Z  17.69549197320101

```

The query returns field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement multiplied to the power of 4. -->

###### 计算指定field key对应的field value的4次方并包含多个子句

```sql
> SELECT POW("water_level", 4) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  pow
----                  ---
2015-08-18T00:18:00Z  20.429279055375993
2015-08-18T00:12:00Z  16.914992230656004
2015-08-18T00:06:00Z  20.047612231936
2015-08-18T00:00:00Z  18.148417929216
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的4次方，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个(即前两个数据point不返回）。

#### 高级语法

```
SELECT POW(<function>( [ * | <field_key> ] ), <x>) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的`x`次方。

`POW()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值的4次方

```sql
> SELECT POW(MEAN("water_level"), 4) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  pow
----                  ---
2015-08-18T00:00:00Z  19.08029760999999
2015-08-18T00:12:00Z  18.609983417041
2015-08-18T00:24:00Z  17.523567165456008
```

该查询返回每12分钟的时间间隔对应的`water_level`的平均值的4次方。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的`water_level`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`POW()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值的4次方。

### ROUND()

返回指定值的四舍五入后的整数。

#### 基本语法

```
SELECT ROUND( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`ROUND(field_key)`
返回field key对应的field value四舍五入后的整数。

`ROUND(*)`
返回在measurement中每个field key对应的field value四舍五入后的整数。

`ROUND()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`ROUND()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用[示例数据](https://gist.github.com/sanderson/8f8aec94a60b2c31a61f44a37737bfea?spm=a2c4g.11186623.2.91.41fc3ee27HC1R6)中的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的field value四舍五入后的整数

```sql
> SELECT ROUND("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  round
----                  -----
2015-08-18T00:00:00Z  2
2015-08-18T00:06:00Z  2
2015-08-18T00:12:00Z  2
2015-08-18T00:18:00Z  2
2015-08-18T00:24:00Z  2
2015-08-18T00:30:00Z  2
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value四舍五入后的整数。

###### 计算measurement中每个field key对应的field value四舍五入后的整数

```sql
> SELECT ROUND(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  round_water_level
----                  -----------------
2015-08-18T00:00:00Z  2
2015-08-18T00:06:00Z  2
2015-08-18T00:12:00Z  2
2015-08-18T00:18:00Z  2
2015-08-18T00:24:00Z  2
2015-08-18T00:30:00Z  2
```

<!-- ##### Rounds field values associated with each field key that matches a regular expression
```
> SELECT ROUND(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                   round_water_level
----                   -----------------
2015-08-18T00:00:00Z   3
2015-08-18T00:06:00Z   3
2015-08-18T00:12:00Z   3
2015-08-18T00:18:00Z   3
2015-08-18T00:24:00Z   3
2015-08-18T00:30:00Z   4
```

The query returns field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement rounded to the nearest integer. -->

###### 计算指定field key对应的field value四舍五入后的整数并包含多个子句

```sql
> SELECT ROUND("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  round
----                  -----
2015-08-18T00:18:00Z  2
2015-08-18T00:12:00Z  2
2015-08-18T00:06:00Z  2
2015-08-18T00:00:00Z  2
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value四舍五入后的整数，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个(即前两个数据point不返回）。

#### 高级语法

```
SELECT ROUND(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果四舍五入后的整数。

`ROUND()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值四舍五入后的整数

```sql
> SELECT ROUND(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  round
----                  -----
2015-08-18T00:00:00Z  2
2015-08-18T00:12:00Z  2
2015-08-18T00:24:00Z  2
```

该查询返回每12分钟的时间间隔对应的`water_level`的平均值四舍五入后的整数。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的`water_level`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`ROUND()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值四舍五入后的整数。

### SIN()

返回field value的正弦值。

#### 基本语法

```
SELECT SIN( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`SIN(field_key)`
返回field key对应的field value的正弦值。

`SIN(*)`
返回在measurement中每个field key对应的field value的正弦值。

`SIN()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`SIN()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用`NOAA_water_database`数据集的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的field value的正弦值

```sql
> SELECT SIN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  sin
----                  ---
2015-08-18T00:00:00Z  0.8808206017241819
2015-08-18T00:06:00Z  0.8550216851706579
2015-08-18T00:12:00Z  0.8972904165810275
2015-08-18T00:18:00Z  0.8497930984115993
2015-08-18T00:24:00Z  0.8914760289023131
2015-08-18T00:30:00Z  0.8869008523376968
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的正弦值。

###### 计算measurement中每个field key对应的field value的正弦值

```sql
> SELECT SIN(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  sin_water_level
----                  ---------------
2015-08-18T00:00:00Z  0.8808206017241819
2015-08-18T00:06:00Z  0.8550216851706579
2015-08-18T00:12:00Z  0.8972904165810275
2015-08-18T00:18:00Z  0.8497930984115993
2015-08-18T00:24:00Z  0.8914760289023131
2015-08-18T00:30:00Z  0.8869008523376968
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的正弦值。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

<!-- ##### Calculate the sine of field values associated with each field key that matches a regular expression
```
> SELECT SIN(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  sin
----                  ---
2015-08-18T00:00:00Z  0.8808206017241819
2015-08-18T00:06:00Z  0.8550216851706579
2015-08-18T00:12:00Z  0.8972904165810275
2015-08-18T00:18:00Z  0.8497930984115993
2015-08-18T00:24:00Z  0.8914760289023131
2015-08-18T00:30:00Z  0.8869008523376968
```

The query returns sine of field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement. -->

###### 计算指定field key对应的field value的正弦值并包含多个子句

```sql
> SELECT SIN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  sin
----                  ---
2015-08-18T00:18:00Z  0.8497930984115993
2015-08-18T00:12:00Z  0.8972904165810275
2015-08-18T00:06:00Z  0.8550216851706579
2015-08-18T00:00:00Z  0.8808206017241819
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的正弦值，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个(即前两个数据point不返回）。

#### 高级语法

```
SELECT SIN(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的正弦值。

`SIN()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值的正弦值

```sql
> SELECT SIN(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  sin

----                  ---
2015-08-18T00:00:00Z  0.8682145834456126
2015-08-18T00:12:00Z  0.8745914945253902
2015-08-18T00:24:00Z  0.8891995555912935
```

该查询返回每12分钟的时间间隔对应的`water_level`的平均值的正弦值。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的`water_level`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`SIN()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值的正弦值。

### SQRT()

返回field value的平方根。

#### 基本语法

```
SELECT SQRT( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`SQRT(field_key)`
返回field key对应的field value的平方根。

`SQRT(*)`
返回在measurement中每个field key对应的field value的平方根。

`SQRT()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`SQRT()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用”NOAA_water_database”数据集的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的field value的平方根

```sql
> SELECT SQRT("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  sqrt
----                  ----
2015-08-18T00:00:00Z  1.4366627996854378
2015-08-18T00:06:00Z  1.4546477236774544
2015-08-18T00:12:00Z  1.4240786495134319
2015-08-18T00:18:00Z  1.4580809305384939
2015-08-18T00:24:00Z  1.4286357128393508
2015-08-18T00:30:00Z  1.4321312788986909
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的平方根。

###### 计算measurement中每个field key对应的field value的平方根

```sql
> SELECT SQRT(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  sqrt_water_level
----                  ----------------
2015-08-18T00:00:00Z  1.4366627996854378
2015-08-18T00:06:00Z  1.4546477236774544
2015-08-18T00:12:00Z  1.4240786495134319
2015-08-18T00:18:00Z  1.4580809305384939
2015-08-18T00:24:00Z  1.4286357128393508
2015-08-18T00:30:00Z  1.4321312788986909
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的平方根。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

<!-- ##### Calculate the square root of field values associated with each field key that matches a regular expression
```
> SELECT SQRT(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  sqrt_water_level
----                  ----------------
2015-08-18T00:00:00Z  1.4366627996854378
2015-08-18T00:06:00Z  1.4546477236774544
2015-08-18T00:12:00Z  1.4240786495134319
2015-08-18T00:18:00Z  1.4580809305384939
2015-08-18T00:24:00Z  1.4286357128393508
2015-08-18T00:30:00Z  1.4321312788986909
```

The query returns the square roots of field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement. -->

###### 计算指定field key对应的field value的平方根并包含多个子句

```sql
> SELECT SQRT("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  sqrt
----                  ----
2015-08-18T00:18:00Z  1.4580809305384939
2015-08-18T00:12:00Z  1.4240786495134319
2015-08-18T00:06:00Z  1.4546477236774544
2015-08-18T00:00:00Z  1.4366627996854378
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的平方根，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个(即前两个数据point不返回）。

#### 高级语法

```
SELECT SQRT(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的平方根。

`SQRT()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值的平方根

```sql
> SELECT SQRT(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  sqrt
----                  ----
2015-08-18T00:00:00Z  1.445683229480096
2015-08-18T00:12:00Z  1.4411800720243115
2015-08-18T00:24:00Z  1.430384563675098
```

该查询返回每12分钟的时间间隔对应的`water_level`的平均值的平方根。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的`water_level`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`SQRT()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值的平方根。

### TAN()

返回field value的正切值。

#### 基本语法

```
SELECT TAN( [ * | <field_key> ] ) [INTO_clause] FROM_clause [WHERE_clause] [GROUP_BY_clause] [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`TAN(field_key)`
返回field key对应的field value的正切值。

`TAN(*)`
返回在measurement中每个field key对应的field value的正切值。

`TAN()`支持数据类型为int64和float64的field value。

基本语法支持group by tags的`GROUP BY`子句，但是不支持group by time。请查看高级语法章节了解如何使用`TAN()`和`GROUP BY time()`子句。

##### 示例

下面的示例将使用`NOAA_water_database`数据集的如下数据：

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  water_level
----                  -----------
2015-08-18T00:00:00Z  2.064
2015-08-18T00:06:00Z  2.116
2015-08-18T00:12:00Z  2.028
2015-08-18T00:18:00Z  2.126
2015-08-18T00:24:00Z  2.041
2015-08-18T00:30:00Z  2.051
```

###### 计算指定field key对应的field value的正切值

```sql
> SELECT TAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  tan
----                  ---
2015-08-18T00:00:00Z  -1.8604293534384375
2015-08-18T00:06:00Z  -1.6487359603347427
2015-08-18T00:12:00Z  -2.0326408012302273
2015-08-18T00:18:00Z  -1.6121545688343464
2015-08-18T00:24:00Z  -1.9676434782626282
2015-08-18T00:30:00Z  -1.9198657720074992
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的正切值。

###### 计算measurement中每个field key对应的field value的正切值

```sql
> SELECT TAN(*) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  tan_water_level
----                  ---------------
2015-08-18T00:00:00Z  -1.8604293534384375
2015-08-18T00:06:00Z  -1.6487359603347427
2015-08-18T00:12:00Z  -2.0326408012302273
2015-08-18T00:18:00Z  -1.6121545688343464
2015-08-18T00:24:00Z  -1.9676434782626282
2015-08-18T00:30:00Z  -1.9198657720074992
```

该查询返回measurement `h2o_feet`中每个存储数值的field key对应的field value的正切值。measurement `h2o_feet`中只有一个数值类型的field：`water_level`。

<!-- ##### Calculate the tangent of field values associated with each field key that matches a regular expression
```
> SELECT TAN(/water/) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                  tan
----                  ---
2015-08-18T00:00:00Z  -1.8604293534384375
2015-08-18T00:06:00Z  -1.6487359603347427
2015-08-18T00:12:00Z  -2.0326408012302273
2015-08-18T00:18:00Z  -1.6121545688343464
2015-08-18T00:24:00Z  -1.9676434782626282
2015-08-18T00:30:00Z  -1.9198657720074992
```

The query returns tangent of field values for each field key that stores numerical values and includes the word `water` in the `h2o_feet` measurement. -->

###### 计算指定field key对应的field value的正切值并包含多个子句

```sql
> SELECT TAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2

name: h2o_feet
time                  tan
----                  ---
2015-08-18T00:18:00Z  -1.6121545688343464
2015-08-18T00:12:00Z  -2.0326408012302273
2015-08-18T00:06:00Z  -1.6487359603347427
2015-08-18T00:00:00Z  -1.8604293534384375
```

该查询返回measurement `h2o_feet`中field key `water_level`对应的field value的正切值，它涵盖的时间范围在`2015-08-18T00:00:00Z`和`2015-08-18T00:30:00Z`之间，并且以递减的时间戳顺序返回结果，同时，该查询将返回的数据point个数限制为4，并将返回的数据point偏移两个(即前两个数据point不返回）。

#### 高级语法

```
SELECT TAN(<function>( [ * | <field_key> ] )) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

高级语法需要一个`GROUP BY time()`子句和一个嵌套的InfluxQL函数。查询首先计算在指定的`GROUP BY time()`间隔内嵌套函数的结果，然后计算这些结果的正切值。

`TAN()`支持以下嵌套函数：

- [`COUNT()`](#count)
- [`MEAN()`](#mean)
- [`MEDIAN()`](#median)
- [`MODE()`](#mode)
- [`SUM()`](#sum)
- [`FIRST()`](#first)
- [`LAST()`](#last)
- [`MIN()`](#min)
- [`MAX()`](#max)
- [`PERCENTILE()`](#percentile)

##### 示例

###### 计算平均值的正弦值

```sql
> SELECT TAN(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                  tan
----                  ---
2015-08-18T00:00:00Z  -1.7497661902817365
2015-08-18T00:12:00Z  -1.8038002062256624
2015-08-18T00:24:00Z  -1.9435224805850773
```

该查询返回每12分钟的时间间隔对应的`water_level`的平均值的正切值。

为了得到这些结果，InfluxDB首先计算每12分钟的时间间隔对应的`water_level`的平均值。这一步跟同时使用`MEAN()`函数和`GROUP BY time()`子句、但不使用`TAN()`的情形一样：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)

name: h2o_feet
time                   mean
----                   ----
2015-08-18T00:00:00Z   2.09
2015-08-18T00:12:00Z   2.077
2015-08-18T00:24:00Z   2.0460000000000003
```

然后，InfluxDB计算这些平均值的正切值。

## Predictors

### HOLT_WINTERS()

* 使用[Holt-Winters](https://www.otexts.org/fpp/7/5?spm=a2c4g.11186623.2.92.41fc3ee27HC1R6)的季节性方法返回N个预测的field value。

  `HOLT_WINTERS()`可用于：

  - 预测时间什么时候会超过给定的阈值
  - 将预测值与实际值进行比较，检测数据中的异常

#### 语法

```
SELECT HOLT_WINTERS[_WITH-FIT](<function>(<field_key>),<N>,<S>) [INTO_clause] FROM_clause [WHERE_clause] GROUP_BY_clause [ORDER_BY_clause] [LIMIT_clause] [OFFSET_clause] [SLIMIT_clause] [SOFFSET_clause]
```

`HOLT_WINTERS(function(field_key),N,S)`
返回field key对应的`N`个季节性调整的预测field value。

`N`个预测值出现的时间间隔跟group by time时间间隔相同。如果您的`GROUP BY time()`时间间隔是`6m`并且`N`等于`3`，那么您将会得到3个时间间隔为6分钟的预测值。

`S`是一个季节性模式参数，并且根据`GROUP BY time()`时间间隔限定一个季节性模式的长度。如果您的`GROUP BY time()`时间间隔是`2m`并且`S`等于`3`，那么这个季节性模式每六分钟出现一次，也就是每三个数据point。如果您不希望季节性调整您的预测值，请将`S`设置为`0`或`1`。

`HOLT_WINTERS_WITH_FIT(function(field_key),N,S)`
除了返回field key对应的`N`个季节性调整的预测field value，还返回拟合值。

`HOLT_WINTERS()`和`HOLT_WINTERS_WITH_FIT()`处理以相同的时间间隔出现的数据；嵌套的InfluxQL函数和`GROUP BY time()`子句确保Holt-Winters函数能够对常规数据进行操作。

`HOLT_WINTERS()`和`HOLT_WINTERS_WITH_FIT()`支持数据类型为int64和float64的field value。

#### 示例

##### 预测指定field key的field value

###### 原始数据

示例一使用了[Chronograf](https://github.com/influxdata/chronograf?spm=a2c4g.11186623.2.93.41fc3ee27HC1R6)来可视化数据。该示例重点关注`NOAA_water_database`数据集的如下数据：

```sql
SELECT "water_level" FROM "NOAA_water_database"."autogen"."h2o_feet" WHERE "location"='santa_monica' AND time >= '2015-08-22 22:12:00' AND time <= '2015-08-28 03:00:00'
```

![Raw Data](/img/influxdb/1-3-hw-raw-data-1-2.png)

###### 步骤一：匹配原始数据的趋势

编写一个`GROUP BY time()`查询，使得它匹配原始`water_level`数据的总体趋势。这里，我们使用了`FIRST()`函数：

```sql
SELECT FIRST("water_level") FROM "NOAA_water_database"."autogen"."h2o_feet" WHERE "location"='santa_monica' and time >= '2015-08-22 22:12:00' and time <= '2015-08-28 03:00:00' GROUP BY time(379m,348m)
```

在`GROUP BY time()`子句中，第一个参数(`379m`)匹配`water_level`数据中每个波峰和波谷之间发生的时间长度，第二个参数(`348m`)是一个偏移间隔，它通过改变InfluxDB的默认`GROUP BY time()`边界来匹配原始数据的时间范围。

蓝线显示了查询结果：

![First step](/img/influxdb/1-3-hw-first-step-1-2.png)

###### 步骤二：确定季节性模式

使用步骤一中查询的信息确定数据中的季节性模式。

关注下图中的蓝线，`water_level`数据中的模式大约每25小时15分钟重复一次。每个季节有四个数据point，所以`4`是季节性模式参数。

![Second step](/img/influxdb/1-3-hw-second-step-1-2.png)

###### 步骤三：应用`HOLT_WINTERS()`函数

在查询中加入Holt-Winters函数。这里，我们使用`HOLT_WINTERS_WITH_FIT()`来查看拟合值和预测值：

```sql
SELECT HOLT_WINTERS_WITH_FIT(FIRST("water_level"),10,4) FROM "NOAA_water_database"."autogen"."h2o_feet" WHERE "location"='santa_monica' AND time >= '2015-08-22 22:12:00' AND time <= '2015-08-28 03:00:00' GROUP BY time(379m,348m)
```

在`HOLT_WINTERS_WITH_FIT()`函数中，第一个参数(`10`)请求10个预测的field value。每个预测的数据point相距`379m`，与`GROUP BY time()`子句中的第一个参数相同。`HOLT_WINTERS_WITH_FIT()`函数中的第二个参数(`4`)是我们在上一步骤中确定的季节性模式。

蓝线显示了查询结果：

![Third step](/img/influxdb/1-3-hw-third-step-1-2.png)

#### `HOLT_WINTERS()`的常见问题

##### `HOLT_WINTERS()`和收到的数据point少于”N”个

在某些情况下，用户可能会收到比参数`N`请求的更少的预测数据point。当数学计算不稳定和不能预测更多数据point时，这种情况就会发生。这意味着该数据集不适合使用`HOLT_WINTERS()`，或者，季节性调整参数是无效的并且是算法混乱。

## 技术分析

下面技术分析的函数将广泛使用的算法应用在您的数据中。虽然这些函数主要应用在金融和投资领域，但是它们也适用于其它行业和用例。

[CHANDE_MOMENTUM_OSCILLATOR()](#chande-momentum-oscillator)  
[EXPONENTIAL_MOVING_AVERAGE()](#exponential-moving-average)  
[DOUBLE_EXPONENTIAL_MOVING_AVERAGE()](#double-exponential-moving-average)  
[KAUFMANS_EFFICIENCY_RATIO()](#kaufmans-efficiency-ratio)  
[KAUFMANS_ADAPTIVE_MOVING_AVERAGE()](#kaufmans-adaptive-moving-average)  
[TRIPLE_EXPONENTIAL_MOVING_AVERAGE()](#triple-exponential-moving-average)  
[TRIPLE_EXPONENTIAL_DERIVATIVE()](#triple-exponential-derivative)  
[RELATIVE_STRENGTH_INDEX()](#relative-strength-index)  

### 参数

除了field key，技术分析函数还接受以下参数：

#### `PERIOD`

**必需，整数，min=1**

算法的样本大小。这基本上是对算法的输出有显著影响的历史样本的数量。例如，`2`表示当前的数据point和前一个数据point。算法使用指数衰减率来决定历史数据point的权重，通常称为`alpha(α)`。参数`PERIOD`控制衰减率。

> 请注意，历史数据point仍然可以产生影响。

#### `HOLD_PERIOD`

**整数，min=-1**

算法需要多少个样本才会开始发送结果。默认值`-1`表示该参数的值基于算法、`PERIOD`和`WARMUP_TYPE`，但是这是一个可以使算法发送有意义的结果的值。

**默认的Hold Periods：**

对于大多数提供的技术分析，`HOLD_PERIOD`的默认值由您使用的技术分析算法和`WARMUP_TYPE`决定。

| 算法 \ Warmup Type                                           | simple                 | exponential |                 none                 |
| ------------------------------------------------------------ | ---------------------- | ----------- | :----------------------------------: |
| [EXPONENTIAL_MOVING_AVERAGE](#exponential-moving-average)    | PERIOD - 1             | PERIOD - 1  | <span style="opacity:.35">n/a</span> |
| [DOUBLE_EXPONENTIAL_MOVING_AVERAGE](#double-exponential-moving-average) | ( PERIOD - 1 ) * 2     | PERIOD - 1  | <span style="opacity:.35">n/a</span> |
| [TRIPLE_EXPONENTIAL_MOVING_AVERAGE](#triple-exponential-moving-average) | ( PERIOD - 1 ) * 3     | PERIOD - 1  | <span style="opacity:.35">n/a</span> |
| [TRIPLE_EXPONENTIAL_DERIVATIVE](#triple-exponential-derivative) | ( PERIOD - 1 ) * 3 + 1 | PERIOD      | <span style="opacity:.35">n/a</span> |
| [RELATIVE_STRENGTH_INDEX](#relative-strength-index)          | PERIOD                 | PERIOD      | <span style="opacity:.35">n/a</span> |
| [CHANDE_MOMENTUM_OSCILLATOR](#chande-momentum-oscillator)    | PERIOD                 | PERIOD      |              PERIOD - 1              |

_**Kaufman算法默认的Hold Periods：**_

| 算法                                                         | 默认的Hold Period |
| ------------------------------------------------------------ | ----------------- |
| [KAUFMANS_EFFICIENCY_RATIO()](#kaufmans-efficiency-ratio)    | PERIOD            |
| [KAUFMANS_ADAPTIVE_MOVING_AVERAGE()](#kaufmans-adaptive-moving-average) | PERIOD            |

#### `WARMUP_TYPE`

**默认=”exponential”**

这个参数控制算法如何为第一个`PERIOD`样本初始化自身，它本质上是具有不完整样本集的持续时间。

`simple`
第一个`PERIOD`样本的简单移动平均值(simple moving average，SMA)。这是[ta-lib](https://www.ta-lib.org/?spm=a2c4g.11186623.2.106.41fc3ee27HC1R6)使用的方法。

`exponential`
具有缩放alpha(α)的指数移动平均值(exponential moving average，EMA)。基本上是这样使用EMA：`PERIOD=1`用于第一个点，`PERIOD=2`用于第二个点，以此类推，直至算法已经消耗了`PERIOD`个数据point。由于算法一开始就使用了EMA，当使用此方法并且没有指定`HOLD_PERIOD`的值或`HOLD_PERIOD`的值为`-1`时，算法可能会在比`simple`小得多的样本大小的情况下开始发送数据point。

`none`
算法不执行任何的平滑操作。这是[ta-lib](https://www.ta-lib.org/?spm=a2c4g.11186623.2.107.41fc3ee27HC1R6)使用的方法。当使用此方法并且没有指定`HOLD_PERIOD`时，`HOLD_PERIOD`的默认值是`PERIOD - 1`。

> 类型`none`仅适用于`CHANDE_MOMENTUM_OSCILLATOR()`函数。

### CHANDE_MOMENTUM_OSCILLATOR()

Chande Momentum Oscillator (CMO)是由Tushar Chande开发的一个技术动量指标。通过计算所有最近较高数据point的总和与所有最近较低数据point的总和的差值，然后将结果除以给定时间范围内的所有数据变动的总和来创建CMO指标。将结果乘以100可以得到一个从-100到+100的范围。
<sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="https://www.fidelity.com/learning-center/trading-investing/technical-analysis/technical-indicator-guide/cmo" target="\_blank">Source</a>

#### 基本语法

```
CHANDE_MOMENTUM_OSCILLATOR([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period>, [warmup_type]])
```

**可用的参数：**

[period](#period)
[hold_period](#warmup-type) （可选项）
[warmup_type](#warmup-type) （可选项）

`CHANDE_MOMENTUM_OSCILLATOR(field_key, 2)`  
返回使用CMO算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`CHANDE_MOMENTUM_OSCILLATOR(field_key, 10, 9, 'none')`  
返回使用CMO算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为9，warmup type设为`none`。

`CHANDE_MOMENTUM_OSCILLATOR(MEAN(<field_key>), 2) ... GROUP BY time(1d)`  
返回使用CMO算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

> **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`CHANDE_MOMENTUM_OSCILLATOR()`函数中调用聚合函数。

`CHANDE_MOMENTUM_OSCILLATOR(/regular_expression/, 2)`  
返回使用CMO算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`CHANDE_MOMENTUM_OSCILLATOR(*, 2)`  
返回使用CMO算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`CHANDE_MOMENTUM_OSCILLATOR()` 支持数据类型为int64和float64的field value。

### EXPONENTIAL_MOVING_AVERAGE()

指数移动平均值 (Exponential Moving Average，EMA)类似于简单移动平均值，不同的是，指数移动平均值对最新数据给予更多的权重，它也被称为”指数加权移动平均值”。与简单移动平均值相比，这种类型的移动平均值对最近数据的变化反应更快。

<sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="https://www.investopedia.com/terms/e/ema.asp" target="\_blank">Source</a>

#### 基本语法

```
EXPONENTIAL_MOVING_AVERAGE([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period)[, <warmup_type]])
```

**Available Arguments:**  

[period](#period)
[hold_period](#warmup-type) （可选项）
[warmup_type](#warmup-type) （可选项）

`EXPONENTIAL_MOVING_AVERAGE(field_key, 2)`  
返回使用EMA算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`EXPONENTIAL_MOVING_AVERAGE(field_key, 10, 9, 'exponential')`  
返回使用EMA算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为9，warmup type设为`exponential`。

`EXPONENTIAL_MOVING_AVERAGE(MEAN(<field_key>), 2) ... GROUP BY time(1d)`  
返回使用EMA算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

> **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`EXPONENTIAL_MOVING_AVERAGE()`函数中调用聚合函数。

`EXPONENTIAL_MOVING_AVERAGE(/regular_expression/, 2)`  
返回使用EMA算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`EXPONENTIAL_MOVING_AVERAGE(*, 2)`  
返回使用EMA算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`EXPONENTIAL_MOVING_AVERAGE()` 支持数据类型为int64和float64的field value。

### DOUBLE_EXPONENTIAL_MOVING_AVERAGE()

双重指数移动平均值 (Double Exponential Moving Average，DEMA)通过增加最近数据的权重，尝试消除与移动平均值相关的固有滞后。该名字似乎表明这是通过双重指数平滑来实现的，然而事实并非如此，它表示的是将EMA的值翻倍。为了使它与实际数据保持一致，也为了消除滞后，从之前两倍EMA的值中把”EMA of EMA”的值减去，公式为：DEMA = 2 * EMA - EMA(EMA)。

<sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="https://en.wikipedia.org/wiki/Double_exponential_moving_average" target="\_blank">Source</a>

#### 基本语法

```
DOUBLE_EXPONENTIAL_MOVING_AVERAGE([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period)[, <warmup_type]])
```

**可用的参数：**  

[period](#period)
[hold_period](#warmup-type) （可选项）
[warmup_type](#warmup-type) （可选项）

`DOUBLE_EXPONENTIAL_MOVING_AVERAGE(field_key, 2)`
返回使用DEMA算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`DOUBLE_EXPONENTIAL_MOVING_AVERAGE(field_key, 10, 9, 'exponential')`
返回使用DEMA算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为9，warmup type设为`exponential`。

`DOUBLE_EXPONENTIAL_MOVING_AVERAGE(MEAN(<field_key>), 2) ... GROUP BY time(1d)`
返回使用DEMA算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

> **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`DOUBLE_EXPONENTIAL_MOVING_AVERAGE()`函数中调用聚合函数。

`DOUBLE_EXPONENTIAL_MOVING_AVERAGE(/regular_expression/, 2)`
返回使用DEMA算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`DOUBLE_EXPONENTIAL_MOVING_AVERAGE(*, 2)`
返回使用DEMA算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`DOUBLE_EXPONENTIAL_MOVING_AVERAGE()`支持数据类型为int64和float64的field value。

### KAUFMANS_EFFICIENCY_RATIO()

Kaufman效率比 (Kaufman’s Efficiency Ration)，或简称为效率比 (Efficiency Ratio，ER)，它的计算方法是：将一段时间内的数据变化除以实现该变化所发生的数据变动的绝对值的总和。得出的比率在0和1之间，比率越高，表示市场越有效率或越有趋势。



ER跟Chande Momentum Oscillator (CMO)非常类似。不同的是，CMO将市场方向考虑在内，但是如果您将CMO的绝对值除以100，就可以得到ER。

<sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="http://etfhq.com/blog/2011/02/07/kaufmans-efficiency-ratio/" target="\_blank">Source</a>

#### 基本语法

```
KAUFMANS_EFFICIENCY_RATIO([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period>])
```

**可用的参数：**

[period](#period)
[hold_period](#warmup-type) （可选项）

`KAUFMANS_EFFICIENCY_RATIO(field_key, 2)`
返回使用效率指数(Efficiency Index)算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period。

`KAUFMANS_EFFICIENCY_RATIO(field_key, 10, 10)`
返回使用效率指数算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为10。

`KAUFMANS_EFFICIENCY_RATIO(MEAN(<field_key>), 2) ... GROUP BY time(1d)`
返回使用效率指数算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period。

> **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`KAUFMANS_EFFICIENCY_RATIO()`函数中调用聚合函数。

`KAUFMANS_EFFICIENCY_RATIO(/regular_expression/, 2)`
返回使用效率指数算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period。

`KAUFMANS_EFFICIENCY_RATIO(*, 2)`
返回使用效率指数算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period。

`KAUFMANS_EFFICIENCY_RATIO()`支持数据类型为int64和float64的field value。

### KAUFMANS_ADAPTIVE_MOVING_AVERAGE()

Kaufman自适应移动平均值 (Kaufman’s Adaptive Moving Average，KAMA)，是一个用于计算样本噪音或波动率的移动平均值。当数据波动相对较小并且噪音较低时，KAMA会密切关注数据point。当数据波动较大时，KAMA会进行调整，平滑噪音。该趋势跟踪指标可用于识别总体趋势、时间转折点和过滤价格变动。

<sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:kaufman_s_adaptive_moving_average" target="\_blank">Source</a>

#### 基本语法

```
KAUFMANS_ADAPTIVE_MOVING_AVERAGE([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period>])
```

**可用的参数：**
[period](#period)
[hold_period](#warmup-type) （可选项）

`KAUFMANS_ADAPTIVE_MOVING_AVERAGE(field_key, 2)`
返回使用KAMA算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period。

`KAUFMANS_ADAPTIVE_MOVING_AVERAGE(field_key, 10, 10)`
返回使用KAMA算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为10。

`KAUFMANS_ADAPTIVE_MOVING_AVERAGE(MEAN(<field_key>), 2) ... GROUP BY time(1d)`
返回使用KAMA算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period。

> **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`KAUFMANS_ADAPTIVE_MOVING_AVERAGE()`函数中调用聚合函数。

`KAUFMANS_ADAPTIVE_MOVING_AVERAGE(/regular_expression/, 2)`
返回使用KAMA算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period。

`KAUFMANS_ADAPTIVE_MOVING_AVERAGE(*, 2)`
返回使用KAMA算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period。

`KAUFMANS_ADAPTIVE_MOVING_AVERAGE()`支持数据类型为int64和float64的field value。

### TRIPLE_EXPONENTIAL_MOVING_AVERAGE()

三重指数移动平均值 (Triple Exponential Moving Average，TEMA)，旨在过滤常规移动平均值的波动。该名字似乎表明这是通过三重指数平滑来实现的，然而事实并非如此，它实际上是包含[指数移动平均值](https://help.aliyun.com/document_detail/113126.html?spm=a2c4g.11186623.6.752.79c45773lFKbWc#46)、[双重指数移动平均值](https://help.aliyun.com/document_detail/113126.html?spm=a2c4g.11186623.6.752.79c45773lFKbWc#47)和三重指数移动平均值的复合函数。

<sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="https://www.investopedia.com/terms/t/triple-exponential-moving-average.asp " target="\_blank">Source</a>

#### 基本语法

```
TRIPLE_EXPONENTIAL_MOVING_AVERAGE([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period)[, <warmup_type]])
```

**Available Arguments:**  

[period](#period)
[hold_period](#warmup-type) （可选项）
[warmup_type](#warmup-type) （可选项）

`TRIPLE_EXPONENTIAL_MOVING_AVERAGE(field_key, 2)`
返回使用TEMA算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`TRIPLE_EXPONENTIAL_MOVING_AVERAGE(field_key, 10, 9, 'exponential')`
返回使用TEMA算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为9，warmup type设为`exponential`。

`TRIPLE_EXPONENTIAL_MOVING_AVERAGE(MEAN(<field_key>), 2) ... GROUP BY time(1d)`
返回使用TEMA算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

> **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`TRIPLE_EXPONENTIAL_MOVING_AVERAGE()`函数中调用聚合函数。

`TRIPLE_EXPONENTIAL_MOVING_AVERAGE(/regular_expression/, 2)`
返回使用TEMA算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`TRIPLE_EXPONENTIAL_MOVING_AVERAGE(*, 2)`
返回使用TEMA算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`TRIPLE_EXPONENTIAL_MOVING_AVERAGE()`支持数据类型为int64和float64的field value。

### TRIPLE_EXPONENTIAL_DERIVATIVE()

三重指数导数指标 (Triple Exponential Derivative Indicator)，通常称为”TRIX”，是一种用于识别超卖和超买市场的振荡器，也可用作动量指标。TRIX计算一段时间内输入数据的对数的[三重指数移动平均值](https://help.aliyun.com/document_detail/113126.html?spm=a2c4g.11186623.6.752.79c45773lFKbWc#50)。从当前的值中减去之前的值，这可以防止指标考虑比规定期间短的周期。



跟很多振荡器一样，TRIX围绕着零线震荡。当它用作振荡器时，正数表示炒买超买市场，而负数表示超卖市场。当它用作动量指标时，正数表示动量在增加，而负数表示动量在减少。很多分析师认为，当TRIX超过零线时，它会给出买入信号，当低于零线时，它会给出卖出信号。

<sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="https://www.investopedia.com/articles/technical/02/092402.asp " target="\_blank">Source</a>

#### 基本语法

```
TRIPLE_EXPONENTIAL_DERIVATIVE([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period)[, <warmup_type]])
```

**可用的参数：**

[period](#period)
[hold_period](#warmup-type) （可选项）
[warmup_type](#warmup-type) （可选项）

`TRIPLE_EXPONENTIAL_DERIVATIVE(field_key, 2)`
返回使用三重指数导数算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`TRIPLE_EXPONENTIAL_DERIVATIVE(field_key, 10, 10, 'exponential')`
返回使用三重指数导数算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为10，warmup type设为`exponential`。

`TRIPLE_EXPONENTIAL_DERIVATIVE(MEAN(<field_key>), 2) ... GROUP BY time(1d)`
返回使用三重指数导数算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

> **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`TRIPLE_EXPONENTIAL_DERIVATIVE()`函数中调用聚合函数。

`TRIPLE_EXPONENTIAL_DERIVATIVE(/regular_expression/, 2)`
返回使用三重指数导数算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`TRIPLE_EXPONENTIAL_DERIVATIVE(*, 2)`
返回使用三重指数导数算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`TRIPLE_EXPONENTIAL_DERIVATIVE()`支持数据类型为int64和float64的field value。

### RELATIVE_STRENGTH_INDEX()

相对强弱指数 (Relative Strength Index，RSI)是一个动量指标，用于比较在指定时间段内最近数据增大和减小的幅度，以便measurement数据变动的速度和变化。

<sup style="line-height:0; font-size:.7rem; font-style:italic; font-weight:normal;"><a href="https://www.investopedia.com/terms/r/rsi.asp" target="\_blank">Source</a>

#### 基本语法

```
RELATIVE_STRENGTH_INDEX([ * | <field_key> | /regular_expression/ ], <period>[, <hold_period)[, <warmup_type]])
```

**Available Arguments:**  

[period](#period)
[hold_period](#warmup-type) （可选项）
[warmup_type](#warmup-type) （可选项）

`RELATIVE_STRENGTH_INDEX(field_key, 2)`
返回使用RSI算法处理field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`RELATIVE_STRENGTH_INDEX(field_key, 10, 10, 'exponential')`
返回使用RSI算法处理field key对应的field value后的结果，该算法中，period设为10，hold period设为10，warmup type设为`exponential`。

`RELATIVE_STRENGTH_INDEX(MEAN(<field_key>), 2) ... GROUP BY time(1d)`
返回使用RSI算法处理field key对应的field value平均值后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

> **注意：**当使用`GROUP BY`子句将数据进行聚合时，您必须在`RELATIVE_STRENGTH_INDEX()`函数中调用聚合函数。

`RELATIVE_STRENGTH_INDEX(/regular_expression/, 2)`
返回使用RSI算法处理与正则表达式匹配的每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`RELATIVE_STRENGTH_INDEX(*, 2)`
返回使用RSI算法处理measurement中每个field key对应的field value后的结果，该算法中，period设为2，使用默认的hold period和warmup type。

`RELATIVE_STRENGTH_INDEX()`支持数据类型为int64和float64的field value。

## 其它

### 示例数据

本文档使用的数据可在[示例数据](/influxdb/v1.8/query_language/data_download/)中下载。

### 函数的通用语法

#### 在SELECT子句中指定多个函数

##### 语法

```
SELECT <function>(),<function>() FROM_clause [...]
```

使用逗号(`,`)将`SELECT`语句中的多个函数分开。该语法适用于除`TOP()`和`BOTTOM()`之外的所有InfluxQL函数。`SELECT`子句不支持`TOP()`或`BOTTOM()`和其它函数同时使用。

##### 示例

###### 在一个查询中计算field value的平均值和平均数

```sql
> SELECT MEAN("water_level"),MEDIAN("water_level") FROM "h2o_feet"

name: h2o_feet
time                  mean               median
----                  ----               ------
1970-01-01T00:00:00Z  4.442107025822522  4.124
```

该查询返回`water_level`的平均值和平均数。

###### 在一个查询中计算两个field的mode

```sql
> SELECT MODE("water_level"),MODE("level description") FROM "h2o_feet"

name: h2o_feet
time                  mode  mode_1
----                  ----  ------
1970-01-01T00:00:00Z  2.69  between 3 and 6 feet
```

该查询返回`water_level`中出现频率最高的field value和`level description`中出现频率最高的field value。`water_level`对应的值在列`mode`中，`level description`对应的值在列`mode_1`中。因为系统不能返回多个具有相同名字的列，所以它将第二个列`mode`重命名为`mode_1`。

关于如何配置输出列的名字，请查看[重命名输出的field key](#rename-the-output-field-key)章节。

###### 在一个查询中计算field value的最小值和最大值

```sql
> SELECT MIN("water_level"), MAX("water_level") [...]

name: h2o_feet
time                  min    max
----                  ---    ---
1970-01-01T00:00:00Z  -0.61  9.964
```

该查询返回`water_level`的最小值和最大值。

请注意，该查询返回`1970-01-01T00:00:00Z`作为时间戳，这是InfluxDB的空时间戳。`MIN()`和`MAX()`是selector函数；当selector函数是`SELECT`子句中的唯一函数时，它返回一个特定的时间戳。因为`MIN()`和`MAX()`返回两个不同的时间戳（见下面的例子），所以系统会用空时间戳覆盖这些时间戳。

```sql
>  SELECT MIN("water_level") FROM "h2o_feet"

name: h2o_feet
time                  min
----                  ---
2015-08-29T14:30:00Z  -0.61    <--- Timestamp 1

>  SELECT MAX("water_level") FROM "h2o_feet"

name: h2o_feet
time                  max
----                  ---
2015-08-29T07:24:00Z  9.964    <--- Timestamp 2
```

#### 重命名输出的field key

##### 语法

```
SELECT <function>() AS <field_key> [...]
```

默认情况下，函数返回的结果在与函数名称匹配的field key下面。使用`AS`子句可以指定输出的field key的名字。

##### 示例

###### 指定输出的field key

```sql
> SELECT MEAN("water_level") AS "dream_name" FROM "h2o_feet"

name: h2o_feet
time                  dream_name
----                  ----------
1970-01-01T00:00:00Z  4.442107025822522
```

该查询返回`water_level`的平均值，并将输出的field key重命名为`dream_name`。如果没有`AS`子句，那么查询会返回`mean`作为输出的field key：

```sql
> SELECT MEAN("water_level") FROM "h2o_feet"

name: h2o_feet
time                  mean
----                  ----
1970-01-01T00:00:00Z  4.442107025822522
```

###### 为多个函数指定输出的field key

```sql
> SELECT MEDIAN("water_level") AS "med_wat",MODE("water_level") AS "mode_wat" FROM "h2o_feet"

name: h2o_feet
time                  med_wat  mode_wat
----                  -------  --------
1970-01-01T00:00:00Z  4.124    2.69
```

该查询返回`water_level`的平均数和`water_level`中出现频率最高的field value，并将输出的field key分别重命名为`med_wat`和`mode_wat`。如果没有`AS`子句，那么查询会返回`median`和`mode`作为输出的field key：

```sql
> SELECT MEDIAN("water_level"),MODE("water_level") FROM "h2o_feet"

name: h2o_feet
time                  median  mode
----                  ------  ----
1970-01-01T00:00:00Z  4.124   2.69
```

#### 改变不含数据的时间间隔的返回值

默认情况下，包含InfluxQL函数和`GROUP BY time()`子句的查询对不包含数据的时间间隔返回空值。在`GROUP BY`子句后面加上`fill()`可以更改这个值。关于`fill()`的详细讨论，请查看数据探索。

### 函数的常见问题

以下部分描述了所有函数、聚合函数和选择函数的常见混淆来源，有关单个功能的常见问题，请参见以下特定文档：

* [DISTINCT()](#common-issues-with-distinct)
* [BOTTOM()](#common-issues-with-bottom)
* [PERCENTILE()](#common-issues-with-percentile)
* [SAMPLE()](#common-issues-with-sample)
* [TOP()](#common-issues-with-top)
* [ELAPSED()](#common-issues-with-elapsed)
* [HOLT_WINTERS()](#common-issues-with-holt-winters)

#### 所有函数

##### 嵌套函数


某些InfluxQL 函数支持 [`SELECT` clause](/influxdb/v1.8/query_language/explore-data/#select-clause)中嵌套:
* [`COUNT()`](#count) with [`DISTINCT()`](#distinct)
* [`CUMULATIVE_SUM()`](#cumulative-sum)
* [`DERIVATIVE()`](#derivative)
* [`DIFFERENCE()`](#difference)
* [`ELAPSED()`](#elapsed)
* [`MOVING_AVERAGE()`](#moving-average)
* [`NON_NEGATIVE_DERIVATIVE()`](#non-negative-derivative)
* [`HOLT_WINTERS()`](#holt-winters) and [`HOLT_WINTERS_WITH_FIT()`](#holt-winters)

对于其他函数，请使用 InfluxQL's [子查询](/influxdb/v1.8/query_language/explore-data/#subqueries) 中的嵌套函数  [`FROM` clause](/influxdb/v1.8/query_language/explore-data/#from-clause).
有关使用子查询的更多信息，请参见 [数据探索](/influxdb/v1.8/query_language/explore-data/#subqueries) 页面

##### 查询在now()之后的时间范围

大多数`SELECT`语句的默认时间范围在`1677-09-21 00:12:43.145224194` UTC和`2262-04-11T23:47:16.854775806Z` UTC之间。对于包含InfluxQL函数和`GROUP BY time()`子句的`SELECT`查询，默认的时间范围在`1677-09-21 00:12:43.145224194`和`now()`之间。

如果要查询时间戳发生在`now()`之后的数据，那么包含InfluxQL函数和`GROUP BY time()`子句的`SELECT`查询必须在`WHERE`子句中提供一个时间上限。请查看FAQ。

#### 聚合函数

##### 理解返回的时间戳

子句中具有 [聚合函数](#aggregations) 且 [`WHERE` clause](/influxdb/v1.8/query_language/explore-data/#the-where-clause) 没有时间范围的查询讲返回 epoch 0 (`1970-01-01T00:00:00Z`) 作为时间戳.
InfluxDB 使用 epoch 0 作为等效的空时间戳.
带有聚合函数的查询，如果 `WHERE` 子句中包含时间范围，将返回时间下限作为时间戳.

##### 示例

###### 使用聚合函数并且没有指定时间范围

```sql
> SELECT SUM("water_level") FROM "h2o_feet"

name: h2o_feet
time                   sum
----                   ---
1970-01-01T00:00:00Z   67777.66900000004
```

该查询将InfluxDB的空时间戳(epoch 0: `1970-01-01T00:00:00Z`)作为时间戳返回。`SUM()`将多个数据point聚合，没有单个时间戳可以返回。

###### 使用聚合函数并且指定时间范围

```sql
> SELECT SUM("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z'

name: h2o_feet
time                  sum
----                  ---
2015-08-18T00:00:00Z  67777.66900000004
```

该查询将时间范围的下界(`WHERE time >= '2015-08-18T00:00:00Z'`)作为时间戳返回。

###### 使用聚合函数并且指定时间范围和使用GROUP BY time()子句

```sql
> SELECT SUM("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:18:00Z' GROUP BY time(12m)

name: h2o_feet
time                  sum
----                  ---
2015-08-18T00:00:00Z  20.305
2015-08-18T00:12:00Z  19.802999999999997
```

该查询将每个`GROUP BY time()`间隔的时间下界作为时间戳返回。

###### 将聚合函数和不聚合的数据混合使用

聚合函数不支持在`SELECT`语句中指定不使用聚合函数的单独的field key或tag key。聚合函数返回一个计算结果，对于没有被聚合的field或tag，没有明显的单个值可以返回。当`SELECT`语句同时包含聚合函数和单独的field key或tag key时，会返回错误：

```sql
> SELECT SUM("water_level"),"location" FROM "h2o_feet"

ERR: error parsing query: mixing aggregate and non-aggregate queries is not supported
```

##### 得到略有不同的结果

对于某些聚合函数，在相同的数据point（数据类型为float64)上执行相同的函数，可能会产生稍微不同的结果。在应用聚合函数之间，InfluxDB不会将数据point进行排序；该行为可能会导致查询结果中出现小小的差异。

#### Selector函数

##### 理解返回的时间戳

selector函数返回的时间戳依赖查询中函数的数量和查询中的其它子句：

带有单个选择器函数，单个 [field key](/influxdb/v1.8/concepts/glossary/#field-key) 参数和无 [`GROUP BY time()` clause](/influxdb/v1.8/query_language/explore-data/#group-by-time-intervals) 的查询返回原始数据中出现的point时间戳.
具有单个 selector 函数, 多个 `field key` 参数的查询, [`GROUP BY time()` clause](/influxdb/v1.8/query_language/explore-data/#group-by-time-intervals) 返回原始数据中出现的point 时间戳，或与空时间戳 (epoch 0: `1970-01-01T00:00:00Z`)等价的InfluxDB.

在 [`WHERE` clause](/influxdb/v1.8/query_language/explore-data/#the-where-clause) 子句中有多个函数且没有时间范围的查询将返回相当于空时间戳 (epoch 0: `1970-01-01T00:00:00Z`).
在 `WHERE`子句中包含多个函数和时间范围的查询将时间下限作为时间戳返回 

带有 selector 函数和  `GROUP BY time()` 子句的查询返回每个 `GROUP BY time()`间隔的时间下限.
请注意， `SAMPLE()`函数与其他selector 函数在与 `GROUP BY time()` 子句匹配中表现不同
有关更多信息，请参见 [常见问题 `样本()`](#common-issues-with-sample).

##### 示例

###### 使用单个selector函数和单个field key，并且没有指定时间范围

```sql
> SELECT MAX("water_level") FROM "h2o_feet"

name: h2o_feet
time                  max
----                  ---
2015-08-29T07:24:00Z  9.964

> SELECT MAX("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z'

name: h2o_feet
time                  max
----                  ---
2015-08-29T07:24:00Z  9.964
```

该查询返回原始数据中具有`最大`值的数据point的时间戳。

###### 使用单个selector函数和多个field key，并且没有指定时间范围

```sql
> SELECT FIRST(*) FROM "h2o_feet"

name: h2o_feet
time                  first_level description  first_water_level
----                  -----------------------  -----------------
1970-01-01T00:00:00Z  between 6 and 9 feet     8.12

> SELECT MAX(*) FROM "h2o_feet"

name: h2o_feet
time                  max_water_level
----                  ---------------
2015-08-29T07:24:00Z  9.964
```

第一个查询返回InfluxDB的空时间戳(epoch 0: `1970-01-01T00:00:00Z`)作为查询结果中的时间戳。因为`FIRST(*)`返回两个时间戳（对应measurement `h2o_feet`中的每个field key），所以系统使用空时间戳覆盖这两个时间戳。

第二个查询返回原始数据中具有最大值的数据point的时间戳。因为`MAX(*)`只返回一个时间戳(measurement `h2o_feet`中只有一个数值类型的field)，所以系统不会覆盖原始时间戳。

###### 使用多个selector函数，并且没有指定时间范围

```sql
> SELECT MAX("water_level"),MIN("water_level") FROM "h2o_feet"

name: h2o_feet
time                  max    min
----                  ---    ---
1970-01-01T00:00:00Z  9.964  -0.61
```

该查询返回InfluxDB的空时间戳(epoch 0: `1970-01-01T00:00:00Z`)作为查询结果中的时间戳。因为`MAX()`和`MIN()`函数返回不同的时间戳，所以系统没有单个时间戳可以返回。

###### 使用多个selector函数，并且指定时间范围

```sql
> SELECT MAX("water_level"),MIN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z'

name: h2o_feet
time                  max    min
----                  ---    ---
2015-08-18T00:00:00Z  9.964  -0.61
```

该查询返回时间范围的下界(`WHERE time >= '2015-08-18T00:00:00Z'`)作为查询结果中的时间戳。

###### 使用单个selector函数，并且指定时间范围

```sql
> SELECT MAX("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:18:00Z' GROUP BY time(12m)

name: h2o_feet
time                  max
----                  ---
2015-08-18T00:00:00Z  8.12
2015-08-18T00:12:00Z  7.887
```

该查询返回每个`GROUP BY time()`间隔的时间下限作为查询结果中的时间戳。

