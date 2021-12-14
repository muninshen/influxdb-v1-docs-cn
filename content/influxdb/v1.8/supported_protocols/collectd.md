---
title: InfluxDB中的CollectD协议支持
description: >
  The collectd input allows InfluxDB to accept data transmitted in collectd native format.
aliases:
    - /influxdb/v1.8/tools/collectd/
menu:
  influxdb_1_8:
    name: CollectD协议支持
    weight: 10
    parent: 支持的协议
---

所述collectd输入允许InfluxDB接受collectd本机格式发送的数据。此数据通过UDP传输。

## 关于 UDP/IP 缓冲区大小的说明

如果您运行的是Linux或FreeBSD，请调整操作系统的UDP缓冲区大小限制, [有关更多详细信息，请参见此处.](/influxdb/v1.8/supported_protocols/udp/#a-note-on-udp-ip-os-buffer-sizes)

## 配置

每个收集的输入都允许设置绑定地址，目标databases和Retention policy，如果databases不存在，则在初始化输入时将自动创建该databases，如果未配置Retention policy，则使用databases的默认Retention policy，但是如果设置了Retention policy，则必须显示创建Retention policy，输入将不会自动创建它.

每个收集的输入还对其接受的Point执行内部批处理，因为对databases的批处理写入效率更高，默认批处理大小为1000，待批处理的处理因子为5，批处理超时为1秒，这意味着输入将写入最大大小为1000的批次，但是如果一个批次在添加到批次中的第一个Point后1秒内仍为达到1000点，则它将发出该批次而与大小无关，待处理的批次因子控制一次可以在内存中存储多少批次，从而允许输入传输批次，同时仍建立其他批次.

多值插件可以通过两种方式处理。将parse-multivalue-plugin设置为“ split”会将多值插件数据（例如df free：5000，used：1000）解析并存储到单独的测量值中（例如（df_free，value = 5000）（df_used，value = 1000）），而“联接”将解析并存储多值插件作为单个多值度量（例如（df，free = 5000，used = 1000））。向后兼容influxdb的早期版本的默认行为是“ split”。

也可以设置收集的类型databases文件的路径.

## 大型 UDP 数据包

请注意，大于1452的标准大小的UDP数据包在提取时会被丢弃，确保maxPaketSize在收集的配置中将其设置为1452

## 配置示列

```
[[collectd]]
  enabled = true
  bind-address = ":25826" # the bind address
  database = "collectd" # Name of the database that will be written to
  retention-policy = ""
  batch-size = 5000 # will flush if this many points get buffered
  batch-pending = 10 # number of batches that may be pending in memory
  batch-timeout = "10s"
  read-buffer = 0 # UDP read buffer size, 0 means to use OS default
  typesdb = "/usr/share/collectd/types.db"
  security-level = "none" # "none", "sign", or "encrypt"
  auth-file = "/etc/collectd/auth_file"
  parse-multivalue-plugin = "split"  # "split" or "join"
```

GitHub 上[README](https://github.com/influxdata/influxdb/tree/1.8/services/collectd/README.md) 的内容.
