---
title: 使用InfluxQL管理数据库
description: >
  Use InfluxQL to administer your InfluxDB server and work with InfluxDB databases, retention policies, series, measurements, and shards.
menu:
  influxdb_1_8:
    name: 数据库管理
    weight: 40
    parent: InfluxQL
aliases:
  - /influxdb/v1.8/query_language/database_management/
---

InfluxQL提供一整套的数据库管理命令

<table style="width:100%">
  <tr>
    <td><b>数据库管理</b></td>
    <td><b>保留策略管理</br></td>
  </tr>
  <tr>
    <td><a href="#create-database">CREATE DATABASE</a></td>
    <td><a href="#create-retention-policies-with-create-retention-policy">CREATE RETENTION POLICY</a></td>
  </tr>
  <tr>
    <td><a href="#delete-a-database-with-drop-database">DROP DATABASE</a></td>
    <td><a href="#modify-retention-policies-with-alter-retention-policy">ALTER RETENTION POLICY</a></td>
  </tr>
  <tr>
    <td><a href="#drop-series-from-the-index-with-drop-series">DROP SERIES</a></td>
    <td><a href="#delete-retention-policies-with-drop-retention-policy">DROP RETENTION POLICY</a></td>
  </tr>
  <tr>
    <td><a href="#delete-series-with-delete">DELETE</a></td>
    <td></td>
  </tr>
  <tr>
    <td><a href="#delete-measurements-with-drop-measurement">DROP MEASUREMENT</a></td>
    <td></td>
  </tr>
  <tr>
    <td><a href="#delete-a-shard-with-drop-shard">DROP SHARD</a></td>
    <td></td>
  </tr>
</table>

如果您想要的是关于`SHOW`的查询(例如，`SHOW DATABASES`或者`SHOW RETENTION POLICIES`)，请查阅[Schema探索](/influxdb/v1.8/query_language/explore-schema)章节。

以下章节中的示例使用了InfluxDB的[命令行界面(CLI)](/influxdb/v1.8/introduction/getting-started/)。您也可以使用InfluxDB API来执行这些命令；只需向`/query`路径发送`GET`请求，并将命令包含在URL参数`q`中。

想要获得更多使用InfluxDB API的信息，请参阅 [查询数据](/influxdb/v1.8/guides/querying_data/)。

> **注意：**启用身份验证后，只有管理员用户才能执行此页面上列出的大多数命令。有关更多信息，请参见[身份验证与授权](/influxdb/v1.8/administration/authentication_and_authorization/)中的文档。

## 数据库管理

### CREATE DATABASE

创建一个新数据库

#### 语法

```sql
CREATE DATABASE <database_name> [WITH [DURATION <duration>] [REPLICATION <n>] [SHARD DURATION <duration>] [NAME <retention-policy-name>]]
```

#### 语法描述

