---
title: TSI 详解
description: Enable and understand the Time Series Index (TSI).
menu:
  influxdb_1_8:
    name: TSI 详解
    weight: 80
    parent: 概念
---

当influxdb提取数据时，我们不仅存储值，而且还索引测量值和标签信息，以便快速的查询，在较早的版本中，索引数据只能存储在内存中，但是这需要大量的RAM，并在机器上可以容的序列数上设置了上线，根据所使用的机器，该上线通常在1-4百万系列之间

开发时间序列索引（TSI）可以使我们超越该上限，TSI将索引数据存储在磁盘上，因为我们不在受RAM限制，TSI使用操作系统的页面缓存将热数据拉入内存中，并使冷数据保留在磁盘上

## Enable TSI

要启用TSI，需要在配置文件（influxdb.conf`）进行设置:

```
index-version = "tsi1"
```

(确保包括双引号.)

### InfluxDB 企业版

- To convert your data nodes to support TSI, see [Upgrade InfluxDB Enterprise clusters](/enterprise_influxdb/v1.8/administration/upgrading/).

- For detail on configuration, see [Configure InfluxDB Enterprise clusters](/enterprise_influxdb/v1.8/administration/configuration/).

### InfluxDB OSS

- For detail on configuration, see [Configuring InfluxDB OSS](/influxdb/v1.8/administration/config/).

## Tooling

### `influx_inspect dumptsi`

如果要对索引问题进行故障排除，可使用该influx_inspect dumptsi命令，此命令可以打印一些摘要信息，一次仅对一个索引起作用

### `influx_inspect buildtsi`

如果要将现有的分片从内存中的索引转换为TSI索引，或者如果现有的索引已损坏，则可以使用该buildtsi命令从基础TSM数据创建索引，如果需要重建现有的TSI索引，则首先删除index分片中的目录

该命令在服务器级别起作用，但是可以选择添加数据库，保留策略和分片过滤器，以仅应用于分片的子集

For details on this command, see [influx inspect buildtsi](/influxdb/v1.8/tools/influx_inspect/#buildtsi).


## 了解TSI

### 文件组织

TSI (Time Series Index)是用于influxdb系列数据的基于日志结构且基于合并数的数据库，TSI由以下几个部分组成

* **Index**: 包含单个碎片的整个索引数据集

* **Partition**（分区）包含分片数据的分片分区

* **LogFile**: 包含新编写的系列作为内存索引，并作为WAL持久保存

* **IndexFile**: 包含一个不可变的，内存映射的索引，该索引是从Logfile构建的，或者是从两个连续的索引文件合并而成

  还有一个seriesFile，其中包含整个数据库中所有系列键的集合，数据库中的每个分片共享相同的系列文件

### 写

1. 当写入系统时会发生以下情况：

   系列被添加到系列文件中，或者如果它已经存在，则进行查找。这将返回一个自动递增的序列ID。
   该系列将发送到索引。该索引维护了现有系列ID的咆哮位图，并忽略了已创建的系列。
   对该系列进行哈希处理并将其发送到适当的分区。
   分区将系列写入LogFile的条目。
   LogFile将系列写入磁盘上的预写日志文件，并将系列添加到一组内存索引。

压实

一旦LogFile超过阈值（5MB），则将创建一个新的活动日志文件，并且先前的活动日志文件开始压缩为IndexFile。该第一个索引文件位于级别1（L1）。日志文件被认为是0级（L0）。

也可以通过将两个较小的索引文件合并在一起来创建索引文件。例如，如果存在两个相邻的L1索引文件，则可以将它们合并到L2索引文件中。

读

索引提供了一些API调用来检索数据集，例如：

*  MeasurementIterator()：返回测量名称的排序列表。

  TagKeyIterator()：返回度量中标签键的排序列表。

  TagValueIterator()：返回标签键的标签值的排序列表。

  MeasurementSeriesIDIterator()：返回测量的所有系列ID的排序列表。

  TagKeySeriesIDIterator()：返回标签键的所有系列ID的排序列表。

  TagValueSeriesIDIterator()：返回标签值的所有系列ID的排序列表。

这些迭代器都可以使用多个合并迭代器进行组合。对于每种迭代器类型（度量，标记键，标记值，系列ID），有多种合并迭代器类型：

* 合并：从两个迭代器中删除项。
* 相交：仅返回存在于两个迭代器中的项目。
* 区别：仅从第一个迭代器返回第二个迭代器中不存在的项。

例如，一个带有WHERE子句的查询region != 'us-west'可在两个分片上运行的查询将构造一组迭代器，如下所示：

```
DifferenceSeriesIDIterators(
    MergeSeriesIDIterators(
        Shard1.MeasurementSeriesIDIterator("m"),
        Shard2.MeasurementSeriesIDIterator("m"),
    ),
    MergeSeriesIDIterators(
        Shard1.TagValueSeriesIDIterator("m", "region", "us-west"),
        Shard2.TagValueSeriesIDIterator("m", "region", "us-west"),
    ),
)
```

### Log File Structure

日志文件被简单地构造为按顺序写入磁盘的LogEntry对象的列表。写入日志文件，直到达到5MB，然后将其压缩为索引文件。日志中的条目对象可以是以下任意一种：

* AddSeries（添加系列）
* DeleteSeries（删除系列）
* DeleteMeasurement （删除measurement）
* DeleteTagKey（删除标签key）
* DeleteTagValue（删除标签值）

日志文件上的内存中索引跟踪以下内容：

* Measurements by name（按名称测量）
* Tag keys by measurement（通过测量标记钥匙）
* Tag values by tag key（通过标记键标记值）
* Series by measurement（测量系列）
* Series by tag value（按标签值系列）
* Tombstones for series, measurements, tag keys, and tag values.（系列，测量，标签键和标签值的墓碑）

日志文件还维护系列标识存在和墓碑的位集。 这些位集与其他日志文件和索引文件合并，以便在启动时重新生成完整的索引位集。

### 索引文件结构

索引文件是一个不变的文件，它跟踪与日志文件类似的信息，但是所有数据都被索引并写入磁盘，以便可以直接从内存映射中访问它。

索引文件包含以下部分：

* **TagBlocks:** 维护单个标签键的标签值索引
* **MeasurementBlock:** 维护测量索引及其标签键
* **Trailer:** 存储文件的偏移信息以及用于基数估计的HyperLogLog草图。

### Manifest

MANIFEST文件存储在索引目录中，并列出了属于该索引的所有文件及其应被访问的顺序。每次压缩时都会更新此文件。目录中所有不在索引文件中的文件都是正在压缩的索引文件。

### FileSet

文件集是在InfluxDB进程运行时获取的清单的内存中快照。这要求在时间点上提供一致的索引视图。该文件集还便于对其所有文件进行引用计数，以便在压缩所有文件的读者之前，不会通过压缩删除任何文件。
