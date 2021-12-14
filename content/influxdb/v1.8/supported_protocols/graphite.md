---
title: InfluxDB中的Graphite协议支持
description: >
  Use the Graphite plugin to write data to InfluxDB using the Graphite protocol.
aliases:
    - /influxdb/v1.8/tools/graphite/
    - /influxdb/v1.8/write_protocols/graphite/
menu:
  influxdb_1_8:
    name: Graphite协议支持
    weight: 20
    parent: 支持的协议
---

#  Graphite Input

## UDP/IP OS Buffer Sizes注释

如果您使用UDP输入并运行Linux或FreeBSD,请调整UDP缓冲区大小限制, [有关更多详细信息，请参见此处.](/influxdb/v1.8/supported_protocols/udp#a-note-on-udp-ip-os-buffer-sizes)

## 组态

每个Graphite输入都可以设置绑定地址，目标databases和协议。如果databases不存在，则在初始化输入时将自动创建该databases。还可以设置写一致性级别。如果有任何写操作不符合配置的一致性保证，则会发生错误，并且不会对数据建立索引。默认的一致性级别为ONE。

每个Graphite输入也会对接收到的Point进行内部批处理，因为批量写入databases的效率更高。默认批处理大小为1000，挂起的批处理因子为5，批处理超时为1秒。这意味着输入将写入最大大小为1000的批次，但是如果批次在添加到批次中的第一个Point后的1秒内未达到1000Point，则它将发出该批次，而不管大小如何。待处理的批次因子控制一次可以在内存中存储多少批次，从而允许输入传输批次，同时仍建立其他批次。

## 解析 Metrics

Graphite插件允许使用Graphite线协议保存measurement。默认情况下，启用Graphite插件将允许您收集指标并使用metric名称作为指标存储measurement。如果您发送名为的metric 标准servers.localhost.cpu.loadavg.10，它将存储完整的metric名称作为measurement，而不会提取tags。

尽管此默认设置有效，但由于它不利用tags，因此不是将measurement结果存储在InfluxDB中的理想方法。由于查询将被迫使用已知无法很好扩展的正则表达式，因此对于大数据集大小，它也不会有最佳性能。

要从指标中提取tags，必须配置一个或多个模板以将metrics解析为tag和measurements

## 模板

模板允许measurement标准的匹配部分用于存储的measurement标准中的tag keys，它们的格式类似于Graphite metric名称，分隔符之间的值用于tsg keys，与Graphite metric部分相同位置的tag key的位置用作该值，如果没有，则将跳过Graphite 部分

特殊值metric用于定义measurement，它可以带有尾随*以指示应使用metric的其余部分，如果未指定measurement，则使用完整的metric名称

### Basic Matching

`servers.localhost.cpu.loadavg.10`

* 模板: `.host.resource.measurement*`
* 输出:  _measurement_ =`loadavg.10` _tags_ =`host=localhost resource=cpu`

### 多重 Measurement & Tags匹配

该measurement可以在模板指定多次，以提供对measurement名称更多的控制，tag key也可以多次匹配，使用Separator config变量将多个值连接在一起，默认情况下，此值为 `.`

`servers.localhost.localdomain.cpu.cpu0.user`

* 模板: `.host.host.measurement.cpu.measurement`
* 输出: _measurement_ = `cpu.user` _tags_ = `host=localhost.localdomain cpu=cpu0`

由于 `.`要求对measurement查询使用双引号，因此可能需要将其设置_为简化查询已分析metrics的查询.

`servers.localhost.cpu.cpu0.user`

* 分隔符: `_`
* 模板: `.host.measurement.cpu.measurement`
* 输出: _measurement_ = `cpu_user` _tags_ = `host=localhost cpu=cpu0`

### 添加Tags

如果接受到的metric不存在其他tags，则可以将其添加到该metric，可以通过在模式之后指定他们来添加其tags，Tags的格式与line protocol相同，多个tags用逗号分隔.

`servers.localhost.cpu.loadavg.10`

* 模板: `.host.resource.measurement* region=us-west,zone=1a`
* 输出:  _measurement_ = `loadavg.10` _tags_ = `host=localhost resource=cpu region=us-west zone=1a`

### Fields

可以使用关键字field指定field key. 默认情况下，如果未指定field，则该metric将被写入名为value的field。

也可以通过指定field*（例如measurement.measurement.field*）从输入metric名称的第二个“half”导出field 关键字。不能与“measurement*”一起使用！

可以使用其他fields来修改measurement 指标，例如：

Input:
```
sensu.metric.net.server0.eth0.rx_packets 461295119435 1444234982
sensu.metric.net.server0.eth0.tx_bytes 1093086493388480 1444234982
sensu.metric.net.server0.eth0.rx_bytes 1015633926034834 1444234982
sensu.metric.net.server0.eth0.tx_errors 0 1444234982
sensu.metric.net.server0.eth0.rx_errors 0 1444234982
sensu.metric.net.server0.eth0.tx_dropped 0 1444234982
sensu.metric.net.server0.eth0.rx_dropped 0 1444234982
```

使用模板
```
sensu.metric.* ..measurement.host.interface.field
```

成为databases条目:
```
> select * from net
name: net
---------
time      host  interface rx_bytes    rx_dropped  rx_errors rx_packets    tx_bytes    tx_dropped  tx_errors
1444234982000000000 server0  eth0    1.015633926034834e+15 0   0   4.61295119435e+11 1.09308649338848e+15  0 0
```

## 多个模板

一个模板可能不匹配所有指标。例如，将多个插件与Diamond一起使用将产生不同格式的指标。如果需要使用多个模板，则需要定义一个前缀过滤器，该前缀过滤器必须匹配才能应用模板。

### 筛选器

过滤器的格式与模板相似，但更像通配符表达式，当多个过滤器将与一个指标匹配符.将选择更具体的一个，通过在模板之前添加过滤器来配置才能应用模板

例如

```
servers.localhost.cpu.loadavg.10
servers.host123.elasticsearch.cache_hits 100
servers.host456.mysql.tx_count 10
servers.host789.prod.mysql.tx_count 10
```
* `servers.*` 将匹配所有值
* `servers.*.mysql`会匹配`servers.host456.mysql.tx_count 10`
* `servers.localhost.*` 会匹配 `servers.localhost.cpu.loadavg`
* `servers.*.*.mysql`会匹配`servers.host789.prod.mysql.tx_count 10`

## 默认模板

如果未定义模板过滤器，或者您只想拥有一个基本模板，则可以定义一个默认模板。该模板将应用于尚未与过滤器匹配的任何指标r.

```
dev.http.requests.200
prod.myapp.errors.count
dev.db.queries.count
```

* `env.app.measurement*` 会创造
  * _measurement_=`requests.200` _tags_=`env=dev,app=http`
  * _measurement_= `errors.count` _tags_=`env=prod,app=myapp`
  * _measurement_=`queries.count` _tags_=`env=dev,app=db`

## 全局Tags

如果需要向所有metrics, 添加相同的tag set,则可以在插件级别全局定义它们，而不会在每个模板描述中定义

## 最低配置
```
[[graphite]]
  enabled = true
  # bind-address = ":2003"
  # protocol = "tcp"
  # consistency-level = "one"

  ### If matching multiple measurement files, this string will be used to join the matched values.
  # separator = "."

  ### Default tags that will be added to all metrics.  These can be overridden at the template level
  ### or by tags extracted from metric
  # tags = ["region=us-east", "zone=1c"]

  ### Each template line requires a template pattern.  It can have an optional
  ### filter before the template and separated by spaces.  It can also have optional extra
  ### tags following the template.  Multiple tags should be separated by commas and no spaces
  ### similar to the line protocol format.  The can be only one default template.
  # templates = [
  #   "*.app env.service.resource.measurement",
  #   # Default template
  #   "server.*",
 #]
```

## 自定义配置
```
[[graphite]]
   enabled = true
   separator = "_"
   tags = ["region=us-east", "zone=1c"]
   templates = [
     # filter + template
     "*.app env.service.resource.measurement",

     # filter + template + extra tag
     "stats.* .host.measurement* region=us-west,agent=sensu",

     # filter + template with field key
     "stats.* .host.measurement.field",

     # default template. Ignore the first Graphite component "servers"
     ".measurement*",
 ]
```

## 两个 Graphite 监听, UDP 和 TCP 配置

```
[[graphite]]
  enabled = true
  bind-address = ":2003"
  protocol = "tcp"
  # consistency-level = "one"

[[graphite]]
  enabled = true
  bind-address = ":2004" # the bind address
  protocol = "udp" # protocol to read via
  udp-read-buffer = 8388608 # (8*1024*1024) UDP read buffer size
```

GiHub 上[README](https://github.com/influxdata/influxdb/tree/1.8/services/graphite/README.md) 的内容
