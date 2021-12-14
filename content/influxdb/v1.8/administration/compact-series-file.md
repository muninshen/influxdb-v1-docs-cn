---
title: 压缩series文件
description: >
  Use the `influx_inspect buildtsi -compact-series-file` command to compact your
  series file and reduce its size on disk.
menu:
  influxdb_1_8:
    weight: 67
    parent: 管理
    name: 压缩series文件
---

使用系列文件压缩工具压缩系列文件并减小其在磁盘上的大小，这对于快速增长的系列文件非常有用，例如，当series文件频繁创建和删除时

要压缩系列文件

1.  停止 `influxd` 进程

2.  运行以下命令，包括 **data 目录** 和 **WAL 目录**:

    ```sh
    # Syntax
    influx_inspect buildtsi -compact-series-file -datadir <data_dir> -waldir <wal_dir>

    # Example
    influx_inspect buildtsi -compact-series-file -datadir /data -waldir /wal
    ```

3. 重新启动Influxd进程.

4. **_(InfluxDB Enterprise only)_** 在每个数据节点:
   
    1. 完成步骤 1-3.
    2. 等待提示 [hinted handoff queue (HHQ)](/{{< latest "enterprise_influxdb" >}}/concepts/clustering/#hinted-handoff)将所有丢失的数据写入节点.
    3. 继续到下一个数据节点.
