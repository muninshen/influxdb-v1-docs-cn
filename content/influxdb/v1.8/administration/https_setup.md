---
title: InfluxDB 中启用 HTTPS
description: >
  Enable HTTPS and Transport Security Layer (TLS) secure communication between clients and your InfluxDB servers.
menu:
  influxdb_1_8:
    name: 启用 HTTPS
    weight: 30
    parent: 管理
---

启用HTTPS会加密客户端与Influxdb服务器之间的通信，配置了签名证书后，HTTPS还可以验证Influxdb服务器对连接客户端的真实性

InfluxData `强烈建议`启用HTTPS，尤其是当您的计划通过网络向Influxdb发送请求时

要求

要使用Influxdb启用HTTPS，需要一个现有的或新的Influxdb实例以及一个传输层安全性（TLS）证书也（也称为安全套接字层（SSL）证书）。

InfluxDB 支持三种类型的TLS证书

* 由证书颁发机构签署的单域证书

    单域证书为HTTPS请求提供加密安全性，并允许客户端验证Influxdb服务器的身份，使用此证书选项，每个Influxdb实例都需要唯一的单个域证书。
    
* 证书颁发机构签署的通配符证书

    通配符证书对HTTPS请求提供加密安全性，并允许客户端验证Influxdb服务器的身份。通配符证书可以在不通服务器上的多个Influxdb实例中使用
    
* **自签名证书**

    自签名证书不是由证书颁发机构（CA）签名的，在您自己的计算机上生成一个自签名证书，与CA签名证书不同，自签名证书仅为HTTPS请求提供加密安全性，它们不允许客户端验证Influxdb服务器的身份。使用此证书选项，每个Influxdb实例都需要一个唯一的自签名证书
    无论您的证书类型如何，Influxdb都支持由私钥文件（.key）和签名证书文件（.crt）文件对组成的证书，以及将私钥文件和签名证书文件组合为单个捆绑文件（.pem）的证书。

以下两节概述了如何在Ubuntu 16.04上使用CA签名证书和自签名证书通过Influxdb设置HTTPS，对于其他操作系统，步骤可能有所不同

## 使用CA证书设置HTTPS

#### Step 1: 安装证书

将私钥文件（.key）和签名证书文件（.crt）或单个捆绑文件（.pem）放在/etc/ssl目录中

#### Step 2: 设置证书文件权限

运行Influxdb的用户必须要对TLS证书具有读取权限

>***Note***: 您可以选择设置多个用户，组合权限，最终确保所有Influxdb的用户都具有TLS证书的读取权限

```bash
sudo chown influxdb:influxdb /etc/ssl/<CA-certificate-file>
sudo chmod 644 /etc/ssl/<CA-certificate-file>
sudo chmod 600 /etc/ssl/<private-key-file>
```

#### Step 3: 查看TLS配置设置

默认情况下，Influxdb支持顶级域名值`Ciphers`，`min-version`以及`max-version并取决于用于构建Influxdb的Go版本，
可以配置Influxdb来支持TLS密码套件标识和版本的受限列表，有关更多信息，请参见[传输层安全性（TLS）配置设置](/influxdb/v1.8/administration/config#transport-layer-security-tls-settings).。

#### Step 4: 在Influxdb配置文件中启用HTTPS

默认情况下禁用HTTPS，通过设置[http],在配置文件（/etc/influxdb/influxdb.conf）部分中启用HTTPS：

* `https-enabled` 至 `true`
* `https-certificate` 到 `/etc/ssl/<signed-certificate-file>.crt` (或到 to `/etc/ssl/<bundled-certificate-file>.pem`)
* `https-private-key` 到 `/etc/ssl/<private-key-file>.key` (或到 `/etc/ssl/<bundled-certificate-file>.pem`)

```toml
[http]

  [...]

  # Determines whether HTTPS is enabled.
  https-enabled = true

  [...]

  # The SSL certificate to use when HTTPS is enabled.
  https-certificate = "<bundled-certificate-file>.pem"

  # Use a separate private key location.
  https-private-key = "<bundled-certificate-file>.pem"
