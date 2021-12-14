---
title: 升级至 InfluxDB 1.8.x
description: 升级至 InfluxDB 最新版。
menu:
  influxdb_1_8:
    name: 升级 InfluxDB
    weight: 25
    parent: 管理
---


我们建议启用时间序列索引（TSI）升级到Influxdb 1.8.x的第三步骤【根据需要在TSM和TSI之间切换】（#开关-索引-类型）要了解有关TSI的更多信息，请参见:

- [时间序列索引（TSI）](/influxdb/v1.8/concepts/time-series-index/)
- [时间序列索引(TSI) 详细信息](/influxdb/v1.8/concepts/tsi-details/)

> **_Note:_** 默认配置继续使用带有内存中索引的基于TSM的分片

{{% note %}}
### 升级到 InfluxDB Enterprise（企业版）

要从InfluxDB OSS升级到InfluxDB Enterprise，[请联系influx data Sales](https://www . influx data . com/contact-Sales/) 并参见[迁移到InfluxDB Enterprise](/{{ <最新的"Enterprise _ Influxdb"> } }/指南/迁移/)。
{{% /note %}}

## 升级到 InfluxDB 1.8.x

1. [下载](https://portal . influx data . com/downloads)influx db 1.8 . x版和[安装升级版](/influx db/v 1.8/introduction/installation)。


2. 将配置文件自定义从现有配置文件迁移到Influxdb 1.8 . x[配置文件](/Influxdb/v 1.8/administration/config/)。根据需要添加或修改您的环境变量

3. 要在InfluxDB 1.8.x中启用TSI，请完成以下步骤:


    a.如果使用InfluxDB配置文件，找到`[数据]`部分，取消注释` index-version = "inmem " `并将值更改为` tsi1`。
    
    b.如果使用环境变量，将“INFLUXDB_DATA_INDEX_VERSION”设置为“tsi1”。 
    
    c.删除shards“索引”目录(默认位于/<shards_标识>/索引处)。 
    
    d.通过运行[influx db/v 1.8/tools/influx _ inspect/# build TSI]命令来构建TSI。

 > **Note** 使用运行数据库的用户帐户运行“buildtsi”命令，或者确保权限匹配。

5. 重新启动 `influxdb` 服务.

## 切换索引类型

通过执行以下操作之一，随时切换索引类型

- 要从“inmem”切换到“tsi1”，请完成以上[升级到influx db 1.8 . x](# Upgrade-to-influx db-1-8-x)中的步骤3和4
- To switch from to `tsi1` to `inmem`, change `tsi1` to `inmem` by completing steps 3a-3c and 4 above in [Upgrade to InfluxDB 1.8.x](#upgrade-to-influxdb-1-8-x).

## 降级 InfluxDB

降级到早期版本，请完成[升级到Influxdb 1.8 . x](# Upgrade-to-Influxdb-1-8-x)中的上述步骤，用要降级到的版本替换版本号。 下载版本、迁移配置设置并启用TSI或TSM后，请确保[重建索引](/influx db/v 1.8/administration/rebuild-TSI-index/)。

>**Note:** 某些版本的InfluxDB可能会有影响您升级和降级能力的重大更改。例如，您不能从InfluxDB 1.3或更高版本降级到早期版本。请查看适用版本的发行说明，以检查不同版本之间的兼容性问题。

## 升级 InfluxDB Enterprise 集群

参见 [升级 InfluxDB Enterprise 集群](/enterprise_influxdb/v1.8/administration/upgrading/).
