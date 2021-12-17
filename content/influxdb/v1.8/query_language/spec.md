---
title: InfluxQL 参考
description: List of resources for Influx Query Language (InfluxQL).
menu:
  influxdb_1_8:
    name: InfluxQL 参考
    weight: 90
    parent: InfluxQL
---

## 介绍

Influx查询语言（InfluxQL）的定义和详细信息，包括：

* [符号(Notation)](/influxdb/v1.8/query_language/spec/#notation)
* [查询表示(Query representation)](/influxdb/v1.8/query_language/spec/#query-representation)
* [标识符(Identifiers)](/influxdb/v1.8/query_language/spec/#identifiers)
* [关键字(Keywords)](/influxdb/v1.8/query_language/spec/#keywords)
* [文字(Literals)](/influxdb/v1.8/query_language/spec/#literals)
* [查询(Queries)](/influxdb/v1.8/query_language/spec/#queries)
* [语句(Statements)](/influxdb/v1.8/query_language/spec/#statements)
* [子句(Clauses)](/influxdb/v1.8/query_language/spec/#clauses)
* [表达式(Expressions)](/influxdb/v1.8/query_language/spec/#expressions)
* [其它(Other)](/influxdb/v1.8/query_language/spec/#other)
* [查询引擎内部(Query engine internals)](/influxdb/v1.8/query_language/spec/#query-engine-internals)

要了解有关InfluxQL的更多信息，请查看以下主题：

* [探索数据](/influxdb/v1.8/query_language/explore-data/)
* [探索架构](/influxdb/v1.8/query_language/explore-schema/)
* [数据库管理](/influxdb/v1.8/query_language/manage-database/)
* [身份验证与授权](/influxdb/v1.8/administration/authentication_and_authorization/)

InfluxQL是一种类SQL的查询语言，用于与InfluxDB进行交互并提供专门用于存储和分析时序数据的功能。

## 符号

使用Extended Backus-Naur Form (“EBNF”)指定语法。EBNF与[Go](http://golang.org/)语言规范中使用的符号相同，可在[这里](https://golang.org/ref/spec)找到。这不是巧合，因为InfluxDB就是用Go语言编写的。

```
Production  = production_name "=" [ Expression ] "." .
Expression  = Alternative { "|" Alternative } .
Alternative = Term { Term } .
Term        = production_name | token [ "…" token ] | Group | Option | Repetition .
Group       = "(" Expression ")" .
Option      = "[" Expression "]" .
Repetition  = "{" Expression "}" .
```

符号运算符按优先级递增排序：

```
|   alternation
()  grouping
[]  option (0 or 1 times)
{}  repetition (0 to n times)
```

## 查询表示

### 字符

InfluxQL是使用[UTF-8](http://en.wikipedia.org/wiki/UTF-8)编码的Unicode文本。

```
newline             = /* the Unicode code point U+000A */ .
unicode_char        = /* an arbitrary Unicode code point except newline */ .
```

## 字母和数字

字母是ASCII字符和下划线 (U+005F)的集合，下划线*(U+005F)被认为是字母。

InfluxQL只支持十进制数字。

```
letter              = ascii_letter | "_" .
ascii_letter        = "A" … "Z" | "a" … "z" .
digit               = "0" … "9" .
```

## 标识符

标识符指的是[数据库](/influxdb/v1.8/concepts/glossary/#database)名字、[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)名字、[用户](/influxdb/v1.8/concepts/glossary/#user)名、[measurement](/influxdb/v1.8/concepts/glossary/#measurement)的名字、[tag key](/influxdb/v1.8/concepts/glossary/#tag-key)和[field key](/influxdb/v1.8/concepts/glossary/#field-key)。

规则：

- 用双引号括起来的标识符可以包含除换行符(new line)之外的任意unicode字符
- 用双引号括起来的标识符可以包含转义的`"`字符(也就是，`\"`)
- 用双引号括起来的标识符可以包含InfluxQL[关键字](/influxdb/v1.8/query_language/spec/#keywords)
- 不带引号的标识符必须以大写或小写的ASCII字符或者”_”开头
- 不带引号的标识符只能包含ASCII字符、数字和”_”

```
identifier          = unquoted_identifier | quoted_identifier .
unquoted_identifier = ( letter ) { letter | digit } .
quoted_identifier   = `"` unicode_char { unicode_char } `"` .
```

#### 示例：

```
cpu
_cpu_stats
"1h"
"anything really"
"1_Crazy-1337.identifier>NAME👍"
```

## 关键字

```
ALL           ALTER         ANY           AS            ASC           BEGIN
BY            CREATE        CONTINUOUS    DATABASE      DATABASES     DEFAULT
DELETE        DESC          DESTINATIONS  DIAGNOSTICS   DISTINCT      DROP
DURATION      END           EVERY         EXPLAIN       FIELD         FOR
FROM          GRANT         GRANTS        GROUP         GROUPS        IN
INF           INSERT        INTO          KEY           KEYS          KILL
LIMIT         SHOW          MEASUREMENT   MEASUREMENTS  NAME          OFFSET
ON            ORDER         PASSWORD      POLICY        POLICIES      PRIVILEGES
QUERIES       QUERY         READ          REPLICATION   RESAMPLE      RETENTION
REVOKE        SELECT        SERIES        SET           SHARD         SHARDS
SLIMIT        SOFFSET       STATS         SUBSCRIPTION  SUBSCRIPTIONS TAG
TO            USER          USERS         VALUES        WHERE         WITH
WRITE
```

如果您使用InfluxQL关键字作为[标识符](/influxdb/v1.8/concepts/glossary/#identifier)，您需要将每个查询中的标识符用双引号括起来。

关键字`time`是一个特例。`time`可以是一个[连续查询](/influxdb/v1.8/concepts/glossary/#continuous-query-cq)名字、数据库名字、[measurement](/influxdb/v1.8/concepts/glossary/#measurement)的名字、[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)名字、[subscription](/influxdb/v1.8/concepts/glossary/#subscription)的名字和[用户](/influxdb/v1.8/concepts/glossary/#user)名。在这些情况下，不需要在查询中用双引号将`time`括起来。`time`不能是field key或tag key；InfluxDB拒绝写入将`time`作为[field key](/influxdb/v1.8/concepts/glossary/#field-key)或[tag key](/influxdb/v1.8/concepts/glossary/#tag-key)的数据，对于这种数据写入，InfluxDB会返回错误。请查阅[FAQ](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#time)获得更多相关信息。

## 文字

### 整数

InfluxQL支持十进制的整数。目前不支持十六进制和八进制。

```
int_lit             = ( "1" … "9" ) { digit } .
```

### 浮点数

InfluxQL支持浮点数。目前不支持指数。

```
float_lit           = int_lit "." int_lit .
```

### 字符串

字符串必须用单引号括起来。字符串可以包含转义的`'`字符(也就是`\'`)。

```
string_lit          = `'` { unicode_char } `'` .
```

### 持续时间

持续时间(duration)指定了一段时间的长度。整数后面紧跟着(没有空格)以下列出的一个时间单位表示duration literal。可使用混合单位指定持续时间。

#### 持续时间单位

| 单位   | 含义                |
| ------ | ------------------- |
| ns     | 纳秒 (十亿分之一秒) |
| u or µ | 微秒 (百万分之一秒) |
| ms     | 毫秒 (千分之一秒)   |
| s      | 秒                  |
| m      | 分                  |
| h      | 小时                |
| d      | 天                  |
| w      | 周                  |


```
duration_lit        = int_lit duration_unit .
duration_unit       = "ns" | "u" | "µ" | "ms" | "s" | "m" | "h" | "d" | "w" .
```

### 日期和时间

与本文档的其它部分一样，日期和时间的格式没有指定为EBNF，而是使用Go的日期/时间解析格式来指定，这是以InfluxQL所需格式编写的参考日期。参考日期时间是：

InfluxQL参考日期时间：2006年1月2日下午3:04:05

```
time_lit            = "2006-01-02 15:04:05.999999" | "2006-01-02" .
```

### 布尔值

```
bool_lit            = TRUE | FALSE .
```

### 正则表达式

```
regex_lit           = "/" { unicode_char } "/" .
```

**比较：**

| 操作符 | 含义   |
| ------ | ------ |
| `=~`   | 匹配   |
| `!~`   | 不匹配 |

> **注意：**InfluxQL支持使用正则表达式，当指定以下内容可以使用：
* [`SELECT`子句](/influxdb/v1.8/query_language/explore-data/#the-basic-select-statement)中的[field keys](/influxdb/v1.8/concepts/glossary/#field-key)和[tag keys](/influxdb/v1.8/concepts/glossary/#tag-key) 
* [`FROM`子句](/influxdb/v1.8/query_language/explore-data/#the-basic-select-statement)中的[measurements](/influxdb/v1.8/concepts/glossary/#measurement)
* [`WHERE`子句](/influxdb/v1.8/query_language/explore-data/#the-where-clause)中的[tag values](/influxdb/v1.8/concepts/glossary/#tag-value)和字符串[field values](/influxdb/v1.8/concepts/glossary/#field-value)
* [`GROUP BY`子句](/influxdb/v1.8/query_language/explore-data/#group-by-tags)中的[tag keys](/influxdb/v1.8/concepts/glossary/#tag-key)
>目前，InfluxQL不支持使用正则表达式匹配WHERE子句、[数据库](/influxdb/v1.8/concepts/glossary/#database)和[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)中的非字符串类型的field value。

## 查询

查询由一个或多个以分号分隔的语句组成。

```
query               = statement { ";" statement } .

statement           = alter_retention_policy_stmt |
                      create_continuous_query_stmt |
                      create_database_stmt |
                      create_retention_policy_stmt |
                      create_subscription_stmt |
                      create_user_stmt |
                      delete_stmt |
                      drop_continuous_query_stmt |
                      drop_database_stmt |
                      drop_measurement_stmt |
                      drop_retention_policy_stmt |
                      drop_series_stmt |
                      drop_shard_stmt |
                      drop_subscription_stmt |
                      drop_user_stmt |
                      explain_stmt |
                      explain_analyze_stmt |
                      grant_stmt |
                      kill_query_statement |
                      revoke_stmt |
                      select_stmt |
                      show_continuous_queries_stmt |
                      show_databases_stmt |
                      show_diagnostics_stmt |
                      show_field_key_cardinality_stmt |
                      show_field_keys_stmt |
                      show_grants_stmt |
                      show_measurement_cardinality_stmt |
                      show_measurement_exact_cardinality_stmt |
                      show_measurements_stmt |
                      show_queries_stmt |
                      show_retention_policies_stmt |
                      show_series_cardinality_stmt |
                      show_series_exact_cardinality_stmt |
                      show_series_stmt |
                      show_shard_groups_stmt |
                      show_shards_stmt |
                      show_stats_stmt |
                      show_subscriptions_stmt |
                      show_tag_key_cardinality_stmt |
                      show_tag_key_exact_cardinality_stmt |
                      show_tag_keys_stmt |
                      show_tag_values_stmt |
                      show_tag_values_cardinality_stmt |
                      show_users_stmt .
```

## 语句

### 修改保留策略

```
alter_retention_policy_stmt  = "ALTER RETENTION POLICY" policy_name on_clause
                               retention_policy_option
                               [ retention_policy_option ]
                               [ retention_policy_option ]
                               [ retention_policy_option ] .
```

#### 示例

```sql
-- 将mydb的默认保留策略设置为1h.cpu。
ALTER RETENTION POLICY "1h.cpu" ON "mydb" DEFAULT

-- 更改持续时间和复制因子。
-- REPLICATION (复制因子)对OSS实例无效。
ALTER RETENTION POLICY "policy1" ON "somedb" DURATION 1h REPLICATION 4
```

### 创建连续查询

```
create_continuous_query_stmt = "CREATE CONTINUOUS QUERY" query_name on_clause
                               [ "RESAMPLE" resample_opts ]
                               "BEGIN" select_stmt "END" .

query_name                   = identifier .

resample_opts                = (every_stmt for_stmt | every_stmt | for_stmt) .
every_stmt                   = "EVERY" duration_lit
for_stmt                     = "FOR" duration_lit
```

#### 示例

```sql
-- 从保留策略DEFAULT中选择并写入保留策略"6_months"。
CREATE CONTINUOUS QUERY "10m_event_count"
ON "db_name"
BEGIN
  SELECT count("value")
  INTO "6_months"."events"
  FROM "events"
  GROUP (10m)
END;

-- 从一个保留策略中一个连续查询的输出中选择，并在另一个保留策略中输出到另一个系列
CREATE CONTINUOUS QUERY "1h_event_count"
ON "db_name"
BEGIN
  SELECT sum("count") as "count"
  INTO "2_years"."events"
  FROM "6_months"."events"
  GROUP BY time(1h)
END;

-- 这样可以自定义重采样间隔，以便每10秒查询一次间隔，并在开始时间后2m间隔重新采样
-- 使用重采样时，必须至少使用“EVERY”或“ FOR”之一
CREATE CONTINUOUS QUERY "cpu_mean"
ON "db_name"
RESAMPLE EVERY 10s FOR 2m
BEGIN
  SELECT mean("value")
  INTO "cpu_mean"
  FROM "cpu"
  GROUP BY time(1m)
END;
```

### 创建数据库

```
create_database_stmt = "CREATE DATABASE" db_name
                       [ WITH
                           [ retention_policy_duration ]
                           [ retention_policy_replication ]
                           [ retention_policy_shard_group_duration ]
                           [ retention_policy_name ]
                       ] .
```

{{% warn %}} 复制因子不适用于单节点实例。
{{% /warn %}}

#### 示例

```sql
-- 创建一个名为foo的数据库
CREATE DATABASE "foo"

-- 使用新的保留策略DEFAULT创建一个名为bar的数据库，并指定持续时间，复制因子，分片组持续时间以及该保留策略的名称
CREATE DATABASE "bar" WITH DURATION 1d REPLICATION 1 SHARD DURATION 30m NAME "myrp"

-- 使用新的保留策略DEFAULT创建名为mydb的数据库，并指定该保留策略的名称
CREATE DATABASE "mydb" WITH NAME "myrp"
```

### 创建保留策略

```
create_retention_policy_stmt = "CREATE RETENTION POLICY" policy_name on_clause
                               retention_policy_duration
                               retention_policy_replication
                               [ retention_policy_shard_group_duration ]
                               [ "DEFAULT" ] .
```

{{% warn %}} 复制因子不适用于单节点实例。
{{% /warn %}}

#### 示例

```sql
-- 创建保留策略
CREATE RETENTION POLICY "10m.events" ON "somedb" DURATION 60m REPLICATION 2

-- 创建一个保留策略并将其设置为DEFAULT。
CREATE RETENTION POLICY "10m.events" ON "somedb" DURATION 60m REPLICATION 2 DEFAULT

-- 创建保留策略并指定分片组的持续时间。
CREATE RETENTION POLICY "10m.events" ON "somedb" DURATION 60m REPLICATION 2 SHARD DURATION 30m
```

### 创建订阅

订阅告诉InfluxDB将接收的所有数据发送到[Kapacitor](/{{< latest "kapacitor" >}}/introduction/)。

```
create_subscription_stmt = "CREATE SUBSCRIPTION" subscription_name "ON" db_name "." retention_policy "DESTINATIONS" ("ANY"|"ALL") host { "," host} .
```

#### 示例

```sql
-- 在数据库“mydb”的保留策略“autogen”上创建一个SUBSCRIPTION，数据通过UDP发送到“example.com:9090”。
CREATE SUBSCRIPTION "sub0" ON "mydb"."autogen" DESTINATIONS ALL 'udp://example.com:9090'

-- 在数据库“mydb”的保留策略“autogen”上创建一个SUBSCRIPTION，将数据循环发送到“h1.example.com:9090”和“h2.example.com:9090”。
CREATE SUBSCRIPTION "sub0" ON "mydb"."autogen" DESTINATIONS ANY 'udp://h1.example.com:9090', 'udp://h2.example.com:9090'
```

### 创建用户

```
create_user_stmt = "CREATE USER" user_name "WITH PASSWORD" password
                   [ "WITH ALL PRIVILEGES" ] .
```

#### 示例

```sql
-- 创建普通数据库用户
CREATE USER "jdoe" WITH PASSWORD '1337password'

-- 创建管理员用户
-- 注意: 与GRANT语句不同，此处需要“PRIVILEGES”关键字。
CREATE USER "jdoe" WITH PASSWORD '1337password' WITH ALL PRIVILEGES
```

> **注意：** 密码必须用单引号引起来。

### DELETE

```
delete_stmt = "DELETE" ( from_clause | where_clause | from_clause where_clause ) .
```

#### 示例

```sql
DELETE FROM "cpu"
DELETE FROM "cpu" WHERE time < '2000-01-01T00:00:00Z'
DELETE WHERE time < '2000-01-01T00:00:00Z'
```

### 删除连续查询

```
drop_continuous_query_stmt = "DROP CONTINUOUS QUERY" query_name on_clause .
```

#### 示例

```sql
DROP CONTINUOUS QUERY "myquery" ON "mydb"
```

### 删除数据库

```
drop_database_stmt = "DROP DATABASE" db_name .
```

#### 示例

```sql
DROP DATABASE "mydb"
```

### 删除measurement

```
drop_measurement_stmt = "DROP MEASUREMENT" measurement .
```

#### 示例

```sql
-- 删除名称为"cpu"的measurement
DROP MEASUREMENT "cpu"
```

### 删除保留策略

```
drop_retention_policy_stmt = "DROP RETENTION POLICY" policy_name on_clause .
```

#### 示例

```sql
-- 从mydb删除名为1h.cpu的保留策略
DROP RETENTION POLICY "1h.cpu" ON "mydb"
```

### 删除series

```
drop_series_stmt = "DROP SERIES" ( from_clause | where_clause | from_clause where_clause ) .
```

> **注意：** WHERE子句中不支持按时间过滤。

#### 示例

```sql
DROP SERIES FROM "telegraf"."autogen"."cpu" WHERE cpu = 'cpu8'

```

### 删除shards

```
drop_shard_stmt = "DROP SHARD" ( shard_id ) .
```

#### 示例

```sql
DROP SHARD 1
```

### 删除订阅

```
drop_subscription_stmt = "DROP SUBSCRIPTION" subscription_name "ON" db_name "." retention_policy .
```

#### 示例

```sql
DROP SUBSCRIPTION "sub0" ON "mydb"."autogen"
```

### 删除用户

```
drop_user_stmt = "DROP USER" user_name .
```

#### 示例

```sql
DROP USER "jdoe"
```

### 说明

解析并计划查询，然后打印查询预计开销的摘要。

很多SQL引擎使用EXPLAIN语句来显示join顺序、join算法以及谓词和表达式下推(predicate and expression pushdown)。由于InfluxQL不支持join，一个InfluxQL查询的开销通常是一个关于访问的总时间series、访问TSM文件的迭代器数量和需要扫描的TSM block的数量的函数。

`EXPLAIN`查询计划的内容包括：

- 表达式 (expression)
- 辅助field (auxillary fields)
- shard的数量 (number of shards)
- series的数量 (number of series)
- 缓存的值 (cached values)
- 文件的数量 (number of files)
- block的数量 (number of blocks)
- block的大小 (size of blocks)

```
explain_stmt = "EXPLAIN" select_stmt .
```

#### 示例：

```sql
> explain select sum(pointReq) from "_internal"."monitor"."write" group by hostname;
> QUERY PLAN
------
EXPRESSION: sum(pointReq::integer)
NUMBER OF SHARDS: 2
NUMBER OF SERIES: 2
CACHED VALUES: 110
NUMBER OF FILES: 1
NUMBER OF BLOCKS: 1
SIZE OF BLOCKS: 931
```

### 解释分析

执行指定的SELECT语句，并在运行时返回有关查询性能和存储的数据，以树形显示。 使用此语句分析查询性能和存储，包括[execution_time（执行时间）](#execution_time)和[planning_time（计划时间）](#planning-time)以及[iterator_type（迭代器类型）](#iterator-type)和[cursor-type（游标类型）](#cursor-type)。

例如，执行以下语句：

```sql
> explain analyze select mean(usage_steal) from cpu where time >= '2018-02-22T00:00:00Z' and time < '2018-02-22T12:00:00Z'
```

可能会产生类似以下内容的输出：

```sql
EXPLAIN ANALYZE
---------------
.
└── select
    ├── execution_time: 2.25823ms
    ├── planning_time: 18.381616ms
    ├── total_time: 20.639846ms
    └── field_iterators
        ├── labels
        │   └── statement: SELECT mean(usage_steal::float) FROM telegraf."default".cpu
        └── expression
            ├── labels
            │   └── expr: mean(usage_steal::float)
            └── create_iterator
                ├── labels
                │   ├── measurement: cpu
                │   └── shard_id: 608
                ├── cursors_ref: 779
                ├── cursors_aux: 0
                ├── cursors_cond: 0
                ├── float_blocks_decoded: 431
                ├── float_blocks_size_bytes: 1003552
                ├── integer_blocks_decoded: 0
                ├── integer_blocks_size_bytes: 0
                ├── unsigned_blocks_decoded: 0
                ├── unsigned_blocks_size_bytes: 0
                ├── string_blocks_decoded: 0
                ├── string_blocks_size_bytes: 0
                ├── boolean_blocks_decoded: 0
                ├── boolean_blocks_size_bytes: 0
                └── planning_time: 14.805277ms```
```

> 注意：EXPLAIN ANALYZE忽略查询输出，因此不考虑series化为JSON或CSV的成本。

#### 执行时间

显示查询执行所花费的时间，包括读取时间series数据，在数据经过迭代器时执行操作以及从迭代器中排出已处理的数据。 执行时间不包括将输出series化为JSON或其他格式所花费的时间。

#### 计划时间

显示查询计划所需的时间。

在InfluxDB中计划查询需要很多步骤。 取决于查询的复杂性，与执行查询相比，计划可能需要更多的工作以及消耗更多的CPU和内存资源。 例如，执行查询所需的系列key的数量会影响计划查询的速度和所需的内存。

首先，InfluxDB确定查询的有效时间范围并选择要访问的分片（在InfluxDB Enterprise中，分片可能位于远程节点上）。

接下来，对于每个分片和每个measurement，InfluxDB执行以下步骤：

1. 从索引中选择匹配的系列key，并通过WHERE子句中的tag进行过滤。
2. 根据GROUP BY维度将过滤后的系列key分组为tag set。
3. 枚举每个tag set，并为每个系列key创建一个游标和迭代器。
4. 合并迭代器，并将合并的结果返回给查询执行器。

#### iterator type

EXPLAIN ANALYZE支持以下迭代器类型：

- `create_iterator` 表示由本地influxd实例完成的工作──嵌套迭代器的复杂组成通过合并生成最终查询结果。
- `remote_iterator`（仅InfluxDB企业） 表示在远程计算机上完成的工作，有关更多迭代器的信息，请参阅[了解迭代器](#understanding-iterators)。

#### cursor type

EXPLAIN ANALYZE区分3种cursor type。 尽管cursor type具有相同的数据结构，并且具有相同的CPU和I/O成本，但每种游标类型都是出于不同的原因构造的，并在最终输出中分开。 调整语句时，请考虑以下游标类型：

- cursor_ref：包含函数（如：last()或mean()）的SELECT映射的引用游标。
- cursor_aux：为简单表达式（不是选择器或聚合）创建的辅助游标。 例如，“`SELECT foo FROM m`或`SELECT foo + bar FROM m`，其中“`foo`和` bar`是字段。
- cursor_cond： 为WHERE子句中引用的字段创建的条件游标。

有关游标的更多信息，请参阅[理解游标](#understanding-cursors)。

#### block types

EXPLAIN ANALYZE分离存储block类型，并在磁盘上报告已解码block的总数及其大小（以字节为单位）, 支持以下block类型：

| `float`    | 64bit，IEEE-754浮点数 |
| :----------: | :---------------------: |
| `integer`  | 64bit，有符号整型     |
| `unsigned` | 64bit，无符号整型     |
| `boolean`  | 1bit，LSB编码         |
| `string`   | UTF-8字符串           |

有关block存储的更多信息，请参阅[TSM文件](/influxdb/v1.8/concepts/storage_engine/#tsm-files)。

### GRANT

> **注意：**可以为用户授予的数据库特权。

```
grant_stmt = "GRANT" privilege [ on_clause ] to_clause .
```

#### 示例

```sql
-- grant admin privileges
GRANT ALL TO "jdoe"

-- grant read access to a database
GRANT READ ON "mydb" TO "jdoe"
```

### KILL QUERY

中断当前正在运行的查询。

```
kill_query_statement = "KILL QUERY" query_id .
```

其中，query_id是查询ID，在[`SHOW QUERIES`](/influxdb/v1.8/troubleshooting/query_management/#list-currently-running-queries-with-show-queries)输出中显示为`qid`。

终止集群上的查询，需要指定查询ID（`qid`）和TCP主机（例如，`myhost：8088`），可在`SHOW QUERIES`输出中找到。

```
KILL QUERY <qid> ON "<host>"
```

#### 示例

```sql
-- 在本地主机上终止qid为36的查询
KILL QUERY 36
```

```sql
-- 在InfluxDB企业集群上终止查询
KILL QUERY 53 ON "myhost:8088"
```

### REVOKE

```sql
revoke_stmt = "REVOKE" privilege [ on_clause ] "FROM" user_name .
```

#### Examples

```sql
-- 撤销jdoe的管理员权限
REVOKE ALL PRIVILEGES FROM "jdoe"

-- 撤消mydb上jdoe的读取权限
REVOKE READ ON "mydb" FROM "jdoe"
```

### SELECT

```
select_stmt = "SELECT" fields from_clause [ into_clause ] [ where_clause ]
              [ group_by_clause ] [ order_by_clause ] [ limit_clause ]
              [ offset_clause ] [ slimit_clause ] [ soffset_clause ] [ timezone_clause ] .
```

#### 示例

从所有以”cpu”开头的measurement中选择数据，并将数据写入相同的measurement和保留策略为”cpu_1h”中。

```sql
SELECT mean("value") INTO "cpu_1h".:MEASUREMENT FROM /cpu.*/
```

查询measurement中的数据，并将结果按天进行分组(带有时区)。

```sql
SELECT mean("value") FROM "cpu" GROUP BY region, time(1d) fill(0) tz('America/Chicago')
```

### SHOW CARDINALITY

指用于估计或精确计算measurement、series、tag key、tag value和field key的基数的一组命令。

SHOW CARDINALITY命令有两种可用的版本：估计和精确。估计值使用草图进行计算，对于所有基数大小来说，这是一个安全默认值。精确值是直接对TSM(Time-Structured Merge Tree)数据进行计数，但是，对于基数大的数据来说，运行成本很高。除非必须要使用，否则，请使用估计的方法。

当数据库启用Time Series Index (TSI)时，才支持对`time`进行过滤。

请查看特定的SHOW CARDINALITY命令获得更多信息：

- [SHOW FIELD KEY CARDINALITY](#show-field-key-cardinality)
- [SHOW MEASUREMENT CARDINALITY](#show-measurement-cardinality)
- [SHOW SERIES CARDINALITY](#show-series-cardinality)
- [SHOW TAG KEY CARDINALITY](#show-tag-key-cardinality)
- [SHOW TAG VALUES CARDINALITY](#show-tag-values-cardinality)

### SHOW CONTINUOUS QUERIES

```
show_continuous_queries_stmt = "SHOW CONTINUOUS QUERIES" .
```

#### 示例

```sql
-- 显示所有连续查询
SHOW CONTINUOUS QUERIES
```

### SHOW DATABASES

```
show_databases_stmt = "SHOW DATABASES" .
```

#### 示例

```sql
-- 显示所有数据库
SHOW DATABASES
```

### SHOW DIAGNOSTICS

显示节点信息，例如构建信息、运行时间、主机名、服务器配置、内存使用情况和Go运行时诊断。

有关使用`SHOW DIAGNOSTICS`命令的更多信息，请参阅[使用SHOW DIAGNOSTICS命令监控InfluxDB](/platform/monitoring/influxdata-platform/tools/show-diagnostics/).

```sql
show_diagnostics_stmt = "SHOW DIAGNOSTICS"
```

### SHOW FIELD KEY CARDINALITY

除非使用`ON <database>`指定数据库，否则估计或精确计算当前数据库的field key集的基数。

> **注意：**`ON <database>`、`FROM <sources>`、`WITH KEY = <key>`、`WHERE <condition>`、`GROUP BY <dimensions>`和`LIMIT/OFFSET`子句是可选的。当使用这些查询子句时，查询将回退到精确计数(exect count)。当启用Time Series Index (TSI)时，才支持对`time`进行过滤。不支持在WHERE子句中使用`time`。

```sql
show_field_key_cardinality_stmt = "SHOW FIELD KEY CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ]

show_field_key_exact_cardinality_stmt = "SHOW FIELD KEY EXACT CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ]
```

#### 示例

```sql
-- 显示当前数据库的field set的估计基数
SHOW FIELD KEY CARDINALITY
-- 在指定数据库的field set上显示确切的基数
SHOW FIELD KEY EXACT CARDINALITY ON mydb
```

### SHOW FIELD KEYS

```
show_field_keys_stmt = "SHOW FIELD KEYS" [on_clause] [ from_clause ] .
```

#### 示例

```sql
-- 显示所有measurement的field key和field value的数据类型
SHOW FIELD KEYS

-- 显示指定measurement field key和field value的数据类型
SHOW FIELD KEYS FROM "cpu"
```

### SHOW GRANTS

```
show_grants_stmt = "SHOW GRANTS FOR" user_name .
```

#### 示例

```sql
-- 显示授予jdoe的权限
SHOW GRANTS FOR "jdoe"
```

#### SHOW MEASUREMENT CARDINALITY

除非使用`ON <database>`指定数据库，否则估计或精确计算当前数据库的measurement集的基数。

> **注意：**`ON <database>`、`FROM <sources>`、`WITH KEY = <key>`、`WHERE <condition>`、`GROUP BY <dimensions>`和`LIMIT/OFFSET`子句是可选的。当使用这些查询子句时，查询将回退到精确计数(exect count)。当启用Time Series Index (TSI)时，才支持对`time`进行过滤。不支持在`WHERE`子句中使用`time`。

```sql
show_measurement_cardinality_stmt = "SHOW MEASUREMENT CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ]

show_measurement_exact_cardinality_stmt = "SHOW MEASUREMENT EXACT CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ]
```

#### 示例

```sql
-- 显示当前数据库上measurement的估计基数
SHOW MEASUREMENT CARDINALITY
-- 显示指定数据库上measurement的精确基数
SHOW MEASUREMENT EXACT CARDINALITY ON mydb
```

### SHOW MEASUREMENTS

```
show_measurements_stmt = "SHOW MEASUREMENTS" [on_clause] [ with_measurement_clause ] [ where_clause ] [ limit_clause ] [ offset_clause ] .
```

#### 示例

```sql
-- 显示所有measurement
SHOW MEASUREMENTS

-- 显示region tag = 'uswest' 并且 host tag = 'serverA'的measurement
SHOW MEASUREMENTS WHERE "region" = 'uswest' AND "host" = 'serverA'

-- 显示以'h2o'开头的measurement
SHOW MEASUREMENTS WITH MEASUREMENT =~ /h2o.*/
```

### SHOW QUERIES

```
show_queries_stmt = "SHOW QUERIES" .
```

#### 示例

```sql
-- 显示所有当前正在运行的查询
SHOW QUERIES
--
```

### SHOW RETENTION POLICIES

```
show_retention_policies_stmt = "SHOW RETENTION POLICIES" [on_clause] .
```

#### 示例

```sql
-- 显示数据库中的所有保留策略
SHOW RETENTION POLICIES ON "mydb"
```

### SHOW SERIES

```
show_series_stmt = "SHOW SERIES" [on_clause] [ from_clause ] [ where_clause ] [ limit_clause ] [ offset_clause ] .
```

#### 示例

```sql
SHOW SERIES FROM "telegraf"."autogen"."cpu" WHERE cpu = 'cpu8'
```

### SHOW SERIES CARDINALITY

Estimates or counts exactly the cardinality of the series for the current database unless a database is specified using the `ON <database>` option.

除非使用`ON <database>`指定数据库，否则估计或精确计算当前数据库的series的基数，[series-cardinality](/influxdb/v1.8/concepts/glossary/#series-cardinality)是影响内存(RAM)使用量的主要因素。更多信息请参阅：

- 在[硬件大小调整准则](/influxdb/v1.8/guides/hardware_sizing/)中[什么时候需要更多内存?](/influxdb/v1.8/guides/hardware_sizing/#when-do-i-need-more-ram) 
- [不需要很多系列](/influxdb/v1.8/concepts/schema_and_data_layout/#avoid-too-many-series)

> **注意：**`ON <database>`、`FROM <sources>`、`WITH KEY = <key>`、`WHERE <condition>`、`GROUP BY <dimensions>`和`LIMIT/OFFSET`子句是可选的。当使用这些查询子句时，查询将回退到精确计数(exect count)。当启用Time Series Index (TSI)时，才支持对`time`进行过滤。不支持在`WHERE`子句中使用`time`。

```
show_series_cardinality_stmt = "SHOW SERIES CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ]

show_series_exact_cardinality_stmt = "SHOW SERIES EXACT CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ]
```

#### 示例

```sql
-- 在当前数据库上显示系列的估计基数
SHOW SERIES CARDINALITY
-- 显示指定数据库上系列的估计基数
SHOW SERIES CARDINALITY ON mydb
-- 显示精确的系列基数
SHOW SERIES EXACT CARDINALITY
-- 在指定的数据库上显示系列的基数
SHOW SERIES EXACT CARDINALITY ON mydb
```

### SHOW SHARD GROUPS

```
show_shard_groups_stmt = "SHOW SHARD GROUPS" .
```

#### 示例

```sql
SHOW SHARD GROUPS
```

### SHOW SHARDS

```
show_shards_stmt = "SHOW SHARDS" .
```

#### 示例

```sql
SHOW SHARDS
```

### SHOW STATS

返回一个InfluxDB节点和可用(以启用)的组件的可用组件的详细统计信息。

有关`SHOW STATS`的更多信息，请参阅[使用SHOW STATS命令监控InfluxDB](/platform/monitoring/tools/show-stats/)。

```
show_stats_stmt = "SHOW STATS [ FOR '<component>' | 'indexes' ]"
```

#### `SHOW STATS`

* `SHOW STATS`命令不会列出关于索引的内存使用量—请使用[`SHOW STATS FOR 'indexes'`](#show-stats-for-indexes)命令。
* `SHOW STATS`返回的统计信息存储在内存中，并且在节点重启时重新设置为0，但是，每10秒会触发一次`SHOW STATS`来填充数据库`_internal`。

#### `SHOW STATS FOR <component>`

* 该命令返回指定组件的统计信息。
* 对于`runtime`组件，该命令使用[Go runtime](https://golang.org/pkg/runtime/?spm=a2c4g.11186623.2.78.250e1118df6rLy)返回InfluxDB系统的内存使用量概要。

#### `SHOW STATS FOR 'indexes'`

* 该命令返回所有索引的内存使用量，这是一个估计值。`SHOW STATS`不会列出索引的内存使用量，因为这可能是一个很耗资源的操作。

#### 示例

```sql
> show stats
name: runtime
-------------
Alloc   Frees   HeapAlloc       HeapIdle        HeapInUse       HeapObjects     HeapReleased    HeapSys         Lookups Mallocs NumGC   NumGoroutine    PauseTotalNs    Sys             TotalAlloc
4136056 6684537 4136056         34586624        5816320         49412           0               40402944        110     6733949 83      44              36083006        46692600        439945704


name: graphite
tags: proto=tcp
batches_tx      bytes_rx        connections_active      connections_handled     points_rx       points_tx
----------      --------        ------------------      -------------------     ---------       ---------
159             3999750         0                       1                       158110          158110
```

### SHOW SUBSCRIPTIONS

```
show_subscriptions_stmt = "SHOW SUBSCRIPTIONS" .
```

#### 示例

```sql
SHOW SUBSCRIPTIONS
```

#### 查看TAG KEY 基数

除非使用`ON <database>`指定数据库，否则估计或精确计算当前数据库的tag key set的基数。

> **注意：**`ON <database>`、`FROM <sources>`、`WITH KEY = <key>`、`WHERE <condition>`、`GROUP BY <dimensions>`和`LIMIT/OFFSET`子句是可选的。当使用这些查询子句时，查询将回退到精确计数(exect count)。当启用Time Series Index (TSI)时，才支持对`time`进行过滤。不支持在`WHERE`子句中使用`time`。

```
show_tag_key_cardinality_stmt = "SHOW TAG KEY CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ]

show_tag_key_exact_cardinality_stmt = "SHOW TAG KEY EXACT CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ]
```

#### 示例

```sql
-- show estimated tag key cardinality
SHOW TAG KEY CARDINALITY
-- show exact tag key cardinality
SHOW TAG KEY EXACT CARDINALITY
```

### 查看 TAG KEYS

```
show_tag_keys_stmt = "SHOW TAG KEYS" [on_clause] [ from_clause ] [ where_clause ]
                     [ limit_clause ] [ offset_clause ] .
```

#### 示例

```sql
-- 显示所有tag key
SHOW TAG KEYS

-- 显示名称为cpu的measurement中的所有tag key
SHOW TAG KEYS FROM "cpu"

-- 显示名称为cpu的measurement中region等于uswest的所有tag key
SHOW TAG KEYS FROM "cpu" WHERE "region" = 'uswest'

-- 显示host等于serverA的所有tag key
SHOW TAG KEYS WHERE "host" = 'serverA'
```

### 查看 TAG VALUES

```
show_tag_values_stmt = "SHOW TAG VALUES" [on_clause] [ from_clause ] with_tag_clause [ where_clause ]
                       [ limit_clause ] [ offset_clause ] .
```

#### 示例

```sql
-- 显示measurement中tag key为region的所有tag value
SHOW TAG VALUES WITH KEY = "region"

-- 显示名称为cpu的measurement中tag key为regiion的所有tag value
SHOW TAG VALUES FROM "cpu" WITH KEY = "region"

-- 显示measurement中的tag key不包含字母的所有tag value
SHOW TAG VALUES WITH KEY !~ /.*c.*/

-- show tag values from the cpu measurement for region & host tag keys where service = 'redis'
-- 显示tag key为region和host的measurement为cpu并且service ='redis'的所有tag value
-- 
SHOW TAG VALUES FROM "cpu" WITH KEY IN ("region", "host") WHERE "service" = 'redis'
```

#### 查看 TAG VALUES 基数

除非使用`ON <database>`指定数据库，否则估计或精确计算当前数据库的指定tag key对应的tag value的基数。

> **注意：**`ON <database>`、`FROM <sources>`、`WITH KEY = <key>`、`WHERE <condition>`、`GROUP BY <dimensions>`和`LIMIT/OFFSET`子句是可选的。当使用这些查询子句时，查询将回退到精确计数(exect count)。当启用Time Series Index (TSI)时，才支持对`time`进行过滤。不支持在`WHERE`子句中使用`time`。

```
show_tag_values_cardinality_stmt = "SHOW TAG VALUES CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ] with_key_clause

show_tag_values_exact_cardinality_stmt = "SHOW TAG VALUES EXACT CARDINALITY" [ on_clause ] [ from_clause ] [ where_clause ] [ group_by_clause ] [ limit_clause ] [ offset_clause ] with_key_clause
```

#### 例子

```sql
-- 显示指定tag key的tag value的估计基数
SHOW TAG VALUES CARDINALITY WITH KEY = "myTagKey"

-- 显示指定tag key的tag value的精确基数
SHOW TAG VALUES EXACT CARDINALITY WITH KEY = "myTagKey"
```

### SHOW USERS

```
show_users_stmt = "SHOW USERS" .
```

#### 示例

```sql
-- 显示所有用户
SHOW USERS
```

## 子句

```
from_clause     = "FROM" measurements .

group_by_clause = "GROUP BY" dimensions fill(fill_option).

into_clause     = "INTO" ( measurement | back_ref ).

limit_clause    = "LIMIT" int_lit .

offset_clause   = "OFFSET" int_lit .

slimit_clause   = "SLIMIT" int_lit .

soffset_clause  = "SOFFSET" int_lit .

timezone_clause = tz(string_lit) .

on_clause       = "ON" db_name .

order_by_clause = "ORDER BY" sort_fields .

to_clause       = "TO" user_name .

where_clause    = "WHERE" expr .

with_measurement_clause = "WITH MEASUREMENT" ( "=" measurement | "=~" regex_lit ) .

with_tag_clause = "WITH KEY" ( "=" tag_key | "!=" tag_key | "=~" regex_lit | "IN (" tag_keys ")"  ) .
```

## 表达方式

```
binary_op        = "+" | "-" | "*" | "/" | "%" | "&" | "|" | "^" | "AND" |
                   "OR" | "=" | "!=" | "<>" | "<" | "<=" | ">" | ">=" .

expr             = unary_expr { binary_op unary_expr } .

unary_expr       = "(" expr ")" | var_ref | time_lit | string_lit | int_lit |
                   float_lit | bool_lit | duration_lit | regex_lit .
```

## 其他

```
alias            = "AS" identifier .

back_ref         = ( policy_name ".:MEASUREMENT" ) |
                   ( db_name "." [ policy_name ] ".:MEASUREMENT" ) .

db_name          = identifier .

dimension        = expr .

dimensions       = dimension { "," dimension } .

field_key        = identifier .

field            = expr [ alias ] .

fields           = field { "," field } .

fill_option      = "null" | "none" | "previous" | int_lit | float_lit | "linear" .

host             = string_lit .

measurement      = measurement_name |
                   ( policy_name "." measurement_name ) |
                   ( db_name "." [ policy_name ] "." measurement_name ) .

measurements     = measurement { "," measurement } .

measurement_name = identifier | regex_lit .

password         = string_lit .

policy_name      = identifier .

privilege        = "ALL" [ "PRIVILEGES" ] | "READ" | "WRITE" .

query_id         = int_lit .

query_name       = identifier .

retention_policy = identifier .

retention_policy_option      = retention_policy_duration |
                               retention_policy_replication |
                               retention_policy_shard_group_duration |
                               "DEFAULT" .

retention_policy_duration    = "DURATION" duration_lit .

retention_policy_replication = "REPLICATION" int_lit .

retention_policy_shard_group_duration = "SHARD DURATION" duration_lit .

retention_policy_name = "NAME" identifier .

series_id        = int_lit .

shard_id         = int_lit .

sort_field       = field_key [ ASC | DESC ] .

sort_fields      = sort_field { "," sort_field } .

subscription_name = identifier .

tag_key          = identifier .

tag_keys         = tag_key { "," tag_key } .

user_name        = identifier .

var_ref          = measurement .
```

### 注释

在InfluxQL语句中使用注释来描述您的查询。

* 单行注释以（`--`）开头，并在InfluxDB检测到换行符的地方结束，但是不能跨多行注释。
* 多行注释以`/ *`开头，以`* /`结尾，并且可以跨多行注释。

## 查询引擎内部

一旦您理解了语言本身，了解如何在查询引擎中实现这些语言结构是十分重要的，因为这样可以使您直观地了解如何处理结果和如何创建有效的查询。

一个查询的生命周期如下所示：

1. 符号化InfluxQL查询语句，然后解析成一个抽象语法树(abstract syntac tree，简称AST)。这是查询本身的代码表示。
2. 将AST传给`QueryExecutor`，它将查询定向到合适的处理器(handler)。例如，与元数据相关的查询由元数据服务执行，`SELECT`语句由shard本身执行。
3. 然后，查询引擎确定与`SELECT`语句中的时间范围匹配的shard。在这些shard中，为语句中的每个field创建迭代器(iterator)。
4. 将迭代器传到发射器(emitter)，发射器将它们排出并连接结果中的数据点。发射器的工作是将简单的time/value数据点转换为更复杂的结果返回给客户端。

### 理解迭代器

迭代器是查询引擎的核心。迭代器提供一个简单的接口，用于循环遍历一组数据点。例如，这是浮点数上的迭代器：

```
type FloatIterator interface {
    Next() *FloatPoint
}
```

通过接口`IteratorCreator`创建迭代器：

```
type IteratorCreator interface {
    CreateIterator(opt *IteratorOptions) (Iterator, error)
}
```

`IteratorOptions`提供关于field选择、时间范围和维度的参数，使得迭代器创建者在规划迭代器的时候可以使用这些参数。接口`IteratorCreator`可以在多个层面使用，例如`Shards`、`Shard`和`Engine`。这允许在适当的时候执行优化，例如返回预计算的`COUNT()`。

迭代器不仅仅用于从存储中读取原始数据，迭代器还可以组合使用，以便它们为输入迭代器(input iterator)提供额外的功能。例如，迭代器`DistinctIterator`可以为输入迭代器计算每个时间窗口的不同的值，或者，迭代器`FillIterator`可以生成输入迭代器中缺少的数据点。

这种组合也很适合用于聚合。例如，以下语句：

```sql
SELECT MEAN(value) FROM cpu GROUP BY time(10m)
```

在这种情况下，`MEAN(value)`是一个迭代器`MeanIterator`，它从底层的shard中包装一个迭代器。然而，我们可以添加一个额外的迭代器来决定这些平均值的导数：

```
SELECT DERIVATIVE(MEAN(value), 20m) FROM cpu GROUP BY time(10m)
```

### 理解游标

**游标**通过元组（time，value）中的分片（measurement，tag set和field）识别数据。 游标遍历存储为日志结构的合并树的数据，并跨级别处理重复数据删除，删除数据的逻辑删除以及合并缓存（预写日志）。 游标按时间升序或降序对（time，value）元组进行排序。

例如，一个查询评估3个分片上的1,000个系列的一个字段的查询将构造至少3,000个游标（每个分片1,000个）。

### 理解辅助field

因为InfluxQL允许用户使用selector函数，例如，`FIRST()`、`LAST()`、`MIN()`和`MAX()`，所以查询引擎必须提供一种与选定数据点同时返回相关数据的方法。

例如，以下查询：

```sql
SELECT FIRST(value), host FROM cpu GROUP BY time(1h)
```

我们查询每小时发生的第一个`value`，同时我们也要获得该数据点对应的`host`。因为效率问题，`Point`类型只指定了一个`value`类型，所以我们将`host`推送到该数据点的辅助field。这些辅助field将附加到数据点，直到它被传送到发射器(在那里field会被拆分到它们自己的迭代器)。

### 内置迭代器

有许多辅助迭代器(helper iterators)可以让我们构建查询：

* Merge Iterator(合并迭代器) - 该迭代器将一个或多个迭代器合并成一个有相同类型的新的迭代器。该迭代器保证在开始下一个窗口之前输出当前窗口内的所有数据点，但是并不保证窗口内的数据点已经排好序，这使得不需要更高排序要求的聚合查询能够快速访问。
* Sorted Merge Iterator(排序合并迭代器) - 该迭代器也将一个或多个迭代器合并成一个有相同类型的新的迭代器。但是，该迭代器保证每个数据点都是按时间排好序的。这使得它的速度比`MergeIterator`慢，但是对于返回原始数据点的非聚合查询，这种排序保证是必须的。
* Limit Iterator(限制迭代器) - 该迭代器限制了每个name/tag组的数据点个数。这是`LIMIT`和`OFFSET`语法的实现。
* Fill Iterator(填充迭代器) - 该迭代器用额外的数据点填充在输入迭代器中缺失的数据点，它可以提供`null`数据点、与前一个值相同的数据点、或者有特定值的数据点。
* Buffered Iterator(缓冲迭代器) - 该迭代器提供将一个数据点”unread”(未读)并且返回缓冲区的能力，以便下次读取它。这被广泛用于为窗口提供前瞻。
* Reduce Iterator(reduce迭代器) - 该迭代器为窗口中的每一个数据点调用reduction函数。当窗口内的所有运算完成后，该窗口的所有数据点会被输出。这用于简单聚合函数，例如`COUNT()`。
* Reduce Slice Iterator(reduce slice迭代器) - 该迭代器首先收集窗口内的所有数据点，然后立刻将它们全部传送到一个reduction函数。结果从迭代器返回。这用于聚合函数，例如`DERIVATIVE()`。
* Transform Iterator(转换迭代器) - 该迭代器对输入迭代器中的每个数据点调用转换函数。这用于执行二进制表达式。
* Dedupe Iterator(去重迭代器) - 该迭代器只输出不同的数据点。因为该迭代器非常消耗资源，所以它只用于小查询，例如元查询语句(meta query statements)。

### 调用迭代器

InfluxQL中的函数调用分两个级别(level)实现：shard级别和引擎级别。

为了提高效率，有些调用可以在多个层被包装，例如，`COUNT()`可以在shard级别执行，然后一个`CountIterator`可以包装多个`CountIterator`来计算所有shard的个数。这些迭代器可以使用`NewCallIterator()`来创建。

有些迭代器更复杂或者需要在更高的级别实现。例如，`DERIVATIVE()`首先需要获得窗口内的所有数据点，然后再执行计算，该迭代器由引擎本身创建，并且永远不会由更低级别创建。