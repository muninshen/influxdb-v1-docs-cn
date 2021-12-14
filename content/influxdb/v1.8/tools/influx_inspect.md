---
title: Influx_inspect工具
description: >
  Use the `influx_inspect` commands to manage InfluxDB disks and shards.
menu:
  influxdb_1_8:
    weight: 50
    parent: Tools
---

Influx Inspect是一个有关磁盘分片的工具，主要用于：

* 查看有关磁盘分片的详细信息。
* 将数据从分片导出到[InfluxDB行协议](/influxdb/v1.8/concepts/glossary/#influxdb-line-protocol)，然后可以将其插入回数据库中。
* 将TSM索引分片转换为TSI索引分片。

## `influx_inspect` 工具

### 语法

```
influx_inspect [ [ 命令 ] [ 选项 ] ]
```

`-help` 默认命令，并且能够显示该工具的语法和使用信息。

### `influx_inspect` 命令

`influx_inspect` 总结了以下命令，并提供了指向每个命令的详细信息的链接。

* [`buildtsi`](#buildtsi)：将内存中的分片（基于TSM）转换为TSI。
* [`deletetsm`](#deletetsm)：批量删除原始TSM文件中的度量。
* [`dumptsi`](#dumptsi)：转储有关TSI文件的低级详细信息。
* [`dumptsm`](#dumptsm)：转储有关TSM文件的低级详细信息。
* [`dumptsmwal`](#dumptsmwal): 转储WAL文件中的所有数据。
* [`export`](#export)：从InfluxDB的分片中以行协议格式导出原始数据。
* [`report`](#report)：显示分片级别报告。
* [`reporttsi`](#reporttsi)：有关测量和分片基数的报告。
* [`verify`](#verify)：验证TSM文件的完整性。
* [`verify-seriesfile`](#verify-seriesfile)：验证系列文件的完整性。
* [`verify-tombstone`](#verify-tombstone)：验证墓碑文件的完整性。

### `buildtsi`

构建基于TSI（时间序列索引）磁盘的分片索引文件和关联的序列文件。索引被写入临时位置，直到完成，然后再移至永久位置。如果发生错误，则此操作将退回到原始内存索引。

> ***注意：\*** **仅适用于离线转换。** 启用TSI后，新分片将使用TSI索引。现有分片将继续作为基于TSM的分片，直到脱机转换为止。

##### 语法

```
influx_inspect buildtsi -datadir <data_dir> -waldir <wal_dir> [ options ]
```
> **注意：**将`buildtsi`命令与您将用来运行数据库的用户帐户一起使用，或者确保在运行命令后权限匹配。

#### 选项

##### `[ -batch-size ]`

写入索引的批次大小，默认值为`10000`。

{{% warn %}}**警告：** 设置该值可能会对性能和堆大小产生不利影响。{{% /warn %}}

##### `[ -compact-series-file ]`

**不重建索引。**压缩现有的系列文件，包括脱机系列。迭代每个段中的系列，并将索引中未逻辑删除的系列重写为该段旁边的新.tmp文件。转换所有段之后，临时文件将覆盖原始段。

##### `[ -concurrency ]`

用于分片索引构建的CPU数量。默认为[`GOMAXPROCS`](https://docs.influxdata.com/influxdb/v1.8/administration/config#gomaxprocs-environment-variable)值。

##### `[ -database <db_name> ]`

指定数据库名称。

##### `-datadir <data_dir>`

`data` 目录位置。

##### `[ -max-cache-size ]`

开始拒绝写入之前，高速缓存的最大大小，此值将覆盖的配置设置 `[data] cache-max-memory-size`，默认值为`1073741824`。

##### `[ -max-log-file-size ]`

日志文件的最大大小，默认值为`1048576`。

##### `[ -retention <rp_name> ]`

保留策略的名称。

##### `[ -shard <shard_ID> ]`

分片ID。

##### `[ -v ]`

启用详细日志输出。

##### `-waldir <wal_dir>`

WAL（预写日志）文件的目录。

#### 示例

##### 转换节点上的所有分片

```
$ influx_inspect buildtsi -datadir ~/.influxdb/data -waldir ~/.influxdb/wal

```

##### 转换数据库的所有分片

```
$ influx_inspect buildtsi -database mydb -datadir ~/.influxdb/data -waldir ~/.influxdb/wal

```

##### 转换指定分片

```
$ influx_inspect buildtsi -database stress -shard 1 -datadir ~/.influxdb/data -waldir ~/.influxdb/wal
```

### `deletetsm`

Use `deletetsm -measurement` to delete a measurement in a raw TSM file (from specified shards).
Use `deletetsm -sanitize` to remove all tag and field keys containing non-printable Unicode characters in a raw TSM file (from specified shards).

`deletetsm -measurement`可以删除原始文件TSM的测量（在指定的分片上），`deletetsm -sanitize`可以从原始TSM文件（在指定的分片上）中删除所有包含不可打印的Unicode字符的标记和字段键。

{{% warn %}} **警告：** `deletetsm`只有在`influxd`服务未运行时才可以使用。{{% /warn %}}

#### 语法

````
influx_inspect deletetsm -measurement <measurement_name> [ arguments ] <path>
````
##### `<path>`

`.tsm`文件的路径，默认情况下位于`data`目录中。

指定路径时，通配符（`*`）可以替换一个或多个字符。

#### 选项

`-measurement` 或 `-sanitize` 是必须指定的。

##### `-measurement`

在TSM文件中删除的度量的名称。

##### `-sanitize`

Flag to remove all keys containing non-printable Unicode characters from TSM files.

在TSM文件中删除所有包含不可打印Unicode字符的键。

##### `-v`

可选项，启用详细日志记录。

#### 示例

##### 从单个分片删除度量

从单个分片删除测量`h2o_feet`。

```
./influx_inspect deletetsm -measurement h2o_feet /influxdb/data/location/autogen/1384/*.tsm
```

##### 从数据库中的所有分片中删除度量

从数据库中的所有分片中删除度量`h2o_feet`。

```
./influx_inspect deletetsm -measurement h2o_feet /influxdb/data/location/autogen/*/*.tsm
```

### `dumptsi`

转储有关TSI文件的低级详细信息，包括`.tsl`日志文件和`.tsi`索引文件。

#### 语法

```
influx_inspect dumptsi [ options ] <index_path>
```
如果未指定选项，则为每个文件提供摘要统计信息。

#### 选项

##### `-series-file <series_path>`

Path to the `_series` directory under the database `data` directory. Required.

数据库`data`目录中数据库目录下的`_series`路径，必选项。

##### [ `-series` ]

转储原始系列数据。

##### [ `-measurements` ]

转储原始[测量](/influxdb/v1.8/concepts/glossary/#measurement)数据。

##### [ `-tag-keys` ]

转储原始 [tag keys](/influxdb/v1.8/concepts/glossary/#tag-key).

##### [ `-tag-values` ]

转储原始 [tag values](/influxdb/v1.8/concepts/glossary/#tag-value).

##### [ `-tag-value-series` ]

为每个标签值转储原始系列。

##### [ `-measurement-filter <regular_expression>` ]

通过正则表达式过滤度量。

##### [ `-tag-key-filter <regular_expression>` ]

通过正则表达式过滤tag key。

##### [ `-tag-value-filter <regular_expresssion>` ]

通过正则表达式过滤tag value。

#### 示例

##### 指定`_series`和`index`目录的路径

```
$ influx_inspect dumptsi -series-file /path/to/db/_series /path/to/index
```

##### 指定_series目录和index文件的路径

```
$ influx_inspect dumptsi -series-file /path/to/db/_series /path/to/index/file0
```
##### 指定_series目录和多个index文件的路径

```
$ influx_inspect dumptsi -series-file /path/to/db/_series /path/to/index/file0 /path/to/index/file1 ...
```

### `dumptsm`

转储有关[TSM](/influxdb/v1.8/concepts/glossary/#tsm-time-structured-merge-tree)文件的低级详细信息，包括TSM（`.tsm`）文件和WAL（`.wal`）文件。

#### 语法

```
influx_inspect dumptsm [ options ] <path>
```

##### `<path>`

`.tsm`文件的路径，默认情况下位于`data`目录中。

#### 选项

##### [ `-index` ]

转储原始索引数据，默认值为`false`。

##### [ `-blocks` ]

转储原始block数据。默认值为`false`。

##### [ `-all` ]

转储所有数据，警告：这可能会打印很多信息，默认值为`false`。

##### [ `-filter-key <key_name>` ]

仅显示与此key子字符串匹配的索引数据和block数据，默认值为`""`。

### `dumptsmwal`

仅转储一个或多个WAL（`.wal`）文件中的所有条目，不包括TSM（`.tsm`）文件。

#### 语法

```
influx_inspect dumptsmwal [ options ] <wal_dir>
```

#### 选项

##### [ `-show-duplicates` ]

显示具有重复或无序时间戳key。如果用户使用客户端设置的时间戳，则可以写入具有相同时间戳（或时间递减时间戳）的多个数据点。

### `export`

以InfluxDB行协议数据格式导出所有TSM文件和写入的所有WAL文件，可以使用[influx -import](/influxdb/v1.8/tools/shell/#import-data-from-a-file-with-import)命令导入此输出文件。

#### 语法

```
influx_inspect export [ options ]
```

#### 选项

##### [ `-compress` ]

使用gzip压缩来压缩输出，默认值为`false`。

##### [ `-database <db_name>` ]

指定导出的数据库的名称。默认值为`""`。

##### `-datadir <data_dir>`

`data`目录的路径，默认值为`"$HOME/.influxdb/data"`。

##### [ `-end <timestamp>` ]

时间范围截止的时间戳。必须为[RFC3339格式](https://tools.ietf.org/html/rfc3339)。

RFC3339需要非常特定的格式，例如，要表示没有时区偏移量（UTC+0），必须在秒后添加Z或+00:00，有效的RFC3339格式的示例包括：

**无偏移**

```
YYYY-MM-DDTHH:MM:SS+00:00
YYYY-MM-DDTHH:MM:SSZ
YYYY-MM-DDTHH:MM:SS.nnnnnnZ (fractional seconds (.nnnnnn) are optional)
```

**有偏移**

```
YYYY-MM-DDTHH:MM:SS-08:00
YYYY-MM-DDTHH:MM:SS+07:00
```

##### [ `-lponly` ]
仅以行协议格式输出数据，不包含注释或数据定义语言（DDL），例如`CREATE DATABASE`。

##### [ `-out <export_dir>` ]

导出文件的位置，默认值为`"$HOME/.influxdb/export"`。

##### [ `-retention <rp_name> ` ]

[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)的名称，默认值为`""`。

##### [ `-start <timestamp>` ]

时间范围开始的时间戳，时间戳字符串必须为[RFC3339格式](https://tools.ietf.org/html/rfc3339)。

##### [ `-waldir <wal_dir>` ]

[WAL](/influxdb/v1.8/concepts/glossary/#wal-write-ahead-log)目录的路径。默认值为`"$HOME/.influxdb/wal"`。

#### 示例

##### 导出所有数据库并压缩输出

```bash
influx_inspect export -compress
```

##### 从指定的数据库和保留策略导出数据

```bash
influx_inspect export -database mydb -retention autogen
```

##### 输出文件

```bash
# DDL
CREATE DATABASE MY_DB_NAME
CREATE RETENTION POLICY autogen ON MY_DB_NAME DURATION inf REPLICATION 1

# DML
# CONTEXT-DATABASE:MY_DB_NAME
# CONTEXT-RETENTION-POLICY:autogen
randset value=97.9296104805 1439856000000000000
randset value=25.3849066842 1439856100000000000
```

### `report`

显示所有分片的系列元数据，默认位置是`$HOME/.influxdb`。

#### 语法

```
influx_inspect report [ options ]
```

#### 选项

##### [ `-pattern "<regular expression/wildcard>"` ]

匹配包含文件的正则表达式或通配符模式，默认值为`""`。

##### [ `-detailed` ]

报告详细基数估计，默认值为`false`。

##### [ `-exact` ]

确切基数的计数而不是估计，默认值为`false`。注意：这会占用大量内存。

### `reporttsi`

此命令执行以下操作

* 计算数据库中的精确的总系列基数。
* 通过度量将基数分组，并打印这些基数值。
* 打印数据库中每个分片精确的总基数。
* 为每个分片细分分片中每个度量的精确基数。
* （可选）将每个分片中的结果限制为“top n”。

`reporttsi`命令主要用于基数发生变化的情况，尚不清楚是哪个度量值导致此变化，以及*何时* 发生该变化。估算每个度量和每个分片的精确基数细分将有助于回答这些问题。

### 用法

```
influx_inspect reporttsi -db-path <path-to-db> [ options ]
```

#### 选项

##### `-db-path <path-to-db>`

数据库的路径。

##### [ `-top <n>` ]

将结果限制为每个分片中指定的top n。

#### 性能（Performance）

该`reporttsi`命令使用简单的slice/maps来存储低基数度量，从而节省了初始化位图的成本。对于高基数的度量，该工具使用 [roaring bitmaps](https://roaringbitmap.org/)，这意味着在运行该工具时，我们不需要在堆上存储所有系列ID。工具运行时，会自动完成从低基数表示到高基数表示的转换。

### `verify`

验证TSM文件的完整性。

#### 语法

```
influx_inspect verify [ options ]
```
#### 选项

##### `-dir <storage_root>`

存储根目录的路径。默认值为`"/root/.influxdb"`。

### `verify-seriesfile`

验证系列文件的完整性。

#### 语法

```
influx_inspect verify-seriesfile [ options ]
```

#### 选项

##### [ `-c <number>` ]

指定要为此命令运行的并发数。默认值等于GOMAXPROCS的值。如果性能受到不利影响，则可以设置较低的值。

##### [ `-dir <path>` ]

指定根数据路径。默认为`~/.influxdb/data`。

##### [ `-db <db_name>` ]

将验证series文件限制为数据目录中的指定数据库。

##### [ `-series-file <path>` ]

特定系列文件的路径；覆盖`-db`和`-dir`。

##### [ `-v` ]

启用详细日志记录。

### `verify-tombstone`

验证墓碑的完整性。

#### 语法

```
influx_inspect verify-tombstone [ options ]
```

查找并验证指定目录路径（默认为`~/.influxdb/data`）下的所有逻辑删除，文件被串行验证。

#### 选项

##### [ `-dir <path>` ]

指定要为此命令运行的并发数。默认值等于GOMAXPROCS的值。如果性能受到不利影响，则可以设置较低的值。

##### [ `-v` ]

启用详细日志记录。确认文件正在验证中，每500万个逻辑删除条目显示一次进度。

##### [ `-vv` ]

启用非常详细的日志记录。在逻辑删除文件中显示每个系列键和时间范围的进度。自纪元（`1970-01-01T00:00:00Z`）起，时间戳以纳秒为单位显示。

##### [ `-vvv` ]

启用非常详细的日志记录。在逻辑删除文件中显示每个系列键和时间范围的进度。时间戳以[RFC3339格式](https://tools.ietf.org/html/rfc3339)显示，精度为纳秒。

> **有关详细日志记录的注意事项：**较高的详细级别会覆盖较低的级别。

## 注意事项

导出TSM分片时，系统无权访问metastore。这样，它始终会创建无限期且复制因子为1的[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)。如果最终用户要导入群集或需要不同的保留期限，则可能需要在重新导入之前进行更改。