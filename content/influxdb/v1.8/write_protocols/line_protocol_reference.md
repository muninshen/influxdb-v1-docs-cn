---
title: InfluxDB 线路协议参考
description: >
  InfluxDB line protocol is a text-based format for writing points to InfluxDB.
aliases:
    - /influxdb/v1.8/write_protocols/write_syntax/
menu:
  influxdb_1_8:
    name: InfluxDB line protocol 参考
    weight: 10
    parent: 写入协议
---

InfluxDB line protocol 是一种基于文本的格式，用于将points 写入InfluxDB

## line protocol语法

```
<measurement>[,<tag_key>=<tag_value>[,<tag_key>=<tag_value>]] <field_key>=<field_value>[,<field_key>=<field_value>] [<timestamp>]
```

Line protocol 接受换行符`\n `,并且区分空格

>**Note** Line protocol 不支持tag value 或filed value 中的换行符。

### 语法描述

InfluxDB line protocol 将数据的measurement,tag set,field  set和timestamp 通知给Influxdb.

| 组件 | 可选/必须 | 描述 | 类型<br>(有关更多信息，请参见[数据类型](#数据类型))。 |
| :-------| :---------------- |:----------- |:----------------
| [Measurement](/influxdb/v1.8/concepts/glossary/#measurement) | 需要 | 测量名称. InfluxDB 每一个point 接受一次 measurement  | 字符串
| [Tag set](/influxdb/v1.8/concepts/glossary/#tag-set) | 可选| 该point对应一个 tag key-value 标记键值对.  | [Tag keys](/influxdb/v1.8/concepts/glossary/#tag-key) 和 [tag values](/influxdb/v1.8/concepts/glossary/#tag-value) 都是字符串
| [Field set](/influxdb/v1.8/concepts/glossary/#field-set) | 需要 Points 点必须至少具有一个字段. | 该pointl 所有 key-value 键值对. | [Field keys字段键](/influxdb/v1.8/concepts/glossary/#field-key) 是字符串. [Field values字段值](/influxdb/v1.8/concepts/glossary/#field-value) 可以使浮点数, 整数,字符串,或者 Booleans.
| [Timestamp](/influxdb/v1.8/concepts/glossary/#timestamp) |可选. 如果时间戳不包含在该point中，Influxdb数据库将使用服务器的本地纳秒时间 （以世界协调为单位） | 数据point. | Unix 纳秒时间戳. 使用Influxdb数据库应用API接口替代精度

> #### 性能提示:
>
- 在将数据发送到InfluxDB之前，请按tag keys 排序，以匹配 [Go字节.Compare 函数](http://golang . org/pkg/bytes/# Compare)
- 为了显著提高压缩性能，请尽可能使用最粗略的时间戳[precision](/influx db/v 1.8/tools/API/# write-http-endpoint).
- 使用网络时间协议(NTP)来同步主机之间的时间。Influxdb使用主机的本地时间(以世界协调时表示)为数据分配时间戳。如果主机的时钟与NTP不同步，主机写入InfluxDB的数据可能会有不准确的时间戳。

## Data types

| 数据类型 | 元素 | 描述 |
| :----------- | :------------------------ |:------------ |
| Float | Field values（字段值） | 默认数字类型。IEEE-754 64位浮点数(NaN或+/- Inf除外)。例子:` 1 '，` 1.0 '，` 1.e+78 '，` 1。E+78 `。 |
| Integer | Field values（字段值） | 有符号64位整数(-9223372036854775808至9223372036854775807)。请指定一个在数字后面带有“I”的整数。示例:` 1i |
| String | Measurements, tag keys, tag values, field keys, field values | 长度限制64KB. |
| Boolean | Field values | 存储TRUE或FASE值.<br><br>正确的写入语法:`[t, T, true, True, TRUE]`.<br><br>伪写语法:`[f, F, false, False, FALSE]` |
| Timestamp | Timestamps | Unix 纳秒级时间戳. 使用 [InfluxDB API](/influxdb/v1.8/tools/api/#write-http-endpoint).指定替代精度，最小有效时间戳为-9223372036854775806` 或 `1677-09-21T00:12:43.145224194Z`. 最大有效时间戳为  `9223372036854775806` 或 `2262-04-11T23:47:16.854775806Z`. |

#### 用于写入和查询的boolean语法

数据写入和数据查询可接受 Boolean 语法不同， 有关更多信息，请参考[常见问题](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#why-can-t-i-query-boolean-field-values).

#### 字段类型差异

在measurement中, 一个 field's type 在 [shard](/influxdb/v1.8/concepts/glossary/#shard)不能不同, 但在shards可以不同

要了解field value 类型差异如何影响“select *”查询， 请参考[InfluxDB 如何处理shards 之间的 field 类型差异?](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#how-does-influxdb-handle-field-type-discrepancies-across-shards).

### 例子

#### 将field value `-1.234456e+78`作为浮点数写入 InfluxDB

```sql
> INSERT mymeas value=-1.234456e+78
```

InfluxDB 支持科学计数法指定的field value.

#### 将field value 1.0 作为浮点数写入 InfluxDB

```sql
> INSERT mymeas value=1.0
```

#### 将field value  `1`作为浮点数写入 InfluxDB

```sql
> INSERT mymeas value=1
```

#### 将field value 1作为浮点数写入 InfluxDB

```sql
> INSERT mymeas value=1i
```

#### 将filed value `stringing along` 作为字符串写入 InfluxDB

```sql
> INSERT mymeas value="stringing along"
```

始终用双引号将字符串 field value引起来，更多关于引用如下 [below](#quoting).

#### 将filed value `true`作为boolean写入influxdb

```sql
> INSERT mymeas value=true
```

不要引用以下语句将`true`字符串field value 写入InfluxDB：

```sql
> INSERT mymeas value="true"
```

尝试将字符串写入先前接受的浮点型field 

如果float和string上的时间戳记存储在同一shards中：

```sql
> INSERT mymeas value=3 1465934559000000000
> INSERT mymeas value="stringing along" 1465934559000000001
ERR: {"error":"field type conflict: input field \"value\" on measurement \"mymeas\" is type string, already exists as type float"}
```

如果浮点数和字符串上的时间戳没有存储在同一个shards中

```sql
> INSERT mymeas value=3 1465934559000000000
> INSERT mymeas value="stringing along" 1466625759000000000
>
```

### 引用、特殊字符和其他命名准则

| 元素 | 双引号 | 单引号 |
| :------ | :------------ |:------------- |
| Timestamp | 从不 | 从不 |
| Measurements, tag keys, tag values, field keys | 从不* | 从不r* |
| Field values | 双引号字符串字段值，不要用引号引上浮点数，整数或者Booleans | 从不 |

\* InfluxDB line protocol 允许用户使用双引号和单引号measurement名称，tag keys，tag values和field key。但是，它将假定双引号或单引号是名称，key 或values的一部分。这会使查询语法复杂化（请参见下面的示例）

#### 例子

##### 无效的line protocol-双引号时间戳

```sql
> INSERT mymeas value=9 "1466625759000000000"
ERR: {"error":"unable to parse 'mymeas value=9 \"1466625759000000000\"': bad timestamp"}
```

双重引用（或单引号）时间戳会产生bad time stamp错误.

##### 语义错误 - 双引号表示Boolean

```sql
> INSERT mymeas value="true"
> SHOW FIELD KEYS FROM "mymeas"
name: mymeas
------------
fieldKey	 fieldType
value		   string
```

InfluxDB 假设所有双引号field values都是字符串

##### Semantic error - Double quote a measurement name

```sql
> INSERT "mymeas" value=200
> SHOW MEASUREMENTS
name: measurements
------------------
name
"mymeas"
> SELECT * FROM mymeas
> SELECT * FROM "mymeas"
> SELECT * FROM "\"mymeas\""
name: "mymeas"
--------------
time				                        value
2016-06-14T20:36:21.836131014Z	 200
```

如果您在line protocol中重复引用measurement值，对此有任何疑问 measurement 要求在 ` FROM `子句

### 特殊字符

您必须使用反斜杠字符\来转义下列特殊字符：

* 在字符串field value中，必须转义:
  * 双引号 
  * 反斜杠字符

例如，\ "转义双引号。

>反斜杠上的注释:
* 如果使用多个反斜杠，它们必须被转义。内流按如下方式解释反斜杠:
  *	`\` 或 `\\` 解释为 `\`
  *	`\\\` 或 `\\\\`解释为 `\\`
  * `\\\\\` 或 `\\\\\\` 解释为 `\\\`, 依次类推

* 在tag key ,tag values和field key中，必须转义
  * 逗号
  * 等号
  * 空格

例如，\,转义逗号。

* 在测量中，您必须转义：
  * commas  
  * spaces

您不需要转义其他特殊字符.

#### 例子

##### 用特殊字符写Point

```sql
> INSERT "measurement\ with\ quo⚡️es\ and\ emoji",tag\ key\ with\ sp🚀ces=tag\,value\,with"commas" field_k\ey="string field value, only \" need be esc🍭ped"
```

系统会写一个测量点"measurement with quo⚡️es and emoji"，tag key 为tag key with sp🚀ces，tag values为`tag,value,with"commas"`，field key 为field_key,field value为`string field value, only " need be esc🍭ped`。

### 附加命名准则

`#`行的开头是line protocol的有效注释字符。InfluxDB将忽略所有后续字符，直到下一个换行符为止\n。

measurement 名称，tag keys，tag values，field key 和field values区分大小写。

InfluxDB line protocol接受[InfluxQL 关键字](/influxdb/v1.8/query_language/spec/#keywords)和 [标识符](/influxdb/v1.8/concepts/glossary/#identifier) 名称.通过, 我们建议避免使用 InfluxQL 关键字， 因为它可能在查询数据时引起[混乱](/influxdb/v1.8/troubleshooting/errors/#error-parsing-query-found-expected-identifier-at-line-char) .

> 注意：避免使用保留键`_field`和`_measurement`。如果将这些key作为标记或filed key 包括在内，则关联的point 将被丢弃。

关键字`time`是一种特殊情况。`time`可以是[continuous query](/influxdb/v1.8/concepts/glossary/#continuous-query-cq) 名称，数据库名称，[measurement](/influxdb/v1.8/concepts/glossary/#measurement) name，[retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp) name,，[subscription](/influxdb/v1.8/concepts/glossary/#subscription) 名称,和[user](/influxdb/v1.8/concepts/glossary/#user) 名称。在这种情况下，`time`查询中不需要双引号。
`time`不能是[field key](/influxdb/v1.8/concepts/glossary/#field-key)或[tag key](/influxdb/v1.8/concepts/glossary/#tag-key);  InfluxDB拒绝使用`time`作为field key 或tag key的写入，否则返回错误。有关更多信息，请参考[常见问题](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#time) 

## InfluxDB line protocol 实践

要了解如何将line protocol 写入数据库，请参阅[工具](/influxdb/v1.8/tools/).。

### 重复 points

Point由measurement 名称、tag set、filed get和timestamp组成的唯一标识 

如果您将一个point 写入到一个具有与现有point 匹配的时间戳的序列中，则该field set 将成为新旧field get 的集合，而冲突则有利于新字field set 。

 有关这种行为以及如何避免这种行为的完整示例，请参见 [InfluxDB如何处理重复点？](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#how-does-influxdb-handle-duplicate-points)

### 重复 keys

如果measurement 中具有相同名称的tag key和field key ，则其中一个key 将返回并附加一个`_1`查询结果（并在Chronograf中作为列标题）。例如`location`和`location_1`。要查询重复的key，请删除`_1`并在查询中使用`InfluxQL::tag`或`::field`语法，例如：

```sql
  SELECT "location"::tag, "location"::field FROM "database_name"."retention_policy"."measurement"
```
