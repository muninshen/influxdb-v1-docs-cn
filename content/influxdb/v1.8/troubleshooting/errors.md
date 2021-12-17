---
title: InfluxDB 错误信息
description: >
  Covers InfluxDB error messages, their descriptions, and common resolutions.
menu:
  influxdb_1_8:
    name: 错误信息
    weight: 30
    parent: 故障排除
---

此页面记录了错误，它们的描述以及（如适用）常见的解决方案

{{% warn %}}
**免责声明:**本文档未详尽列出所有可能出现的Influxdb错误.
{{% /warn %}}

## `error: database name required`

当某些SHOW查询未指定数据库时，将发生此错误，指定数据库与ON在子句SHOW描述查询时，USE <database_name>在[CLI](/influxdb/v1.8/tools/shell/), 或与db在查询字符串参数 [InfluxDB API](/influxdb/v1.8/tools/api/#query-string-parameters) 请求.

相关的查询包括 `SHOW RETENTION POLICIES`, `SHOW SERIES`,
`SHOW MEASUREMENTS`, `SHOW TAG KEYS`, `SHOW TAG VALUES`, and `SHOW FIELD KEYS`.

**资源:**
[模式探索](/influxdb/v1.8/query_language/explore-schema/),
[InfluxQL 参考](/influxdb/v1.8/query_language/spec/)

## `error: max series per database exceeded: < >`

当写入数据的series数量超过每数据库最大允许series,就会发生错误。每个数据库的最大允许series由配置文件部分中的max-series-per-database设置控制[data]。

图中的信息< >显示了超出的series的measurement值和tag set max-series-per-database。

默认情况下max-series-per-database设置为一百万。如设置更改为0允许每个数据库无限数量的series

**资源:**
[数据库配置](/influxdb/v1.8/administration/config/#max-series-per-database-1000000)

## `error parsing query: found < >, expected identifier at line < >, char < >`

### InfluxQL 语法

 `expected identifier`

当Influxdb预期的标识符的查询，但没有找到它发生的错误，标识符是引用连续查询的名称，数据库名称，field keys,measurement 名称，retention policy 名称，subscription 名称，tag keys 和user名称以及用户名令牌，该错误通常会提醒你自己检查查询的语法问题

**例**

*Query 1:*

```sql
> CREATE CONTINUOUS QUERY ON "telegraf" BEGIN SELECT mean("usage_idle") INTO "average_cpu" FROM "cpu" GROUP BY time(1h),"cpu" END
ERR: error parsing query: found ON, expected identifier at line 1, char 25
```

此查询缺少介于`CREATE CONTINUOUS QUERY`之间的连续查询名称和 ON

* 查询2:

```sql
> SELECT * FROM WHERE "blue" = true
ERR: error parsing query: found WHERE, expected identifier at line 1, char 15
```

Query 2：缺少介于FROM之间的measurement名称的WHERE`.

### InfluxQL 关键字

`expected identifier`

在某些情况下，当查询中的标识符之一是InfluxQL关键字时，就会发生错误
要成功查询也是关键字的标识符，请将该标识符括在双引号中。

例

* 查询 1:

```sql
> SELECT duration FROM runs
ERR: error parsing query: found DURATION, expected identifier, string, number, bool at line 1, char 8
```

查询 1, 关键字duration是Influxdb关键字，双引号duration以避免错误

```sql
> SELECT "duration" FROM runs
```

*查询 2:*

```sql
> CREATE RETENTION POLICY limit ON telegraf DURATION 1d REPLICATION 1
ERR: error parsing query: found LIMIT, expected identifier at line 1, char 25
```

在查询2中，保留策略名称`limit`是InfluxQL关键字，双引号`limit`以避免错误；

```sql
> CREATE RETENTION POLICY "limit" ON telegraf DURATION 1d REPLICATION 1
```

尽管使用双引号是一种可接受的解决办法，但为简单起见，我们建议避免将Influxdb关键字用作标识符；

**资源:**[InfluxQL 关键字](/influxdb/v1.8/query_language/spec/#keywords),[查询语言文档](/influxdb/v1.8/query_language/)

## `error parsing query: found < >, expected string at line < >, char < >`

在 `expected string`当Influxdb预计一个字符串，但没有找到它发生的错误，在大多数情况下，该错误是由于忘记CREATE USER语句引用密码字符串而导致的。

例

```sql
> CREATE USER penelope WITH PASSWORD timeseries4dayz
ERR: error parsing query: found timeseries4dayz, expected string at line 1, char 36
```

该 `CREATE USER`语句在密码字符串周围需要单引号：

```sql
> CREATE USER penelope WITH PASSWORD 'timeseries4dayz'
```

请注意.对请求进行身份验证时不应该包含单引号；

**资源:**[身份验证与授权](/influxdb/v1.8/administration/authentication_and_authorization/)

## `error parsing query: mixing aggregate and non-aggregate queries is not supported`

在 `mixing aggregate and non-aggregate` 当发生错误SELECT的语句包含一个聚合函数和一个field key 或tag keys，聚合函数返回单个计算值，对于任何未聚合的filed 或者tag，没有明显的单个值要返回

**例**

*原始数据:*

该 `peg` measurement 有两个feilds (`square` 和 `round`) 和一个tag
(`force`):

```sql
name: peg
---------
time                   square   round   force
2016-10-07T18:50:00Z   2        8       1
2016-10-07T18:50:10Z   4        12      2
2016-10-07T18:50:20Z   6        14      4
2016-10-07T18:50:30Z   7        15      3
```

*查询 1:*

```sql
> SELECT mean("square"),"round" FROM "peg"
ERR: error parsing query: mixing aggregate and non-aggregate queries is not supported
```

查询 1包含一个汇总函数和一个独立字段

mean("square")会square根据peg measurement的四个值计算得出一个聚合值，并且没有明显的单个field value 要从该field的四个未聚合值中返回round field。

* 查询 2:*

```sql
> SELECT mean("square"),"force" FROM "peg"
ERR: error parsing query: mixing aggregate and non-aggregate queries is not supported
```

查询 2 包含一个聚合函数和一个独立的标签.

mean("square")会square根据peg measurement中的四个值计算得出一个聚合值，并且没有明显的单一tag value要从tag的四个未聚合值中返回force tag 。

**资源:**
[功能](/influxdb/v1.8/query_language/functions/)

## `invalid operation: time and \*influxql.VarRef are not compatible`

time and \*influxql.VarRef are not compatible当日期时间字符串在查询中双引号时，将发生错误。日期时间字符串需要单引号。.

### 例子

双引号日期时间字符串:

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= "2015-08-18T00:00:00Z" AND time <= "2015-08-18T00:12:00Z"
ERR: invalid operation: time and *influxql.VarRef are not compatible
```

单引号日期时间字符串:

```sql
> SELECT "water_level" FROM "h2o_feet" WHERE "location" = 'santa_monica' AND time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:12:00Z'

name: h2o_feet
time                   water_level
----                   -----------
2015-08-18T00:00:00Z   2.064
2015-08-18T00:06:00Z   2.116
2015-08-18T00:12:00Z   2.028
```

资源:**
[数据探索](/influxdb/v1.8/query_language/explore-data/#time-syntax)

## `unable to parse < >: bad timestamp`

### 时间戳语法

在 `bad timestamp` 发生错误 [line protocal](/influxdb/v1.8/concepts/glossary/#influxdb-line-protocol)包含在除UNIX时间戳意外的格式的时间戳

**例**

```sql
> INSERT pineapple value=1 '2015-08-18T23:00:00Z'
ERR: {"error":"unable to parse 'pineapple value=1 '2015-08-18T23:00:00Z'': bad timestamp"}
```

上面的line protocal 使用 [RFC3339](https://www.ietf.org/rfc/rfc3339.txt)时间戳，将时间戳替换为UNIX时间戳记可避免该错误，并将该点成功写入Influxdb：

```sql
> INSERT pineapple,fresh=true value=1 1439938800000000000
```

### InfluxDB line protocol 语法

在某些情况下，该bad timestamp错误与InfluxDB line protocal中的更多常规语法错误一起发生。line protocal对空格敏感；错位的空格会导致InfluxDB认为field 或tag 是无效的时间戳。.

**例**

*Write 1*

```sql
> INSERT hens location=2 value=9
ERR: {"error":"unable to parse 'hens location=2 value=9': bad timestamp"}
```

Write 1中的line protocal
使用空格而不是逗号将hens measurement与location=2标签分开。InfluxDB假定该value=9字段是时间戳，并返回错误。

在measurement和tag 之间使用逗号而不是空格来避免错误：

```sql
> INSERT hens,location=2 value=9
```

*Write 2*

```sql
> INSERT cows,name=daisy milk_prod=3 happy=3
ERR: {"error":"unable to parse 'cows,name=daisy milk_prod=3 happy=3': bad timestamp"}
```

Write 2中的line protocol 将milk_prod=3字段和happy=3 field 分隔为空格而不是逗号。InfluxDB假定该happy=3字段是时间戳，并返回错误。

请使用逗号而不是两个字段之间的空格来避免该错误：

```sql
> INSERT cows,name=daisy milk_prod=3,happy=3
```

**资源:**[InfluxDB line protocol tutorial](/influxdb/v1.8/write_protocols/line_protocol_tutorial/),[InfluxDB line protocol reference](/influxdb/v1.8/write_protocols/line_protocol_reference/)

## `unable to parse < >: time outside range`

在time outside range 当在所述时间戳发生
[InfluxDB line protocol](/influxdb/v1.8/concepts/glossary/#influxdb-line-protocol)落在Influxdb的有效时间范围之外

最小有效时间戳为 `-9223372036854775806`或 `1677-09-21T00:12:43.145224194Z`.
最大有效时间戳为 `9223372036854775806` 或 `2262-04-11T23:47:16.854775806Z`.

**资源:**
[InfluxDB 线协议教程](/influxdb/v1.8/write_protocols/line_protocol_tutorial/#data-types),
[InfluxDB 线协议参考](/influxdb/v1.8/write_protocols/line_protocol_reference/#data-types)

## write failed for shard < >: engine: cache maximum memory size exceeded

当缓存的内存大小增加超过了存储器的大小增加时，就会发生此错误。
cache-max-memory-size设定的配置文件中

默认情况下，cache-max-memory-size设置为512mb。该值对于大多数工作负载而言都很好，但对于较大的写入量或具有较高`series cardinality`而言，该值太小。如果您有大量RAM，则可以将其设置`0`, 禁用缓存的内存限制，并且永远不会出现此错误。您还可检查数据库中的measurement中`memBytes`字段，以了解内存中的大小`cache _internal`l

**资源:**[数据库配置](/influxdb/v1.8/administration/config/)

## `already killed`

`already killed`当查询已被终止时，会出现此错误，但是在退出查询之间会有后续的终止尝试，查询被杀死后，将处于killed状态，这以为已发送信息

**资源:**
[查询管理](/influxdb/v1.0/troubleshooting/query_management/)

## 常见 `-import` 错误

查找在命令行界面（CLI）中导致数据发生的常见错误

1. (可选) `-import`通过运行以下任何命令来定义如何查看错误输出:

  - 发送错误并输出到新文件: `influx -import -path={import-file}.gz -compressed {new-file} 2>&1`
  - 发送错误并输出到单独的文件: `influx -import -path={import-file}.gz -compressed > {output-file} 2> {error-file}`
  - 将错误发送到新文件: `influx -import -path={import-file}.gz -compressed 2> {new-file}`
  - 将输出发送到新文件: `influx -import -path={import-file}.gz -compressed {new-file}`

2. 检查导入的错误，找出可能的原因以解决问题；

  - [数据类型不一致](#inconsistent-data-types)
  - [Points早于保留策略](#data-points-older-than-retention-policy)
  - [未命名的导入文件](#unnamed-import-file)
  - [Docker 容器无法读取主机文件](#docker-container-cannot-read-host-files)

  >**注意** 要了解如何使用`-import`命令，请参阅[使用`-inpor`从文件导入数据`](/influxdb/v1.8/tools/shell/#import-data-from-a-file-with-import).

### 数据不一致

**错误:** `partial write: field type conflict:`

当导入的measurement中的字段的数据类型不一致时，会发生此错误。确保度量中的所有field都具有相同的数据类型，例如float64，int64等。

### 数据 points 早于保留策略

**错误:** `partial write: points beyond retention policy dropped={number-of-points-dropped}`

当导入的points早于指定的保留策略并被删除时，将发生此错误。验证在导入文件中指定了正确的保留策略。

### 未命名的导入文件

**错误:** `reading standard input: /path/to/directory: is a directory`

  当-import命令不包含导入文件的名称时，将发生此错误。指定要导入的文件，例如：$ influx -import -path={filename}.txt -precision=s

### Docker容器无法读取主机文件

**错误:** `open /path/to/file: no such file or directory`

当Docker容器无法读取主机上的文件时，会发生此错误。要使主机文件可读，请完成以下过程。

#### 使主机文件对 Docker可读

  1. 创建一个目录，然后将要导入的Influxdb的文件复制到该目录.

  2. 启动Docker容器时，通过运行以下命令将新目录安装在Influxdb容器上:

     ```
        docker run -v /dir/path/on/host:/dir/path/in/container
     ```


  3. 通过运行以下命令来验证docker容器可以读取主机文件

     ```
      influx -import -path=/path/in/container
     ```

     ​        