`CREATE DATABASE`需要数据库[名称](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#what-words-and-characters-should-i-avoid-when-writing-data-to-influxdb)。

`WITH` ，`DURATION`，`REPLICATION`，`SHARD DURATION`，`NAME` 子句以及创建与数据库相关联的单个[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)是可选项。
如果未在`WITH`之后指定子句，则会默认创建名称为`autogen`的保留策略。

有关更多保留策略管理的信息，请参阅 [保留策略管理](/influxdb/v1.8/query_language/manage-database/#retention-policy-management)。

成功的`CREATE DATABASE`查询不返回任何结果。

如果创建一个已经存在的数据库，InfluxDB不执行任何操作，但也不会返回错误。

#### 示例

##### 创建数据库

```
> CREATE DATABASE "NOAA_water_database"
>
```

该查询创建一个名为 `NOAA_water_database`的数据库。

[默认情况下](/influxdb/v1.8/administration/config/#retention-autocreate-true)，InfluxDB还会创建默认的保留策略`autogen`并与数据库`NOAA_water_database`进行关联。

##### 创建具有特定保留策略的数据库

```
> CREATE DATABASE "NOAA_water_database" WITH DURATION 3d REPLICATION 1 SHARD DURATION 1h NAME "liquid"
>
```

该操作创建一个名称为`NOAA_water_database`的数据库。还为`NOAA_water_database`创建一个默认的保留策略，名称为`liquid`，其`DURATION`为3d，[复制因子](/influxdb/v1.8/concepts/glossary/#replication-factor)为1，[分片组](/influxdb/v1.8/concepts/glossary/#shard-group)持续时间为1h

### 使用`DROP DATABASE`删除数据库

`DROP DATABASE`查询从指定数据库中删除所有数据，measurement，series，连续查询和保留策略。

查询采语法如下：

```sql
DROP DATABASE <database_name>
```

删除数据库`NOAA_water_database`：
```bash
> DROP DATABASE "NOAA_water_database"
>
```

成功的`DROP DATABASE`命令不返回任何结果。如果删除不存在的数据库，InfluxDB也不会返回错误。

### 使用`DROP SERIES`从索引中删除series

`DROP SERIES`查询会删除数据库中的所有数据Point，并从索引中删除该[series](/influxdb/v1.8/concepts/glossary/#series)。

> **注意：**`DROP SERIES`不支持`WHERE`子句中使用时间条件。查看 [`DELETE`](/influxdb/v1.8/query_language/manage-database/#delete-series-with-delete) 了解更多

查询采用以下格式，必须指定`FROM`子句和`WHERE`子句：

```sql
DROP SERIES FROM <measurement_name[,measurement_name]> WHERE <tag_key>='<tag_value>'
```

在单个measurement删除所有series：

```sql
> DROP SERIES FROM "h2o_feet"
```

在单个measurement中删除具有特定tag的series：

```sql
> DROP SERIES FROM "h2o_feet" WHERE "location" = 'santa_monica'
```

Drop all points in the series that have a specific tag pair from all measurements in the database:

在数据库中的所有measurement中删除series中具有特定tag的所有数据点：

```sql
> DROP SERIES WHERE "location" = 'santa_monica'
```

注意：成功的`DROP SERIES` 查询不返回任何结果。

### 使用`DELETE`删除series

使用`DELETE`在一个数据中删除某一个[series](/influxdb/v1.8/concepts/glossary/#series)的所有数据点。

不像[`DROP SERIES`](/influxdb/v1.8/query_language/manage-database/#drop-series-from-the-index-with-drop-series), 它不会从索引中删除series，并且支持`WHERE`子句中的时间条件。

查询必须包括`FROM`子句或`WHERE`子句，或者同时包含这两者：

```sql
DELETE FROM <measurement_name> WHERE [<tag_key>='<tag_value>'] | [<time interval>]
```

删除与measurement`h2o_feet`相关的所有数据：

```sql
> DELETE FROM "h2o_feet"
```

删除所有与measurement`h2o_quality`相关的数据，并且tag `randtag`等于3：

```sql
> DELETE FROM "h2o_quality" WHERE "randtag" = '3'
```

Delete all data in the database that occur before January 01, 2016:



```sql
> DELETE WHERE time < '2016-01-01'
```

成功的`DELETE` 查询不返回任何结果。

有关 `DELETE`的注意事项：

* `DELETE`在指定measurement名称和`WHERE`子句中指定`tag value`时支持使用[正则表达式](/influxdb/v1.8/query_language/explore-data/#regular-expressions)。
* `DELETE`不支持`WHERE`子句中的 [fields](/influxdb/v1.8/concepts/glossary/#field)。
* 如果需要删除数据点，则必须执行时间段，因此默认情况下，`DELETE SERIES` 运行时间`time < now()`为默认[语法](https://github.com/influxdata/influxdb/issues/8007)。

### Delete measurements with DROP MEASUREMENT

使用`DROP MEASUREMENT`删除measurement

`DROP MEASUREMENT`查询从指定的[measurement](/influxdb/v1.8/concepts/glossary/#measurement)中删除所有数据和series，并删除measurement。

查询语法如下：
```sql
DROP MEASUREMENT <measurement_name>
```

Delete the measurement `h2o_feet`:

删除名称为`h2o_feet`的measurement

```sql
> DROP MEASUREMENT "h2o_feet"
```

> **注意：**`DROP MEASUREMENT`会删除measurement中的所有数据点和series。但不会删除相关联的连续查询。

成功的`DROP MEASUREMENT`查询不返回任何结果。

{{% warn %}} 当前，InfluxDB不支持带有DROP MEASUREMENTS的正则表达式。有关更多信息，请参阅GitHub问题[#4275](https://github.com/influxdb/influxdb/issues/4275)。

{{% /warn %}}

### 使用`DROP SHARD`删除分片

使用`DROP SHARD`查询删除分片，它还会从[元信息](/influxdb/v1.8/concepts/glossary/#metastore)中删除分片。

查询格式如下：

```sql
DROP SHARD <shard_id_number>
```

删除分片ID为`1`的分片

```
> DROP SHARD 1
>
```

成功的`DROP SHARD`查询不返回任何结果。
如果删除不存在的碎片，InfluxDB不会返回错误。

## 保留策略（RP）管理

以下各节介绍如何创建，更改和删除保留策略。

请注意，当创建数据库时，InfluxDB会自动创建一个名为`autogen`的保留策略，该策略具有无限的保留期限。

您可以在[配置文件](/influxdb/v1.8/administration/config/#metastore-settings)中禁用自动创建的功能。

### 使用`CREATE RETENTION POLICY`创建保留策略

#### 语法
```
CREATE RETENTION POLICY <retention_policy_name> ON <database_name> DURATION <duration> REPLICATION <n> [SHARD DURATION <duration>] [DEFAULT]
```

#### 语法描述

##### `DURATION`

- `DURATION`子句确定InfluxDB将数据保留多长时间。 保留策略的最短持续时间为一小时，最长持续时间为`INF`（无限）。

##### `REPLICATION`

- `REPLICATION`子句确定每个数据点在集群中存储了多少个独立副本。
- 默认情况下，复制因子`n`通常等于date node的数量。 但是，如果您有四个或更多data node，则默认复制因子`n`为3。
- 为了确保数据立即可用于查询，请将复制因子` n`设置为小于或等于集群中data node的数量。

> **重要：**如果您有四个或更多data node，请验证数据库复制因子是否正确。

- 复制因子不适用于单节点实例。

##### `SHARD DURATION`

- 可选项， `SHARD DURATION` 子句确定[分片组](/influxdb/v1.8/concepts/glossary/#shard-group)的时间范围。
- 默认情况下，分片组的持续时间由保留策略的`DURATION`确定：

| 保留策略期限 | 分片组持续时间 |
|---|---|
| < 2 days  | 1 hour  |
| >= 2 days and <= 6 months  | 1 day  |
| > 6 months  | 7 days  |

最小允许的 `SHARD GROUP DURATION` 为`1h`.
如果 `创建保留策略` 查询试图将 `SHARD GROUP DURATION` 设置为小于 `1h` 且大于 `0s`, InfluxDB 会自动的讲 `SHARD GROUP DURATION` 设置为 `1h`.
如果 `CREATE RETENTION POLICY` 查询试图讲 `SHARD GROUP DURATION` 设置为你 `0s`, InfluxDB 会根据上面列出的默认自动设置`SHARD GROUP DURATION` 

想了解更多请参阅[Shard group duration management](/influxdb/v1.8/concepts/schema_and_data_layout/#shard-group-duration-management)
推荐配置

##### `DEFAULT`

将新的保留策略设置为数据库的默认保留策略。此设置是可选项。

#### 示例

##### 创建保留策略

```
> CREATE RETENTION POLICY "one_day_only" ON "NOAA_water_database" DURATION 1d REPLICATION 1
>
```
该查询为数据库`NOAA_water_database`创建了一个名为`one_day_only`的保留策略，该策略的期限为`1d`，复制因子为`1`。

##### 创建默认保留策略

```sql
> CREATE RETENTION POLICY "one_day_only" ON "NOAA_water_database" DURATION 23h60m REPLICATION 1 DEFAULT
>
```

该查询创建与上例相同的保留策略，但是将其设置为数据库的默认保留策略。

成功的`CREATE RETENTION POLICY`查询不返回任何结果。

如果尝试创建与现有策略相同的保留策略，则InfluxDB不会返回错误。
如果尝试创建与现有保留策略相同名称的保留策略，但属性不同，则InfluxDB将返回错误。

> **注意：**您也可以在`CREATE DATABASE`查询中指定新的保留策略。
请参阅 [使用`CREATE DATABASE`创建数据库](/influxdb/v1.8/query_language/manage-database/#create-database).

### 使用`ALTER RETENTION POLICY`修改保留策略

The `ALTER RETENTION POLICY` query takes the following form, where you must declare at least one of the retention policy attributes `DURATION`, `REPLICATION`, `SHARD DURATION`, or `DEFAULT`:

`ALTER RETENTION POLICY`查询语法如下，必须声明至少一个保留策略属性`DURATION`，`REPLICATION`，`SHARD DURATION`或`DEFAULT`：

```sql
ALTER RETENTION POLICY <retention_policy_name> ON <database_name> DURATION <duration> REPLICATION <n> SHARD DURATION <duration> DEFAULT
```

{{% warn %}} 复制因子不适用于单节点实例。
{{% /warn %}}

First, create the retention policy `what_is_time` with a `DURATION` of two days:

首先，以2d的`DURATION`创建保留策略`what_is_time`：

```sql
> CREATE RETENTION POLICY "what_is_time" ON "NOAA_water_database" DURATION 2d REPLICATION 1
>
```

Modify `what_is_time` to have a three week `DURATION`, a two hour shard group duration, and make it the `DEFAULT` retention policy for `NOAA_water_database`.

修改`what_is_time`以使其具有三周的`DURATION`，两个小时的分片组持续时间，并使其成为`NOAA_water_database`的`DEFAULT`保留策略。

```sql
> ALTER RETENTION POLICY "what_is_time" ON "NOAA_water_database" DURATION 3w SHARD DURATION 2h DEFAULT
>
```
在最后一个示例中，` what_is_time`保留其原始复制因子`1`。

成功的`ALTER RETENTION POLICY`查询不返回任何结果。

### 使用`DROP RETENTION POLICY`删除保留策略

删除保留策略中的所有measurement和数据：

{{% warn %}}
删除保留策略将永久删除保留在保留策略中的所有measurement和数据。
{{% /warn %}}

```sql
DROP RETENTION POLICY <retention_policy_name> ON <database_name>
```

在`NOAA_water_database`数据库中删除保留策略`what_is_time`：

```bash
> DROP RETENTION POLICY "what_is_time" ON "NOAA_water_database"
>
```

成功的`DROP RETENTION POLICY`查询不返回任何结果。
如果尝试删除不存在的保留策略，则InfluxDB不会返回错误。