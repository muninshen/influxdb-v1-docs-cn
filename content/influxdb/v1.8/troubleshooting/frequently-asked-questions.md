---
title: InfluxDB 常见问题
description: Common issues with InfluxDB OSS.
aliases:
  - /influxdb/v1.8/troubleshooting/frequently_encountered_issues/

menu:
  influxdb_1_8:
    name: 常见问题 (FAQs)
    weight: 10
    parent: 故障检测
---

该页面解决了常见的混乱来源以及InfluxDB相对于其他数据库系统表现出意外行为的地方。 在适用的情况下，它链接到GitHub上的未决问题。

**Administration**

* [如何在密码中包含单引号?](#how-do-i-include-a-single-quote-in-a-password)
* [如何识别我的 InfluxDB版本?](#how-can-i-identify-my-version-of-influxdb)
* [如何查找 InfluxDB 日志?](#where-can-i-find-influxdb-logs)
* [分片组持续保留时间与保留策略的关系?](#what-is-the-relationship-between-shard-group-durations-and-retention-policies)
* [为什么在我更改保留策略后数据没有被删除?](#why-aren-t-data-dropped-after-i-ve-altered-a-retention-policy)
* [为什么Influxdb无法解析配置文件中的微秒单位?](#why-does-influxdb-fail-to-parse-microsecond-units-in-the-configuration-file)
* [更改保留策略后，为什么不能删除数据?](#does-influxdb-have-a-file-system-size-limit)


**Command line interface (CLI)**

* [如何使Influxdb的CLI返回人类可读的时间戳?](#how-do-i-use-the-influxdb-cli-to-return-human-readable-timestamps)
* [非管理员用户如何 `USE`InfluxDB CLI中创建数据库?](#how-can-a-non-admin-user-use-a-database-in-the-influxdb-cli)
* [如何`DEFAULT`使用InfluxDB CLI写入非保留策略?](#how-do-i-write-to-a-non-default-retention-policy-with-the-influxdb-cli)
* [如何取消长时间运行的查询?](#how-do-i-cancel-a-long-running-query)

**Data types**

* [为什么不能查询boolean字段值?](#why-can-t-i-query-boolean-field-values)
* [Influxdb如何处理各个分片之间的字段类型差异?](#how-does-influxdb-handle-field-type-discrepancies-across-shards)
* [Infuxdb可以存储的最小和最大整数是多少?](#what-are-the-minimum-and-maximum-integers-that-influxdb-can-store)
* [Influxdb可以存储的最小和最大时间戳是多少?](#what-are-the-minimum-and-maximum-timestamps-that-influxdb-can-store)
* [如何判断字段中存储的数据类型?](#how-can-i-tell-what-type-of-data-is-stored-in-a-field)
* [我可以更改字段的数据类型吗?](#can-i-change-a-field-s-data-type)

**InfluxQL 功能**

* [如何在函数中执行数学函数?](#how-do-i-perform-mathematical-operations-within-a-function)
* [为什么我的查询返回epoch 0作为时间戳?](#why-does-my-query-return-epoch-0-as-the-timestamp)
* [哪些InfluxQL函数支持嵌套?](#which-influxql-functions-support-nesting)

**Querying data**

* [什么决定 `GROUP BY time()` 查询返回的时间间隔?](#what-determines-the-time-intervals-returned-by-group-by-time-queries)
* [为什么我的查询不返回数据或者部分数据?](#why-do-my-queries-return-no-data-or-partial-data)
* [为什么我的 `GROUP BY time()` 查询不返回之后发生的时间戳 `now()`?](#why-don-t-my-group-by-time-queries-return-timestamps-that-occur-after-now)
* [我可以 针对时间戳执行数学运算吗?](#can-i-perform-mathematical-operations-against-timestamps)
* [我可以从返回的时间戳执行数学运算吗?](#can-i-identify-write-precision-from-returned-timestamps)
* [在查询中什么时候应该单引号和什么时候应该双引号?](#when-should-i-single-quote-and-when-should-i-double-quote-in-queries)
* [为什么创建新的默认保留策略后，我会丢失数据](#why-am-i-missing-data-after-creating-a-new-default-retention-policy)
* [为什么我的带有WHERE 和time子句的查询返回空结果？?](#why-is-my-query-with-a-where-or-time-clause-returning-empty-results)
* [为什么 `fill(previous)` 返回空结果?](#why-does-fill-previous-return-empty-results)
* [为什么fill(previous)返回空结果？](#why-are-my-into-queries-missing-data)
* [如何使用相同的标记关键字和字段关键字查询数据?](#how-do-i-query-data-with-an-identical-tag-key-and-field-key)
* [如何跨measurements查询数据?](#how-do-i-query-data-across-measurements)
* [时间戳记的顺序重要吗?](#does-the-order-of-the-timestamps-matter)
* [如何select使用没有价值的标签进行数据处理?](#how-do-i-select-data-with-a-tag-that-has-no-value)

**Series and series cardinality**

* [为什么series cardinality很重要?](#why-does-series-cardinality-matter)
* [如何从索引中删除序列?](#how-can-i-remove-series-from-the-index)

**Writing data**

* [如何写整数field values?](#how-do-i-write-integer-field-values)
* [influxdb如何处理重复points?](#how-does-influxdb-handle-duplicate-points)
* [InfluxDB API 接口需要什么换行符?](#what-newline-character-does-the-influxdb-api-require)
* [向Influxdb写入数据时，应该避免哪些单词和字符?](#what-words-and-characters-should-i-avoid-when-writing-data-to-influxdb)
* [写数据什么时候单引号，什么时候双引号?](#when-should-i-single-quote-and-when-should-i-double-quote-when-writing-data)
* [ timestamp的精度真的很重要吗?](#does-the-precision-of-the-timestamp-matter)
* [编写稀疏历史数据的配置建议和模式指南是什么?](#what-are-the-configuration-recommendations-and-schema-guidelines-for-writing-sparse-historical-data)

## how-do-i-include-a-single-quote-in-a-password?

创建密码时用反斜杠(`\ `)转义单引号 以及何时发送认证请求。

## how-can-i-identify-my-version-of-influxdb?

有多种方法可以识别您正在使用的influxdb数据库版本:

#### 在你的终端上运行“influxd version”,即可查看版本信息:

```bash
$ influxd version

InfluxDB ✨ v1.4.0 ✨ (git: master b7bb7e8359642b6e071735b50ae41f5eb343fd42)
```

#### `curl` 该 `/ping` 端点:

```bash
$ curl -i 'http://localhost:8086/ping'

HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: 1e08aeb6-fec0-11e6-8486-000000000000
✨ X-Influxdb-Version: 1.4.x ✨
Date: Wed, 01 Mar 2017 20:46:17 GMT
```

#### 启动 InfluxDB [命令行界面](/influxdb/v1.8/tools/shell/):

```bash
$ influx

Connected to http://localhost:8086✨ version 1.4.x ✨
InfluxDB shell version: 1.4.x
```

#### 检查日志中的HTTP响应:

```bash
$ journalctl -u influxdb.service

Mar 01 20:49:45 rk-api influxd[29560]: [httpd] 127.0.0.1 - - [01/Mar/2017:20:49:45 +0000] "POST /query?db=&epoch=ns&q=SHOW+DATABASES HTTP/1.1" 200 151 "-" ✨ "InfluxDBShell/1.4.x" ✨ 9a4371a1-fec0-11e6-84b6-000000000000 1709
```

## where-can-i-find-influxdb-logs?

在 System V 操作系统上，日志存储在`/var/log/influxdb/`.

在 systemd 操作系统上，可以使用来访问日志`journalctl`.
使用 `journalctl -u influxdb` 查看日志，或者使用`journalctl -u influxdb > influxd.log` 将日志打印到文本文件中，对于systemd, 日志保留取决于系统的日志设置.

## What is the relationship between shard group durations and retention policies?

InfluxDB 将数据存储在shard groups中，单个shard groups覆盖特定的时间间隔，Influxdb通过查看DURATION相关的保留策略（RP）来确定该时间间隔，下表概述了DURATION RP和shard groups的时间间隔之间的的默认关系；

| RP 持续时间 | Shard group 间隔 |
|---|---|
| < 2 days  | 1 hour  |
| >= 2 days and <= 6 months  | 1 day  |
| > 6 months  | 7 days  |

用户还可以使用[`CREATE和ALTER RETENTION POLICY`](/influxdb/v1.8/query_language/manage-database/#create-retention-policies-with-create-retention-policy)和[`ALTER RETENTION POLICY`](/influxdb/v1.8/query_language/manage-database/#modify-retention-policies-with-alter-retention-policy)语句配置Shard group持续时间，使用该SHOW RETENTION POLICES语句检查保留策略的shard持续时间；

使用该[`SHOW RETENTION POLICIES`](/influxdb/v1.8/query_language/explore-schema/#show-retention-policies)语句检查保留策略的shard持续时间


## Why aren't data dropped after I've altered a retention policy?

有几个因素可以解释为什么更改保留策略（RP）后可能不会立即删除数据.

第一个也是最有可能的原因，默认情况下，Influxdb每30分钟检查一次以执行RP，你可能需要等待下一个RP检查，以便Influxdb删除RP新DURATION设置之外的数据，30分钟间隔是可以[配置](/influxdb/v1.8/administration/config/#check-interval-30m0s)的.

其次，同时更改RP DURATION 和SHARD DURATION RP可能会导致意外的数据保留，Influxdb将数据存储在分片组中，这些分片组涵盖特定的RP和时间间隔，当Influxdb强制执行RP时，它将丢弃整个分片组，而不是单个数据点，Influxdb无法划分分片组.
 如果RP的新版本DURATION少于旧的，SHARD DURATION而Influxdb当前正在将数据写入旧的较长的分片组之一，则系统被迫将所有数据保留在该分片中，即使该分片组中的某些数据不再new范围内，也会发生这种情况DURATION，一旦它的所有数据都在新数据库之外，Influxdb就会删除该分片组DURATION。然后，系统将开始将数据写入具有新的，较短的分片组，SHOW DURATION从而防止任何进一步的意外数据保留

## Why does InfluxDB fail to parse microsecond units in the configuration file?

 在InfluxDB [命令行界面](/influxdb/v1.8/tools/shell/) (CLI)中，用于指定微秒持续时间单位的语法因 [配置](/influxdb/v1.8/administration/config/) 设置, 写入，查询和设置精度而异，下表显示了每个类别支持的语法:

| | 配置文件 | InfluxDB API 写入 | 所有查询 | CLI Precision 命令 |
|---|---|---|---|---|
| u  | ❌ | 👍  |  👍 |  👍  |
| us |  👍  | ❌ | ❌ |  ❌ |
|  µ  | ❌ | ❌ |  👍  | ❌ |
|  µs  | 👍  | ❌ | ❌ |  ❌ |


如果配置选项指定 `u`和 `µ`语法, InfluxDB 无法启动，并在日志中报告一下错误:

```
run: parse config: time: unknown unit [µ|u] in duration [<integer>µ|<integer>u]
```

## Does InfluxDB have a file system size limit?

InfluxDB 在 Linux 和 Windows POSIX的文件系统大小限制内存运行，某些存储提供程序和发行版本具有大小限制，例如:

- Amazon EBS volume 将大小限制为  ~16TB
- Linux ext3 文件系统限制大小为 ~16TB
- Linux ext4 文件系统大小 ~1EB (文件大小限制为 ~16TB)

如果你希望每个卷/文件系统增长为~16TB。建议找到支持存储需求的提供程序和分发；

## How do I use the InfluxDB CLI to return human readable timestamps?

首次连接CLI，请指定 [rfc3339](https://www.ietf.org/rfc/rfc3339.txt) 精度:

```bash
influx -precision rfc3339
```

或者，在连接到CLI后指定精度:

```bash
$ influx
Connected to http://localhost:8086 version 0.xx.x
InfluxDB shell 0.xx.x
> precision rfc3339
>
```

请查看 [CLI/Shell](/influxdb/v1.8/tools/shell/) 以获取更多有用的CLI选项.

## How can a non-admin user `USE` a database in the InfluxDB CLI?

在v1.3之前的版本中, [非管理员用户](/influxdb/v1.8/administration/authentication_and_authorization/#user-types-and-privileges) `USE <database_name>` 即使该数据库上具有READ和/或者具有WRITE该数据库的权限，也无法在CLI中执行查询

从 1.3版本开始, 非管理员用户可以 `USE <database_name>` 对拥有 `READ` 和/或 `WRITE` 许可的数据库执行查询.如果非管理员用户尝试USE数据库，用户不必READ和/或WRITE权限，系统将返回一个错误

```
ERR: 数据库<database_name> 不存在. 运行 SHOW DATABASES 获取现有数据库的列表.
```

> **注意** `SHOW DATABASES` 查询仅返回非管理员用户具有READ和/或WRITE权限的那些数据库

## How do I write to a non-DEFAULT retention policy with the InfluxDB CLI?

使用语法通过CLI  INSERT INTO [<database>.]<retention_policy> <line_protocol>` 将数据写入非`DEFAULT` 保留策略.
(只有CLI才允许以这种方式指定数据库和保留策略，通过HTTP写入必须指定数据库，以及（可选）使用db和rp查询参数来指定保留策略
)

例如:

```
> INSERT INTO one_day mortality bool=true
Using retention policy one_day
> SELECT * FROM "mydb"."one_day"."mortality"
name: mortality
---------------
time                             bool
2016-09-13T22:29:43.229530864Z   true
```

请注意，将需要完全限定measurement以查询非DEFAULT保留策略中的数据，使用以下语法完全限定measurement；

```
"<database>"."<retention_policy>"."<measurement>"
```

## How do I cancel a long-running query?

可以使用从CLI取消长时间运行的交互查询Ctrl+C,要停止使用[`SHOW QUERIES`](/influxdb/v1.3/query_language/spec/#show-queries) 命令时看到的其他长时间运行的查询，可以使用 [`KILL QUERY命令将其停止.

## Why can't I query Boolean field values?

对于数据写入和数据查询，可接受 Boolean语法不同 

| Boolean syntax |  Writes | Queries  |
-----------------------|-----------|--------------|
|  `t`,`f` |	👍 | ❌ |
|  `T`,`F` |  👍 |  ❌ |
|  `true`,`false` | 👍  | 👍  |
|  `True`,`False` |  👍 |  👍 |
|  `TRUE`,`FALSE` |  👍 |  👍 |

例如,`SELECT * FROM "hamlet" WHERE "bool"=True` 返回 `bool`设置为所有 points `TRUE`, 但此操作 `SELECT * FROM "hamlet" WHERE "bool"=T` 不会返回任何值.

{{% warn %}} [GitHub 第 #3939期](https://github.com/influxdb/influxdb/issues/3939) {{% /warn %}}

## How does InfluxDB handle field type discrepancies across shards?

字段值可以是 floats（浮点数）, integers（整数）, strings（字符串）, 或者 Booleans.
字段值类型不能同时出现不同shard，但因shards而异

### SELECT 语句

如果所有值具有相同类型，则该[`SELECT` 语句](/influxdb/v1.8/query_language/explore-data/#the-basic-select-statement)
**返回所有字段值，如果字段值的类型跨越shards不同，Influxdb首先执行任何适用[cast](influxdb/v1.8/query_language/explore-data/#cast-operations)操作，然后返回与第一发生在以下列表中的类型的所以值：浮点数，整数，字符串，booleans；

如果你的数据存在字段值类型差异，请使用语法
`<field_key>::<type>` 查询不同的数据类型

#### 例

该 measurement `just_my_type`具有一个称为 `my_field`.
`my_field`在四个不同的分片上具有四个字段值，并且每个值具有不同的数据类型 (float, integer, string, and Boolean).

`SELECT *` 仅返回 float 和 integer 字段值.
请注意，Influxdb在响应中将整数值转换为浮点数.

```
SELECT * FROM just_my_type

name: just_my_type
------------------
time		                	my_field
2016-06-03T15:45:00Z	  9.87034
2016-06-03T16:45:00Z	  7
```

`SELECT <field_key>::<type> [...]` 返回所有值类型.InfluxDB 在其自己的列中以传递的列名输出每种值类型.在可能的情况下
Influxdb会将字段值转换为另一种类型，它 `7`在第一列中将整数强制转换为浮点数 `9.879034`在第二列中将其强制转换为整数，Influxdb无法将浮点数转换为字符串或者Booleans.

```
SELECT "my_field"::float,"my_field"::integer,"my_field"::string,"my_field"::boolean FROM just_my_type

name: just_my_type
------------------
time			               my_field	 my_field_1	 my_field_2		 my_field_3
2016-06-03T15:45:00Z	 9.87034	  9
2016-06-03T16:45:00Z	 7	        7
2016-06-03T17:45:00Z			                     a string
2016-06-03T18:45:00Z					                                true
```

### The SHOW FIELD KEYS query

`SHOW FIELD KEYS`  返回与field key关联的每个shard上的每个数据类型。

#### 例

该 measurement `just_my_type`具有一个称为字段 `my_field`.`my_field` 在四个不同的分片上具有四个字段值，并且每个值具有不同的数据类型 (float, integer, string, and Boolean).`SHOW FIELD KEYS` 返回所有四种数据类型

```sql
> SHOW FIELD KEYS

name: just_my_type
fieldKey   fieldType
--------   ---------
my_field   float
my_field   string
my_field   integer
my_field   boolean
```

## What are the minimum and maximum integers that InfluxDB can store?
InfluxDB 将所有整数存储为带符号的int64数据类型，int64的最小和最大的有效值为.`-9023372036854775808` 和 `9023372036854775807`.有关更多信息，请参见[Go builtins](http://golang.org/pkg/builtin/#int64) .

接近但在这些限制内存的值可能会导致意外结果发生，.一些函数和运算过程中会将int64数据类型转换为float64，这可能会导致溢出的问题

## What are the minimum and maximum timestamps that InfluxDB can store?
最小时间戳为 `-9223372036854775806` 或 `1677-09-21T00:12:43.145224194Z`.
最大时间戳为 `9223372036854775806` 或 `2262-04-11T23:47:16.854775806Z`.

超出该范围的时间戳将返回解析错误 [parsing error](/influxdb/v1.8/troubleshooting/errors/#unable-to-parse-time-outside-range).

## How can I tell what type of data is stored in a field?

该 [`SHOW FIELD KEYS`](/influxdb/v1.8/query_language/explore-schema/#show-field-keys) 查询会返回field的类型.

#### Example

```sql
> SHOW FIELD KEYS FROM all_the_types
name: all_the_types
-------------------
fieldKey  fieldType
blue      string
green     boolean
orange    integer
yellow    float
```

## Can I change a field's data type?

当前, InfluxDB 为更改field的数据类型提供了非常有限的支持。

该 `<field_key>::<type>` 语法支持将field value从整数转换为浮点数或从浮点转换为整数，有关示例，请参见 [强制转换操作](/influxdb/v1.8/query_language/explore-data/#data-types-and-cast-operations).
 无法将浮点数或整数强制转换为字符串或者 Boolean (反之亦然).

我们在下面列出了更改field数据类型的可能解决方法，请注意，这些变通方法不会更新已经写入数据库的数据

#### Write the data to a different field

最简单的解决办法是开始将新数据类型写入同一个系列[series](/influxdb/v1.8/concepts/glossary/#series).

#### Work the shard system

字段类型有不同的[shard](/influxdb/v1.8/concepts/glossary/#shard) 但可以在跨不同的shards.

希望更改field数据类型的用户可以使用“SHOW SHARDS”查询 以识别当前shards的`end_time`(结束时间)。如果指针有时间戳，InfluxDB将接受对现有字段的不同数据类型的写入 发生在`end_time` (结束时间)之后。

请注意，这不会更改先前shard上的field数据类型，有关这将会影响您的查询，请参阅
[InfluxDB 如何处理shards上的字段类型](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#how-does-influxdb-handle-field-type-discrepancies-across-shards).

## How do I perform mathematical operations within a function?

当前 InfluxDB 不支持函数内的数学运算.建议使用 InfluxQL's [子查询](/influxdb/v1.8/query_language/explore-data/#subqueries)作为解决办法.

### 例

InfluxQL 不支持以下语法:

```sqk
SELECT MEAN("dogs" - "cats") from "pet_daycare"
```

而是, 使用子查询来获取相同的结果:

```sql
> SELECT MEAN("difference") FROM (SELECT "dogs" - "cat" AS "difference" FROM "pet_daycare")
```

有关更多信息，请参见[数据浏览页面](/influxdb/v1.8/query_language/explore-data/#subqueries).

## Why does my query return epoch 0 as the timestamp?

在 InfluxDB,时期0  (`1970-01-01T00:00:00Z`) 通常用作等效的空时间戳，如果请求没有时间戳的查询返回，例如具有不受限制的时间范围的聚合函数，则Influxdb返回 时期0作为时间戳.

## Which InfluxQL functions support nesting?

以下Influxdb函数支持嵌套：

* [`COUNT()`](/influxdb/v1.8/query_language/functions/#count) 与 [`DISTINCT()`](/influxdb/v1.8/query_language/functions/#distinct)
* [`CUMULATIVE_SUM()`](/influxdb/v1.8/query_language/functions/#cumulative-sum)
* [`DERIVATIVE()`](/influxdb/v1.8/query_language/functions/#derivative)
* [`DIFFERENCE()`](/influxdb/v1.8/query_language/functions/#difference)
* [`ELAPSED()`](/influxdb/v1.8/query_language/functions/#elapsed)
* [`MOVING_AVERAGE()`](/influxdb/v1.8/query_language/functions/#moving-average)
* [`NON_NEGATIVE_DERIVATIVE()`](/influxdb/v1.8/query_language/functions/#non-negative-derivative)
* [`HOLT_WINTERS()`](/influxdb/v1.8/query_language/functions/#holt-winters) and [`HOLT_WINTERS_WITH_FIT()`](/influxdb/v1.8/query_language/functions/#holt-winters)

有关如何使用子查询代替嵌套函数的信息，请参阅：[数据探索](/influxdb/v1.8/query_language/explore-data/#subqueries).

## What determines the time intervals returned by `GROUP BY time()` queries?

 `GROUP BY time()` 查询返回的时间间隔符合Influxdb数据库的预设时间段或用户指定的 [偏移间隔](/influxdb/v1.8/query_language/explore-data/#advanced-group-by-time-syntax).

#### 例

##### Offset interval

以下查询计算 `sunflowers` 在 6:15pm 至 7:45pm之间的平均值，并将这些平均值分为一小时间隔:

```sql
SELECT mean("sunflowers")
FROM "flower_orders"
WHERE time >= '2016-08-29T18:15:00Z' AND time <= '2016-08-29T19:45:00Z' GROUP BY time(1h)
```

以下结果显示了InfluxDB如何维护其预设时间段。

在此示例中，下午6点是预设的时间段，而下午7是预设的时间段。由于有`WHERE`time子句，下午6点时间段的平均值不包含6:15 之前的数据，但是下午6点时间段的平均值中包含的任何数据都必须在下午6点时出现。下午7点的时间段也是如此；下午7点时段的平均值中包含的所有数据都必须在下午7点进行。虚线表示组成每个平均值的points。

请注意，虽然结果中的第一个时间戳是2016-08-29T18:00:00Z，但是该时间段的查询结果不包含带有时间戳的数据，这些数据在`WHERE`time子句（2016-08-29T18:15:00Z）的开始之前出现.

原始数据:

结果:

```sql
name: flower_orders                                name: flower_orders
—————————                                          -------------------
time                    sunflowers                 time                  mean
2016-08-29T18:00:00Z    34                         2016-08-29T18:00:00Z  22.332
                       |--|                        2016-08-29T19:00:00Z  62.75
2016-08-29T18:15:00Z   |28|
2016-08-29T18:30:00Z   |19|
2016-08-29T18:45:00Z   |20|
                       |--|
                       |--|
2016-08-29T19:00:00Z   |56|
2016-08-29T19:15:00Z   |76|
2016-08-29T19:30:00Z   |29|
2016-08-29T19:45:00Z   |90|
                       |--|
2016-08-29T20:00:00Z    70

```

##### Offset interval

以下查询计算`sunflowers` 6:15pm 至 7:45pm 之间的平均值.并将这些平均值分为一个小时间隔，它还将Influxdb数据库的预设时间段偏移了15分钟

```sql
SELECT mean("sunflowers")
FROM "flower_orders"
WHERE time >= '2016-08-29T18:15:00Z' AND time <= '2016-08-29T19:45:00Z' GROUP BY time(1h,15m)
                                                                                         ---
                                                                                          |
                                                                                   offset interval
```

在此示列中，用户指定的[offset interval](/influxdb/v1.8/query_language/explore-data/#advanced-group-by-time-syntax)
将Influxdb数据库的预设时间段向前移动了15分钟，现在，下午6点时间段的平均值包含6:15 pm至7pm之间的数据，而下午7点时间段的平均值包含7:15pm至8pm之间的数据，虚线表示组成每个平均值的Points

请注意，结果中第一个时间戳记 `2016-08-29T18:15:00Z`不是 `2016-08-29T18:00:00Z`.

原始数据:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

结果:

```sql
name: flower_orders                                name: flower_orders
—————————                                          -------------------
time                    sunflowers                 time                  mean
2016-08-29T18:00:00Z    34                         2016-08-29T18:15:00Z  30.75
                       |--|                        2016-08-29T19:15:00Z  65
2016-08-29T18:15:00Z   |28|
2016-08-29T18:30:00Z   |19|
2016-08-29T18:45:00Z   |20|
2016-08-29T19:00:00Z   |56|
                       |--|
                       |--|
2016-08-29T19:15:00Z   |76|
2016-08-29T19:30:00Z   |29|
2016-08-29T19:45:00Z   |90|
2016-08-29T20:00:00Z   |70|
                       |--|
```

## Why do my queries return no data or partial data?

查询不返回任何数据或者不返回部分数据的最常见的原因:

- [查询错误的保留策略](#querying-the-wrong-retention-policy) (未返回任何数据)
- [select子句中没有字段键](#no-field-key-in-the-select-clause) (没有返回数据)
- [SELECT查询包括 `GROUP BY time()`](#select-query-includes-group-by-time) (`now()`返回之前的部分数据)
- [具有相同名称的标签和字段键](#tag-and-field-key-with-the-same-name)

### Querying the wrong retention policy

InfluxDB 自动查询数据库的 `DEFAULT` [retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp) (RP). 如果你的数据存储在另一个RP中，则必须在查询中指定RP以获取结果。

### SELECT子句中没有field key

查询要求select子句中至少有一个[field key](/influxdb/v1.8/concepts/glossary/#field-key) ，如果SELECT子句只包含了tag keys, 则查询返回空响应，有关更多信息，请参阅[数据探索](/influxdb/v1.8/concepts/glossary/#field-key),

### SELECT query includes `GROUP BY time()`

如果您的`SELECT`查询包含一个 [`GROUP BY time()` 子句](/influxdb/v1.8/query_language/explore-data/#group-by-time-intervals), 则仅返回1677-09-21 00:12:43.145224194` 和之间的points now(),请在你的时间间隔指定 [可选上限](/influxdb/v1.8/query_language/explore-data/#time-syntax) 

(默认情况下,大多数 [`SELECT` 查询](/influxdb/v1.8/query_language/explore-data/#the-basic-select-statement) 查询时间戳介于`1677-09-21 00:12:43.145224194` 和 `2262-04-11T23:47:16.854775806Z` UTC之间的数据.)

### Tag and field key with the same name

避免tag和field key 使用相同的名称. 如果你无意为tag 和field keys添加了相同的名称, 然后一起查询两个关键字, 查询结果显示第二个查询的关键字 (标签 or 字段) 附加 `_1` (在 Chronograf中也作为列标题可见). 要查询附加的tag或field keys 附加 `_1`, 必须要删除附加 `_1` **并包含语法 `::tag` 或 `::field`.

#### 例

1. [启动 `influx`](/influxdb/v1.8/tools/shell/#launch-influx).

2. 编写以下几点以创建具有相同名称的field和tag key `leaves`:

    ```bash
    # create the `leaves` tag key
    INSERT grape,leaves=species leaves=6

    #create the `leaves` field key
    INSERT grape leaves=5
    ```

3. 如果同时查看两个key，会注意到两个key都不包含 `_1`:

    ```
    # show the `leaves` tag key
    SHOW TAG KEYS

    name: grape
    tagKey
    ------
    leaves

    # create the `leaves` field key
    SHOW FIELD KEYS

    name: grape
    fieldKey   fieldType
    ------     ---------
    leaves     float
    ```
    
4. 如果查询 `grape` measurement, 你会看到 `leaves` tag keys 后面有一个 `_1`:

    ```bash
    # query the `grape` measurement
    SELECT * FROM <database_name>.<retention_policy>."grape"
    
    name: grape
    time                leaves      leaves_1
    ----                --------    ----------
    1574128162128468000 6.00        species
    1574128238044155000 5.00
    ```

5. 要查询重复的key名称 ， **必须将其放下** `_1` **并在键之后添加** `::tag` 或 `::field` :

    ```bash
    # query duplicate keys using the correct syntax
    SELECT "leaves"::tag, "leaves"::field FROM <database_name>.<retention_policy>."grape"

    name: grape
    time                leaves     leaves_1
    ----                --------   ----------
    1574128162128468000 species    6.00
    1574128238044155000            5.00
    ```

    因此，引用 `leaves_1` 不返回值.

{{％warn％}}警告：如果您无意中添加了重复的key，请按照以下步骤[remove a duplicate key](#remove-a-duplicate-key).。由于内存需求，如果您有大量数据，建议您按指定的时间间隔（例如，日期范围）对数据进行分块（选择时），以适合分配的内存。{{％/ warn％}}

#### 删除重复密钥

1. [启动 `influx`](/influxdb/v1.8/tools/shell/#launch-influx).

2. 使用以下查询删除重复密钥.

    ```sql

    /* select each field key to keep in the original measurement and send to a temporary
       measurement; then, group by the tag keys to keep (leave out the duplicate key) */

    SELECT "field_key","field_key2","field_key3"
    INTO <temporary_measurement> FROM <original_measurement>
    WHERE <date range> GROUP BY "tag_key","tag_key2","tag_key3"

    /* verify the field keys and tags keys were successfully moved to the temporary
    measurement */
    SELECT * FROM "temporary_measurement"

    /* drop original measurement (with the duplicate key) */
    DROP MEASUREMENT "original_measurement"

    /* move data from temporary measurement back to original measurement you just dropped */
    SELECT * INTO "original_measurement" FROM "temporary_measurement" GROUP BY *

    /* verify the field keys and tags keys were successfully moved back to the original
     measurement */
    SELECT * FROM "original_measurement"

    /* drop temporary measurement */
    DROP MEASUREMENT "temporary_measurement"

    ```

## Why don't my GROUP BY time() queries return timestamps that occur after now()?

大多数`SELECT`语句的默认时间范围在[`1677-09-21 00:12:43.145224194和2262-04-11T23:47:16.854775806ZUTC`]之间。对于带有GROUP BY time()子句的select语句，默认时间范围在`1677-09-21 00:12:43.145224194`UTC和UTC[`now()`](/influxdb/v1.8/concepts/glossary/#now)之间

要在时间戳之后发生的查询数据 `now()`, `SELECT`使用语句 `GROUP BY time()` 子句必须加上[`WHERE` clause](/influxdb/v1.8/query_language/explore-data/#the-where-clause)语句

在下面实例中，第一个查询包含时间戳介于`2015-09-18T21:30:00Z` 和 `now()`.
第二个查询包含时间戳在 `2015-09-18T21:30:00Z` 和  `now()`.后的180周之间的数据

```
> SELECT MEAN("boards") FROM "hillvalley" WHERE time >= '2015-09-18T21:30:00Z' GROUP BY time(12m) fill(none)


> SELECT MEAN("boards") FROM "hillvalley" WHERE time >= '2015-09-18T21:30:00Z' AND time <= now() + 180w GROUP BY time(12m) fill(none)
```

请注意：

` WHERE '子句必须提供另一个**上限* *来 覆盖默认的“now()”上限。以下查询只是重置 下限为“now()”,因此查询的时间范围介于 ` now()`和` now()`

```sql
> SELECT MEAN("boards") FROM "hillvalley" WHERE time >= now() GROUP BY time(12m) fill(none)
>
```

有关查询中时间语法，请参见  [数据探索](/influxdb/v1.8/query_language/explore-data/#time-syntax).

## Can I perform mathematical operations against timestamps?

目前，在InfluxDB中无法对时间戳值执行数学运算符。 大多数时间计算必须由接收查询结果的客户端来执行.

针对时间戳值使用InfluxdQL函数的支持有限.函数 [ELAPSED()](/influxdb/v1.8/query_language/functions/#elapsed)返回单个字符中后续时间戳之间的差.

## Can I identify write precision from returned timestamps?

InfluxDB 将所有时间戳存储为纳秒值，而不考虑所提供的写入精度，

需要注意的是，当返回查询结果时，数据库会从时间戳中无声的删除尾随的零这会模糊最初的写入精度

在下面的示例中，`precision_provide`和`timestamp_provided`标记显示了用户在写入时提供的时间精度和时间戳，因为Influxdb在返回的时间戳上无声的丢失尾随零，所以写入精度在返回的时间戳中是不可识别的

```sql
name: trails
-------------
time                  value	 precision_supplied  timestamp_supplied
1970-01-01T01:00:00Z  3      n                   3600000000000
1970-01-01T01:00:00Z  5      h                   1
1970-01-01T02:00:00Z  4      n                   7200000000000
1970-01-01T02:00:00Z  6      h                   2
```

{{% warn %}} [GitHub Issue #2977](https://github.com/influxdb/influxdb/issues/2977) {{% /warn %}}

## When should I single quote and when should I double quote in queries?

单引号字符串值 (例如, tag values) 但不单引号标识符 (database names, retention policy names, user names, measurement names, tag keys, and field keys).

如果双引号以数字开头,包含的字符不是 `[A-z,0-9,_]`, 或者 它们是 [InfluxQL 关键字](https://github.com/influxdata/influxql/blob/master/README.md#keywords).
则双引号标识符，如果标识符不属于这些类别之一，则不需要使用双引号，但是无论如何我们建议使用双引号

例子:

Yes: `SELECT bikes_available FROM bikes WHERE station_id='9'`

Yes: `SELECT "bikes_available" FROM "bikes" WHERE "station_id"='9'`

Yes: `SELECT MIN("avgrq-sz") AS "min_avgrq-sz" FROM telegraf`

Yes: `SELECT * from "cr@zy" where "p^e"='2'`

No: `SELECT 'bikes_available' FROM 'bikes' WHERE 'station_id'="9"`

No: `SELECT * from cr@zy where p^e='2'`

单引号日期时间字符串 (`ERR: invalid
operation: time and *influxql.VarRef are not compatible`) 如果您双引号日期时间字符串，则Influxdb返回错误（）

例子:

Yes: `SELECT "water_level" FROM "h2o_feet" WHERE time > '2015-08-18T23:00:01.232000000Z' AND time < '2015-09-19'`

No: `SELECT "water_level" FROM "h2o_feet" WHERE time > "2015-08-18T23:00:01.232000000Z" AND time < "2015-09-19"`

有关更多查询中时间语法，请参考 [Data Exploration](/influxdb/v1.8/query_language/explore-data/#time-syntax) .

## Why am I missing data after creating a new DEFAULT retention policy?

在DEFAULT`数据库上创建新的 retention policy (RP)时，写入旧的 `DEFAULT` RP 数据将保留在旧RP中.未自定RP的查询会自动查询新的
DEFAULT RP，因此旧数据可能会丢失，要查询久数据，你必须要完全限定查询中的相关数据

Example:

measurement中所有数据都 `fleeting` 属于以下`DEFAULT` RP  `one_hour`:

```sql
> SELECT count(flounders) FROM fleeting
name: fleeting
--------------
time			               count
1970-01-01T00:00:00Z	 8
```

我们 [create](/influxdb/v1.8/query_language/manage-database/#create-retention-policies-with-create-retention-policy) 一个新的 `DEFAULT` RP (`two_hour`)并执行相同的查询:

```sql
> SELECT count(flounders) FROM fleeting
>
```

要查询旧数据, 我们必须要 `DEFAULT`通过完全限制条件来指定 RP  `fleeting`:

```sql
> SELECT count(flounders) FROM fish.one_hour.fleeting
name: fleeting
--------------
time			               count
1970-01-01T00:00:00Z	 8
```

## Why is my query with a `WHERE OR` time clause returning empty results?

目前，InfluxDB不支持在“WHERE”子句中使用“OR”来指定多个时间范围。 如果查询的“WHERE”子句使用“OR”，则InfluxDB返回空响应 有时间间隔

例子

```sql
> SELECT * FROM "absolutismus" WHERE time = '2016-07-31T20:07:00Z' OR time = '2016-07-31T23:07:17Z'
>
```

{{% warn %}} [GitHub 问题 #7530](https://github.com/influxdata/influxdb/issues/7530)
{{% /warn %}}

## Why does `fill(previous)` return empty results?

`fill(previous)` 如果先前的值不在查询的时间范围内，则不会填充时间段的结果.

在下面的例子中, InfluxDB 不填充`2016-07-12T16:50:20Z`-`2016-07-12T16:50:30Z` 从结果时间捅 `2016-07-12T16:50:00Z`-`2016-07-12T16:50:10Z因为查询的时间范围不包含较早的时间捅.

Raw data:

```sql
> SELECT * FROM "cupcakes"
name: cupcakes
--------------
time                   chocolate
2016-07-12T16:50:00Z   3
2016-07-12T16:50:10Z   2
2016-07-12T16:50:40Z   12
2016-07-12T16:50:50Z   11
```

`GROUP BY time()` query:

```sql
> SELECT max("chocolate") FROM "cupcakes" WHERE time >= '2016-07-12T16:50:20Z' AND time <= '2016-07-12T16:51:10Z' GROUP BY time(20s) fill(previous)
name: cupcakes
--------------
time                   max
2016-07-12T16:50:20Z
2016-07-12T16:50:40Z   12
2016-07-12T16:51:00Z   12
```

尽管这是的预期行为 `fill(previous)`, 但GitHub [开放功能请求](https://github.com/influxdata/influxdb/issues/6878) 建议 `fill(previous)` 即使先前值超过查询时间范围也应填充结果.

## Why are my INTO queries missing data?

默认情况下, `INTO`.查询会将初始数据中的所有tag转换为新写入的数据中的field，这可能导致Influxdb覆盖以前由tag区分的 [points](/influxdb/v1.8/concepts/glossary/#point) ，包括GROUP BY * 在所有INFO查询中以在新写入的数据中保留tag

请注意，此操作不适用于 [`TOP()`](/influxdb/v1.8/query_language/functions/#top) 或 [`BOTTOM()`](/influxdb/v1.8/query_language/functions/#bottom) 函数的查询.
有关更多信息，请参考 [`TOP()`](/influxdb/v1.8/query_language/functions/#top-tags-and-the-into-clause) 和 [`BOTTOM()`](/influxdb/v1.8/query_language/functions/#bottom-tags-and-the-into-clause) 子句文档

#### 例子

##### 初始化数据

该 `french_bulldogs` measurement 包含在 `color` tag和 `name`.field

```sql
> SELECT * FROM "french_bulldogs"
name: french_bulldogs
---------------------
time                  color  name
2016-05-25T00:05:00Z  peach  nugget
2016-05-25T00:05:00Z  grey   rumple
2016-05-25T00:10:00Z  black  prince
```

##### `INTO` 查询 `GROUP BY *`

 没有  `GROUP BY *`字句的`INFO`查询会将  `color` tag 转换为新写入数据中的一个filed.
在初始化中， `nugget` points 和  `rumple` points仅通过 `color` tag区分.
一旦 `color`成为 一个field, InfluxDB 会假定 `nugget` point 和 `rumple` 是重复的point 它就会覆盖 `nugget` point；
 `rumple` point.

```sql
> SELECT * INTO "all_dogs" FROM "french_bulldogs"
name: result
------------
time                  written
1970-01-01T00:00:00Z  3

> SELECT * FROM "all_dogs"
name: all_dogs
--------------
time                  color  name
2016-05-25T00:05:00Z  grey   rumple                <---- no more nugget 🐶
2016-05-25T00:10:00Z  black  prince
```

##### `INTO` 用.. 查询 `GROUP BY *`

`INTO` 带有 `GROUP BY *`子句的查询color在新的数据中保留为tag ，在这种情况下，该.`nugget` point 和该  `rumple` point 仍是唯一的point，并且Influxdb不会覆盖任何数据.

```sql
> SELECT "name" INTO "all_dogs" FROM "french_bulldogs" GROUP BY *
name: result
------------
time                  written
1970-01-01T00:00:00Z  3

> SELECT * FROM "all_dogs"
name: all_dogs
--------------
time                  color  name
2016-05-25T00:05:00Z  peach  nugget
2016-05-25T00:05:00Z  grey   rumple
2016-05-25T00:10:00Z  black  prince
```

## How do I query data with an identical tag key and field key?

使用 `::` 语法指定键是 field key 还是 tag key.

#### Examples

##### 样本数据

```sql
> INSERT candied,almonds=true almonds=50,half_almonds=51 1465317610000000000
> INSERT candied,almonds=true almonds=55,half_almonds=56 1465317620000000000

> SELECT * FROM "candied"
name: candied
-------------
time                   almonds  almonds_1  half_almonds
2016-06-07T16:40:10Z   50       true       51
2016-06-07T16:40:20Z   55       true       56
```

##### 指定键是一个字段:

```sql
> SELECT * FROM "candied" WHERE "almonds"::field > 51
name: candied
-------------
time                   almonds  almonds_1  half_almonds
2016-06-07T16:40:20Z   55       true       56
```

##### 指定键是标签:

```sql
> SELECT * FROM "candied" WHERE "almonds"::tag='true'
name: candied
-------------
time                   almonds  almonds_1  half_almonds
2016-06-07T16:40:10Z   50       true       51
2016-06-07T16:40:20Z   55       true       56
```

## How do I query data across measurements?

当前，无法执行交叉测试数学和分组，所有数据都必须要进行一次测量才能一起查询.
InfluxDB 是不能跨越的measurement 关系数据库和映射的数据是：目前并不建议 [架构](/influxdb/v1.8/concepts/glossary/#schema).
有关在Influxdb中实现JOIN的讨论，请参见 GitHub Issue [#3552](https://github.com/influxdata/influxdb/issues/3552) 。

## Does the order of the timestamps matter?

不重要.
我们测试标明，Influxdb完成以下查询所花费的时间之间的差异可以忽略不计

```sql
SELECT ... FROM ... WHERE time > 'timestamp1' AND time < 'timestamp2'
SELECT ... FROM ... WHERE time < 'timestamp2' AND time > 'timestamp1'
```

## How do I SELECT data with a tag that has no value?

使用指定空tag value `''`. 例如:

```sql
> SELECT * FROM "vases" WHERE priceless=''
name: vases
-----------
time                   origin   priceless
2016-07-20T18:42:00Z   8
```

## Why does series cardinality matter?

InfluxDB 维护系统中每个 [series](/influxdb/v1.8/concepts/glossary/#series) 的内存索引，随着唯一系列书的增加. RAM使用率也随之增加. 高 [series cardinality](/influxdb/v1.8/concepts/glossary/#series-cardinality) 可能会导致操作系统内存不足memory (OOM)异常而杀死Influxd进程.请参阅 [显示基本信息](/influxdb/v1.8/query_language/spec/#show-cardinality) 以了解有关序列基数的InfluxSQL命令；

## How can I remove series from the index?

为了减少 series cardinality，必须从索引中删除series.
[`DROP DATABASE`](/influxdb/v1.8/query_language/manage-database/#delete-a-database-with-drop-database),
[`DROP MEASUREMENT`](/influxdb/v1.8/query_language/manage-database/#delete-measurements-with-drop-measurement), 和
[`DROP SERIES`](/influxdb/v1.8/query_language/manage-database/#drop-series-from-the-index-with-drop-series) 都将从索引中删除序列，并降低整个series cardinality.

> 注意： DROP命令通常会占用大量CPU，因为它们经常触发TSM压缩。DROP频繁发出查询可能会严重影响写入和其他查询吞吐量。.

## How do I write integer field values?

i写入整数时，在filed value 的末尾添加尾随。如果不提供i，InfluxDB会将field value视为浮点型

写一个整数: `value=100i`
写一个浮点数: `value=100`

## How does InfluxDB handle duplicate points?

 point 由 measurement 名称, [tag set](/influxdb/v1.8/concepts/glossary/#tag-set), 和 timestamp.
如果提交的新points具有与现有point相同的 measurement, tag set, 和 timestamp 则该字段集将成为files  set 和新files set的并集，其中任何联系都将移至新字段集，这是预期的行为

例如:

老Point: `cpu_load,hostname=server02,az=us_west val_1=24.5,val_2=7 1234567890000000`

新Point: `cpu_load,hostname=server02,az=us_west val_1=5.24 1234567890000000`

提交新Point后，InfluxDB`val_1`将使用新的field keys覆盖并保留该field `val_2`：

```sql
> SELECT * FROM "cpu_load" WHERE time = 1234567890000000
name: cpu_load
--------------
time                      az        hostname   val_1   val_2
1970-01-15T06:56:07.89Z   us_west   server02   5.24    7
```

要存储两个Points:

* 引入一个任意的新tag以强制唯一性.

    老Points: `cpu_load,hostname=server02,az=us_west,uniq=1 val_1=24.5,val_2=7 1234567890000000`

    新Points: `cpu_load,hostname=server02,az=us_west,uniq=2 val_1=5.24 1234567890000000`

    提交新Points之后，Influxdb `val_1`将使用新的tag value覆盖并保留该filed `val_2`:

```sql
> SELECT * FROM "cpu_load" WHERE time = 1234567890000000
name: cpu_load
--------------
time                      az        hostname   uniq   val_1   val_2
1970-01-15T06:56:07.89Z   us_west   server02   1      24.5    7
1970-01-15T06:56:07.89Z   us_west   server02   2      5.24
```

* 要存储两个Points.

    老Points: `cpu_load,hostname=server02,az=us_west val_1=24.5,val_2=7 1234567890000000`

    新Points: `cpu_load,hostname=server02,az=us_west val_1=5.24 1234567890000001`

    将新Points写入 InfluxDB之后:

```sql
> SELECT * FROM "cpu_load" WHERE time >= 1234567890000000 and time <= 1234567890000001
name: cpu_load
--------------
time                             az        hostname   val_1   val_2
1970-01-15T06:56:07.89Z          us_west   server02   24.5    7
1970-01-15T06:56:07.890000001Z   us_west   server02   5.24
```

## What newline character does the InfluxDB API require?

InfluxDB lien protocol 依赖于换行符（\nASCII 0x0A）来指示行的结尾和新行的开始。使用除换行符以外的其他文件或数据\n将导致以下错误：bad timestamp，unable to parse。

请注意，Windows使用回车符和换行符（\r\n）作为换行符

## What words and characters should I avoid when writing data to InfluxDB?

### InfluxQL keywords

如果使用  [InfluxQL 关键字](https://github.com/influxdata/influxql/blob/master/README.md#keywords) 作为标识符，则需要在每个查询中引入双引号，这可能导致 [非直觉的错误](/influxdb/v1.8/troubleshooting/errors/#error-parsing-query-found-expected-identifier-at-line-char).
标识符是连续查询 名称, database names, field keys, measurement names, retention policy names, subscription names, tag keys, 和 user names.

### time

 关键字 `time` 是一种特殊情况.
`time` 可以是一个
[continuous query](/influxdb/v1.8/concepts/glossary/#continuous-query-cq) 名称,
database 名称,
[measurement](/influxdb/v1.8/concepts/glossary/#measurement) 名称,
[retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp) 名称,
[subscription](/influxdb/v1.8/concepts/glossary/#subscription) 名称, and
[user](/influxdb/v1.8/concepts/glossary/#user) 名称.
在这种情况, `time`在查询中不需要双引号.
`time` 不能为 [field key](/influxdb/v1.8/concepts/glossary/#field-key) 或[tag key](/influxdb/v1.8/concepts/glossary/#tag-key);
InfluxDB 拒绝以 `time` 作为filed key或者tag key的写入，并返回错误； 

#### 例子

##### 写 `time` 为 measurement 并 查询

```sql
> INSERT time value=1

> SELECT * FROM time

name: time
time                            value
----                            -----
2017-02-07T18:28:27.349785384Z  1
```

`time` 是 InfluxDB中有效的measurement名称.

#####  `time` 作为field key 写入并尝试查询它

```sql
> INSERT mymeas time=1
ERR: {"error":"partial write: invalid field name: input field \"time\" on measurement \"mymeas\" is invalid dropped=1"}
```

`time` 是InfluxDB中不是有效的字段密钥
系统不写入该point并返回`400`.

##### 写 `time`为标签键并尝试查询它

```sql
> INSERT mymeas,time=1 value=1
ERR: {"error":"partial write: invalid tag key: input tag \"time\" on measurement \"mymeas\" is invalid dropped=1"}
```

`time` 在InfluxDB中不是有效的标记键，系统不写入该点并返回`400`.

### 特性

为了使正则表达式和引号保持简单，请避免在标识符中使用以下字符：

`\` backslash
 `^` circumflex accent
 `$` dollar sign
 `'` single quotation mark
 `"` double quotation mark
 `=` equal sign
 `,` comma

## When should I single quote and when should I double quote when writing data?

* 通过line protocol 写入数据时，避免使用单引号和双引号标识符；请参阅下面的示例，了解如何用引号编写标识符可以使查询复杂化。标识符是数据库名称，保留策略名称，用户名，measurement名称，标签键和字段键。

用双引号括起来写：INSERT "bikes" bikes_available=3
	适用查询：SELECT * FROM "\"bikes\""
	
用单引号括起来写：INSERT 'bikes' bikes_available=3
	适用查询：SELECT * FROM "\'bikes\'"
	
用不带引号的度量值写：INSERT bikes bikes_available=3
	适用的查询：SELECT * FROM "bikes"
	

* 双引号field key是字符串。

	写：INSERT bikes happiness="level 2" 适用查询：SELECT * FROM "bikes" WHERE "happiness"='level 2'
	
* Special characters should be escaped with a backslash and not placed in quotes.

	Write: `INSERT wacky va\"ue=4`
	Applicable query: `SELECT "va\"ue" FROM "wacky"`

有关更多信息 , 请参见 [line protocol](/influxdb/v1.8/write_protocols/).

## Does the precision of the timestamp matter?

Yes.
为了是性能最大化，在将数据写入InfluxDB时，请使用最粗略的时间精度.

在以下两个示列中，第一个请求使用默认精度为纳秒，而第二个示例将精度设置为秒:

```bash
curl -i -XPOST "http://localhost:8086/write?db=weather" --data-binary 'temperature,location=1 value=90 1472666050000000000'

curl -i -XPOST "http://localhost:8086/write?db=weather&precision=s" --data-binary 'temperature,location=1 value=90 1472666050'
```

代价是，随着精度变得更粗糙，更有可能出现时间戳重复的相同points可能会覆盖其他points.

## What are the configuration recommendations and schema guidelines for writing sparse, historical data?

对于想要将稀疏的历史数据写入Influxdb用户，Influxdb建议:

首先，将 [retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)‘的 [shard group](/influxdb/v1.8/concepts/glossary/#shard-group) 持续时间延长到数年，默认shrad持续时间为一周，如果您的数据涵盖数百年.那么这么多
 shard group ,对于Influxdb来说，用于大量的shard 是无效的，加大对您的数据与保留策略的碎片组持续时间 [`ALTER RETENTION POLICY` 查询](/influxdb/v1.8/query_language/manage-database/#modify-retention-policies-with-alter-retention-policy).

第二， 暂时降低[`cache-snapshot-write-cold-duration` 配置设置](/influxdb/v1.8/administration/config/#cache-snapshot-write-cold-duration-10m).
如果你要写入大量历史数据，则默认设置 (`10m`) 会使系统为每个 shard将所有数据保存在缓存中，在写入历史数据时暂时将.
 `cache-snapshot-write-cold-duration设置`降低到 `10s` 可以使过程更有效.