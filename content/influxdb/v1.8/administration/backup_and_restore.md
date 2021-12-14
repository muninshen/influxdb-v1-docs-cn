---
title: InfluxDB OSS 备份和还原
description: >
  To prevent unexpected data loss, back up and restore InfluxDB OSS instances.
aliases:
  - /influxdb/v1.8/administration/backup-and-restore/
menu:
  influxdb_1_8:
    name: 备份与还原
    weight: 60
    parent: 管理
---

## 总览

InfluxDB OSS `backup` 实用程序提供:

* 选择在联机（实时）数据库上运行备份和还原功能
* 单个或多个数据库的备份和还原功能，以及可选的时间戳筛选
* 可以从 [InfluxDB Enterprise](/{{< latest "enterprise_influxdb" >}}/) 集群导入数据
* 可以导入Influxdb Enterprise数据库的备份文件.

> **InfluxDB Enterprise 用户:** 请参阅 [ InfluxDB Enterprise备份和还原](/{{< latest "enterprise_influxdb" >}}/administration/backup-and-restore/).

> ***Note:*** 在InfluxDB OSS 1.5之前，该backup实用程序创建的备份文件格式与InfluxDB Enterprise不兼容。新backup实用程序仍支持此旧格式，作为新的联机还原功能的输入。不推荐使用InfluxDB OSS 1.4版或更早版本中的脱机备份和还原实用程序，但下面在向后兼容的脱机备份和还原中对此进行了说明。

## 在线备份和还原 (用于 InfluxDB OSS)

使用`backup`和`restore`实用程序在Influxdb具有相同版本或仅有较小版本差异的实例之间备份和还原，例如，可以从1.7.3备份并在1.8.0上还原。

### 配置远程连接

联机备份和还原过程通过与数据库的TCP连接执行

**要为备份和还原过程通过与数据库的TCP连接执行:**

