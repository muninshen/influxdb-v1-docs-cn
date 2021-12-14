---
title: InfluxDB SDK
description: >
  InfluxDB client libraries includes support for Arduino, C#, Go, Java, JavaScript, PHP, Python, and Ruby.
aliases:
    - /influxdb/v1.8/clients/api_client_libraries/
    - /influxdb/v1.8/clients/
    - /influxdb/v1.8/clients/api
menu:
  influxdb_1_8:
    weight: 30
    parent: Tools
---

InfluxDB客户端库是特定语言的软件包，与InfluxDB 2.0 API集成在一起，并支持**InfluxDB 1.8 +**和**InfluxDB 2.0**。

>**注意：**我们建议使用本页上的新客户端库来进行读取（通过Flux）和写入，并准备转换为InfluxDB 2.0和InfluxDB Cloud。有关更多信息，请参阅[InfluxDB 2.0 API兼容性端点](https://docs.influxdata.com/influxdb/v1.8/tools/api/#influxdb-2-0-api-compatibility-endpoints)。[InfluxDB 1.7和更早版本的](https://docs.influxdata.com/influxdb/v1.7/tools/api_client_libraries/)客户端库可能会继续工作，但不会由InfluxData维护。

## 客户端库

客户端库之间的功能有所不同。有关每个客户端库的详细信息，请参考GitHub上的客户端库。

### Arduino

- [InfluxDB Arduino Client](https://github.com/tobiasschuerg/InfluxDB-Client-for-Arduino)
  - 贡献者： [Tobias Schürg (tobiasschuerg)](https://github.com/tobiasschuerg)

### C\#

- [influxdb-client-csharp](https://github.com/influxdata/influxdb-client-csharp)
  - 贡献者： [InfluxData](https://github.com/influxdata)

### Go

- [influxdb-client-go](https://github.com/influxdata/influxdb-client-go)
  - 贡献者： [InfluxData](https://github.com/influxdata)

### Java

- [influxdb-client-java](https://github.com/influxdata/influxdb-client-java)
   - 贡献者： [InfluxData](https://github.com/influxdata)

### JavaScript

* [influxdb-javascript](https://github.com/influxdata/influxdb-client-js)
   - 贡献者： [InfluxData](https://github.com/influxdata)

### PHP

- [influxdb-client-php](https://github.com/influxdata/influxdb-client-php)
   - 贡献者： [InfluxData](https://github.com/influxdata)

### Python

* [influxdb-client-python](https://github.com/influxdata/influxdb-client-python)
   - 贡献者： [InfluxData](https://github.com/influxdata)

### Ruby

- [influxdb-client-ruby](https://github.com/influxdata/influxdb-client-ruby)
   - 贡献者： [InfluxData](https://github.com/influxdata)

## 安装&使用

To install and use the Python client library, follow the [instructions below](#install-and-use-the-python-client-library). To install and use other client libraries, refer to the client library documentation for detail.

安装和使用Python客户端库，请按照以下[说明进行操作](#install-and-use-the-python-client-library)。安装和使用其他客户端库，请参阅客户端库文档以获取详细信息。

### 安装并使用Python客户端库

1. 安装Python客户端库

    ```sh
    pip install influxdb-client
    ```

2. 确保InfluxDB正在运行，如果InfluxDB运行在本地，请访问[http://localhost:8086](http://localhost:8086/)。（如果使用InfluxDB Cloud，请访问InfluxDB Cloud UI的URL）

3. 在程序中导入客户端库，例如：

    ```sh
    import influxdb_client
    from influxdb_client.client.write_api import SYNCHRONOUS
    ```

4. 定义数据库和令牌变量，创建客户端对象，InfluxDBClient对象使用两个参数：`url` and `token`

    ```sh
    database = "<my-db>"
    token = "<my-token>"
    client = influxdb_client.InfluxDBClient(
    url="http://localhost:8086",
    token=token,
    ```

    > **注意：**数据库（和保留策略，如果适用）将转换为与InfluxDB 2.0兼容的存储[桶](https://v2. docs.influxdata.com/v2.0/reference/glossary/#bucket)。

5. 使用客户端对象和write_api方法实例化writer对象，使用`write_api`方法配置writer对象。

    ```sh
    client = influxdb_client.InfluxDBClient(url=url, token=token)
    write_api = client.write_api(write_options=SYNCHRONOUS)
    ```

6. 使用API writer对象的write方法创建一个数据点对象并将其写入InfluxDB。write方法需要三个参数：数据库，（可选）保留策略和记录（record）。

    ```sh
    p = influxdb_client.Point("my_measurement").tag("location", "Prague").field("temperature", 25.3)
    write_api.write(database:rp, record=p)
    ```
