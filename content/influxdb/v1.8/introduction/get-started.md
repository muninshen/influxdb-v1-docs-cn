---
title: 快速开始
description: Get started with InfluxDB OSS.
aliases:
  - /influxdb/v1.8/introduction/getting_started/
  - /influxdb/v1.8/introduction/getting-started/
menu:
  influxdb_1_8:
    name: 快速开始
    weight: 30
    parent: 介绍
---

使用[已安装](/influxdb/v1.8/introduction/installation)的InfluxDB OSS, 您就可以做一些有趣的事情了。在本节中，我们将使用`influx`[命令行界面](/influxdb/v1.8/tools/shell/)（CLI），它包含在所有InfluxDB软件包中，是一种轻量简单的数据库交互工具。默认情况下，CLI通过在端口`8086`向InfluxDB API发送请求来直接与InfluxDB通信。

> **注意：**也可以通过发出原始HTTP请求来使用数据库。请查看[写入数据](/influxdb/v1.8/guides/writing_data/)和[查询数据](/influxdb/v1.8/guides/querying_data/)。例如使用`curl`

## 创建数据库

如果您在本地安装了InfluxDB，则应该通过命令行使用`influx`命令。执行`influx`将启动CLI并自动连接到本地的InfluxDB实例（假设您已经使用`service influxdb start`或直接运行`influxd`启动了服务），输出将如下所示：

```bash
$ influx -precision rfc3339
Connected to http://localhost:8086 version 1.8.x
InfluxDB shell 1.8.x
>
```

