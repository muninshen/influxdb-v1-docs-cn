---
title: Schema探索
description: Useful query syntax for exploring schema in InfluxQL.
menu:
  influxdb_1_8:
    name: Schema探索
    weight: 30
    parent: InfluxQL
aliases:
  - /influxdb/v1.8/query_language/schema_exploration/
---

InfluxQL是一种类SQL的查询语言，用于与InfluxDB中的数据进行交互。以下章节介绍了实用的查询[schema](/influxdb/v1.8/concepts/glossary/#schema)的语法。

<table style="width:100%">
  <tr>
    <td><a href="#show-databases">SHOW DATABASES</a></td>
    <td><a href="#show-retention-policies">SHOW RETENTION POLICIES</a></td>
    <td><a href="#show-series">SHOW SERIES</a></td>
  </tr>
  <tr>
    <td><a href="#show-measurements">SHOW MEASUREMENTS</a></td>
    <td><a href="#show-tag-keys">SHOW TAG KEYS</a></td>
    <td><a href="#show-tag-values">SHOW TAG VALUES</a></td>
  </tr>
  <tr>
    <td><a href="#show-field-keys">SHOW FIELD KEYS</a></td>
    <td><a href="#filter-meta-queries-by-time">Filter meta queries by time</a></td>
    <td></td>
  </tr>
</table>
**示例数据**

本文档使用的数据可在[示例数据](/influxdb/v1.8/query_language/data_download/)章节中下载。

在开始之前，请先登录Influx CLI。

```bash
$ influx -precision rfc3339
Connected to http://localhost:8086 version 1.8.x
InfluxDB shell 1.8.x
>
```

## `SHOW DATABASES`
返回实例上所有[数据库](/influxdb/v1.8/concepts/glossary/#database)的列表。

### 语法

```sql
SHOW DATABASES
```

### 示例

#### 运行 `SHOW DATABASES` 查询语句

```sql
> SHOW DATABASES

name: databases
name
----
NOAA_water_database
_internal
```

该查询以表格格式返回数据库名称，这个InfluxDB实例有两个数据库：`NOAA_water_database`和`_internal`。

## `SHOW RETENTION POLICIES`

返回指定[数据库](/influxdb/v1.8/concepts/glossary/#database)的[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)列表。

### 语法

```sql
SHOW RETENTION POLICIES [ON <database_name>]
```

### 语法说明

`ON <database_name>`是可选项。如果查询中没有包含`ON <database_name>`，您必须在[CLI](/influxdb/v1.8/tools/shell/)中使用`USE <database_name>`指定数据库，或者在[InfluxDB API](/influxdb/v1.8/tools/api/#query-string-parameters)请求中使用参数`db`指定数据库。

### 示例

#### 运行带有`ON`子句的`SHOW RETENTION POLICIES`查询

```sql
> SHOW RETENTION POLICIES ON NOAA_water_database

name      duration   shardGroupDuration   replicaN   default
----      --------   ------------------   --------   -------
autogen   0s         168h0m0s             1          true
```

该查询以表格的形式返回数据库`NOAA_water_database`中所有的保留策略。这个数据库有一个名为`autogen`的保留策略，该保留策略具有无限的持续时间，为期7天的shard group持续时间，复制系数为1，并且它是这个数据库的默认(`DEFAULT`)保留策略。

#### 运行不带有`ON`子句的`SHOW RETENTION POLICIES`查询

{{< tabs-wrapper >}}
{{% tabs %}}
[CLI](#)
[InfluxDB API](#)
{{% /tabs %}}
{{% tab-content %}}

使用`USE <database_name>`指定数据库

```sql
> USE NOAA_water_database
Using database NOAA_water_database

> SHOW RETENTION POLICIES

name      duration   shardGroupDuration   replicaN   default
----      --------   ------------------   --------   -------
autogen   0s         168h0m0s             1          true
```

{{% /tab-content %}}

{{% tab-content %}}

使用参数`db`指定数据库

```bash
~# curl -G "http://localhost:8086/query?db=NOAA_water_database&pretty=true" --data-urlencode "q=SHOW RETENTION POLICIES"

{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "columns": [
                        "name",
                        "duration",
                        "shardGroupDuration",
                        "replicaN",
                        "default"
                    ],
                    "values": [
                        [
                            "autogen",
                            "0s",
                            "168h0m0s",
                            1,
                            true
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

## `SHOW SERIES`

返回指定[数据库](/influxdb/v1.8/concepts/glossary/#database)的[系列](/influxdb/v1.8/concepts/glossary/#database)。

### 语法

```sql
SHOW SERIES [ON <database_name>] [FROM_clause] [WHERE <tag_key> <operator> [ '<tag_value>' | <regular_expression>]] [LIMIT_clause] [OFFSET_clause]
```

### 语法描述

`ON <database_name>`是可选的。如果查询中没有包含`ON <database_name>`，您必须在[CLI](/influxdb/v1.8/tools/shell/)中使用`USE <database_name>`指定数据库，或者在[InfluxDB API](/influxdb/v1.8/tools/api/#query-string-parameters)请求中使用参数`db`指定数据库。

`FROM`子句，`WHERE`子句，`LIMIT`子句和`OFFSET`子句是可选项。`WHERE`子句支持tag比较；在`SHOW SERIES`查询中，field比较是无效的。

`WHERE`子句中支持的操作符：

| 操作符 | 含义   |
| ------ | ------ |
| `=`    | 等于   |
| `<>`   | 不等于 |
| `!=`   | 不等于 |
| `=~`   | 匹配   |
| `!~`   | 不匹配 |

请查阅数据探索章节获得关于[`FROM`子句](/influxdb/v1.8/query_language/explore-data/#the-basic-select-statement)、[`LIMIT`子句](/influxdb/v1.8/query_language/explore-data/#the-limit-clause)、[`OFFSET`子句](/influxdb/v1.8/query_language/explore-data/#the-offset-clause)和[正则表达式](/influxdb/v1.8/query_language/explore-data/#regular-expressions)的介绍。

### 示例

#### 运行带有`ON`子句的`SHOW SERIES`查询

```sql
// Returns series for all shards in the database
> SHOW SERIES ON NOAA_water_database

key
---
average_temperature,location=coyote_creek
average_temperature,location=santa_monica
h2o_feet,location=coyote_creek
h2o_feet,location=santa_monica
h2o_pH,location=coyote_creek
h2o_pH,location=santa_monica
h2o_quality,location=coyote_creek,randtag=1
h2o_quality,location=coyote_creek,randtag=2
h2o_quality,location=coyote_creek,randtag=3
h2o_quality,location=santa_monica,randtag=1
h2o_quality,location=santa_monica,randtag=2
h2o_quality,location=santa_monica,randtag=3
h2o_temperature,location=coyote_creek
h2o_temperature,location=santa_monica
```

该查询的输出类似[行协议](/influxdb/v1.8/concepts/glossary/#influxdb-line-protocol)格式。第一个逗号之前的所有内容是[measurement](/influxdb/v1.8/concepts/glossary/#measurement)的名字。第一个逗号之后的所有内容都是[tag key](/influxdb/v1.8/concepts/glossary/#tag-key)或者[tag value](/influxdb/v1.8/concepts/glossary/#tag-value)。数据库`NOAA_water_database`有五个不同的measurement和14个不同的系列。

#### 运行不带有`ON`子句的`SHOW SERIES`查询

{{< tabs-wrapper >}}
{{% tabs %}}
[CLI](#)
[InfluxDB API](#)
{{% /tabs %}}
{{% tab-content %}}

使用`USE <database_name>`指定数据库：

```sql
> USE NOAA_water_database
Using database NOAA_water_database

> SHOW SERIES

key
---
average_temperature,location=coyote_creek
average_temperature,location=santa_monica
h2o_feet,location=coyote_creek
h2o_feet,location=santa_monica
h2o_pH,location=coyote_creek
h2o_pH,location=santa_monica
h2o_quality,location=coyote_creek,randtag=1
h2o_quality,location=coyote_creek,randtag=2
h2o_quality,location=coyote_creek,randtag=3
h2o_quality,location=santa_monica,randtag=1
h2o_quality,location=santa_monica,randtag=2
h2o_quality,location=santa_monica,randtag=3
h2o_temperature,location=coyote_creek
h2o_temperature,location=santa_monica
```

{{% /tab-content %}}

{{% tab-content %}}

使用参数`db`指定数据库：

```bash
~# curl -G "http://localhost:8086/query?db=NOAA_water_database&pretty=true" --data-urlencode "q=SHOW SERIES"

{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "columns": [
                        "key"
                    ],
                    "values": [
                        [
                            "average_temperature,location=coyote_creek"
                        ],
                        [
                            "average_temperature,location=santa_monica"
                        ],
                        [
                            "h2o_feet,location=coyote_creek"
                        ],
                        [
                            "h2o_feet,location=santa_monica"
                        ],
                        [
                            "h2o_pH,location=coyote_creek"
                        ],
                        [
                            "h2o_pH,location=santa_monica"
                        ],
                        [
                            "h2o_quality,location=coyote_creek,randtag=1"
                        ],
                        [
                            "h2o_quality,location=coyote_creek,randtag=2"
                        ],
                        [
                            "h2o_quality,location=coyote_creek,randtag=3"
                        ],
                        [
                            "h2o_quality,location=santa_monica,randtag=1"
                        ],
                        [
                            "h2o_quality,location=santa_monica,randtag=2"
                        ],
                        [
                            "h2o_quality,location=santa_monica,randtag=3"
                        ],
                        [
                            "h2o_temperature,location=coyote_creek"
                        ],
                        [
                            "h2o_temperature,location=santa_monica"
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

#### 运行带有多个子句的`SHOW SERIES`查询

```sql
> SHOW SERIES ON NOAA_water_database FROM "h2o_quality" WHERE "location" = 'coyote_creek' LIMIT 2

key
---
h2o_quality,location=coyote_creek,randtag=1
h2o_quality,location=coyote_creek,randtag=2
```

该查询返回数据库`NOAA_water_database`中，与measurement `h2o_quality`和tag `location = coyote_creek`相关联的所有系列。`LIMIT`子句将返回的系列个数限制为2。

#### 运行带有时间限制的`SHOW SERIES`查询

在指定的分片组持续时间内返回系列。

```sql
// 返回当前分片中的所有系列
> SHOW SERIES ON NOAA_water_database WHERE time > now() - 1m

key
---
average_temperature,location=coyote_creek
h2o_feet,location=coyote_creek
h2o_pH,location=coyote_creek
h2o_quality,location=coyote_creek,randtag=1
h2o_quality,location=coyote_creek,randtag=2
h2o_quality,location=coyote_creek,randtag=3
h2o_temperature,location=coyote_creek
```

上面的查询返回当前分片组中数据库`NOAA_water_database`中的所有系列。`WHERE`子句将结果限制为shard组中包含最后一分钟时间戳的系列。注意，如果分片组持续时间为7天，则返回的结果可能最长为7天。

```sql
// 返回分片组中时间戳包含过去28天的所有系列
> SHOW SERIES ON NOAA_water_database WHERE time > now() - 28d

key
---
average_temperature,location=coyote_creek
average_temperature,location=santa_monica
h2o_feet,location=coyote_creek
h2o_feet,location=santa_monica
h2o_pH,location=coyote_creek
h2o_pH,location=santa_monica
h2o_quality,location=coyote_creek,randtag=1
h2o_quality,location=coyote_creek,randtag=2
h2o_quality,location=coyote_creek,randtag=3
h2o_quality,location=santa_monica,randtag=1
h2o_quality,location=santa_monica,randtag=2
h2o_quality,location=santa_monica,randtag=3
h2o_temperature,location=coyote_creek
h2o_temperature,location=santa_monica
```

注意，如果指定分片持续时间为7天，则上面的查询将返回最后3或4个分片的系列。

## `SHOW MEASUREMENTS`

返回指定[数据库](/influxdb/v1.8/concepts/glossary/#database)的[measurement](/influxdb/v1.8/concepts/glossary/#measurement)。

### 语法

```sql
SHOW MEASUREMENTS [ON <database_name>] [WITH MEASUREMENT <operator> ['<measurement_name>' | <regular_expression>]] [WHERE <tag_key> <operator> ['<tag_value>' | <regular_expression>]] [LIMIT_clause] [OFFSET_clause]
```

### 语法描述

`ON <database_name>`是可选项。如果查询中没有包含`ON <database_name>`，您必须在[CLI](/influxdb/v1.8/tools/shell/)中使用`USE <database_name>`指定数据库，或者在[InfluxDB API](/influxdb/v1.8/tools/api/#query-string-parameters)请求中使用参数`db`指定数据库。

`WITH`子句，`WHERE`子句，`LIMIT`子句和`OFFSET`子句是可选的。`WHERE`子句支持tag比较；在`SHOW MEASUREMENTS`查询中，field比较是无效的。

`WHERE`子句中支持的操作符：

| 操作符 | 含义   |
| ------ | ------ |
| `=`    | 等于   |
| `<>`   | 不等于 |
| `!=`   | 不等于 |
| `=~`   | 匹配   |
| `!~`   | 不匹配 |

请查阅数据探索章节获得关于[`LIMIT`子句](/influxdb/v1.8/query_language/explore-data/#the-limit-clause)、[`OFFSET`子句](/influxdb/v1.8/query_language/explore-data/#the-offset-clause)和[正则表达式](/influxdb/v1.8/query_language/explore-data/#regular-expressions)的介绍。

### 示例

#### 运行带有`ON`子句的`SHOW MEASUREMENTS`查询

```sql
> SHOW MEASUREMENTS ON NOAA_water_database

name: measurements
name
----
average_temperature
h2o_feet
h2o_pH
h2o_quality
h2o_temperature
```

该查询返回数据库`NOAA_water_database`中的measurement。数据库`NOAA_water_database`有五个measurement：`average_temperature`、`h2o_feet`、`h2o_pH`、`h2o_quality`和`h2o_temperature`。

#### 运行不带有`ON`子句的`SHOW MEASUREMENTS`查询

{{< tabs-wrapper >}}
{{% tabs %}}
[CLI](#)
[InfluxDB API](#)
{{% /tabs %}}

{{% tab-content %}}

使用`USE <database_name>`指定数据库：

```sql
> USE NOAA_water_database
Using database NOAA_water_database

> SHOW MEASUREMENTS
name: measurements
name
----
average_temperature
h2o_feet
h2o_pH
h2o_quality
h2o_temperature
```

{{% /tab-content %}}

{{% tab-content %}}

使用参数`db`指定数据库：
```
~# curl -G "http://localhost:8086/query?db=NOAA_water_database&pretty=true" --data-urlencode "q=SHOW MEASUREMENTS"

{
  {
      "results": [
          {
              "statement_id": 0,
              "series": [
                  {
                      "name": "measurements",
                      "columns": [
                          "name"
                      ],
                      "values": [
                          [
                              "average_temperature"
                          ],
                          [
                              "h2o_feet"
                          ],
                          [
                              "h2o_pH"
                          ],
                          [
                              "h2o_quality"
                          ],
                          [
                              "h2o_temperature"
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

#### 运行带有多个子句的`SHOW MEASUREMENTS查询`(i)

```sql
> SHOW MEASUREMENTS ON NOAA_water_database WITH MEASUREMENT =~ /h2o.*/ LIMIT 2 OFFSET 1

name: measurements
name
----
h2o_pH
h2o_quality
```

该查询返回数据库`NOAA_water_database`中名字以`h2o`开头的measurement。`LIMIT`子句将返回的measurement名字的个数限制为2，`OFFSET`子句将measurement `h2o_feet`跳过，从`h2o_feet`后的measurement开始输出。

#### 运行带有多个子句的`SHOW MEASUREMENTS`查询(ii)

```sql
> SHOW MEASUREMENTS ON NOAA_water_database WITH MEASUREMENT =~ /h2o.*/ WHERE "randtag"  =~ /\d/

name: measurements
name
----
h2o_quality
```

该查询返回数据库`NOAA_water_database`中名字以`h2o`开头并且`randtag`的值包含一个整数的measurement。

## `SHOW TAG KEYS`

返回指定[数据库](/influxdb/v1.8/concepts/glossary/#database)的[tag key](/influxdb/v1.8/concepts/glossary/#tag-key)。

### 语法

```sql
SHOW TAG KEYS [ON <database_name>] [FROM_clause] [WHERE <tag_key> <operator> ['<tag_value>' | <regular_expression>]] [LIMIT_clause] [OFFSET_clause]
```

### 语法描述

`ON <database_name>`是可选项。如果查询中没有包含`ON <database_name>`，您必须在[CLI](/influxdb/v1.8/tools/shell/)中使用`USE <database_name>`指定数据库，或者在[InfluxDB API](/influxdb/v1.8/tools/api/#query-string-parameters)请求中使用参数`db`指定数据库。

`FROM`子句和`WHERE`子句是可选的。`WHERE`子句支持tag比较；在`SHOW TAG KEYS`查询中，field比较是无效的。

`WHERE`子句中支持的操作符：

| 操作符 |  含义  |
| :----: | :----: |
|   =    |  等于  |
|   <>   | 不等于 |
|   !=   | 不等于 |
|   =~   |  匹配  |
|   !~   | 不匹配 |

请查阅数据探索章节获得关于[`FROM`子句](/influxdb/v1.8/query_language/explore-data/#the-basic-select-statement)、[`LIMIT`子句](/influxdb/v1.8/query_language/explore-data/#the-limit-clause)、[`OFFSET`子句](/influxdb/v1.8/query_language/explore-data/#the-offset-clause)和[正则表达式](/influxdb/v1.8/query_language/explore-data/#regular-expressions)的介绍。

### 示例

#### 运行带有`ON`子句的`SHOW TAG KEYS`查询

```sql
> SHOW TAG KEYS ON "NOAA_water_database"

name: average_temperature
tagKey
------
location

name: h2o_feet
tagKey
------
location

name: h2o_pH
tagKey
------
location

name: h2o_quality
tagKey
------
location
randtag

name: h2o_temperature
tagKey
------
location
```

该查询返回数据库`NOAA_water_database`中的tag key。查询结果按measurement的名字进行分组；它展示了每个measurement都有一个名为`location`的tag key，并且，measurement `h2o_quality`还具有另外一个tag key `randtag`。

#### 运行不带有`ON`子句的`SHOW TAG KEYS`查询

{{< tabs-wrapper >}}
{{% tabs %}}
[CLI](#)
[InfluxDB API](#)
{{% /tabs %}}
{{% tab-content %}}

使用`USE <database_name>`指定数据库

```sql
> USE NOAA_water_database
Using database NOAA_water_database

> SHOW TAG KEYS

name: average_temperature
tagKey
------
location

name: h2o_feet
tagKey
------
location

name: h2o_pH
tagKey
------
location

name: h2o_quality
tagKey
------
location
randtag

name: h2o_temperature
tagKey
------
location
```

{{% /tab-content %}}

{{% tab-content %}}

使用参数`db`指定数据库

```sql
~# curl -G "http://localhost:8086/query?db=NOAA_water_database&pretty=true" --data-urlencode "q=SHOW TAG KEYS"

{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "average_temperature",
                    "columns": [
                        "tagKey"
                    ],
                    "values": [
                        [
                            "location"
                        ]
                    ]
                },
                {
                    "name": "h2o_feet",
                    "columns": [
                        "tagKey"
                    ],
                    "values": [
                        [
                            "location"
                        ]
                    ]
                },
                {
                    "name": "h2o_pH",
                    "columns": [
                        "tagKey"
                    ],
                    "values": [
                        [
                            "location"
                        ]
                    ]
                },
                {
                    "name": "h2o_quality",
                    "columns": [
                        "tagKey"
                    ],
                    "values": [
                        [
                            "location"
                        ],
                        [
                            "randtag"
                        ]
                    ]
                },
                {
                    "name": "h2o_temperature",
                    "columns": [
                        "tagKey"
                    ],
                    "values": [
                        [
                            "location"
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

#### 运行带有多个子句的`SHOW TAG KEYS`查询

```sql
> SHOW TAG KEYS ON "NOAA_water_database" FROM "h2o_quality" LIMIT 1 OFFSET 1

name: h2o_quality
tagKey
------
randtag
```

该查询返回数据库`NOAA_water_database`中名为`h2o_quality`的measurement里的tag key。`LIMIT`子句将返回的tag key的个数限制为1，`OFFSET`子句将输出结果偏移一个。

## `SHOW TAG VALUES`

返回数据库中指定[tag key](/influxdb/v1.8/concepts/glossary/#tag-key)的[tag value](/influxdb/v1.8/concepts/glossary/#tag-value)。

### 语法

```sql
SHOW TAG VALUES [ON <database_name>][FROM_clause] WITH KEY [ [<operator> "<tag_key>" | <regular_expression>] | [IN ("<tag_key1>","<tag_key2")]] [WHERE <tag_key> <operator> ['<tag_value>' | <regular_expression>]] [LIMIT_clause] [OFFSET_clause]
```

### 语法描述

`ON <database_name>`是可选的。如果查询中没有包含`ON <database_name>`，您必须在CLI中使用`USE <database_name>`指定数据库，或者在HTTP API请求中使用参数`db`指定数据库。

`WITH`子句是必须要有的，它支持指定一个tag key、一个正则表达式或多个tag key。

`FROM`子句、`WHERE`子句、`LIMIT`子句和`OFFSET`子句是可选的。`WHERE`子句支持tag比较；在`SHOW TAG VALUES`查询中，field比较是无效的。

`WITH`子句和`WHERE`子句中支持的操作符：

| 操作符 |  含义  |
| :----: | :----: |
|   =    |  等于  |
|   <>   | 不等于 |
|   !=   | 不等于 |
|   =~   |  匹配  |
|   !~   | 不匹配 |

请查阅数据探索章节获得关于[`FROM`子句](/influxdb/v1.8/query_language/explore-data/#the-basic-select-statement)、[`LIMIT`子句](/influxdb/v1.8/query_language/explore-data/#the-limit-clause)、[`OFFSET`子句](/influxdb/v1.8/query_language/explore-data/#the-offset-clause)和[正则表达式](/influxdb/v1.8/query_language/explore-data/#regular-expressions)的介绍。

### 示例

#### 运行带有`ON`子句的`SHOW TAG VALUES`查询

```sql
> SHOW TAG VALUES ON "NOAA_water_database" WITH KEY = "randtag"

name: h2o_quality
key       value
---       -----
randtag   1
randtag   2
randtag   3
```

该查询返回数据库`NOAA_water_database`中的tag key `randtag`的所有tag value。`SHOW TAG VALUES`将查询结果按measurement的名字进行分组。

#### 运行不带有`ON`子句的`SHOW TAG VALUES`查询

{{< tabs-wrapper >}}
{{% tabs %}}
[CLI](#)
[InfluxDB API](#)
{{% /tabs %}}
{{% tab-content %}}

使用`USE <database_name>`指定数据库

```sql
> USE NOAA_water_database
Using database NOAA_water_database

> SHOW TAG VALUES WITH KEY = "randtag"

name: h2o_quality
key       value
---       -----
randtag   1
randtag   2
randtag   3
```

{{% /tab-content %}}

{{% tab-content %}}

使用参数`db`指定数据库

```bash
~# curl -G "http://localhost:8086/query?db=NOAA_water_database&pretty=true" --data-urlencode 'q=SHOW TAG VALUES WITH KEY = "randtag"'

{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "h2o_quality",
                    "columns": [
                        "key",
                        "value"
                    ],
                    "values": [
                        [
                            "randtag",
                            "1"
                        ],
                        [
                            "randtag",
                            "2"
                        ],
                        [
                            "randtag",
                            "3"
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

#### 运行带有多个子句的`SHOW TAG VALUES`查询

```sql
> SHOW TAG VALUES ON "NOAA_water_database" WITH KEY IN ("location","randtag") WHERE "randtag" =~ /./ LIMIT 3

name: h2o_quality
key        value
---        -----
location   coyote_creek
location   santa_monica
randtag	   1
```

该查询从数据库`NOAA_water_database`的所有measurement中返回`location`或`randtag`的tag value，并且返回的数据还需满足条件：`randtag`的tag value不为空。`LIMIT`子句将返回的tag value的个数限制为3。

## `SHOW FIELD KEYS`

返回[field key](/influxdb/v1.8/concepts/glossary/#field-key)和[field value](/influxdb/v1.8/concepts/glossary/#field-value)的[数据类型](/influxdb/v1.8/write_protocols/line_protocol_reference/#data-types)。

### 语法

```sql
SHOW FIELD KEYS [ON <database_name>] [FROM <measurement_name>]
```

### 语法描述

`ON <database_name>`是可选的。如果查询中没有包含`ON <database_name>`，您必须在[CLI](/influxdb/v1.8/tools/shell/)中使用`USE <database_name>`指定数据库，或者在[InfluxDB API](/influxdb/v1.8/tools/api/#query-string-parameters)请求中使用参数`db`指定数据库。

`FROM`子句也是可选的。请查阅数据探索章节获得关于[`FROM`子句](/influxdb/v1.8/query_language/explore-data/#the-basic-select-statement)的介绍。

> **注意：**在不同的shard，field的数据类型可以不同。如果您的field中有多个数据类型，那么`SHOW FIELD KEYS`按以下顺序返回不同类型的数据：float，integer，string，boolean。

### 示例

#### 运行带有`ON`子句的`SHOW FIELD KEYS`查询

```sql
> SHOW FIELD KEYS ON "NOAA_water_database"

name: average_temperature
fieldKey            fieldType
--------            ---------
degrees             float

name: h2o_feet
fieldKey            fieldType
--------            ---------
level description   string
water_level         float

name: h2o_pH
fieldKey            fieldType
--------            ---------
pH                  float

name: h2o_quality
fieldKey            fieldType
--------            ---------
index               float

name: h2o_temperature
fieldKey            fieldType
--------            ---------
degrees             float
```

该查询返回数据库`NOAA_water_database`中每个measurement的field key以及对应的field value的数据类型。

#### 运行不带有`ON`子句的`SHOW FIELD KEYS`查询

{{< tabs-wrapper >}}
{{% tabs %}}
[CLI](#)
[InfluxDB API](#)
{{% /tabs %}}
{{% tab-content %}}

使用`USE <database_name>`指定数据库

```sql
> USE NOAA_water_database
Using database NOAA_water_database

> SHOW FIELD KEYS

name: average_temperature
fieldKey            fieldType
--------            ---------
degrees             float

name: h2o_feet
fieldKey            fieldType
--------            ---------
level description   string
water_level         float

name: h2o_pH
fieldKey            fieldType
--------            ---------
pH                  float

name: h2o_quality
fieldKey            fieldType
--------            ---------
index               float

name: h2o_temperature
fieldKey            fieldType
--------            ---------
degrees             float
```

{{% /tab-content %}}

{{% tab-content %}}

使用参数`db`指定数据库

```bash
~# curl -G "http://localhost:8086/query?db=NOAA_water_database&pretty=true" --data-urlencode 'q=SHOW FIELD KEYS'

{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "average_temperature",
                    "columns": [
                        "fieldKey",
                        "fieldType"
                    ],
                    "values": [
                        [
                            "degrees",
                            "float"
                        ]
                    ]
                },
                {
                    "name": "h2o_feet",
                    "columns": [
                        "fieldKey",
                        "fieldType"
                    ],
                    "values": [
                        [
                            "level description",
                            "string"
                        ],
                        [
                            "water_level",
                            "float"
                        ]
                    ]
                },
                {
                    "name": "h2o_pH",
                    "columns": [
                        "fieldKey",
                        "fieldType"
                    ],
                    "values": [
                        [
                            "pH",
                            "float"
                        ]
                    ]
                },
                {
                    "name": "h2o_quality",
                    "columns": [
                        "fieldKey",
                        "fieldType"
                    ],
                    "values": [
                        [
                            "index",
                            "float"
                        ]
                    ]
                },
                {
                    "name": "h2o_temperature",
                    "columns": [
                        "fieldKey",
                        "fieldType"
                    ],
                    "values": [
                        [
                            "degrees",
                            "float"
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


#### 运行带有`FROM`子句的`SHOW FIELD KEYS`查询

```sql
> SHOW FIELD KEYS ON "NOAA_water_database" FROM "h2o_feet"

name: h2o_feet
fieldKey            fieldType
--------            ---------
level description   string
water_level         float
```

该查询返回数据库`NOAA_water_database`中measurement `h2o_feet`里的fields key以及对应的field value的数据类型。

### `SHOW FIELD KEYS`的常见问题

#### `SHOW FIELD KEYS`和field的类型差异

在同一个[shard](/influxdb/v1.8/concepts/glossary/#shard)，field value的[数据类型](/influxdb/v1.8/write_protocols/line_protocol_reference/#data-types)不能发生变化，但是在不同的shard，field的数据类型可以不同。`SHOW FIELD KEYS`遍历每个shard返回与field key相关联的所有数据类型。

##### 示例

field `all_the_types`中存储了四个不同的数据类型：

```sql
> SHOW FIELD KEYS

name: mymeas
fieldKey        fieldType
--------        ---------
all_the_types   integer
all_the_types   float
all_the_types   string
all_the_types   boolean
```

**注意：**`SHOW FIELD KEYS`处理field的类型差异与`SELECT`语句不一样。有关更多信息，请参阅[InfluxDB如何处理各个分片之间的字段类型差异？](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#how-does-influxdb-handle-field-type-discrepancies-across-shards)

### 按时间过滤元查询

当您按时间过滤元查询时，您可能会看到超出指定时间的结果。元查询结果在分片级别进行过滤，因此结果的粒度与分片组的持续时间大致相同。如果您的时间过滤器跨越多个分片，您将获得所有分片的结果，这些分片在指定的时间范围内。要查看分片上的分片和时间戳，请运行`SHOW SHARDS`。要了解有关分片及其持续时间的更多信息，请参阅[建议的分片组持续时间](/influxdb/v1.8/concepts/schema_and_data_layout/#shard-group-duration-recommendations)。

下面的示例显示了如何`SHOW TAG KEYS`使用1h分片组持续时间过滤大约一小时。要过滤其他元数据，替换`SHOW TAG KEYS`与`SHOW TAG VALUES`，`SHOW SERIES`，`SHOW FIELD KEYS`，等等。

> **注意：** `SHOW MEASUREMENTS`无法按时间过滤。

#### `SHOW TAG KEYS`按时间过滤的示例

1. 在新数据库上指定分片持续时间或[更改现有的分片持续时间](/influxdb/v1.8/query_language/manage-database/#modify-retention-policies-with-alter-retention-policy)。要在创建新数据库时指定1h的分片持续时间，请运行以下命令：

    ```sh
    > CREATE database mydb with duration 7d REPLICATION 1 SHARD DURATION 1h name myRP;.
    ```

    > **注意：**最小分片持续时间为1h。

2. 通过运行`SHOW SHARDS`命令验证分片持续时间是否具有正确的时间间隔（精度）。下面的示例显示了一个小时精度的分片持续时间。

    ```sh
    > SHOW SHARDS
    name: mydb
    id database retention_policy shard_group start_time end_time expiry_time owners
    -- -------- ---------------- ----------- ---------- -------- ----------- ------
    > precision h
    ```

3. （可选）插入样本标签键。此步骤仅用于演示目的。如果您已经有tag key（或其他元数据）要搜索，请跳过此步骤。

    ```sh
    // 将样本tag为"test_key"插入到measurement"test"中，然后检查时间戳：
    > INSERT test,test_key=hello value=1
    
    > select * from test
    name: test
    time test_key value
    ---- -------- -----
    434820 hello 1
    
    // 添加时间戳分别为1h，2h,3h的新tag key
    
    > INSERT test,test_key_1=hello value=1 434819
    > INSERT test,test_key_2=hello value=1 434819
    > INSERT test,test_key_3_=hello value=1 434818
    > INSERT test,test_key_4=hello value=1 434817
    > INSERT test,test_key_5_=hello value=1 434817
    ```

4. 分片时间范围内查找tag key，请运行以下命令：

    `SHOW TAG KEYS ON database-name <WHERE time clause>` 或`SELECT * FROM measurement <WHERE time clause>`

    下面步骤使用步骤3中的测试数据。

    ```sh
    // 使用步骤3中的数据，显示当前时间到一个小时前的tag key
    > SHOW TAG KEYS ON mydb where time > now() -1h and time < now()
    name: test
    tagKey
    ------
    test_key
    test_key_1
    test_key_2
    
    // 查找一个小时前到两个小时前的tag key
    > SHOW TAG KEYS ON mydb where > time > now() -2h and time < now()-1h
    name: test
    tagKey
    ------
    test_key_1
    test_key_2
    test_key_3
    
    // 查找2个小时前到三个小时前的tag key
    > SHOW TAG KEYS ON mydb where > time > now() -3h and time < now()-2h
    name: test
    tagKey
    ------
    test_key_3
    test_key_4
    test_key_5
    
    // 对于指定的measurement，通过指定分片的时间范围来查找给定分片中的tag key
    > SELECT * FROM test WHERE time >= '2019-08-09T00:00:00Z' and time < '2019-08-09T10:00:00Z'
    name: test
    time test_key_4 test_key_5 value
    ---- ------------ ------------ -----
    434817 hello 1
    434817 hello 1
    
    // 对于指定的数据库，通过指定分片的时间范围来查找给定分片中的tag key
    > SHOW TAG KEYS ON mydb WHERE time >= '2019-08-09T00:00:00Z' and time < '2019-08-09T10:00:00Z'
    name: test
    tagKey
    ------
    test_key_4
    test_key_5
    ```
