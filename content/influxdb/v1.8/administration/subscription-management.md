---
title: 管理InfluxDB中的订阅
description: >
  Manage subscriptions, which copy all written data to a local or remote endpoint, in InfluxDB OSS.
menu:
  influxdb_1_8:
    parent: 管理
    name: 订阅管理
    weight: 100
---

InfluxDB 数据库是订阅本地或远程端点，写入Influxdb的所有数据都被复制到这些端点

订阅主要用于[kapacitor]（/kapacitor）,但任何端点能够接受UDP，HTTP或HTTPS连接的用户可以订阅Influxdb并接收，所有数据写入副本时；

## 订阅是如何工作的

当数据被写入Influxdb时，写入将通过复制到订户端点HTTP，HTTPS, 或UDP in [line protocol](/influxdb/v1.8/write_protocols/line_protocol_tutorial/).
Influxdb订户服务创建多个"写入着" ([goroutines](https://golangbot.com/goroutines/))
它向订阅端点发送写操作；

写线程的数量由写并发配置定义 [`write-concurrency`](/influxdb/v1.8/administration/config#write-concurrency-40)._

当写入发生在Influxdb数据库中时，每个订阅编写器都会将写入的数据发送到指定的订阅端点。然而，由于高“写入并发性"（多个写入器）和高摄取率。写入进程和传输层可能会产生纳秒级的差异，无序接受写入

> #### 有关高写入负载的重要信息
> 虽然将订阅服务器设置`write-concurrency`为大于1确实会增加订阅服务器的写入吞吐量，但是在高接收速率下可能导致乱序写入。设置`write-concurrency`为1可以确保写入顺序地传递到订户端点，但是会在高接收速率下造成瓶颈。
> 
> `write-concurrency`应该设置为什么取决于您的特定工作负载以及对订阅端点进行有序写入的需要

## InfluxQL 订阅声明

使用以下Influxdb语句来管理订阅:

[`CREATE SUBSCRIPTION`](#create-subscriptions)  
[`SHOW SUBSCRIPTIONS`](#show-subscriptions)  
[`DROP SUBSCRIPTION`](#remove-subscriptions)  

## 创建subscriptions

使用 `CREATE SUBSCRIPTION` InfluxQ 语句创建订阅.指定订阅名称，要订阅的数据库名称和保留策略，以及将写入Influxdb的数据复制到的主机URL

```sql
-- Pattern:
CREATE SUBSCRIPTION "<subscription_name>" ON "<db_name>"."<retention_policy>" DESTINATIONS <ALL|ANY> "<subscription_endpoint_host>"

-- Examples:
-- Create a SUBSCRIPTION on database 'mydb' and retention policy 'autogen' that sends data to 'example.com:9090' via HTTP.
CREATE SUBSCRIPTION "sub0" ON "mydb"."autogen" DESTINATIONS ALL 'http://example.com:9090'

-- Create a SUBSCRIPTION on database 'mydb' and retention policy 'autogen' that round-robins the data to 'h1.example.com:9090' and 'h2.example.com:9090' via UDP.
CREATE SUBSCRIPTION "sub0" ON "mydb"."autogen" DESTINATIONS ANY 'udp://h1.example.com:9090', 'udp://h2.example.com:9090'
```
如果在订阅者主机上启用了身份验证，请修改URL以包含凭据

```
-- Create a SUBSCRIPTION on database 'mydb' and retention policy 'autogen' that sends data to another InfluxDB on 'example.com:8086' via HTTP. Authentication is enabled on the subscription host (user: subscriber, pass: secret).
CREATE SUBSCRIPTION "sub0" ON "mydb"."autogen" DESTINATIONS ALL 'http://subscriber:secret@example.com:8086'
```

{{% warn %}}
`SHOW SUBSCRIPTIONS` 以纯文本格式输出所有的订户URL，包括带有身份验证凭据的URL,任何具有运行特权的用户
{{% /warn %}}

### 将订阅数据发送到多个主机

该 `CREATE SUBSCRIPTION`语句允许您将多个主机指定为预定的端点.在DESTINATIONS子句中，可以传递跨多个主机字符串，以逗号分隔，在子句中使用ALL或决定Influxdb如何将数据写入每个端点：ANY DESTNATIONS

`ALL`:将数据写入所指定的主机

`ANY`: 循环在指定主机之间写入.

_**具有多个主机订阅**_

```sql
-- Write all data to multiple hosts
CREATE SUBSCRIPTION "mysub" ON "mydb"."autogen" DESTINATIONS ALL 'http://host1.example.com:9090', 'http://host2.example.com:9090'

-- Round-robin writes between multiple hosts
CREATE SUBSCRIPTION "mysub" ON "mydb"."autogen" DESTINATIONS ANY 'http://host1.example.com:9090', 'http://host2.example.com:9090'
```

### 订阅协议

订阅可以使用HTTP，HTTPS或者UDP传输协议，使用哪个由订阅端点期望的协议确定，如果创建Kapacitor订阅，则由subscription-protocol的[[influxdb]]部分中的选项定义kapacitor.conf.

_**kapacitor.conf**_

```toml
[[influxdb]]

  # ...

  subscription-protocol = "http"

  # ...

```

有关HTTPS连接和Influxdb与Kapacitor之间的安全通信的信息，请参阅Kapacitor安全文档
view the [Kapacitor security](/kapacitor/v1.5/administration/security/#secure-influxdb-and-kapacitor) documentation._

## 显示订阅

该SHOW SUBSCRIPTIONS` InfluxQL 语句返回Influxdb注册的所有订阅列表.

```sql
SHOW SUBSCRIPTIONS
```

输出示例

```bash
name: _internal
retention_policy name                                           mode destinations
---------------- ----                                           ---- ------------
monitor          kapacitor-39545771-7b64-4692-ab8f-1796c07f3314 ANY  [http://localhost:9092]
```

## 删除订阅

使用  `DROP SUBSCRIPTION` InfluxQL 语句删除或者删除订阅.

```sql
-- Pattern:
DROP SUBSCRIPTION "<subscription_name>" ON "<db_name>"."<retention_policy>"

-- Example:
DROP SUBSCRIPTION "sub0" ON "mydb"."autogen"
```

### 删除所有订阅

在某些情况下，可能有必要删除所有订阅，运行一下influxdb CLI的bash脚本，循环遍历所有订阅，然后将其删除，该脚本取决于$INFLUXUSER和$INFLUXPASS环境变量。如果未设置，则将其导出为脚本的一部分。

```bash
# Environment variable exports:
# Uncomment these if INFLUXUSER and INFLUXPASS are not already globally set.
# export INFLUXUSER=influxdb-username
# export INFLUXPASS=influxdb-password

IFS=$'\n'; for i in $(influx -format csv -username $INFLUXUSER -password $INFLUXPASS -database _internal -execute 'show subscriptions' | tail -n +2 | grep -v name); do influx -format csv -username $INFLUXUSER -password $INFLUXPASS -database _internal -execute "drop subscription \"$(echo "$i" | cut -f 3 -d ',')\" ON \"$(echo "$i" | cut -f 1 -d ',')\".\"$(echo "$i" | cut -f 2 -d ',')\""; done
```

## Configure InfluxDB subscriptions（配置订阅）

InfluxDB订阅配置选项在的[subscriber]
部分中可用influxdb.conf。为了使用字幕，enabled该[subscriber]部分中的选项必须设置为true。以下是示例influxdb.conf订户配置：

```toml
[subscriber]
  enabled = true
  http-timeout = "30s"
  insecure-skip-verify = false
  ca-certs = ""
  write-concurrency = 40
  write-buffer-size = 1000
```

_**有关 `[subscriber]` 配置选项说明，请参见 [Configuring InfluxDB](/influxdb/v1.8/administration/config#subscription-settings) **_

## 故障排除

### 无法访问或停用的订阅端点

除非订阅下降，InfluxDB假设端点应该始终接收数据，并会继续尝试发送数据。如果端点主机不可访问或已停用，您将看到与以下内容类似的错误：

```bash
# Some message content omitted (...) for the sake of brevity
"Post http://x.y.z.a:9092/write?consistency=...: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)" ... service=subscriber
"Post http://x.y.z.a:9092/write?consistency=...: dial tcp x.y.z.a:9092: getsockopt: connection refused" ... service=subscriber
"Post http://x.y.z.a:9092/write?consistency=...: dial tcp 172.31.36.5:9092: getsockopt: no route to host" ... service=subscriber
```

在某些情况下，这可能是由于网络错误或者类似原因导致无法成功连接到订阅终结点引起来的，在其他情况下，这是因为订阅端点不再存在并且没有从Influxdb中删除订阅

> 因为Influxdb不知道订阅端点是否可以再次访问，所以当端点变得不可访问时，订阅不会自动删除，如果删除level订阅端点，则必须要从influxdb中删除订阅 [drop the subscription](#remove-subscriptions)