> **注意：**
* InfluxDB API 默认在端口`8086` 上运行。
因此，默认情况下， `influx` 将连接到 `localhost` 主机的`8086`端口。
如果需要更改这些默认值，请运行 `influx --help`.
* [`-precision` argument](/influxdb/v1.8/tools/shell/#influx-arguments)指定所有时间戳返回的格式和精度。
在上面的示例中， `rfc3339` 告诉InfluxDB以[RFC3339格式](https://www.ietf.org/rfc/rfc3339.txt) (`YYYY-MM-DDTHH:MM:SS.nnnnnnnnnZ`)返回时间戳。

命令行现在以influx查询语言（InfluxQL）格式的形式接收输入，如果需要退出InfluxQL Shell，请输入`exit`并按`Enter`键。

新安装的InfluxDB没有数据库（除了系统自带数据库_internal）,因此第一步需要创建一个数据库，创建数据库的命令为`CREATE DATABASE <db-name>`，其中`<db-name>`是您要创建的数据库名称，数据库名称可以使用所有的unicode字符，只要该字符被双引号引起来。如果名称仅包含ASCII字母、数字、下划线并且不以数字开头，则也可以不加引号。

在指南中，我们使用的数据库名称为`mydb`：

```sql
> CREATE DATABASE mydb
>
```

> **注意：** 按下`Enter`键后，不会出现任何提示和内容。在CLI中，这意味着该语句已成功执行。如果出现提示或内容，则表示命令出错。我们一贯秉承没有消息就是好消息的原则！

现在你已经创建了数据库`mydb`，我们将使用`SHOW DATABASES`语句显示所有现有的数据库：

```sql
> SHOW DATABASES
name: databases
name
----
_internal
mydb
>
```

> **注意:** 数据库_internal由InfluxDB自己创建，用于存储内部运行的监控指标。

与`SHOW DATABASES`不同，大多数InfluxQL语句必须针对特定数据库进行操作。您可以为每个查询显示命名数据库，但是CLI提供了一条便捷语句，`USE <db-name>`语句为以后所有请求自动设置数据库，例如：

```sql
> USE mydb
Using database mydb
>
```

之后的命令只针对数据库`mydb`运行。

## 写入和探索数据

现在我们有了一个数据库，InfluxDB准备接收查询和写入请求。

首先，简单介绍一下InfluxDB数据存储模型。InfluxDB中的数据按照“时间序列”来组织，其包含一个被测量的指标，如“cpu_load”或者“temperature”。时间序列有零个或多个point，每个point都是一个测量值，point由`time`（一个时间戳）、`measurement`（测量指标，例如“cpu_load”）、至少一个key-value格式的`field`（测量值，例如“value=0.64”或者“temperature=2.12”）和零或多个包含测量值元数据的key-value格式的`tag`（例如“host=server01”，“region=EMEA”，“dc=Frankfurt”）组成。

从概念上来讲，您可以将`measurement`看成是一个SQL表格，其中，时间戳始终是主索引，`tag`和`field`是表格中的列，`tag`会被建索引，而`field`则不会。与SQL表格的不同之处在于，使用InfluxDB，您可以有数百万的measurement，无需预先定义数据的schema，并且不会存储空值。

数据写入InfluxDB使用需要使用行协议(Line Protocol)，该协议遵循以下格式:

```
<measurement>[,<tag-key>=<tag-value>...] <field-key>=<field-value>[,<field2-key>=<field2-value>...] [unix-nano-timestamp]
```

以下是符合格式的数据写入InfluxDB的示例:

```
cpu,host=serverA,region=us_west value=0.64
payment,device=mobile,product=Notepad,method=credit billed=33,licenses=3i 1434067467100293230
stock,symbol=AAPL bid=127.46,ask=127.48
temperature,machine=unit42,type=assembly external=25,internal=37 1434067467000000000
```

> **注意:** 更多关于行协议的信息, 请参考 [行协议参考](/influxdb/v1.8/write_protocols/line_protocol_reference/#line-protocol-syntax) .

使用CLI写入一个point到InfluxDB，请先输入`INSERT`，然后输入该point的信息：

```sql
> INSERT cpu,host=serverA,region=us_west value=0.64
>
```

现在，一个measurement为`cpu`，tag为`host`和`region`，测量值`value`为`0.64`的point已经写入数据库。

查询刚刚写入的数据：

```sql
> SELECT "host", "region", "value" FROM "cpu"
name: cpu
---------
time		    	                     host     	region   value
2015-10-21T19:28:07.580664347Z  serverA	  us_west	 0.64

>
```

> **注意:** 前面我们在写入ponts的时候没有提供时间戳。如果写入没有带时间戳的数据点，InfluxDB会在获取该点时，把本地当前时间分配给该数据点，作为该数据点的时间戳。这意味着您的时间戳跟上面的会有所不同。

让我们尝试写入另一种类型的数据，同一个measurement有两个field：

```sql
> INSERT temperature,machine=unit42,type=assembly external=25,internal=37
>
```

查询的时候，若想返回所有的field和tag，可以使用操作符`*`：

```sql
> SELECT * FROM "temperature"
name: temperature
-----------------
time		                        	 external	  internal	 machine	type
2015-10-21T19:28:08.385013942Z  25	        	37     		unit42  assembly

>
```

> **警告：** *在大型数据库上使用*`*`*而不使用*`LIMIT`*子句可能会导致性能问题。 您可以使用*`Ctrl+C`取消响应时间过长的查询。

InfluxQL有很多[功能和特性](/influxdb/v1.8/query_language/spec/) 没有在这里提及，包括支持Go语言风格的正则表达式，例如：
including support for Go-style regex. For example:

```sql
> SELECT * FROM /.*/ LIMIT 1
--
> SELECT * FROM "cpu_load_short"
--
> SELECT * FROM "cpu_load_short" WHERE "value" > 0.9
```

这就是你在入门指南里需要知道的将数据写InfluxDB并进行查询的全部内容，想要获取更多关于InfluxDB写入数据和查询数据的信息，请查看文档[写入数据](/influxdb/v1.8/guides/writing_data/)和[查询数据](/influxdb/v1.8/guides/querying_data/)，想要了解更多InfluxDB相关的概念，请查看文档[关键概念](/influxdb/v1.8/concepts/key_concepts/)。
