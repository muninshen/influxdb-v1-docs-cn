---
title: 安装InfluxDB开源（OSS）版本
description: 安装、启动并配置InfluxDB开源（OSS）版本。
menu:
  influxdb_1_8:
    name: 安装
    weight: 20
    parent: 介绍
aliases:
  - /influxdb/v1.8/introduction/installation/
---

该页面提供了安装、配置、启动InfluxDB OSS的指导。

## InfluxDB OSS 安装要求

安装InfluxDB软件包，需要具有`root`用户或管理员权限。

### InfluxDB OSS 网络端口

默认情况下, InfluxDB 使用以下网络端口

- TCP 端口`8086`：用于客户端-服务端的InfluxDB API通信
- TCP 端口`8088`：用于RPC服务执行备份和还原操作

除上述端口外，InfluxDB还提供了多个插件，这些插件可能需要[自定义端口](/influxdb/v1.8/administration/ports/)。可以通过[配置文件](/influxdb/v1.8/administration/config/)修改所有端口映射，该文件位于默认安装位置`/etc/influxdb/influxdb.conf`。

### 网络时间协议 (NTP)

InfluxDB 使用UTC中主机的本地时间为数据分配时间戳。网络时间协议（NTP）在主机间同步时间；如果主机中的时钟未与NTP同步，则写入InfluxDB的数据上的时间戳可能不准确。

## 安装 InfluxDB OSS