1. 在Influxdb配置文件 (`influxdb.conf`)的根级别上 ，取消注释远程节点上的[`bind-address` 配置注释](/influxdb/v1.8/administration/config#bind-address-127-0-0-1-8088)

2. 将 `bind-address` 值更新为 `<remote-node-IP>:8088`

3. 运行命令时，请为`-host`参数提供IP地址和端口

**例**

```
$ influxd backup -portable -database mydatabase -host <remote-node-IP>:8088 /tmp/mysnapshot
```

### `backup`

`backup` 生成带有过滤选项的Influxdb Enterprise兼容格式，以限制导出到备份的数据点的范围，backup将以下内容创建并存储在指定的目录（文件名在创建时包括UTC时间戳记）

 - 磁盘上的metastore 副本**: 20060102T150405Z.meta (包括用户名和密码）
 - 磁盘上的分片数据副本: 20060102T150405Z.<shard_id>.tar.gz
 - 清单 (JSON file) 描述了收集的备份数据: 20060102T150405Z.manifest

>**Note:** `backup`忽略了WAL文件和内存中的缓存数据

```
influxd backup
    [ -database <db_name> ]
    [ -portable ]
    [ -host <host:port> ]
    [ -retention <rp_name> ] | [ -shard <shard_ID> -retention <rp_name> ]
    [ -start <timestamp> [ -end <timestamp> ] | -since <timestamp> ]
    <path-to-backup>
```

要调用新的Influxdb Enterprise兼容格式，请运行influxdb backup带有-portable标志的命令，如下所示:

```
influxd backup -portable [ arguments ] <path-to-backup>
```

##### 争论

可选参数放在方括号中

- `[ -database <db_name> ]`:要备份的数据库。如果未指定，则备份所有数据库。

- `[ -portable ]`: 以较新的InfluxDB Enterprise兼容格式生成备份文件。强烈建议所有InfluxDB OSS用户使用。

{{% warn %}}
重要提示：如果-portable未指定，则使用默认的旧式备份实用程序-除非-database指定，否则仅备份主机元存储。如果不使用-portable，请查看下面的“备份（旧版）”以了解预期的行为。
{{% /warn %}}

- `[ -host <host:port> ]`: InfluxDB OSS实例的主机和端口。默认值为'127.0.0.1:8088'。远程连接所必需。例：-host 127.0.0.1:8088

- `[ -retention <rp_name> ]`: 备份的保留策略。如果未指定，则默认为使用所有保留策略。如果指定，-database则为必需。

- `[ -shard <ID> ]`: 要备份的分片的分片ID。如果指定，-retention <name>则为必需。

- `[ -start <timestamp> ]`:包括所有从指定时间戳记开始的点（RFC3339格式）。与不兼容-since。例：-start 2015-12-24T08:12:23Z

- `[ -end <timestamp> ]` ]: 排除指定时间戳记（RFC3339格式）之后的所有结果。与不兼容-since。如果不使用-start，则将从1970-01-01开始备份所有数据。例：-end 2015-12-31T08:12:23Z

- `[ -since <timestamp> ]`: 在指定的时间戳记RFC3339格式之后执行增量备份。-start除非有旧版备份支持，否则请改用。

#### 备份范例

**备份所有内容:**

```
influxd backup -portable <path-to-backup>
```

**备份文件系统级别最近更改的所有的数据库**

```
influxd backup -portable -start <timestamp> <path-to-backup>
```

仅备份`telegraf`数据库:**

```
influxd backup -portable -database telegraf <path-to-backup>
```

**指定时间间隔内备份数据库:**

```
influxd backup  -portable -database mytsd -start 2017-04-28T06:49:00Z -end 2017-04-28T06:50:00Z /tmp/backup/influxdb
```

### `restore`

通过使用restore带有-portable参数（指示新的企业兼容备份格式）或-online标志（指示传统备份格式）的命令开始还原过程

```
influxd restore [ -db <db_name> ]
    -portable | -online
    [ -host <host:port> ]
    [ -newdb <newdb_name> ]
    [ -rp <rp_name> ]
    [ -newrp <newrp_name> ]
    [ -shard <shard_ID> ]
    <path-to-backup-files>
```
{{% warn %}}
恢复指定时间段的备份 (使用 `-start` and `-end`)

使用`-start`或`-end`参数指定时间间隔的备份是在数据块上执行的，而不是逐点执行。由于大多数块都是高度压缩的，因此提取每个块以检查每个点会给正在运行的系统造成计算和磁盘空间负担。每个数据块都以该块中包含的时间间隔的开始和结束时间戳记进行注释。当指定时间戳`-start`或`-end`时间戳时，将备份所有指定的数据，但是也会备份同一块中的其他数据点。

**预期行为**

- 还原数据时，可能会看到指定时间段之外的数据
- 如果备份文件中包含重复的数据point，则将再次写入这些point，从而覆盖所有现有的数据.
{{% /warn %}}

#### 争论

可选参数放在方括号中

- `-portable`: 对于Influxdb OSS使用新的企业兼容备份格式。推荐使用而不是-online,可以将在Influxdb Enterprise上创建的备份到还原Influxdb OSS实例

- `-online`:使用旧版备份格式，仅在-portable无法使用较新的选项使用。

- `[ -host <host:port> ]`: Influxdb OSS实例的主机和端口，默认值为:  127.0.0.1:8088`，远程连接所必须。例：-host 127.0.0.1:8088

- `[ -db <db_name> | -database <db_name> ]`: 要从备份还原的数据库名称，如果未指定，将还原所有数据库

- `[ -newdb <newdb_name> ]`: 将目标系统上导入存档数据的数据库名称，如果未指定，则使用的值-db，新的数据库名称对于目标系统必须是唯一的。

- `[ -rp <rp_name> ]`:将从备份中恢复的保留策略的名称，需要-db设置，如果未指定，将使用所有保留策略；

- `[ -newrp <newrp_name> ]`: 要在目标系统上创建保留策略的名称，需要-rp设置，如果未指定，则使用该-rp值

- `[ -shard <shard_ID> ]`: 要恢复的分片的分片ID，如果指定，则-db和-rp是必须的

> **Note:** 如果基于旧格式的自动备份，请考虑将新的联机功能用于旧备份，新的备份实用程序使你可以将单个数据库还原到活动（在线）实例，同时将服务器上的所有现有数据进行保留到原位，该脱机还原方法可能会导致数据丢失，因为它清除服务器上的所有现有的数据库。

#### 恢复示例

**要还原在备份目录中找到所有数据库:**

```
influxd restore -portable path-to-backup
```

**要仅还原 `telegraf` 数据库 (telegraf 数据库必须不存在):**

```
influxd restore -portable -db telegraf path-to-backup
```

**要将数据还原到已经存在的数据库:**

不能直接还原到已经存在的数据库中，如果尝试将restore命令运行到现有的数据库中，则会收到以下信息:

```
influxd restore -portable -db existingdb path-to-backup

2018/08/30 13:42:46 error updating meta: DB metadata not changed. database may already exist
restore: DB metadata not changed. database may already exist
```

1. 将现有的数据备份还原到临时数据库

    ```
    influxd restore -portable -db telegraf -newdb telegraf_bak path-to-backup
    ```
2. 侧向加载数据 (使用 `SELECT ... INTO` 语句) 放入现有目标数据库，并删除临时数据库

    ```
    > USE telegraf_bak
    > SELECT * INTO telegraf..:MEASUREMENT FROM /.*/ GROUP BY *
    > DROP DATABASE telegraf_bak
    ```

要恢复到已存在的保留策略，请执行以下操作:**

1. 将保留策略还原到临时数据库

    ```
    influxd restore -portable -db telegraf -newdb telegraf_bak -rp autogen -newrp autogen_bak path-to-backup
    ```
2. 侧向加载到目标数据库并删除临时数据库

    ```
    > USE telegraf_bak
    > SELECT * INTO telegraf.autogen.:MEASUREMENT FROM /telegraf_bak.autogen_bak.*/ GROUP BY *
    > DROP DATABASE telegraf_bak
    ```
    
    

### 向后兼容的离线备份和恢复（传统格式）

> ***Note:*** 下面记录的Influxdb OSS 数据库操作系统的向后兼容备份和恢复已被否决。InfluxData公司建议对influxdb数据库操作系统服务器使用更新的企业兼容备份和恢复实用程序。.

InfluxDB OSS 操作系统能够在某个时间点对实例进行快照和恢复，所有备份都是完整备份的，不支持增量备份，可能备份两种类型的数据，`metastore`和`measurement本身`，元存储被完整备份，这些指标是独立于metastore备份的操作中基于每个数据库进行备份

#### 备份metastore

Influxdb OSS元存储包含有关系统状态的内部信息，包含用户信息，数据库和分片元数据，连续查询，保留策略和订阅，在节点运行时，可以通过运行一下命令来创建实例的元存储的备份；

```
influxd backup <path-to-backup>
```

其中 `<path-to-backup>` 是你希望备份要写入目录，没有任何其他参数，备份将仅记录系统云存储库的当前状态，例如，命令：

```bash
$ influxd backup /tmp/backup
2016/02/01 17:15:03 backing up metastore to /tmp/backup/meta.00
2016/02/01 17:15:03 backup complete
```

将在目录中创建一个metastore备份 `/tmp/backup` (如果目录不存在，则将创建该目录).

#### Backup (旧版)

每个数据库都必须单独备份.

要备份数据库，请添加-database` 标志:

```bash
influxd backup -database <mydatabase> <path-to-backup>
```

其中 `<mydatabase>`是你想要备份的数据库的名称，并且 `<path-to-backup>`是在备份数据应该存储.

可选标志还包括:

- `-retention <retention-policy-name>`
  - 此标志可以用于备份特定的保留策略, 有关保留策略的更多信息，请参阅
  [保留策略管理](/influxdb/v1.8/query_language/manage-database/#retention-policy-management). 如果未指定，则将备份所有保留策略；

- `-shard <shard ID>` 此标志可用于备份特定的分片ID，要查看可用的分片，可以SHOW SHARDS使用Influxdb查询语言运行命令，如果未指定，将备份所有分片。
  
- `-since <date>` - 自特定日期起，此标志可用于 创建备份，该日期必须为RFC3339（https://www.ietf.org/rfc/rfc3339.txt）格式（例如`2015-12-24T08:12:23Z`). 如果要对数据库进行增量备份，则此标志很重要，如果未指定，将备份数据库中的所有时间范围

> **Note:** Metastore备份也包含在每个数据库的备份中

作为一个实际示例，可以使用以下命令autogen为telegraf自2016年2月1日午夜UTC开始以来的数据库保留策略备份：

```
$ influxd backup -database telegraf -retention autogen -since 2016-02-01T00:00:00Z /tmp/backup
2016/02/01 18:02:36 backing up rp=default since 2016-02-01 00:00:00 +0000 UTC
2016/02/01 18:02:36 backing up metastore to /tmp/backup/meta.01
2016/02/01 18:02:36 backing up db=telegraf rp=default shard=2 to /tmp/backup/telegraf.default.00002.01 since 2016-02-01 00:00:00 +0000 UTC
2016/02/01 18:02:36 backup complete
```

会将生成的备份发送到 `/tmp/backup`, 然后可以对其进行压缩并发送到长期存储.

#### 远程备份 (旧版)

旧事备份模式还支持实时远程备份功能，请按照上面的配置远程连接中的说明配置此功能

## 恢复 (旧版)

{{% warn %}} 此处描述的此脱机还原方法可能会导致数据丢失-清除服务器上所有现有的数据库，参考`-online`标志与更新的restore方法 一起使用，以导入旧数据，而不会丢失任何数据
{{% /warn %}}

要还原备份，将需要使用influxd restore命令

> **Note:** 仅在Influxdb守护程序停止时才支持从备份还原.

要从备份还原，需要制定备份的类型，应将备份还原到的路径以及备份的路径，命令：

```
influxd restore [ -metadir | -datadir ] <path-to-meta-or-data-directory> <path-to-backup>
```

恢复备份所需要的标志是:

- `-metadir <path-to-meta-directory>` - 这是您要将metastore备份恢复到的meta目录的路径。对于打包安装，应将其指定为
  /var/lib/influxdb/meta。
- `-datadir <path-to-data-directory>` - 这是您要将数据库备份恢复到的数据目录的路径。对于打包安装，应将其指定为
  /var/lib/influxdb/data。

用于还原备份的可选标志为:

- `-database <database>` - 这是您要将数据还原到的数据库。如果没有`-metadir`选项，则此选项是必需的
  
- `-retention <retention policy>` -这是要还原到的存储数据的目标保留策略
  
- `-shard <shard id>` - 这是应该还原的Shard数据。如果指定，`database`和`retention`也必须设置

按照上面的备份示例，可以分两个步骤还原备份

1. 需要恢复metastore，以便InfluxDB知道存在哪些数据库

```
$ influxd restore -metadir /var/lib/influxdb/meta /tmp/backup
Using metastore snapshot: /tmp/backup/meta.00
```

2. metastore恢复后，现在就可以恢复备份的数据，在上面的真实示例中，我们将telegraf数据库备份到/tem/backup，因此让我们还原相同的数据集:

```
$ influxd restore -database telegraf -datadir /var/lib/influxdb/data /tmp/backup
Restoring from backup /tmp/backup/telegraf.*
unpacking /var/lib/influxdb/data/telegraf/default/2/000000004-000000003.tsm
unpacking /var/lib/influxdb/data/telegraf/default/2/000000005-000000001.tsm
```

> **Note:** 一旦恢复了备份的数据，分片上的权限可能不在准确，为确保文件权限正确，请运行一下命令: `$ sudo chown -R influxdb:influxdb /var/lib/influxdb`

恢复数据和metastore后，启动Influxdb:

```bash
$ service influxdb start
```

另外可以通过运行`SHOW DATABASES`命令来验证数据库是否已存在:

```
influx -execute 'show databases'
name: databases
---------------
name
_internal
telegraf
```

数据库已成功还原！
