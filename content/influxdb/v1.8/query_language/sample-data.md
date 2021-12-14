---
title: 示例数据
description: Create a database, download, and write sample data.
menu:
  influxdb_1_8:
    weight: 10
    parent: InfluxQL
aliases:
  - /influxdb/v1.8/sample_data/data_download/
  - /influxdb/v1.8/query_language/data_download/
---

为了进一步学习InfluxQL，本节将提供示例数据供您下载，并教您如何将数据导入数据库。[数据探索](../../query_language/data_exploration/)、[Schema探索](../../query_language/schema_exploration/)和InfluxQL[函数](../../query_language/functions/)等章节都会引用到这些示例数据。

## 创建数据库

如果您在本地安装了InfluxDB，则应该在本地使用`influx`命令。执行`influx`将启动CLI并自动连接到本地InfluxDB实例（假设您已经使用service influxdb start或直接运行influxd启动了服务器）。

则会输出如下内容：

```bash
$ influx -precision rfc3339
Connected to http://localhost:8086 version 1.8.x
InfluxDB shell 1.8.x
>
```

> **注意：**
* InfluxDB API默认在端口`8086`上运行。
  因此，默认情况下，`influx`将连接到端口`8086`和` localhost`。
  如果需要更改这些默认值，请运行`influx --help`。

* [`-precision` 参数](/influxdb/v1.8/tools/shell/#influx-arguments) 指定返回的时间戳的格式以及精度。

  以上示例中，`rfc3339`告诉InfluxDB返回[RFC3339格式](https://www.ietf.org/rfc/rfc3339.txt) (`YYYY-MM-DDTHH:MM:SS.nnnnnnnnnZ`)的时间戳。

命令行现在已经准备好以Influx查询语言（InfluxQL）语句的形式接受输入。
如需退出InfluxQL shell，请输入`exit`，然后按回车键。

新安装的InfluxDB没有数据库（_internal除外），
因此创建一个数据库是我们的首要任务。

您可以使用`CREATE DATABASE <db-name>` InfluxQL语句创建数据库，其中`<db-name>`是要创建的数据库的名称。

数据库名称可以包含任何unicode字符，只要该字符串被双引号引起来。
如果名称包含\_only\_ ASCII字母，也可以不加引号，
数字或下划线，并且不能以数字开头。

Throughout the query language exploration, we'll use the database name `NOAA_water_database`:

在查询语言的整个探索过程中，我们将使用数据库名称为`NOAA_water_database`：

```
> CREATE DATABASE NOAA_water_database
> exit
```

### 下载数据并将数据写入InfluxDB

在终端中输入以下命令来下载一个文本文件，文件中包含符合行协议格式的数据：
```
curl https://s3.amazonaws.com/noaa.water-database/NOAA_data.txt -o NOAA_data.txt
```

通过CLI，将下载好的数据写入到InfluxDB：
```
influx -import -path=NOAA_data.txt -precision=s -database=NOAA_water_database
```

### 查询测试
```bash
$ influx -precision rfc3339 -database NOAA_water_database
Connected to http://localhost:8086 version 1.8.x
InfluxDB shell 1.8.x
>
```

查看示例数据中所有的measurement，总共五个：
```bash
> SHOW measurements
name: measurements
------------------
name
average_temperature
h2o_feet
h2o_pH
h2o_quality
h2o_temperature
```

统计在measurement `h2o_feet`中，非`null`的`water_level`的值的数量：

```bash
> SELECT COUNT("water_level") FROM h2o_feet
name: h2o_feet
--------------
time			               count
1970-01-01T00:00:00Z	 15258
```

在`h2o_feet`中查询前五个观察值：

```bash
> SELECT * FROM h2o_feet LIMIT 5
name: h2o_feet
--------------
time			                 level description	      location	       water_level
2015-08-18T00:00:00Z	   below 3 feet		          santa_monica	   2.064
2015-08-18T00:00:00Z	   between 6 and 9 feet	   coyote_creek	   8.12
2015-08-18T00:06:00Z	   between 6 and 9 feet	   coyote_creek	   8.005
2015-08-18T00:06:00Z	   below 3 feet		          santa_monica	   2.116
2015-08-18T00:12:00Z	   between 6 and 9 feet	   coyote_creek	   7.887
```

### 数据来源和需要注意的事项
示例数据是[美国国家海洋和大气管理局(NOAA)业务海洋产品和服务中心](http://tidesandcurrents.noaa.gov/stations.html?type=Water+Levels)的公开数据。该数据包括在2015年8月18日至2015年9月18日期间，在两个站点（加州Santa Monica（ID 9410840）和加州Coyote Creek（ID 9414575））上收集到的水位（ft）观测值，这些数值每6秒收集一次，总共15,258个观测值。

请注意，`average_temperature`、`h2o_pH`、`h2o_quality`和`h2o_temperature`这些measurement中包含有虚构的数据，这些数据用于阐明Schema探索中的查询功能。

