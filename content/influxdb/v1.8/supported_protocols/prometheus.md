---
title: InfluxDB中的Prometheus端点支持
description: Read and write Prometheus data in InfluxDB.
menu:
  influxdb_1_8:
    name: Prometheus协议支持
    weight: 40
    parent: 支持的协议
---

## Prometheus 远程读写API 接口支持

{{% warn %}}
注:普罗米修斯【API稳定性保证】(https://Prometheus.io/docs/Prometheus/latest/Stability/) 声明远程读取和远程写入端点是作为实验性功能列出的功能 或者易受变化影响，因此对于2x来说是不稳定的 将包含在InfluxDB发行说明中。
{{% /warn %}}

InfluxDB 对 Prometheus 远程读写 API 接口支持增加了一下内容传入数据库的HTTP端点：
HTTP endpoints to InfluxDB:

* `/api/v1/prom/read`
* `/api/v1/prom/write`

此外, 还有一个 [`/metrics` endpoint](/influxdb/v1.8/administration/server_monitoring/#influxdb-metrics-http-endpoint) 配置为以prometheus metrics 格式生成默认的GO metrics

### 创建目标数据库

在您的Influxdb实例中创建一个数据库，以容纳从Prometheus发送的数据，在下面提供的示例中，prometheus用作数据库名称，但是欢迎你使用任何数据库名称

```sql
CREATE DATABASE "prometheus"
```

### 配置

要使prometheus远程读写应用程序接口能够与Influxdb数据库一起使用，请将URL添加到prometheus配置文件中的以下设置

* [`remote_write`](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#%3Cremote_write%3E)
* [`remote_read`](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#%3Cremote_read%3E)

这些URL必须可从正在运行的Prometheus服务器上解析，并使用运行InfluxDB的端口（8086默认情况下）。还使用db=查询参数包括数据库名称。

#### 示例：Prometheus配置文件中的端点

```yaml
remote_write:
  - url: "http://localhost:8086/api/v1/prom/write?db=prometheus"

remote_read:
  - url: "http://localhost:8086/api/v1/prom/read?db=prometheus"
```

#### 使用身份验证读取和写入URL

如果在 [ InfluxDB启用了身份验证](/influxdb/v1.8/administration/authentication_and_authorization/),请分别使用和参数向具有读和写特权的Influxdb用户传递username和password u= p=

##### 启用身份验证的端点的示例**_  

```yaml
remote_write:
  - url: "http://localhost:8086/api/v1/prom/write?db=prometheus&u=username&p=password"

remote_read:
  - url: "http://localhost:8086/api/v1/prom/read?db=prometheus&u=username&p=password"
```

> 在Prometheus配置文件中包含纯文本密码并不理想，不幸的是，prometheus配置文件不支持环境变量和机密，有关更多信息，请参见prometheus问题:
> 
> [支持配置文件中的环境变量替换](https://github.com/prometheus/prometheus/issues/2357)

## 如何在Influxdb中解析Prometheus指标

将Prometheus数据导入Influxdb时，将进行一下转换以匹配Influxdb数据结构

* Prometheus数据导入Influxdb measurement名称
* 使用 (value) 字段键，Prometheus示例（值）将成为Influxdb字段，它总是浮点数
* Prometheus标签成为 InfluxDB tags.
* 全部 `# HELP 和所有` `# TYPE`行均被忽略
* [v1.8.6 and later] Prometheus 远程写入端点丢弃不支持的prometheus（`NaN,-Inf和+Inf`），而不是拒绝整个批次
  * 如果 [启用了写入跟踪日志记录 (`[http] write-tracing = true`)](/influxdb/v1.8/administration/config/#write-tracing-false), 则将记录丢失值的摘要.
  * 如果一批值包含随后丢弃的值，204则返回HTTP状态代码.

### 示例 ：将 Prometheus 解析为 InfluxDB

```shell
# Prometheus metric
example_metric{queue="0:http://example:8086/api/v1/prom/write?db=prometheus",le="0.005"} 308

# Same metric parsed into InfluxDB
measurement
  example_metric
tags
  queue = "0:http://example:8086/api/v1/prom/write?db=prometheus"
  le = "0.005"
  job = "prometheus"
  instance = "localhost:9090"
  __name__ = "example_metric"
fields
  value = 308
```

> 在 InfluxDB v1.5 和更早版本中，所有Prometheus 数据都进入一个名为_ measurement
> 中，并且Prometheus measurement名称存储在_name_标签中，在Influxdb v1.6或更高版本中.每个Prometheus measurement都有在Influxdb v1.6或更高版本中，每个Prometheus measurement都有其自己的Influxdb Measurement。

{{% warn %}}
此格式不同于 [Telegraf Prometheus 输入插件](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/prometheus).使用的格式
{{% /warn %}}