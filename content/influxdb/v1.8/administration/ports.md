---
title: InfluxDB 端口
description: Enabled and disabled ports in InfluxDB.
menu:
  influxdb_1_8:
    name: 端口
    weight: 50
    parent: 管理
---

## 启用的端口

### `8086`
运行Influxdb HTTP服务的默认端口，在配置文件中
[配置此端口](/influxdb/v1.8/administration/config#bind-address-8086)

**参考资料** [API 参考](/influxdb/v1.8/tools/api/)

### 8088
RPC服务用语CLI进行的RPC和RPC调用的默认端口，用于备份和还原操作 (`influxdb backup` 和 `influxd restore`).
[在配置文件中配置此端口](/influxdb/v1.8/administration/config#bind-address-127-0-0-1-8088)

**参考资料** [备份 和 还原](/influxdb/v1.8/administration/backup_and_restore/)

## 禁用的端口

### 2003

运行Graphite服务的默认端口，在配置文件中启用并配置此端口
[启用并配置此端口](/influxdb/v1.8/administration/config#bind-address-2003)

**参考资料** [Graphite 自述文件](https://github.com/influxdata/influxdb/tree/1.8/services/graphite/README.md)

### 4242

运行 OpenTSDB 服务的默认端口.
[在配置文件中启用并配置此端口](/influxdb/v1.8/administration/config#bind-address-4242)

**参考资料** [OpenTSDB自述文件](https://github.com/influxdata/influxdb/tree/1.8/services/opentsdb/README.md)

### 8089

运行 UDP 服务的默认端口.
[在配置文件中启用并配置此端口](/influxdb/v1.8/administration/config#bind-address-8089)

**参考资料** [UDP 自述文件](https://github.com/influxdata/influxdb/tree/1.8/services/udp/README.md)

### 25826

运行收集的服务的默认端口，在配置文件中启用并配置此端口，[启用并配置此端口](/influxdb/v1.8/administration/config#bind-address-25826).

**参考资料** [Collectd 自述文件](https://github.com/influxdata/influxdb/tree/1.8/services/collectd/README.md)

