---
title: InfluxDB中的UDP协议支持
description: Overview of support for UDP protocol in InfluxDB.
aliases:
  - /influxdb/v1.8/tools/udp/
  - /influxdb/v1.8/write_protocols/udp/
menu:
  influxdb_1_8:
    name: UDP 协议支持
    weight: 50
    parent: 支持的协议
---

#  UDP 输入

## 关于操作系统缓冲区大小的说明

一些操作系统（尤其是Linux）对UDP协议的性能设置了非常严格的限制，强烈建议您在尝试向实例运行UDP流量之前，将这些操作系统限制至少增加到25Mb,

25Mb只是一个建议，应该进行调整以符合"读取缓冲区"插件设置

### Linux
通过键入以下命令，检查当前的UDP/IP接受缓冲区默认值和限制:

```
sysctl net.core.rmem_max
sysctl net.core.rmem_default
```

如果值小于24214400字节（25Mb），应该在/etc/sysctl.conf文件中添加以下行:

```
net.core.rmem_max=26214400
net.core.rmem_default=26214400
```

对`/etc/sysctl.conf '的更改在重新启动之前不会生效。要立即更新这些值，请以root用户身份键入以下命令:

```
sysctl -w net.core.rmem_max=26214400
sysctl -w net.core.rmem_default=26214400
```

### BSD/Darwin

在BSD/Darwin 系统上，需要在内核限制套接字缓冲区中添加大约15%的填充，例如，如果 要用25Mb的缓冲区 (26214400 字节) ，则需要将内核限制设置为 26214400*1.15 = 30146560`.这没有记录在任何地方，
[而是在此处内核中发生](https://github.com/freebsd/freebsd/blob/master/sys/kern/uipc_sockbuf.c#L63-L64).

#### 检查当前的 UDP/IP 缓冲区限制

要检查当前的UDP/IP缓冲区限制，请执行以下命令：

```
sysctl kern.ipc.maxsockbuf
```

如果该值小于30146560字节，则应在/etc/sysctl.conf文件中添加以下行（必要是创建）

```
kern.ipc.maxsockbuf=30146560
```

etc/sysctl.conf所做的更改要等到重新启动后才能生效。要立即更新值，请以超级用户身份键入以下命令

```
sysctl -w kern.ipc.maxsockbuf=30146560
```

### 使用 `read-buffer`UDP侦听的选项

该 `read-buffer`选项允许用户设置侦听器的缓冲区大小，它设置与UDP流量关联的操作系统的接受缓冲区大小，请记住，操作系统必须能够处理此处设置的数字，否则UDP侦听器将出错退出
设置会read-buffer =0 导致使用操作系统默认值，并且通常对于太高的UDP性能而言太小

## 组态

每个UDP输入都允许设置绑定地址，目标数据库和目标保留策略。如果数据库不存在，则在初始化输入时将自动创建该数据库。如果未配置保留策略，则使用数据库的默认保留策略。但是，如果设置了保留策略，则必须显式创建保留策略。输入将不会自动创建它。

每个UDP输入还对其接收的Point执行内部批处理，因为对数据库的批处理写入效率更高。默认批处理大小为1000，挂起的批处理因子为5，批处理超时为1秒。这意味着输入将写入最大大小为1000的批次，但是如果批次在添加到批次中的第一个Point后的1秒内未达到1000点，则它将发出该批次，而不管大小如何。待处理的批次因子控制一次可以在内存中存储多少批次，从而允许输入传输批次，同时仍建立其他批次

## 处理

UDP输入每次读取最多可以接收64KB，并按换行符拆分接收的数据。然后，每个部分都被解释为line-protocol编码点，并进行相应的解析

## UDP 无连接

由于UDP是无连接协议，因此如果发生任何错误，甚至无法成功索引数据，则无法向数据源发出信号。在决定是否以及何时使用UDP输入时应牢记这一Point。内置的UDP统计信息对于监视UDP输入很有用。

## 配置示例

**一个 UDP 监听配置**

```
# influxd.conf
...
[[udp]]
  enabled = true
  bind-address = ":8089" # the bind address
  database = "telegraf" # Name of the database that will be written to
  batch-size = 5000 # will flush if this many points get buffered
  batch-timeout = "1s" # will flush at least this often even if the batch-size is not reached
  batch-pending = 10 # number of batches that may be pending in memory
  read-buffer = 0 # UDP read buffer, 0 means to use OS default
...
```

**多个 UDP 监听配置**

```
# influxd.conf
...
[[udp]]
  # Default UDP for Telegraf
  enabled = true
  bind-address = ":8089" # the bind address
  database = "telegraf" # Name of the database that will be written to
  batch-size = 5000 # will flush if this many points get buffered
  batch-timeout = "1s" # will flush at least this often even if the batch-size is not reached
  batch-pending = 10 # number of batches that may be pending in memory
  read-buffer = 0 # UDP read buffer size, 0 means to use OS default

[[udp]]
  # High-traffic UDP
  enabled = true
  bind-address = ":8189" # the bind address
  database = "mymetrics" # Name of the database that will be written to
  batch-size = 5000 # will flush if this many points get buffered
  batch-timeout = "1s" # will flush at least this often even if the batch-size is not reached
  batch-pending = 100 # number of batches that may be pending in memory
  read-buffer = 8388608 # (8*1024*1024) UDP read buffer size
... [README](https://github.com/influxdata/influxdb/tree/1.8/services/udp/README.md)
```

