---
title: InfluxDB OSS 配置
description: >
  Learn about InfluxDB OSS configuration settings and environment variables.
menu:
  influxdb_1_8:
    name: InfluxDB 配置
    weight: 10
    parent: 管理
---

Influxdb开源（OSS）配置文件包含特定的本地节点配置设置

#### Content

* [配置概述](#configuration-overview)
* [环境变量](#environment-variables)
  * [InfluxDB 环境变量 (`INFLUXDB_*`)](#influxdb-environment-variables-influxdb)
  * [`GOMAXPROCS` 环境变量](#gomaxprocs-environment-variable)
* [使用配置文件](#using-the-configuration-file)
* [配置设定](#configuration-settings)
  * [全局设置](#global-settings)
  * [Meta存储 `[meta]`](#metastore-settings)
  * [数据 `[data]`](#data-settings)
  * [查询管理 `[coordinator]`](#query-management-settings)
  * [保留策略 `[retention]`](#retention-policy-settings)
  * [Shard 预创建 `[shard-precreation]`](#shard-precreation-settings)
  * [监控方式 `[monitor]`](#monitoring-settings)
  * [HTTP 端点 `[http]`](#http-endpoints-settings)
  * [Subscriptions订阅内容 `[subscriber]`](#subscription-settings)
  * [Graphite `[[graphite]]`](#graphite-settings)
  * [CollectD `[[collectd]]`](#collectd-settings)
  * [OpenTSB `[[opentsdb]]`](#opentsdb-settings)
  * [UDP `[[udp]]`](#udp-settings)
  * [连续查询 `[continuous_queries]`](#continuous-queries-settings)
  * [TLS `[tls]`](#transport-layer-security-tls-settings)

## 配置概述

使用配置文件（`inflxudb.conf`）和环境变量配置inflxudb，如果不取消注释配置选项，则系统将使用其默认设置，本文档中均为默认配置

指定持续时间的配置设置支持以下持续时间单位

- `ns` _(纳秒)_
- `us` or `µs` _(微秒)_
- `ms` _(毫秒)_
- `s` _(秒)_
- `m` _(分钟)_
- `h` _(小时)_
- `d` _(天)_
- `w` _(周)_

>**Note:** 此处记录了配置文件设置以获取最新的官方版本-GitHub上的`示列配置文`件可能会稍微更新

## 环境变量

可以在配置文件或者环境变量中指定配置文件中的所有配置设置，环境变量将覆盖配置文件中的等效设置，如果未在配置文件或环境变量中指定配置选项，则influxdb使用其内部默认配置

> ***Note:*** 如果已经设置了环境变量，那么将忽略配置文件中的等效配置设置

### InfluxDB 环境变量 (`INFLUXDB_*`)

以下记录了InfluxDB环境变量以及相应的配置文件设置,所有特定的Influxdb环境变量都以`INFLUXDB_`为前缀

环境变量

> ***Note:*** GOMACPROCS环境变量不能像其他环境变量一样使用InfluxDB配置文件来设置。


## 使用配置文件

Influxdb系统具有配置文件中所有设置的内部默认值，要查看默认配置设置，请使用`inflxudb config`命令

本地Influxdb配置文件位于以下位置

- Linux: `/etc/influxdb/influxdb.conf`
- macOS: `/usr/local/etc/influxdb.conf`

注释掉的配置被设置为内部系统默认设置，未注释的设置将覆盖内部默认设置，请注意，本地配置文件不需要包括每个配置设置

使用配置文件启动inflxudb的方法有两种

* 使用该-config选项将过程指向配置文件，例如
  
  ```bash
    influxd -config /etc/influxdb/influxdb.conf
  ```
* 将环境变量设置为`INFLUXDB_CONFIG_PATH`配置文件路径，然后开始该过程，例如：
  
    ```
  echo $INFLUXDB_CONFIG_PATH
    /etc/influxdb/influxdb.conf
  
    influxd
  ```

Influxdb首先检查-config选项,然后检查环境变量


## 配置设定

> **Note:**
> 要允许多个配置的config部分中设置或者覆盖设置`[[double_brackets]]`标题中具有任何部分都支持多个配置，必须以序号指定所需的配置，例如，对于一组`[[graphite]]`环境变量，在环境变量中的配置设置名称前加上相关的位置编号（在这种情况下：`0`)：
> 
> INFLUXDB_GRAPHITE_0_BATCH_PENDING
> INFLUXDB_GRAPHITE_0_BATCH_SIZE
> INFLUXDB_GRAPHITE_0_BATCH_TIMEOUT
> INFLUXDB_GRAPHITE_0_BIND_ADDRESS
> INFLUXDB_GRAPHITE_0_CONSISTENCY_LEVEL
>INFLUXDB_GRAPHITE_0_DATABASE
>
>对于配置文件中的第N个Graptite配置，相关的环境变量格式为 `INFLUXDB_GRAPHITE_(N-1)_BATCH_PENDING`.
>对于配置文件每个部分，编号都是从零重新开始.

## 全局设置

### `reporting-disabled = false`

InfluxData 使用从运行中的Influxdb节点资源报告的数据来主要跟踪不同的Influxdb版本的采用率，这些数据有助于inflxuData支持Influxdb的持续开发

该reporting-disabled` 选项每24小时选项将数据报告切换为`usage.inflxudata.com`，每个报告均包含随机生成的标识符，操作系统，体系结构，Influxdb版本以及`数据库`数量，measurement和唯一series，将此选项设置为true将禁用报告

>**Note:** 从未传输过用户数据库中的数据

环境变量: `INFLUXDB_REPORTING_DISABLED`

### `bind-address = "127.0.0.1:8088"`

用于RPC服务进行备份和还原的绑定地址

```
环境变量： INFLUXDB_BIND_ADDRESS
```

## Metastore 设置

### `[meta]`

本节控制Influxdb元存储的参数，该meta存储有关用户，数据库，保留策略，分片和连续查询的信息；

### `dir = "/var/lib/influxdb/meta"`

元数据/RAFT数据的存储目录，meta目录中的文件包含`meta.db `InfluxDB  metastore 文件

>**Note:** macOS安装的默认目录是 `/Users/<username>/.influxdb/meta`

环境变量: `INFLUXDB_META_DIR`

### `retention-autocreate = true`

启动自动创建[`DEFAULT` retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)，`autogen`,创建数据库时，保留策略“autogen”具有无限的持续时间，也设置为 数据库的`default`默认保留策略，在写入或查询时未指定保留策略则使用该保留策略

禁止此设置以防止在创建数据库时创建此保留策略；

环境变量: `INFLUXDB_META_RETENTION_AUTOCREATE`

### `logging-enabled = true`

启用messages的日志记录

环境变量： `INFLUXDB_META_LOGGING_ENABLED`

## 数据设置

### `[data]`

这些`[data]`设置控制influxdb的实际shards数据存储在何处以及从预写入日志（WAL）中刷新它们，`dir`可能需要将其更改为适合你系统的位置，但是WAL设置是高级配置，默认值适用于大多数系统

#### `dir = "/var/lib/influxdb/data"`

TSM引擎存储TSM文件的Influxdb目录，此目录可能会更改

>**Note:** 对于MACOS安装，默认的WAL目录为 `/Users/<username>/.influxdb/data`.

环境变量: `INFLUXDB_DATA_DIR`

#### `wal-dir = "/var/lib/influxdb/wal"`

预写日志（WAL）文件的目录位置.

>**Note:** 对于MACOS安装，默认的WAL目录为 `/Users/<username>/.influxdb/wal`.

环境变量 `INFLUXDB_DATA_WAL_DIR`

#### `wal-fsync-delay = "0s"`

写操作在同步前等待的时间。使用大于0的持续时间批处理多个fsync调用。 这对于速度较慢的磁盘或遇到[WAL](/influxdb/v1.8/concepts/glossary/#wal-write-ahead-log)写争用时非常有用。 默认值`0`表示每次写入WAL时同步。

>**Note:** 对于非SSD磁盘，Inflxudata建议使用0ms-范围内的值100ms.

环境变量: `INFLUXDB_DATA_WAL_FSYNC_DELAY`

#### `index-version = "inmem"`

用于新分片的分片索引的类型，默认（`inmem`）索引是在启动时重新创建的内存中索引，要启用基于时间序列索引（TSI）磁盘的索引，请将其值设置为`Tsi1`.

环境变量: `INFLUXDB_DATA_INDEX_VERSION`

#### `trace-logging-enabled = false`

在TSM引擎和WAL中启用其他调试信息的详细日志记录，跟踪日志记录为调试TSM引擎问题提供了更有用的输出

环境变量: `INFLUXDB_DATA_TRACE_LOGGING_ENABLED`

#### `query-log-enabled = true`

在执行前启用已解析查询的日志记录，查询日志对于故障排查很有用.但会记录查询中包含的所有敏感数据

环境变量: `INFLUXDB_DATA_QUERY_LOG_ENABLED`

#### `validate-keys = false`

验证传入的写操作以确保keys仅具有有效的Unicode字符.由于必须要检查每个密钥，因此此设置会产生少量的开销


### TSM引擎的设置

#### `cache-max-memory-size = "1g"`

分片缓存开始拒绝写入之前可以达到的最大大小.

有效的内存大小后缀: `k`, `m`, or `g` (不区分大小写的1024 = 1k).没有大小后缀的值以字节为单位

环境变量: `INFLUXDB_DATA_CACHE_MAX_MEMORY_SIZE`

#### `cache-snapshot-memory-size = "25m"`

引擎将快照缓存并将其写入TSM文件以释放内存的大小。

有效的内存大小后缀为: `k`, `m`, or `g` (不区分大小写的1024 = 1k).没有大小的后缀已字节为单位

环境变量: `INFLUXDB_DATA_CACHE_SNAPSHOT_MEMORY_SIZE`

#### `cache-snapshot-write-cold-duration = "10m"`

如果分片尚未收到写入或删除，则引擎将对缓存进行快照并将其写入新的TSM文件的时间间隔

环境变量： `INFLUXDB_DATA_CACHE_SNAPSHOT_WRITE_COLD_DURATION`

#### `compact-full-write-cold-duration = "4h"`

如果TSM引擎未收到写入或删除操作，则该时间间隔会将所有的TSM文件压缩到一个分片中。

环境变量: `INFLUXDB_DATA_COMPACT_FULL_WRITE_COLD_DURATION`

#### `max-concurrent-compactions = 0`

一次可以运行的并发完全压缩和级别[压缩](/influxdb/v1.8/concepts/storage_engine/#compactions)的最大数量.默认值`0`导致在运行时将50%的CPU内核用于压缩,如果明确设置,则用于压缩的核心数将限制为指定值,此设置不适用于缓存快照

有关`GOMAXPROCS`环境变量的更多信息，请参见本页上的 see [`GOMAXPROCS` 环境变量 ](#gomaxprocs-environment-variable) .。

环境变量: `INFLUXDB_DATA_MAX_CONCURRENT_COMPACTIONS`

#### `compact-throughput = "48m"`

TSM压缩每秒写入磁盘的最大字节数，默认值为`"48m"`(4800万)，请注意，允许以较大的值发生短暂的产生`compact-throughput-burst`。

环境变量: `INFLUXDB_DATA_COMPACT_THROUGHPUT`  

#### `compact-throughput-burst = "48m"`

短暂突发期间，TSM压缩每秒写入磁盘的最大字节数，默认值为 `"48m"` (4800万).

环境变量: `INFLUXDB_DATA_COMPACT_THROUGHPUT_BURST`

#### `tsm-use-madv-willneed = false`

如果为`true`.则MMap Advise值会`MADV_WILINEED`向内核建议有关如何根据输入/输出分页处理映射的内存区域以及如何在不久的将来针对TSM文件访问映射的内存区域。由于此设置在某些内核（包括Centos和RHEL）上存在问题，因此默认值为false。true在某些情况下，将该值更改为可能会帮助具有慢速磁盘的用户

环境变量: `INFLUXDB_DATA_TSM_USE_MADV_WILLNEED`

### 内存(`inmem`) 索引设置

#### `max-series-per-database = 1000000`

删除写入之前，每个数据库允许的最大series数.默认设置为1000000（一百万），将设置更改0为允许每个数据库无限数量的series

如果某个point 导致数据库中的series数超过max-series-per-database，则Influxdb不会写入该Point，它会返回500并显示以下错误：

```
{"error":"max series per database exceeded: <series>"}
```
> **Note:** series数超过的任何现有数据库max-series-per-database将继续接受对现有series的写入，但是创建新series的写入将失败。

环境变量: `INFLUXDB_DATA_MAX_SERIES_PER_DATABASE`

#### `max-values-per-tag = 100000`

每个 [tag values](/influxdb/v1.8/concepts/glossary/#tag-value) 允许最大 [tag key](/influxdb/v1.8/concepts/glossary/#tag-key)数量.
默认值为 `100000` (十万).
将此设置为 `0` 以允许每个 tag values 有无限个 tag key.
如果 tag value导致 tag 关键字的tag values 超过`max-values-per-tag`最大值，,则 InfluxDB 将不会写入该point,并返回 `partial write` 错误.

环境变量: `INFLUXDB_DATA_MAX_VALUES_PER_TAG`

### TSI (`tsi1`) 索引设置

#### `max-index-log-file-size = "1m"`

索引预写日志（WAL）文件将压缩为索引文件时的阈值（以字节为单位），较小的size 将导致日志文件被更快的压缩，并导致较低的堆使用率，但以写吞吐量为代价，较高的sizes将被更不频繁的压缩，在内存中存储更多的series，并提供更高的写入吞吐量。有效的大小后缀k,m或g（不区分大小写，1024k），没有大小后缀的值以字节为单位

环境变量: `INFLUXDB_DATA_MAX_INDEX_LOG_FILE_SIZE`

#### `series-id-set-cache-size = 100`

TSI索引中用于存储先前计算的series结果的内部缓存的大小。高速缓存的结果将从高速缓存中快速返回，而不是在执行具有匹配的tag key值predicate的后续查询时需要重新计算。将此值设置为0将会禁用缓存，这可能会导致查询性能问题。仅当已知数据库的所有measurement中经常使用的tag key-value的集合大于100时，才应增加此值。缓存大小的增加可能会导致堆使用率的增加。

环境变量: `INFLUXDB_DATA_SERIES_ID_SET_CACHE_SIZE`

## 查询管理设置

### `[coordinator]`

本节包含查询管理的配置设置t.
有关管理查询的更多信息, 请参考 [查询管理](/influxdb/v1.8/troubleshooting/query_management/).

#### `write-timeout = "10s"`

写入请求等待直到”超时“错误返回给调用方的持续时间，默认值为10秒

环境变量: `INFLUXDB_COORDINATOR_WRITE_TIMEOUT`

#### `max-concurrent-queries = 0`

最大并发查询数，0表示无限制，默认值为0

环境变量: `INFLUXDB_COORDINATOR_MAX_CONCURRENT_QUERIES`

#### `query-timeout = "0s"`

查询操作超时阈值，超时后，生成一条慢查询日志，0表示禁用该功能，默认值为0秒

环境变量: `INFLUXDB_COORDINATOR_QUERY_TIMEOUT`

#### `log-queries-after = "0s"`

在Influxdb记录带有`Detected slow query`消息的查询之前，查询可以达到的最大持续时间，默认设置（"0"）从不告诉Influxdb记录查询，此设置是持续时间

环境变量: `INFLUXDB_COORDINATOR_LOG_QUERIES_AFTER`

#### `max-select-point = 0`

`select`语句可以处理的最大[series](/influxdb/v1.8/concepts/glossary/#series) ，0表示无限制，默认值为0

环境变量 `INFLUXDB_COORDINATOR_MAX_SELECT_POINT`

#### `max-select-series = 0`

一次select操作可以处理最大的时间序列线数量，0表示无限制，默认值为0

环境变量: `INFLUXDB_COORDINATOR_MAX_SELECT_SERIES`

#### `max-select-buckets = 0`

一次select查询可以处理最大的`GROUP by time()`时间段的最大数量，默认设置（`0`)允许查询处理的无限数量

环境变量: `INFLUXDB_COORDINATOR_MAX_SELECT_BUCKETS`

-----

## Retention policy 设置

### `[retention]`

这些 `[retention]`设置控制用于删除旧数据的保留策略的执行.

#### `enabled = true`

设置为`false`防止Influxdb强制执行保留策略

环境变量: `INFLUXDB_RETENTION_ENABLED`

#### `check-interval = "30m0s"`

Influxdb检查以强制执行保留策略的时间间隔.

环境变量: `INFLUXDB_RETENTION_CHECK_INTERVAL`

-----

## Shard 重建设置

### `[shard-precreation]`

这些 `[shard-precreation]`设置控制shards 的增量，以便在数据到达之前就可以使用shard，只有在创建后将具有开始时间和结束时间的shards才会被创建，永远不会预先创建全部或者部分过去的shards

#### `enabled = true`

确定是否启动分片增量服务设置.

环境变量: `INFLUXDB_SHARD_PRECREATION_ENABLED`

#### `check-interval = "10m"`

运行检查以预创建新shards的时间间隔.

环境变量: `INFLUXDB_SHARD_PRECREATION_CHECK_INTERVAL`

#### `advance-period = "30m"`

Influxdb为预先创建shards未来时间期限，30m默认值应该适用于大多数系统，将此设置增加太大会导致效率低下

环境变量: `INFLUXDB_SHARD_PRECREATION_ADVANCE_PERIOD`

## Monitoring 配置信息

### `[monitor]`

该 `[monitor]`节设置控制 InfluxDB 系统自我检测

默认情况下，inflxuDB将数据写入 `_internal`数据库，如果数据库不存在，Influxdb会自动创建它，在`DEFAULT`上保留策略`_internal`数据库为七天，如果要使用7天数据保留策略以外的保留策略，则必须要创建它

#### `store-enabled = true`

设置为false禁用内部记录统计信息，如果设置为false，将大大增加检测安装问题的难度；

环境变量: `INFLUXDB_MONITOR_STORE_ENABLED`

#### `store-database = "_internal"`

记录的统计信息的目标数据库

环境变量： `INFLUXDB_MONITOR_STORE_DATABASE`

#### `store-interval = "10s"`

Influxdb记录统计信息的时间间隔，默认值为每十秒钟（10s）

环境变量: `INFLUXDB_MONITOR_STORE_INTERVAL`

## HTTP 端点设置

### `[http]`

### 该 `[http]`部分设置控制Influxdb如何配置HTTP端点，这些是将数据传入和传出Influxdb的主要机制，

关于此部分中的设置以启用HTTPS和身份验证，有关启用HTTPS和身份验证的详细信息,请参阅 [身份验证 与授权](/influxdb/v1.8/administration/authentication_and_authorization/).

#### `enabled = true`

确定是否启用HTTP端点，要禁用对HTTP端点的访问，请将值设置为false，请注意，Influxdb命令行界面（CLI）使用Influxdb API连接到数据库

环境变量: `INFLUXDB_HTTP_ENABLED`

#### `flux-enabled = false`

确定是否启用Flux查询端点，要启用Flux查询，请将值设置为`true`.

环境变量: `INFLUXDB_HTTP_FLUX_ENABLED`

#### `bind-address = ":8086"`

HTTP服务使用的绑定地址（端口）

环境变量: `INFLUXDB_HTTP_BIND_ADDRESS`

#### `auth-enabled = false`

确定是否通过HTTP和HTTPS启用用户身份验证，要进行身份验证，请将值设置为`true`.

环境变量: `INFLUXDB_HTTP_AUTH_ENABLED`

#### `realm = "InfluxDB"`

发出基本身份验证质询时发回的默认领域，领域是HTTP端点使用JWT领域

环境变量: `INFLUXDB_HTTP_REALM`

#### `log-enabled = true`

确定是否启用了HTTP请求日志记录。 若要禁用日志记录，请将该值设置为`false`

环境变量 : `INFLUXDB_HTTP_LOG_ENABLED`

#### `suppress-write-log = false`

确定启用日志后是否应禁止HTTP写请求日志

#### `access-log-path = ""`

访问日志的路径，该路径确定是否启用详细的日志记录，`log-enabled=true`，指定启用后是否将HTTP请求日志记录写入指定的路径，如果Influxdb无法访问指定的路径，它将记录错误并退回`stderr`,启用HTTP请求日志记录后，此选项指定应在其中写入日志条目的路径，如果为指定，则默认写入`stderr`，这会将HTTP日志与内部的Influxdb日志混合在一起，如果Influxdb无法指定的路径，它将记录一个错误并回退到将请求写入`stderr`

环境变量: `INFLUXDB_HTTP_ACCESS_LOG_PATH`

#### `access-log-status-filters = []`

过滤应记录的请求，每个过滤器都具有模式`nnn`，`nnx`或者`nxx`,其中`n`是数字，并且`x`是任何数字的通配符，要过滤所有`5xx`响应，请使用字符串`5xx`，如果使用多个过滤器，则仅需要匹配一个，默认值为没有的过滤器，每个请求都就被打印，

环境变量： `INFLUXDB_HTTP_ACCESS_LOG_STATUS_FILTERS_x`

##### 例子

###### 该配置用来社会访问日志状态过滤器

`access-log-status-filters = ["4xx", "5xx"]`

`"4xx"` 在数组位置 `0`
`"5xx"` 在数组位置 `1`

###### 使用环境变量设置访问日志状态过滤器

访问日志状态过滤器输入值是一个数组，使用环境变量时，可以按如下方式提供值

`INFLUXDB_HTTP_ACCESS_LOG_STATUS_FILTERS_0=4xx`

`INFLUXDB_HTTP_ACCESS_LOG_STATUS_FILTERS_1=5xx`

环境变量末尾的“n”表示条目的数组位置


#### `write-tracing = false`

确定是否启用详细写日志记录，设置为`True`启用写入有效负载的日志记录，如果设置为`true`，它将复制日志中的每个write语句，因此不建议一般使用

环境变量： `INFLUXDB_HTTP_WRITE_TRACING`

#### `pprof-enabled = true`

确定是否`/net/http/pprof`启用HTTP端点，对于故障排除和监视很有用

环境变量: `INFLUXDB_HTTP_PPROF_ENABLED`

#### `pprof-auth-enabled = false`

在`/debug`端点上启用身份验证，如果启用，则用户需要管理员权限才能访问以下端点:

- `/debug/pprof`
- `/debug/requests`
- `/debug/vars`

如果将`auth-enable`或`pprof-enabled`设置为，则此设置无效false

环境变量: `INFLUXDB_HTTP_PPROF_AUTH_ENABLED`

#### `debug-pprof-enabled = false`

启用默认`/pprof`端点并绑定`localhost:6060`.对于调试启动性能问题很有用

环境变量: `INFLUXDB_HTTP_DEBUG_PPROF_ENABLED`

#### `ping-auth-enabled = false`

启用该认证`/piing./metrics`和过时`/status`的端点，如果`auth-enable`设置为，则此设置无效`false`

环境变量: `INFLUXDB_HTTP_PING_AUTH_ENABLED`

#### `http-headers`

用户提供的HTTP响应标头，配置本节返回安全头如X-Frame-Options或Content Security Policy 需要的地方.

例:

```toml
[http.headers]
  X-Frame-Options = "DENY"
```

#### `https-enabled = false`

确定是否启用HTTPS，要启用HTTPS，请将值设置为`true`

环境变量: `INFLUXDB_HTTP_HTTPS_ENABLED`

#### `https-certificate = "/etc/ssl/influxdb.pem"`

启用HTTPS时要使用SSL证书文件的路径.

环境变量: `INFLUXDB_HTTP_HTTPS_CERTIFICATE`

#### `https-private-key = ""`

使用单独的私钥位置。如果仅`https-certificate`指定，则该httpd服务将尝试从`https-certificate`文件中加载私钥。如果`https-private-key`指定了单独的文件，则httpd服务将从文件中加载私钥`https-private-key`。

环境变量: `INFLUXDB_HTTP_HTTPS_PRIVATE_KEY`

#### `shared-secret = ""`

用于使用JWT令牌验证公共API请求的共享机密.

环境变量: `INFLUXDB_HTTP_SHARED_SECRET`

#### `max-row-limit = 0`

系统在非分块查询中可以返回最大行数，默认设置（0）允许无限制的行数，如果查询结果超过指定值，则InflxuDB"partial"：true在相应正文中包含一个标记

环境变量: `INFLUXDB_HTTP_MAX_ROW_LIMIT`

#### `max-connection-limit = 0`

一次可以打开的最大连接数，超出限制的新连接将被删除，默认值0禁用该限制

环境变量: `INFLUXDB_HTTP_MAX_CONNECTION_LIMIT`

#### `unix-socket-enabled = false`

通过UNIX域套接字启用http服务，要通过UNIX域套接字启用HTTP服务，请将值设置为true

环境变量: `INFLUXDB_HTTP_UNIX_SOCKET_ENABLED`

#### `bind-socket = "/var/run/influxdb.sock"`

UNIX域套接字的路径

环境变量: `INFLUXDB_HTTP_UNIX_BIND_SOCKET`

#### `max-body-size = 25000000`

客户端请求正文的最大大小（以字节为单位）。当HTTP客户端发送的数据超过配置的最大大小时，将413 Request Entity Too Large返回HTTP响应。要禁用限制，请将值设置为0。

环境变量： `INFLUXDB_HTTP_MAX_BODY_SIZE`

#### `max-concurrent-write-limit = 0`

可以同时处理的最大写入数.要禁用限制，请将此值设置为0

环境变量: `INFLUXDB_HTTP_MAX_CONCURRENT_WRITE_LIMIT`

#### `max-enqueued-write-limit = 0`

排队等待处理的最大写入数，要禁用限制，请将此值设置为0

环境变量: `INFLUXDB_HTTP_MAX_ENQUEUED_WRITE_LIMIT`

#### `enqueued-write-timeout = 0`
写入等待在列队中等待的最大持续时间，要禁用限制，请将其设置为0或将max-concurrent-write-limit值设置为0.

环境变量: `INFLUXDB_HTTP_ENQUEUED_WRITE_TIMEOUT`

#### `[http.headers]`

Use the `[http.headers]` section to configure user-supplied HTTP response headers.

```
# [http.headers]
#   X-Header-1 = "Header Value 1"
#   X-Header-2 = "Header Value 2"
```

-----

## Logging 设定

### `[logging]`

控制记录器如何将日志发送到输出

#### `format = "auto"`

确定要用于日志的日志编码器，有效值为auto（默认）logfmt，和json选项时，如果输出到TTY设备（例如终端）则使用更加有好的控制台编码，如果输出的是文件，则auto选项使用logfmt编码，在logfmt和json选项时是用于与外部工具的集成非常有用

环境变量: `INFLUXDB_LOGGING_FORMAT`

#### `level = "info"`

要发出的日志级别，有效值为error，warn，info（默认值），和debug，等于或高于指定级别的日志被发出

环境变量: `INFLUXDB_LOGGING_LEVEL`

#### `suppress-logo = false`

禁止启动程序时打印的微标输出，如果STDOUT不是TTY，则将始终显示微标

环境变量: `INFLUXDB_LOGGING_SUPPRESS_LOGO`

-----

## Subscription 设定

### `[subscriber]`

该 `[subscriber]部分控制 [Kapacitor](/kapacitor/v1.4/) 如何接受数据

#### `enabled = true`

确定是否启用订户服务，要禁用订户服务，请将值设置为false.

环境变量: `INFLUXDB_SUBSCRIBER_ENABLED`

#### `http-timeout = "30s"`

HTTP写入订阅服务器的持续时间一直持续到超时.

环境变量: `INFLUXDB_SUBSCRIBER_HTTP_TIMEOUT`

#### `insecure-skip-verify = false`

确定是否允许与订户的不安全的HTTPS连接，使用自签名证书进行测试时，这很有用

环境变量: `INFLUXDB_SUBSCRIBER_INSECURE_SKIP_VERIFY`

#### `ca-certs = ""`

PEM编码的CA certs文件的路径，如果该值为空字符串（"则将使用默认的系统证书"）.

环境变量: `INFLUXDB_SUBSCRIBER_CA_CERTS`

#### `write-concurrency = 40`

处理写通道的写程序

#### `write-buffer-size = 1000`

The number of in-flight writes buffered in the write channel.

环境变量： `INFLUXDB_SUBSCRIBER_WRITE_BUFFER_SIZE`

-----

## Graphite 设置

### `[[graphite]]`

本部分控制一个或多个Graphite数据的侦听器。

#### `enabled = false`

设置 为 `true`  表示启用 Graphite 输入.

环境变量: `INFLUXDB_GRAPHITE_0_ENABLED`

#### `database = "graphite"`

写入数据库的名称

环境变量: `INFLUXDB_GRAPHITE_0_DATABASE`

#### `retention-policy = ""`

相关的保留策略，空字符串等效于数据库的DEFAULT保留策略.

环境变量: `INFLUXDB_GRAPHITE_0_RETENTION_POLICY`

#### `bind-address = ":2003"`

默认端口.

环境变量 `INFLUXDB_GRAPHITE_0_BIND_ADDRESS`

#### `protocol = "tcp"`

设置为 `tcp` 或 `udp`.

环境变量: `INFLUXDB_GRAPHITE_PROTOCOL`

#### `consistency-level = "one"`

必须确认写入的节点数，如果不满足要求，则返回值将是partial, write批处理中的某些点失败或批处理中的write failure所有点都失败。

环境变量: `INFLUXDB_GRAPHITE_CONSISTENCY_LEVEL`

接下来的三个设置控制批处理的工作方式。您应该启用此功能，否则可能会丢失指标或性能不佳。如果有很多进来，批处理将缓冲内存中的点。

#### `batch-size = 5000`

如果有这么多点被缓冲，输入将被刷新.

环境变量: `INFLUXDB_GRAPHITE_BATCH_SIZE`

#### `batch-pending = 10`

内存中可能待处理的批处理数

环境变量: `INFLUXDB_GRAPHITE_BATCH_PENDING`

#### `batch-timeout = "1s"`

即使输入尚未达到配置的批处理大小，它也会至少经常刷新一次

环境变量: `INFLUXDB_GRAPHITE_BATCH_TIMEOUT`

#### `udp-read-buffer = 0`

UDP读取缓冲区大小，0表示操作系统默认值，如果设置为OS max以上，则UDP侦听器将失败

环境变量: `INFLUXDB_GRAPHITE_UDP_READ_BUFFER`

#### `separator = "."`

该字符串连接多个匹配的测量值，从而可以更好的控制最终的测量名称

环境变量 `INFLUXDB_GRAPHITE_SEPARATOR`


-----

## 收集的设置

### `[[collectd]]`

这些[[collectd]]` 设置控制 collectd数据的侦听器，有关更多信息，请参见 Influxdb中的CollectD协议支持

#### `enabled = false`

设置true为启用collectd写操作

环境变量: `INFLUXDB_COLLECTD_ENABLED`

#### `bind-address = ":25826"`

端口

环境变量: `INFLUXDB_COLLECTD_BIND_ADDRESS`

#### `database = "collectd"`

写入数据库的名称。默认为collectd

环境变量: `INFLUXDB_COLLECTD_DATABASE`

#### `retention-policy = ""`

相关的保留策略，空字符串等效于数据库的DEFAULT保留策略

环境变量: `INFLUXDB_COLLECTD_RETENTION_POLICY`

#### `typesdb = "/usr/local/share/collectd"`

收集的服务支持扫描目录中的多种类型db文件，或指定单个db文件


环境变量: `INFLUXDB_COLLECTD_TYPESDB`

#### `security-level = "none"`

环境变量: `INFLUXDB_COLLECTD_SECURITY_LEVEL`

#### `auth-file = "/etc/collectd/auth_file"`

环境变量: `INFLUXDB_COLLECTD_AUTH_FILE`

接下来三个设置控制批处理的工作方式，应该启用此功能，否则可能会丢失指标或者性能不佳，如果有很多进行，批处理将缓冲内存中的points

#### `batch-size = 5000`

如果有这么多points，输入将刷新；

环境变量: `INFLUXDB_COLLECTD_BATCH_SIZE`

#### `batch-pending = 10`

内存中可能待处理的批处理数

环境变量: `INFLUXDB_COLLECTD_BATCH_PENDING`

#### `batch-timeout = "10s"`

即使输入尚未达到匹配的批处理大小，它也会至少经常刷新一次

环境变量: `INFLUXDB_COLLECTD_BATCH_TIMEOUT`

#### `read-buffer = 0`

UDP读取缓冲区大小，0表示操作系统默认值，如果设置OS max以上，UDP侦听器将失败

环境变量: `INFLUXDB_COLLECTD_READ_BUFFER`

#### `parse-multivalue-plugin = "split"`

设置split为时，多值插件数据（例如df free: 5000,used: 1000）将被拆分为单独的测量值（例如（df_free,value=5000）(df_used,value=1000).设置join为时，多值插件将存储为单个多值measurement，（例如（df, free=5000,used=1000））.默认为split。

-----

## OpenTSDB settings

### `[[opentsdb]]`

控制OpenTSDB数据的侦听器
For more information, see [OpenTSDB protocol support in InfluxDB](/influxdb/v1.8/supported_protocols/opentsdb/).

#### `enabled = false`

设置为true启用openTSDB写入.

环境变量: `INFLUXDB_OPENTSDB_0_ENABLED`

#### `bind-address = ":4242"`

默认端口

环境变量 `INFLUXDB_OPENTSDB_BIND_ADDRESS`

#### `database = "opentsdb"`

写入数据的数据库名称，如果数据库不存在，则在初始化输入时将自动创建该数据库

环境变量: `INFLUXDB_OPENTSDB_DATABASE`

#### `retention-policy = ""`

相关的保留策略，空字符串等效于数据库的DEFAULTL保留策略。

环境变量: `INFLUXDB_OPENTSDB_RETENTION_POLICY`

#### `consistency-level = "one"`

设置写一致性水平：any,one,quoru

环境变量： `INFLUXDB_OPENTSDB_CONSISTENCY_LEVEL`

#### `tls-enabled = false`

环境变量: `INFLUXDB_OPENTSDB_TLS_ENABLED`

#### `certificate = "/etc/ssl/influxdb.pem"`

环境变量： `INFLUXDB_OPENTSDB_CERTIFICATE`

#### `log-point-errors = true`

Log an error for every malformed point.

环境变量： `INFLUXDB_OPENTSDB_0_LOG_POINT_ERRORS`

接下来的三个设置控制批处理的工作方式，应该启用此功能，否则可能会会丢失指标或者性能不佳，仅通过telnet协议接受的points指标进行批处理

#### `batch-size = 1000`

如果有这么多点被缓冲，输入将刷新

环境变量: `INFLUXDB_OPENTSDB_BATCH_SIZE`

#### `batch-pending = 5`

内存中可能待处理的批处理数.

环境变量: `INFLUXDB_OPENTSDB_BATCH_PENDING`

#### `batch-timeout = "1s"`

即使输入尚未达到配置的批处理大小.它也会至少经常刷新一次

环境变量: `INFLUXDB_OPENTSDB_BATCH_TIMEOUT`


-----

## UDP settings

### `[[udp]]`

这些`[[udp]]`设置使用UDP控制Influxdb线路协议数据的侦听器.
有关更多信息, 请参阅Influxdb中的UDP协议支持.

#### `enabled = false`

确定是否启用UDP侦听器，要启用UDP写入，请将值设置为true.

环境变量： `INFLUXDB_UDP_ENABLED`

#### `bind-address = ":8089"`

An empty string is equivalent to `0.0.0.0`.

环境变量： `INFLUXDB_UDP_BIND_ADDRESS`

#### `database = "udp"`

写入数据库的名称.

环境变量: `INFLUXDB_UDP_DATABASE`

#### `retention-policy = ""`

数据的相关保留策略，空字符串等效于数据库的DEFAULT保留策略.

环境变量: `INFLUXDB_UDP_RETENTION_POLICY`

接下来的三个设置控制批处理，应该启用此功能，否则可能会丢失指标或性能不佳如果有很多进来，批处

#### `batch-size = 5000`

如果有这么多点被缓冲，输入将刷新

环境变量: `INFLUXDB_UDP_0_BATCH_SIZE`

#### `batch-pending = 10`

内存中可能待处理的批处理数.

环境变量: `INFLUXDB_UDP_0_BATCH_PENDING`

#### `batch-timeout = "1s"`

即使输入尚未达到配置的批处理大小，它也会至少经常刷新一次.

环境变量: `INFLUXDB_UDP_BATCH_TIMEOUT`

#### `read-buffer = 0`

UDP读取缓冲区大小，0表示操作系统默认值，如果设置为OS max以上，UDP侦听器将失败.

环境变量: `INFLUXDB_UDP_BATCH_SIZE`

#### `precision = ""`

解码时间值时使用精度.默认值nanoseconds是数据库的默认值

环境变量: `INFLUXDB_UDP_PRECISION`


-----

## 连续查询设置

### `[continuous_queries]`

这些 `[continuous_queries]`设置控制inflxudb中连续查询（CQ）的运行方式，连续查询是在最近的时间间隔内执行的自动查询批次，Influxdb每次GROUP BY time（）间隔执行一个自动生成的查询

#### `enabled = true`

设置false为禁用CQ

环境变量: `INFLUXDB_CONTINUOUS_QUERIES_ENABLED`

#### `log-enabled = true`

设置false禁用CQ事件的日志记录

环境变量： `INFLUXDB_CONTINUOUS_QUERIES_LOG_ENABLED`

#### `query-stats-enabled = false`

设置为true，连续查询执行统计信息将写入默认监视器存储中

环境变量: `INFLUXDB_CONTINUOUS_QUERIES_QUERY_STATS_ENABLED`

#### `run-interval = "1s"`

Influxdb检查是否需要运行CQ的时间间隔，将此选项设置为CQ运行的最低间隔，例如，如果最频繁的CQ每分钟运行一次，请将设置run-interval为1m.

环境变量: `INFLUXDB_CONTINUOUS_QUERIES_RUN_INTERVAL`

-----

## 传输层安全性（TSL）设置

### `[tls]`

Influxdb中传输层安全性（TLS）的全局配置设置，有关更多信息，请参阅启用HTTPS

如果为指定TLS配置设置，则Influxdb支持列出的所有密码套件ID，以及在Go crypto/tls软件包文档的"常量"部分中实现的所有TLS版本，具体取决用于构建Influxdb的Go版本，使用SHOW DIAGNOSTICS


### 推荐的服务器配置，以实现 "先带你兼容性"

InfluxData 建议配置Influxdb服务器的TLS设置以实现”现代兼容性“这提供了更高级别的安全感，并假定不需要向后兼容，

我们推荐的TLS配置设置ciphers,min-version以及max-version基于在描述Mozilla的"现代兼容"TLS服务器配置安全/服务器端TLS。

在以下配置设置示例中指定了InfluxdbData建议的TLS设置，以实现"现代兼容性":

```
ciphers = [ "TLS_AES_128_GCM_SHA256",
            "TLS_AES_256_GCM_SHA384",
            "TLS_CHACHA20_POLY1305_SHA256"
]

min-version = "tls1.3"

max-version = "tls1.3"
```
> **Important:** Ciphers设置中密码套件ID的顺序决定了优先选择哪种算法，TLSmin-version和max-version设置将支持限制为TLS 1.3

#### `ciphers = [ "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", ]`

指定要协商一组密码套件ID，如果未指定，则ciphers支持Go crypto/tls软件包中列出的所有现有密码套件ID，这与以前版本中的行为一致，再次示例中，仅支持两个指定的密码套件ID

环境变量: `INFLUXDB_TLS_CIPHERS`

#### `min-version = "tls1.0"`

将协商的TLS协议的最低版本，有效值包括：tls1.0，tls1.1，tls1.2和tls1.3.如果未指定，min-version则为Go crypto/tls包中指定的最低TLS版本，在此示例中，tls1.0，将最低版本指定为TLS1.0，这与以前的Influxdb版本的行为一致。

环境变量: `INFLUXDB_TLS_MIN_VERSION`

#### `max-version = "tls1.3"`

将协商的TLS协议的最高版本，有效值包括: `tls1.0`, `tls1.1`, `tls1.2`, and `tls1.3`.
如果未指定, `max-version` 则为 [Go `crypto/tls`包中指定最大的TLS版本](https://golang.org/pkg/crypto/tls/#pkg-constants).
在此示例中 `tls1.3` 将最大版本指定为TLS 1.3,这与以前的Influxdb版本的行为一致

环境变量: `INFLUXDB_TLS_MAX_VERSION`