对于不想安装任何软件并想使用InfluxDB的用户，可以查看[托管的InfluxDB产品](https://cloud.influxdata.com)

{{< tabs-wrapper >}}
{{% tabs %}}
[Ubuntu & Debian](#)
[Red Hat & CentOS](#)
[SLES & openSUSE](#)
[FreeBSD/PC-BSD](#)
[macOS](#)
{{% /tabs %}}
{{% tab-content %}}
有关如何从文件安装Debian软件包的说明,
请看
[下载页面](https://influxdata.com/downloads/).

Debian和Ubuntu用户可以使用`apt-get`软件管理程序安装InfluxDB的最新稳定版本

对于Ubuntu用户，使用以下命令添加InfluxData的仓库:

{{< code-tabs-wrapper >}}
{{% code-tabs %}}
[wget](#)
[curl](#)
{{% /code-tabs %}}
{{% code-tab-content %}}
```bash
wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
```
{{% /code-tab-content %}}

{{% code-tab-content %}}
```bash
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
```
{{% /code-tab-content %}}
{{< /code-tabs-wrapper >}}

对于Debian用户，使用以下命令添加InfluxData的仓库:

{{< code-tabs-wrapper >}}
{{% code-tabs %}}
[wget](#)
[curl](#)
{{% /code-tabs %}}
{{% code-tab-content %}}
```bash
wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/os-release
echo "deb https://repos.influxdata.com/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
```
{{% /code-tab-content %}}

{{% code-tab-content %}}
```bash
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/os-release
echo "deb https://repos.influxdata.com/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
```
{{% /code-tab-content %}}
{{< /code-tabs-wrapper >}}


然后，安装并启动InfluxDB服务:

```bash
sudo apt-get update && sudo apt-get install influxdb
sudo service influxdb start
```

或如果您的操作系统可以使用systemd (Ubuntu 15.04+, Debian 8+)，也可以这样启动：

```bash
sudo apt-get update && sudo apt-get install influxdb
sudo systemctl unmask influxdb.service
sudo systemctl start influxdb
```

{{% /tab-content %}}

{{% tab-content %}}

有关如何从文件安装RPM软件包的说明，请查看 [下载页面](https://influxdata.com/downloads/).

Red Hat 和 CentOS 用户可以使用`yum`软件包管理器来安装InfluxDB的最新稳定版本：

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF
```

将存储库添加到`yum`配置后，通过运行以下命令安装并启动InfluxDB服务：

```bash
sudo yum install influxdb
sudo service influxdb start
```

或如果您的操作系统可以使用systemd (CentOS 7+, RHEL 7+)，也可以这样启动：

```bash
sudo yum install influxdb
sudo systemctl start influxdb
```

{{% /tab-content %}}

{{% tab-content %}}

openSUSE Build Service为SUSE Linux用户提供了RPM软件包：

```bash
# add go repository
zypper ar -f obs://devel:languages:go/ go
# install latest influxdb
zypper in influxdb
```

{{% /tab-content %}}

{{% tab-content %}}

InfluxDB 是 FreeBSD 软件包系统的一部分。
可以通过运行以下命令进行安装：

```bash
sudo pkg install influxdb
```

配置文件位于`/usr/local/etc/influxd.conf` ，示例包括 `/usr/local/etc/influxd.conf.sample`。

通过执行以下命令启动后端程序

```bash
sudo service influxd onestart
```

如果设置InfluxDB开机自启, 请在/etc/rc.conf添加`influxd_enable="YES"` 。

{{% /tab-content %}}

{{% tab-content %}}

macOS 10.8以及更高版本的用户可以使用Homebrew](http://brew.sh/) 软件包管理器。一旦安装了`brew`，您可以运行以下命令来安装InfluxDB：

```bash
brew update
brew install influxdb
```

登录后用 `launchd`开始运行InfluxDB之前， 请先运行：

```bash
ln -sfv /usr/local/opt/influxdb/*.plist ~/Library/LaunchAgents
```

然后启动InfluxDB：

```bash
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.influxdb.plist
```

如果您不想使用launchctl，那可以在单独的终端运行：

```bash
influxd -config /usr/local/etc/influxdb.conf
```

{{% /tab-content %}}
{{< /tabs-wrapper >}}

### 校验下载的二进制文件的完整性（可选）

为了提高安全性，请按照以下步骤使用`gpg`验证InfluxDB下载的签名。

（大多数操作系统默认都包含`gpg`命令，如果`gpg`不可用，请参考[GnuPG主页](https://gnupg.org/download/)以获得安装说明）。

1. 下载并导入InfluxData的public key：
    ```
    curl -sL https://repos.influxdata.com/influxdb.key | gpg --import
    ```

2. 通过在下载URL中添加`.asc`，下载发布的签名文件。例如：
    ```
    wget https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10_linux_amd64.tar.gz.asc
    ```

3. 使用命令`gpg --verify`验证签名文件：
    ```
    gpg --verify influxdb-1.8.10_linux_amd64.tar.gz.asc influxdb-1.8.10_linux_amd64.tar.gz
    ```
    该命令的输出应包括以下内容：
    ```
    gpg: Good signature from "InfluxDB Packaging Service <support@influxdb.com>" [unknown]
    ```
## 配置 InfluxDB OSS

系统对配置文件每个参数都有内部默认值，使用`influxd config` 命令查看默认配置参数。

> **注意：** 如果将InfluxDB部署在可公开访问的端点上，我们强烈建议启用身份验证。否则，任何未经授权的用户都可以公开获得数据。默认设置不启用身份验证与授权。此外，不应该仅依靠身份验证与授权来防止访问并保护数据免受恶意行为者的侵害。如果需要其他安全或合规性功能，则InfluxDB应该第三方服务之后运行，查看[身份验证与授权](/influxdb/v1.8/administration/authentication_and_authorization/)设置。

本地配置文件(`/etc/influxdb/influxdb.conf`) 中大多数配置都已经被注释掉；所有注释掉的配置将由内部默认配置决定。本地配置文件中所有未注释的设置将覆盖内部默认值。请注意，本地配置文件不需要包含每个配置。

使用配置文件启动InfluxDB的方式有两种：

* 使用`-config`选项将进程指向正确的配置文件：

  ```bash
    influxd -config /etc/influxdb/influxdb.conf
  ```
* 将环境变量`INFLUXDB_CONFIG_PATH`设置为配置文件路径并启动该进程，例如：

  ```
  echo $INFLUXDB_CONFIG_PATH
    /etc/influxdb/influxdb.conf
  
    influxd
  ```

InfluxDB首先检查`-config`，然后检查环境变量。

有关更多信息，请参见 [配置](/influxdb/v1.8/administration/config/)文档。

### Data 和 WAL 目录权限

首先确保运行`influxd`服务的用户具有数据存储目录`data`和[预写式日志目录](/influxdb/v1.8/concepts/glossary#wal-write-ahead-log) (WAL) 的读写权限。

> **注意:** 如果data和wal目录不可写，则`influxd`服务将不会启动。

有关`data` 和`wal` 目录的信息，可在[InfluxDB配置](/influxdb/v1.8/administration/config/)的[数据 设置](/influxdb/v1.8/administration/config/#data-settings)文档中找到。

## 在AWS上托管InfluxDB OSS

### InfluxDB的硬件要求

我们建议使用两个SSD卷，一个用于`influxdb/wal`，另一个用于`influxdb/data`。根据您的负载，每个SSD应该具有大约1k ~ 3k 的IOPS。`influxdb/wal`需要的空间较少，但是IOPS要求高。`influxdb/data`需要空间较多，与前者比IOPS要求较低。

每台机器应该有不少于8G的内存。

在AWS上的R4型号的机器上的我们看到了最好的性能，因为这种型号的机器提供的内存比C3/C4和M4型号机器大得多。

### 配置 InfluxDB OSS 实例

本示例假定您已经正在使用两个SSD卷，并且已经正确安装了它们，此示例还假定两个SSD安装在 `/mnt/influx`和`/mnt/db`，有关如何执行此操作的更多信息，请参考Amazon文档[将卷添加到实例](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-attaching-volume.html)。

### 配置文件

您必须为您拥有的每个InfluxDB实例适当地更新配置文件。

```
...

[meta]
  dir = "/mnt/db/meta"
  ...

...

[data]
  dir = "/mnt/db/data"
  ...
wal-dir = "/mnt/influx/wal"
  ...

...

[hinted-handoff]
    ...
dir = "/mnt/db/hh"
    ...
```

### 身份验证与授权
对于所有AWS部署，我们强烈建议启用身份验证。否则，任何未经授权的用户都可以公开获得数据。默认设置不启用身份验证与授权。此外，不应该仅依靠身份验证与授权来防止访问并保护数据免受恶意行为者的侵害。如果需要其他安全或合规性功能，应该在AWS提供的其他服务之后运行运行InfluxDB，查看[身份验证与授权](/influxdb/v1.8/administration/authentication_and_authorization/) 设置。

### InfluxDB OSS 权限

当将非标准目录用于InfluxDB data 和配置时，请确保正确设置文件系统权限：

```bash
chown influxdb:influxdb /mnt/influx
chown influxdb:influxdb /mnt/db
```

对于InfluxDB 1.7.6或更高版本，您必须授予所有者对`init.sh`文件的权限，为此，请在`influxdb`目录中运行以下脚本：

```sh
if [ ! -f "$STDOUT" ]; then
    mkdir -p $(dirname $STDOUT)
    chown $USER:$GROUP $(dirname $STDOUT)
 fi

 if [ ! -f "$STDERR" ]; then
    mkdir -p $(dirname $STDERR)
    chown $USER:$GROUP $(dirname $STDERR)
 fi

 # 用DEFAULT值覆盖初始化脚本变量
```