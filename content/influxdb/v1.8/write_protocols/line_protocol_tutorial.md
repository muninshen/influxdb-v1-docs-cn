---
title: InfluxDB 行协议教程
description: Tutorial for using InfluxDB line protocol.
aliases:
    - /influxdb/v1.8/write_protocols/line/
menu:
  influxdb_1_8:
    name: Influxdb  line protocol 教程
    weight: 20
    parent: 写入协议
---

InfluxDB line protocol  是一种基于文本的格式，用于将points  写入数据库。 points 必须是len protocol 格式，才能成功解析和写point (除非你正在使用 [服务 插件](/influxdb/v1.8/supported_protocols/)).

此页面使用虚构的温度数据介绍line protocol ,主要涵盖：

<table style="width:100%">
  <tr>
    <td><a href="#syntax">语法</a></td>
    <td><a href="#data-types">数据类型</a></td>
    <td><a href="#quoting">引用</a></td>
    <td><a href="#special-characters-and-keywords">特殊字符和关键字</a></td>
  </tr>
</table>



最后一节，[写入数据到influsdb](#写入数据到influsdb)、 描述如何将数据输入到InfluxDB 数据库以及influxdb如何处理line procotol重复

## 语法

Line protocol 格式的单行文本代表Influxdb中的一个point，它将point的measurement、tag set，field set以及timestamp通知给influxdb

以下代码块显示了line procotol示例，并将其分解为各个组件

```
weather,location=us-midwest temperature=82 1465839830100400200
  |    -------------------- --------------  |
  |             |             |             |
  |             |             |             |
+-----------+--------+-+---------+-+---------+
|measurement|,tag_set| |field_set| |timestamp|
+-----------+--------+-+---------+-+---------+
```

遍历图中每个元素:

### Measurement

要写入数据的measurement名称，根据line procotol 生成measurement.

在示例中，measurement的名称weather

### Tag set

您想要包含的[tag](/influx db/v 1.8/概念/术语表/#标签) 用你的数据point 。 tags和line procotol 是可选的。

> **注意:**避免使用保留键keys `_field`, `_measurement`, 和 `time`.如果保留的关键字作为tag 或者field 关键字包含在内以及相关联的字段.

请注意，measurement 和 tag set由逗号分隔，没有空格.

用等号=分隔 tag key-value，不要有空格 :

```
<tag_key>=<tag_value>
```

用逗号分隔多个tag -values对，且没有空格:

```
<tag_key>=<tag_value>,<tag_key>=<tag_value>
```

在示例中，tag set 由一个标记组成：`location=us-midwest`。(`season=summer`)在示例中添加另一个tag （）如下所示:

```
weather,location=us-midwest,season=summer temperature=82 1465839830100400200
```

为了获得最佳性能，您应该在将tags 发送到 数据库。 排序应该与 [Go bytes.Compare 函数](http://golang.org/pkg/bytes/#Compare).

### 空白 I

将measurement和field set 分开，或者如果要在数据point中包含tag set ，请使用空格将tag set和field set 分开。line procotol 中需要空白

没有设置tag 的有效line procotol:

```
weather temperature=82 1465839830100400200
```

### Field set

数据point的 [field(s)](/influxdb/v1.8/concepts/glossary/#field) .
每个point 都需要 line protocol中至少有一个field.

用等号`=` 分隔field key-value ，不要有空格:

```
<field_key>=<field_value>
```

用逗号分隔多个 field-value 不要用空格:

```
<field_key>=<field_value>,<field_key>=<field_value>
```

在该示例中，field set由一个field组成: `temperature=82`.
向示例中添加另一个 field (`humidity=71`)如下所示:

```
weather,location=us-midwest temperature=82,humidity=71 1465839830100400200
```

### 空白 II

用空格分割tag set（field set和可选时间戳 ）如果需要添加时间戳，则line procotol 中必须使用空格

### Timestamp

数据point的时间戳，以ns为单位的Unix时间，时间戳在line protocol 中是可选的，如果没有为数据point 指定时间戳，则influxdb使用服务器的本地纳秒时间戳（以UTC为单位）

在示例中，时间戳为`1465839830100400200（2016-06-13T17:43:50.1004002Z采用RFC3339格式）`下面的line procotol是相同的数据point ，但没有时间戳，当Influxdb将其写入数据库中，它将使用服务器的本地时间戳而不是`2016-06-13T17:43:50.1004002Z`。

```
weather,location=us-midwest temperature=82
```

使用Influxdb API可以以十亿分之一秒（例如微秒，毫秒或秒）以外的精度指定时间戳，建议使用最粗略的精度，因为这可以显示提高压缩率。

> #### 设定提示
>
使用网咯时间协议（NTP）主机之间同步时间，Influxdb使用UTC中主机的本地时间为数据分配的时间戳.如果主机的时钟与NTP同步，则写入Influxdb的数据上的时间戳可能不准确

## 数据类型

本节涵盖了线路协议主要组件的数据类型:
[measurements](/influxdb/v1.8/concepts/glossary/#measurement),
[tag keys](/influxdb/v1.8/concepts/glossary/#tag-key),
[tag values](/influxdb/v1.8/concepts/glossary/#tag-value),
[field keys](/influxdb/v1.8/concepts/glossary/#field-key),
[field values](/influxdb/v1.8/concepts/glossary/#field-value), 和
[timestamps](/influxdb/v1.8/concepts/glossary/#timestamp).


Measurements, tag keys, tag values, 和 field keys都是字符串 

> **Note:**
因为Influxdb将tag values存储为字符串，所以influxdb数据库不能对tag vlaues执行数据运算，此外，Influxdb函数不能接受tag value作为主要参数，在设计架构时考虑这些信息是个好主意

时间戳是UNIX时间戳。最小有效时间戳为`-9223372036854775806`或`1677-09-21T00:12:43.145224194Z`。最大有效时间戳为`9223372036854775806或2262-04-11t 23:47:16.85475806 z`。如上所述，默认情况下，InfluxDB假设时间戳为纳秒有关如何指定替代精度，请参见[API接口](/influxdb/v1.8/tools/api/#write-http-endpoint)。

Field values 可以是浮点数、整数、字符串或者 Booleans:

* 浮点-默认情况下，Influxdb假设所有数值字段值都是浮点

    将field value `82`存储为浮点数:

    ```
    weather,location=us-midwest temperature=82 1465839830100400200
    ```

* 整数-在field values中添加一个“I”来告诉InfluxDB存储 整数.

  将field value存储too warm为字符串:
  
  ```
  weather,location=us-midwest temperature=82i 1465839830100400200
  ```
  
* 字符串-双引号字符串field value(有关line procotol中引用的更多信息 [下方](#引用))

  将field value存储 `too warm`字符串 :
  
  ```
  weather,location=us-midwest temperature="too warm" 1465839830100400200
  ```
  
* Booleans - 指定TRUE有t，T，true，True，或TRUE。指定与FALSE f，F，false，False，或FALSE。

  将 field value 存储为true为 Boolean值:
  
  ```
  weather,location=us-midwest too_hot=true 1465839830100400200
  ```
  
  > **注意:**可接受的booleans在数据写入和数据查询方面有所不同

在measurement中，一个字段类型不能在不同范围内的shard中,但它可能有不同的shard，例如，将整数写入先前接受的field，如果Influxdb试图将整数存储在与浮点数相同的分片中，则将整数写入先前的浮点数将失败:

```sql
> INSERT weather,location=us-midwest temperature=82 1465839830100400200
> INSERT weather,location=us-midwest temperature=81i 1467154750000000000
>
```

有关field value 类型的差异如何影响查询的信息，请参见
[常见问题](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#how-does-influxdb-handle-field-type-discrepancies-across-shards) .

## Quoting

本节介绍了在line procotol 中何时不使用双引号和何时将双引号 (`"`) 或单引号 (`'`)引起来，从
line procotol 中的引号，从不引用到引用

* 不要用双引号或单引号引起时间戳。这不是有效的line procotol

  例:
  
  ```
  > INSERT weather,location=us-midwest temperature=82 "1465839830100400200"
  ERR: {"error":"unable to parse 'weather,location=us-midwest temperature=82 \"1465839830100400200\"': bad timestamp"}
  
  ```

* 不要单引号字段值(即使它们是字符串！). 这也不是有效的line procotol。

  例:
  
  ```
  > INSERT weather,location=us-midwest temperature='too warm'
  ERR: {"error":"unable to parse 'weather,location=us-midwest temperature='too warm'': invalid boolean"}
  ```
*   不要对measurement 名称, tag keys, tag values, 和 field
keys.
这是一个有效的line procotol，但是 InfluxDB 假设引号是名字

例:

```
  > INSERT weather,location=us-midwest temperature=82 1465839830100400200
  > INSERT "weather",location=us-midwest temperature=87 1465839830100400200
  > SHOW MEASUREMENTS
  name: measurements
  ------------------
  name
  "weather"
  weather
```

要在“天气”中查询数据，您需要在measurement名称和 避开measurement的双引号:

    > SELECT * FROM "\"weather\""
    name: "weather"
    ---------------
    time                            location     temperature
    2016-06-13T17:43:50.1004002Z    us-midwest   87
> SELECT * FROM "\"weather\""
name: "weather"
---------------
* 不要对`bouble quote field values` 或者`booleans`field value进行双引号，Influxdb将假设这些值时字符串

  例:
  
  ```
  > INSERT weather,location=us-midwest temperature="82"
  > SELECT * FROM weather WHERE temperature >= 70
  >
  
  ```
* 对字符串field value进行双引号

    例

    ```
    > INSERT weather,location=us-midwest temperature="too warm"
    > SELECT * FROM weather
    name: weather
    -------------
    time                            location     temperature
    2016-06-13T19:10:09.995766248Z  us-midwest   too warm
    
    ```
## 特殊字符和关键字

### 特殊字符

对于 tag keys, tag value, 和 field keys 始终使用反斜杠 `\`转义:

* 逗号 `,`
    ```
    weather,location=us\,midwest temperature=82 1465839830100400200
    ```
    
* 等号 `=`

    ```
    weather,location=us-midwest temp\=rature=82 1465839830100400200
    ```
    
* 空格

    ```
    weather,location\ place=us-midwest temperature=82 1465839830100400200
    ```

对于measurements 请始终使用反斜杠 `\`进行转义:

* 逗号 `,`

    ```
    wea\,ther,location=us-midwest temperature=82 1465839830100400200
    ```

* 空格

    ```
    wea\ ther,location=us-midwest temperature=82 1465839830100400200
    ```

对于 字符串 field values 请使用反斜杠 `\` 进行转义:

* 双引号 `"`

    ```
    weather,location=us-midwest temperature="too\"hot\"" 1465839830100400200
    ```
    
    Line procotol 不要求用户转义反斜杠字符，但是如果非要这样做也没问题，例如，插入以下内容

```
weather,location=us-midwest temperature_str="too hot/cold" 1465839830100400201
weather,location=us-midwest temperature_str="too hot\cold" 1465839830100400202
weather,location=us-midwest temperature_str="too hot\\cold" 1465839830100400203
weather,location=us-midwest temperature_str="too hot\\\cold" 1465839830100400204
weather,location=us-midwest temperature_str="too hot\\\\cold" 1465839830100400205
weather,location=us-midwest temperature_str="too hot\\\\\cold" 1465839830100400206
```

将解释如下（请注意，单反斜杠和双反斜杠产生相同的记录）

```sql
> SELECT * FROM "weather"
name: weather
time                location   temperature_str
----                --------   ---------------
1465839830100400201 us-midwest too hot/cold
1465839830100400202 us-midwest too hot\cold
1465839830100400203 us-midwest too hot\cold
1465839830100400204 us-midwest too hot\\cold
1465839830100400205 us-midwest too hot\\cold
1465839830100400206 us-midwest too hot\\\cold
```

所有其它特殊字符也不需要转义，例如，line procotol可以毫无问题的处理表情符号:

```sql
> INSERT we⛅️ther,location=us-midwest temper🔥ture=82 1465839830100400200
> SELECT * FROM "we⛅️ther"
name: we⛅️ther
------------------
time			              location	   temper🔥ture
1465839830100400200	 us-midwest	 82
```

### 关键字

Line procotol 接受[InfluxQL 关键字](/influxdb/v1.8/query_language/spec/#keywords)作为[标识符](/influxdb/v1.8/concepts/glossary/#identifier) 名称.。

通常，我们建议避免在架构中使用InfluxQL关键字，因为它可能在查询数据时引起[confusion](/influxdb/v1.8/troubleshooting/errors/#error-parsing-query-found-expected-identifier-at-line-char) 。
关键字time是一种特殊情况。time可以是[continuous query](/influxdb/v1.8/concepts/glossary/#continuous-query-cq)，数据库名称，[measurement](/influxdb/v1.8/concepts/glossary/#measurement)名称，[retention policy](/influxdb/v1.8/concepts/glossary/#retention-policy-rp) [subscription](/influxdb/v1.8/concepts/glossary/#subscription) 和[user](/influxdb/v1.8/concepts/glossary/#user) 。

在这种情况下，`time`查询中不需要双引号。time不能是field key 或
tag key ; InfluxDB拒绝使用`time`作为`field key` 或`tag keys`的写入，并返回错误。有关更多信息，请参见[常见问题](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#time) 。

## 将数据写入InfluxDB

### 在数据库中获取数据
现在，您已经了解Influxdb line procotol的全部知识，实际上如何将line procotol 添加到Influxdb，在这里将给出简单的示例，然后将您指向[Tools](/influxdb/v1.8/tools/)部分获取更多信息

#### InfluxDB API

使用Influxdb API将数据写入Influxdb，`POST`向`/write`段发起请求,并在请求正文中提供您的line protocol：

```bash
curl -i -XPOST "http://localhost:8086/write?db=science_is_cool" --data-binary 'weather,location=us-midwest temperature=82 1465839830100400200'
```

#### CLI命令行界面

使用Influxdb数据库命令将数据写入Influxdb数据库，启动命令行界面（CLI）使用相关的数据库，并将Insert放在line procotol前面:

```sql
INSERT weather,location=us-midwest temperature=82 1465839830100400200
```

也可以使用CLI从文件导入Line协议.

有几种方法可以将数据写入 InfluxDB.
有关I [InfluxDB API](/influxdb/v1.8/tools/api/#write-http-endpoint) [CLI](/influxdb/v1.8/tools/shell/), 和可用服务插件  ([UDP](/influxdb/v1.8/tools/udp/),[Graphite](/influxdb/v1.8/tools/graphite/),[CollectD](/influxdb/v1.8/tools/collectd/), 和[OpenTSDB](/influxdb/v1.8/tools/opentsdb/)).请参见[Tools](/influxdb/v1.8/tools/) 部分

### 重复points

 point 由measurement名称，tag set，和timestamp唯一标识，如果提交具有相同measurement、tag set和时间戳的line procotol，但是使用不同的tag set，tag set就变成了旧tag set和新tag set的合集，其中任何冲突都会影响新tag set;

有关此行为的完整示例以及如何避免这种情况，请参阅[Influxdb如何处理重复点?](/influxdb/v1.8/troubleshooting/frequently-asked-questions/#how-does-influxdb-handle-duplicate-points)