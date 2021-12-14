---
title: 使用InfluxDB API写入数据
description: >
  Use the command line interface (CLI) to write data into InfluxDB with the API.
menu:
  influxdb_1_8:
    weight: 10
    parent: 指南
aliases:
  - /influxdb/v1.8/guides/writing_data/
---

使用 [命令行界面](/influxdb/v1.8/tools/shell/), [客户端库](/influxdb/v1.8/clients/api/), 和通用数据格式 [Graphite](/influxdb/v1.8/write_protocols/graphite/)的插件将数据写入InfluxDB

> **Note**:以下示例使用 `curl`,这是一个使用 URL传输数据的命令行工具，使用 [HTTP Scripting Guide](https://curl.haxx.se/docs/httpscripting.html)学习`curl`的基础知识

### 使用InfluxDB API创建数据库

要创建数据库，请向`/query`端点发送POST请求，并将URL参数`q`设置为`CREATE DATABASE <new_database_name>`下面的示例向本地主机上运行的influxdb发送一个请求，并创建mydb数据库；

```bash
curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"
```

### 使用InfluxDB API写入数据

influxdb API是将数据写入influxdb的主要方法

- 要使用Influxdb 1.8 API写入数据库，请将`POST`请求发送到`/write`端点，将单点写入`mydb`数据库，该数据包括的[measurement](/influxdb/v1.8/concepts/glossary/#measurement) `cpu_load_short`时,[代码键](/influxdb/v1.8/concepts/glossary/#tag-key) `host` 和`region`与所述[tag values](/influxdb/v1.8/concepts/glossary/#tag-value) `server01` 和 `us-west`该[field key](/influxdb/v1.8/concepts/glossary/#field-key) `value`与[field value](/influxdb/v1.8/concepts/glossary/#field-value) of `0.64`和 [timestamp](/influxdb/v1.8/concepts/glossary/#timestamp) `1434055562000000000`.

```bash
curl -i -XPOST 'http://localhost:8086/write?db=mydb'
--data-binary 'cpu_load_short,host=server01,region=us-west value=0.64 1434055562000000000'
```

- 要使用InfluxDB 2.0 API（与InfluxDB 1.8+兼容）写入数据库，`POST`请向`/api/v2/write`端点发送请求：

```bash
curl -i -XPOST 'http://localhost:8086/api/v2/write?bucket=db/rp&precision=ns' \
  --header 'Authorization: Token username:password' \
  --data-raw 'cpu_load_short,host=server01,region=us-west value=0.64 1434055562000000000'
```

编写点时，必须在`db`查询参数中指定一个现有的数据库，`db`如果未通过`rp`查询参数提供保留策略，Points将被写入`db`默认保留策略中，有关可用查询参数的完整列表，请参考 [InfluxDB API Reference](/influxdb/v1.8/tools/api/#write-http-endpoint) 

 POST或[InfluxDB line protocol](/influxdb/v1.8/concepts/glossary/#influxdb-line-protocol)的正文包括需要存储的时间序列数据，数据包括

- **Measurement（必填）**

- **Tags**: 严格来说，tags是可选的，但是大多数系列都包含tags，以区分数据源并使查询既简单又高效。tag key 和tag values都是字符串。

- **Fields（必填)**：Field key 是必需的，并且始终为字符串，[默认情况](/influxdb/v1.8/write_protocols/line_protocol_reference/#data-types)，field values为浮点数。

- **Timestamp**：自1970年1月1日以来，在Unix时间的行末以纳秒为单位提供-是可选的。如果未指定时间戳，则InfluxDB在Unix纪元中使用服务器的本地纳秒级时间戳。InfluxDB中的时间默认为UTC格式。

```
注意：避免使用下列保留键：_field,_measurement,和time。如果保留的键作为tags 和field key包括在内，则关联的点被丢弃
```

### 配置gzip压缩

influxdb支持gzip压缩，要减少网络流量，需优先考虑一下选项

* 要接受来自influxdb的压缩数据，请将`Accept-Encoding：gzip`heade信息添加到influxdb API请求中

* 要在将数据发送到influxdb之前压缩数据，将`Content-Encoding:gzip`heade信息添加到influxdb API请求中

在Telegraf influxdb输出插件中启用gzip压缩

* 在telegraf配置文件（telegraf.conf）中的[outputs.influxdb]下，将`content_encoding="identity"`（默认）更改为`content_encoding="gzip"`

>注意：默认情况下，将写入influxdb2.x【outputs.influxdb_v2】配置为以gzip格式压缩内容

### 写多Points

通过用换行分隔每个Points，将多个Points同时发布到多个series中，以这种方式批处理Points可以提高性能。

下面的示例将三个Points写入数据库`mydb`，每一个Points数据具有measurement `cpu_load_short`和tag set 的server，`host=server02`并且具有服务器的本地时间戳，每二Points属于带有measurement`cpu_load_short`和tag set的server，`host=server02`，`region=us-west`并且具有指定的时间戳1422568543702900257。第三Point与第二Points具有相同的指定时间戳记，但已将其写入带有measurement值`cpu_load_short`和tag set 的序列中`direction=in,host=server01,region=us-west`

```bash
curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary 'cpu_load_short,host=server02 value=0.67
cpu_load_short,host=server02,region=us-west value=0.55 1422568543702900257
cpu_load_short,direction=in,host=server01,region=us-west value=2.0 1422568543702900257'
```

### 从文件写入Points

通过传递`@filename`到文件来写入文件中的Points`curl`，文件中的数据应遵循[InfluxDB line protocol syntax](/influxdb/v1.8/write_protocols/write_syntax/).

格式正确的文件（`cpu_data.txt`）的示例：

```txt
cpu_load_short,host=server02 value=0.67
cpu_load_short,host=server02,region=us-west value=0.55 1422568543702900257
cpu_load_short,direction=in,host=server01,region=us-west value=2.0 1422568543702900257
```

写入数据cpu_data.txt到mydb与数据库

```bash
curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary @cpu_data.txt`
```

> 注意：如果您的数据文件具有超过5000个Points，则可能有必要将该文件拆分为多个文件，以便将数据批量写入influxdb，默认情况下，HTTP请求在五秒后超时，超时后，influxdb仍然将尝试写入这些点，但是不会确认它们已经成功写入

### 无架构设计

InfluxDB是schemaless 数据库.
可以随时添加新的measurements, tags, and fields at any time.
请注意：如果试图以不同于以前使用的类型写入数据（例如，向以前接收整数的字段写入字符串）Influxdb将拒绝这些数据

### 关于REST的说明

InfluxDB仅将HTTP用作方便且受到广泛支持的数据传输协议

现代web API已经解决了REST的难题，因为它可以满足常见的需求，随着端点数据的增长，对组织系统的需求变得迫切，REST是行业公认的用于组织大量端点的样式，这种一致性对那REST是一个约定，influxdb使用三个API端点，这个简单易懂的系统使用HTTP作为[InfluxQL](/influxdb/v1.8/query_language/spec/).的传输方法，influxdb api不会尝试成为RESTFUl.

### HTTP 响应摘要

* 2xx:如果收到写请求`HTTP 204 No Content`,
* 4xx: InfluxDB 无法处理该请求
* 5xx: 系统过载或严重损坏

#### 例子

```bash
curl -i -XPOST 'http://localhost:8086/write?db=hamlet' --data-binary 'tobeornottobe booleanonly=true'

curl -i -XPOST 'http://localhost:8086/write?db=hamlet' --data-binary 'tobeornottobe booleanonly=5'
```

返回

```bash
HTTP/1.1 400 Bad Request
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 01 Mar 2017 19:38:01 GMT
Content-Length: 150

{"error":"field type conflict: input field \"booleanonly\" on measurement \"tobeornottobe\" is type float, already exists as type boolean dropped=1"}
```

##### 将Point写入不存在的数据库

```bash
curl -i -XPOST 'http://localhost:8086/write?db=atlantis' --data-binary 'liters value=10'
```

返回:

```bash
HTTP/1.1 404 Not Found
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 01 Mar 2017 19:38:35 GMT
Content-Length: 45

{"error":"database not found: \"atlantis\""}
```

### 后续步骤

现在已经知道了如何使用 InfluxDB AP编写数据，请使用 [Querying data](/influxdb/v1.8/guides/querying_data/) 指南了解如何查询它们！
有关使用 InfluxDB API写入数据的更多信息，请参见 [InfluxDB API 引文](/influxdb/v1.8/tools/api/#write-http-endpoint).

