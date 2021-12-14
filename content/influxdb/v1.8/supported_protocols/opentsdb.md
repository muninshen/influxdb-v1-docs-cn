---
title: InfluxDB中的OpenTSDB协议支持
description: >
  Use the OpenTSBD plugin to write data to InfluxDB using the OpenTSBD protocol.
aliases:
    - /influxdb/v1.8/tools/opentsdb/
menu:
  influxdb_1_8:
    name: OpenTSDB协议支持
    weight: 30
    parent: 支持的协议
---

## OpenTSDB Input

InfluxDB 支持telnet和HTTP Open TSDB协议，这意味着Influxdb可以替代Open TSDB系统.

## Configuration

OpenTSDB输入允许设置绑定地址，目标databases和该databases内的目标replication policy。如果databases不存在，则在初始化输入时将自动创建该databases。如果您还决定配置replication policy（不进行配置，输入将使用自动创建的默认replication policy），则databases和replication policy都必须已经存在

该`write-consistency-level`也可以设置，如果有任何写操作不符合配置的一致性保证，则会发生错误，并且不会对数据建立索引，默认的一致性级别为ONE；

OPenTSDB输入还对接收到的point执行内部处理，因为对databases的批处理写入效率更高，默认批处理大小为1000，挂起的批处理因子为5，批处理超时为1秒，这意味着输入将写入最大大小为1000的批次，但是如果批次在添加到批次中的第一个point后的1秒未达到1000point，则它将发出该批次，而不管大小如何，待处理的批次因子控制一次可以在内存中存储多少批次，从而允许输入传输批次，同时仍建立其它批次

## Telegraf OpenTSDB 输出插件
所述 [Telegraf OpenTSDB 输出插件](https://github.com/influxdata/telegraf/blob/release-1.11/plugins/outputs/opentsdb/README.md)输出OpenTSDB协议来Open TSDB端点，使用该插件写入Influxdb或者其他OpenTSDB兼容端点.

