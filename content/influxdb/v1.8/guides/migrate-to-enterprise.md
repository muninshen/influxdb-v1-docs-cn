---
title: 从InfluxDB OSS迁移到InfluxDB Enterprise
description: >
  Migrate your InfluxDB OSS instance with your data and users to InfluxDB Enterprise.
menu:
  influxdb_1_8:
    weight: 50
    parent: 指南
    name: InfluxDB OSS迁移到InfluxDB企业集群
---

将正在运行的Influxdb开源（OSS）实例迁移到Influxdb Enterprise集群
先决条件

* 运行**InfluxDB 1.7.10**或更高版本的Influxdb OSS实例
* 运行**InfluxDB Enterprise 1.7.10**或更高版本的influxdb Enterprise集群

- OSS示例与所有数据和元节点之间的网络可访问性
> 迁移执行以下操作：
> - 删除现有的Influxdb Enterprise数据节点中的数据
> - 将所有用户从OSS实例转移到Influxdb Enterprise集群
> -  需要OSS实例停机
迁移到InfluxDB Enterorise



完成以下任务：

1、 [将InflxuDB升级到最新版本](#Upgrade-InfluxDB-to-the-Latest-version )

2、[设置InfluxDB Enterprise元节点](#Set-up-InfluxDB-Enterprise-meta-nodes)

3、[设置InflxuDB  Enterprise数据节点](#Set-up-InfluxDB-Enterprise-data-nodes)

4、[在您的OSS实例上升级到InflxuDB二进制文件](#Upgrade-the-InfluxDB-binary-on-your-OSS-instance)

5、[将升级的OFF实例添加到InfluxDB Enterprise集群](#Add-the-upgraded-OSS-instance-to-the-InfluxDB-Enterprise-cluster)

6、[将现有的数据节点添加到集群](#Add-existing-data-nodes-back-to-the-cluster)

7、[重新平衡集群](#ARebalance-the-cluster)

## 将InflxuDB升级到最新版本
在继续之前，将influxdb升级到最新的稳定版本
* ` 升级Influxdb OSS`
* `升级Influxdb企业`
* `设置InfluxDB Enterprise元节点`

在您的Influxdb Enterprise集群中设置所有元节点，有关安装和设置元节点信息，请参阅[安装meta nodes](https://docs.influxdata.com/enterprise_influxdb/v1.8/install-and-deploy/production_installation/meta_node_installation/)

>## 将OSS实例添加到meta /etc/hosts文件
>
>当修改/etc/hosts/文件的每个元节点上，包括你的Influxdb OSS实例的IP和主机名，以便元节点可以与OSS实例进行通信

## 设置Influxdb Enterprise数据节点

如果你的InfluxDB Enterprise集群中没有任何现有的数据节点，请跳过

### 对于每个现有的数据节点

1、从Influxdb企业集群中删除数据节点，执行：

```
influxd-ctl remove-data <data_node_hostname>:8088
```

2、删除现有数据

在从集群删除的每个数据节点上，执行：

```
sudo rm -rf /var/lib/influxdb/{meta，data，hh}
```

3、重新创建数据目录

在从集群中中删除的每个数据节点上，执行：

```
sudo mkdir /var/lib/influxdb/{data，hh，meta}
```

4、确保文件权限正确

在从集群删除的每个数据节点上，执行：

```
sudo chown -R influxdb:influxdb /var/lib/influxdb
```

5、更新`/etc/hosts`文件

在每个数据节点上，将OSS实例的IP和主机名添加到/`etc/hosts`文件中，以允许数据节点与OSS实例进行通信；

## 将Influxdb OSS实例升级到Influxdb Enterprise

1、停止对Influxdb OSS实例的所有写入

2、停止`influxdb` 操作系统上运行的Influxdb services

```
sudo service influxdb stop 
```

3、删除influxdb OSS软件包

```
sudo apt-get remove influxdb
```

4、备份Influxdb OSS配置文件

如果具有influxdb OSS的自定义配置设置，请备份并保存好配置文件，**如果没有备份，在更新的Influxdb二进制文件时，将丢失自定义配置设置**

5、更新influxdb二进制文件

>更新Influxdb二进制文件将覆盖现有的配置文件，要保留自定义设置，请备份好配置文件

```bash
wget https://dl.influxdata.com/enterprise/releases/influxdb-data_1.8.2-c1.8.2_amd64.deb
sudo dpkg -i influxdb-data_1.8.2-c1.8.2_amd64.deb
```

6、更新配置文件

在`/etc/influxdb/influxdb.conf`配置文件中，设置：
- `hostname`数据节点的完整主机名
- `license-key`在`[enterprise]`在influxdbPortal上收到的许可证密钥的部分中，**或者**`license-path`在`[enterprise]`从influxdb Data接受的JSON许可证文件的本地路径部分中

>在`license-key`和`license-path`设置是相互排除的，一个必须被设置为空字符串

```
# Hostname advertised by this host for remote addresses.
# This must be accessible to all nodes in the cluster.
hostname="<data-node-hostname>"

[enterprise]
  # license-key and license-path are mutually exclusive,
  # use only one and leave the other blank
  license-key = "<your_license_key>"
  license-path = "/path/to/readable/JSON.license.file"
```

>将所有自定义设置从OSS配置文件的备份转移到新的Enterprise配置文件

7、更新`/etc/hosts`文件

所有元和数据节点添加到`/etc/hosts`文件中，以允许OSS实例与Influxdb Enterprise集群中的其他节点进行通信

8、启动数据节点

```
sudo service influxdb start 
```

## 将新的数据节点添加到集群

在将OSS实例升级到Inflxudb Enterprise之后，将节点添加到Enterprise集群

从集群中的meta node 运行

```
influxd-ctl add-data <new-data-node-hostname>:8088
```

此时会输出：

```
Added data node y at new-data-node-hostname:8088
```

将现有的数据节点添加回集群，如果从Influxdb Enterprise集群中删除了任何现有的数据节点，请将它们重新添加到集群中

从Influxdb Enterprise集群中的元节点，为每个数据节点运行一下命令：

```
influxdb-ctl add-data <the-hostname>：8088
```

此时会输出：

```
Added data node y at the-hostname:8088
```

验证所有节点现在是否都是集群的成员，执行：

```
influxd-ctl show
```

一旦添加到集群中，Influxdb就将会升级后的OSS节点上存储的数据与集群中的其他数据节点进行同步现有的数据可能要花费几分钟

## 重新平衡集群

1、使用`ALTER RETENTION POLICY`语句将所有现有的保留策略上的`复制因子`增加到集群中的数据节点的数量

2、`手动重新平衡集群`，以满足现有分片所需的复制因子

3、如果使用的是`chronorgraf`，则将Enterprise实例添加为新的数据源