```

#### Step 5: 重新启动Influxdb服务

重新启动Influxdb流程，一是配置更改生效:

```bash
sudo systemctl restart influxdb
```

#### Step 6: 验证HTTPS设置

通过使用CLI工具连接到Influxdb来验证HTTPS是否正常工作

```bash
influx -ssl -host <domain_name>.com
```

成功的连接将返回以下内容:

```bash
Connected to https://<domain_name>.com:8086 version 1.x.x
InfluxDB shell version: 1.x.x
>
```

然而！您已经成功使用Influxdb设置了HTTPS

使用自签名证书设置HTTPS

#### Step 1: 生成自签名证书

以下命令将生成一个私钥文件（.key）和一个自签名证书文件（.crt）

```bash
sudo openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/influxdb-selfsigned.key -out /etc/ssl/influxdb-selfsigned.crt -days <NUMBER_OF_DAYS>
```

当您执行命令时，它将会提示您更多信息，您可以选择填写该信息，也可以将其留空，这两个操作都会生成有效的证书文件

运行一下命令以授予Influxdb对证书的读写权限

```bash
chown influxdb:influxdb /etc/ssl/influxdb-selfsigned.*
```

#### Step 2: 查看TLS域名系统和设置

默认情况下，Influxdb支持Go加密/tls包文档的”常量“部分中列出的TLS密码，最小版本和最大版本的值，并且取决于用于构建Influxdb的go版本，你可以配置Influxdb来支持TLS密码套件标识和版本的受限列表

#### Step 3: 在配置文件中启用HTTPS

默认情况下禁用https，通过【http】在配置文件（/etc/influxdb/influxdb.conf)部分中启用HTTPS:

* `https-enabled` to `true`
* `https-certificate` to `/etc/ssl/influxdb-selfsigned.crt`
* `https-private-key` to `/etc/ssl/influxdb-selfsigned.key`

```
[http]

  [...]

  # Determines whether HTTPS is enabled.
  https-enabled = true

  [...]

  # The TLS or SSL certificate to use when HTTPS is enabled.
  https-certificate = "/etc/ssl/influxdb-selfsigned.crt"

  # Use a separate private key location.
  https-private-key = "/etc/ssl/influxdb-selfsigned.key"
```

> 如果为Influxdb Enterprise设置HTTPS，则还需要在集群中的元节点和数据节点之间配置不安全的TLS连接，Influxdb企业HTTPS设置指南中提供了说明

#### 步骤4: 重新启动Inf'luxDB

#### 重新启动Influxdb流程，以使配置更改生效

```bash
sudo systemctl restart influxdb
```

#### 步骤5: 验证HTTPS设置

通过使用CLI工具连接到Influxdb来验证HTTPS是否正常工作:

```bash
influx -ssl -unsafeSsl -host <domain_name>.com
```

成功的连接将返回以下内容:

```bash
Connected to https://<domain_name>.com:8086 version 1.x.x
InfluxDB shell version: 1.x.x
>
```

就这样！已经成功地在HTTPS建立Influxdb数据库

## 将Telegraf连接到受保护的Influxdb实例

将`Telegraf `连接到使用HTTPS的Influxdb实例需要一些额外的步骤

在Telegraf配置文件 (`/etc/telegraf/telegraf.conf`)中, 编辑 `urls`
设置以表示`https`,并将`localhost`更改为相关域名；
如果使用的是自签名证书，请取消`insecure_skip_verify`，设置并将其设置为`true`。

```toml
    ###############################################################################
    #                            OUTPUT PLUGINS                                   #
    ###############################################################################
>
    # Configuration for InfluxDB server to send metrics to
    [[outputs.influxdb]]
      ## The full HTTP or UDP endpoint URL for your InfluxDB instance.
      ## Multiple urls can be specified as part of the same cluster,
      ## this means that only ONE of the urls will be written to each interval.
      # urls = ["udp://localhost:8089"] # UDP endpoint example
      urls = ["https://<domain_name>.com:8086"]
>
    [...]
>
      ## Optional SSL Config
      [...]
      insecure_skip_verify = true # <-- Update only if you're using a self-signed certificate
```

接下来, 重启 Telegraf 一切准备就绪！
