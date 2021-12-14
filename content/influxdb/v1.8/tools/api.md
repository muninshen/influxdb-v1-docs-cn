---
title: InfluxDB API 参考
description: >
  Use the InfluxDB API endpoints to run queries, write data, check server status, and troubleshoot by tracking HTTP client requests, collecting server statistics, and using Go "pprof" profiles.
aliases:
    - /influxdb/v1.8/concepts/api/
menu:
  influxdb_1_8:
    name: InfluxDB API 参考
    weight: 20
    parent: Tools
---

InfluxDB API提供了一种与数据库进行简单交互的简单方法，它使用HTTP响应请求，HTTP身份验证，JWT令牌和基本身份验证，并且响应以JSON格式返回。

以下各节假定您的InfluxDB实例在`localhost`的`8086`端口上运行，并且没有开启HTTPS，这些设置可以在[[HTTP端点设置](https://docs.influxdata.com/influxdb/v1.8/administration/config/#http-endpoints-settings)中配置的。

- [InfluxDB 2.0 API 兼容性接口](#influxdb-2-0-api-compatibility-endpoints)
- [InfluxDB  1.x HTTP 接口](#influxdb-1-x-http-endpoints)

## InfluxDB 2.0 API 兼容性接口

InfluxDB 1.8.0 introduced forward compatibility APIs for InfluxDB 2.0.

InfluxDB 2.0引入了针对InfluxDB1.8.0的向前兼容性API，引入这些有多种原因：

There are multiple reasons for introducing these:

- 最新的[InfluxDB客户端库](/influxdb/v1.8/tools/api_client_libraries/)是为InfluxDB 2.0 API构建的，但现在也可以与**InfluxDB 1.8.0+**一起使用。
- InfluxDB Cloud是跨多个云服务提供商和地区的通用服务，与**最新的**客户端库完全兼容。

如果您今天才刚刚使用InfluxDB 1.x，我们建议您采用[最新的客户端库](/influxdb/v1.8/tools/api_client_libraries/)，它可以使您轻松地从InfluxDB 1.x迁移到InfluxDB 2.0 Cloud或开源。

可以使用以下向前兼容的API：

| 路径                                         | 描述                                                         |
| :------------------------------------------- | :----------------------------------------------------------- |
| [/api/v2/query](#api-v2-query-http-endpoint) | 使用InfluxDB 2.0 API和[Flux](/flux/latest/)在InfluxDB 1.8.0+中查询数据 |
| [/api/v2/write](#api-v2-write-http-endpoint) | 使用InfluxDB 2.0 API将数据写入InfluxDB 1.8.0+                |
| [/health](#health-http-endpoint)             | 检查InfluxDB实例的运行状况                                   |

### `/api/v2/query/` HTTP 路径

`/api/v2/query` 路径接收HTTP`POST`请求。该路径可以使用[Flux](/influxdb/v1.8/flux/)和[InfluxDB 2.0客户端库](/influxdb/v2.0/tools/client-libraries/)查询数据，Flux是在InfluxDB 2.0中处理数据的主要语言。

**包括以下HTTP请求头：**

- `Accept: application/csv`
- `Content-type: application/vnd.flux`
- 如果[启用身份验证](/influxdb/v1.8/administration/authentication_and_authorization)，则需提供InfluxDB用户名和密码：
  `Authorization: Token username:password`

{{< code-tabs-wrapper >}}
{{% code-tabs %}}
[没有验证](#)
[启用验证](#)
{{% /code-tabs %}}
{{% code-tab-content %}}

```bash
curl -XPOST localhost:8086/api/v2/query -sS \
  -H 'Accept:application/csv' \
  -H 'Content-type:application/vnd.flux' \
  -d 'from(bucket:"telegraf")
        |> range(start:-5m)
        |> filter(fn:(r) => r._measurement == "cpu")'
```
{{% /code-tab-content %}}
{{% code-tab-content %}}
```bash
curl -XPOST localhost:8086/api/v2/query -sS \
  -H 'Accept:application/csv' \
  -H 'Content-type:application/vnd.flux' \
  -H 'Authorization: Token username:password' \
  -d 'from(bucket:"telegraf")
        |> range(start:-5m)
        |> filter(fn:(r) => r._measurement == "cpu")'
```
{{% /code-tab-content %}}
{{< /code-tabs-wrapper >}}

### `/api/v2/write/` HTTP 路径

`/api/v2/write` 路径接收HTTP `POST`请求，该路径可以使用[InfluxDB 2.0客户端库](/influxdb/v2.0/tools/client-libraries/)写入InfluxDB 1.8.0+数据库。

InfluxDB 1.x 和2.0 API 都支持行协议格式，在写入数据时，API仅在URL参数和请求头有所不同，InfluxDB 2.0使用organization和bucket而不是database和retention policy，但`/api/v2/write`路径映射1.8版本的database和retention policy。

**包括以下URL参数：**

- `bucket`：提供数据库名称和保留策略，并用`/`分隔，例如：`database/retention-policy` ，
- `org`：在InfluxDB 1.x中，没有组织的概念，`org`将被忽略，可以设置为空。
- `precision`：行协议中时间戳的精度：`ns`(纳秒)，`us`(微秒)，`ms`(毫秒)，`s`(秒)。

**包括以下HTTP请求头：**

- `Authorization`: 在InfluxDB 2.0中，使用 [API 令牌](/influxdb/v2.0/security/tokens/)访问平台及其所有功能。例如：

{{< code-tabs-wrapper >}}
{{% code-tabs %}}
[没有验证](#)
[启用验证](#)
{{% /code-tabs %}}
{{% code-tab-content %}}

```bash
curl -XPOST "localhost:8086/api/v2/write?bucket=db/rp&precision=s" \
  --data-raw "mem,host=host1 used_percent=23.43234543 1556896326"
```
{{% /code-tab-content %}}
{{% code-tab-content %}}
```bash
curl -XPOST "localhost:8086/api/v2/write?bucket=db/rp&precision=s" \
  -H 'Authorization: Token <username>:<password>' \
  --data-raw "mem,host=host1 used_percent=23.43234543 1556896326"
```
{{% /code-tab-content %}}
{{< /code-tabs-wrapper >}}

### `/health` HTTP 路径
`/health` 接收HTTP `Get` 请求，使用该路径可以检查InfluxDB的运行状况。

```bash
curl -XGET "localhost:8086/health"
```

##### /health 路径响应
| 状态码 | 健康状况  | 描述                           |   状态 |
| :----- | :-------- | :----------------------------- | -----: |
| 200    | Healthy   | `ready for queries and writes` | `pass` |
| 503    | Unhealthy |                                | `fail` |

---

## InfluxDB 1.x HTTP 路径
以下InfluxDB 1.x API作用

| 路径                                             | 描述                                             |
| :----------------------------------------------- | :----------------------------------------------- |
| [/debug/pprof ](#debug-pprof-http-endpoint)      | 生成故障排除的profile                            |
| [/debug/requests](#debug-requests-http-endpoint) | 跟踪HTTP客户端发送到`/write`或`/query`路径的请求 |
| [/debug/vars](#debug-vars-http-endpoint)         | 收集统计信息                                     |
| [/ping](#ping-http-endpoint)                     | 检查InfluxDB实例的状态和版本                     |
| [/query](#query-http-endpoint)                   | 查询数据、管理数据库、保留策略和用户             |
| [/write](#write-http-endpoint)                   | 将数据写入到一个已经存在的数据库                 |

### `/debug/pprof` HTTP 路径

InfluxDB支持Go版本的HTTP路径：[`net/http/pprof`](https://golang.org/pkg/net/http/pprof/)，这在排除故障时非常有用。`pprof`以*pprof*可视化工具期望的格式提供数据的实时分析。

#### 定义

```
curl http://localhost:8086/debug/pprof/
```

`/debug/pprof/`路径生成一个HTML页面，其中包含内置的Go profile及其对应的超链接。

| Profile | 描述 |
| :---------------- | :-------------------- |
| block | 导致同步阻塞的原语的stack跟踪 |
| goroutine  | 所有当前goroutine的stack跟踪  |
| heap  | heap分配的stack跟踪的采样 |
| mutex | 竞争互斥锁的持有者的stack跟踪 |
| threadcreate | 导致创建新的OS线程的stack跟踪 |

要访问上面列出的其中一个`/debug/pprof/` profile，请使用以下的curl请求，将`<profile>`替换成profile的名字。最终生成的profile输出到指定的文件`<path/to/output-file>`中。

```bash
curl -o <path/to/output-file>  http://localhost:8086/debug/pprof/<profile>
```

在以下示例中，curl命令将生成的heap profile输出到一个文件：

```bash
curl -o <path/to/output-file> http://localhost:/8086/debug/pprof/heap
```

您也可以使用[Go pprof交互式工具](https://github.com/google/pprof?spm=a2c4g.11186623.2.34.7da6184cQ1BbTi)来访问 InfluxDB `/debug/pprof/` profiles。例如，使用这个工具查看一个InfluxDB实例的heap profile，您可以使用以下命令：

```bash
go tool pprof http://localhost:8086/debug/pprof/heap
```

关于Go `/net/http/pprof`、交互式*pprof*分析和可视化工具的更多信息，请查看：

* [Package pprof (`net/http/pprof`)](https://golang.org/pkg/net/http/pprof/)
* [`pprof` 分析可视化工具](https://github.com/google/pprof)
* [Profiling Go 程序](https://blog.golang.org/profiling-go-programs)
* [诊断 - Profiling](https://golang.org/doc/diagnostics.html#profiling)

#### `/debug/pprof/all` HTTP 路径

`/debug/pprof/all`路径是一个自定义的`/debug/pprof` profile，它生成`profile.tar.gz`，其中包含标准的Go profiling信息和其它调试数据的文本文件。当使用选项`cpu=true`时（默认cpu=false），会生成一个可选的CPU profile。

如果要创建`profile.tar.gz`，请使用以下的curl命令：

```bash
curl -o profiles.tar.gz "http://localhost:8086/debug/pprof/all?cpu=true"
```

>**注意：** *当使用选项*`cpu=true`*时，生成一个CPU profile需要30秒以上。如果您对运行CPU profile有所顾虑（对性能只有暂时的小影响），那么您可以设置*`?cpu=false`*或者干脆省略*`?cpu=true`。

如下例所示，curl的输出包含`Time Spent`，即花费的时间（以秒为单位）。当收集完30秒数据后，结果会输出到文件：

```bash
➜  ~ curl -o profiles.tar.gz "http://localhost:8086/debug/pprof/all?cpu=true"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  237k    0  237k    0     0   8025      0 --:--:--  0:00:30 --:--:-- 79588
```

### `/debug/requests` HTTP 路径

使用`/debug/requests`来跟踪HTTP客户端发送到`/write`或`/query`路径的请求。该路径返回每个用户和IP地址发送到InfluxDB写和查询请求的数量。

#### 定义

```bash
curl http://localhost:8086/debug/requests
```

#### 字符串类型查询参数

| 字符串类型的查询参数 | 可选/必需 | 定义 |
| :--------------------- | :---------------- |:---------- |
| seconds=\<integer\>      | 可选        | 设置客户端收集信息的持续时间(duration，以秒为单位)，默认的持续时间是10秒。 |

#### 示例

##### 跟踪十秒内的请求

```bash
$ curl http://localhost:8086/debug/requests

{
"user1:123.45.678.91": {"writes":1,"queries":0},
}
```

返回结果显示，在过去的十秒内，用户`user1`从IP地址`123.45.678.91`发送了一个请求到`/write`路径，没有发送任何请求到`/query`路径。

##### 跟踪一分钟内的请求

```bash
$ curl http://localhost:8086/debug/requests?seconds=60

{
"user1:123.45.678.91": {"writes":3,"queries":0},
"user1:000.0.0.0": {"writes":0,"queries":16},
"user2:xx.xx.xxx.xxx": {"writes":4,"queries":0}
}
```

返回结果显示，在过去的一分钟内，`user1`从`123.45.678.91`发送了三个请求到`/write`路径，`user1`从`000.0.0.0`发送了16个请求到`/query`路径，`user2`从`xx.xx.xxx.xxx`发送了四个请求到`/write`路径。

### `/debug/vars` HTTP 路径

InfluxDB通过`/debug/vars`路径公开它在运行时的统计信息，可通过以下curl命令访问：

```bash
curl http://localhost:8086/debug/vars
```

服务器的统计信息以JSON格式显示。

>**注意：** [InfluxDB输入插件](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/influxdb)可以用于收集度量，有关测量和字段的列表，请参考[InfluxDB输入插件 README](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/influxdb#readme)。

### `/ping` HTTP 路径

`/ping`路径接收HTTP`GET`和`HEAD`的请求。使用这个路径，可以检查InfluxDB实例的状态和版本。

#### 定义

```
GET http://localhost:8086/ping
```

```
HEAD http://localhost:8086/ping
```

#### `verbose` 选项

默认情况下，`/ping` HTTP路径返回一个简单的HTTP 204状态，让客户端知道服务器正在运行。`verbose`的默认值是`false`。当`verbose`设置为true时（`/ping?verbose=true`），返回HTTP 200状态。

#### 示例

您可以使用`/ping`路径查看InfluxDB实例的版本（version）。头部字段`X-Influxdb-Version`显示了InfluxDB的版本。

```bash
~ curl -sl -I http://localhost:8086/ping

HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: 9c353b0e-aadc-11e8-8023-000000000000
X-Influxdb-Build: OSS
X-Influxdb-Version: v1.8.0
X-Request-Id: 9c353b0e-aadc-11e8-8023-000000000000
Date: Tue, 05 Nov 2018 16:08:32 GMT
```

#### 状态码和响应

响应的正文是空的。

| HTTP 状态码   | 描述    |
| :----------------- | :------------- |
| 204      | 成功！InfluxDB实例已经启动并正在运行 |

### `/query` HTTP 路径

`/query`路径接受`GET`和`POST`的HTTP请求。使用这个路径，查询数据和管理数据库、保留策略和用户。

#### 定义

```
GET http://localhost:8086/query
```

```
POST http://localhost:8086/query
```

#### 动词用法（Verb usage）

| 动词（Verb） | 查询类型                                                     |
| :----------- | :----------------------------------------------------------- |
| GET          | 用于以如下关键字开头的所有查询：<br><br> [`SELECT`](/influxdb/v1.8/query_language/spec/#select)* <br><br> [`SHOW`](/influxdb/v1.8/query_language/spec/#show-continuous-queries) |
| POST         | 用于以如下关键字开头的所有查询：<br><br> [`ALTER`](/influxdb/v1.8/query_language/spec/#alter-retention-policy) <br><br> [`CREATE`](/influxdb/v1.8/query_language/spec/#create-continuous-query) <br><br> [`DELETE`](/influxdb/v1.8/query_language/spec/#delete) <br><br> [`DROP`](/influxdb/v1.8/query_language/spec/#drop-continuous-query) <br><br> [`GRANT`](/influxdb/v1.8/query_language/spec/#grant) <br><br> [`KILL`](/influxdb/v1.8/query_language/spec/#kill-query) <br><br> [`REVOKE`](/influxdb/v1.8/query_language/spec/#revoke) |

\* 唯一的例外是包含[`INTO`子句](/influxdb/v1.8/query_language/explore-data/#the-into-clause)的SELECT查询，这些查询需要使用`POST`请求。

#### 示例

###### 使用 `SELECT` 语句查询数据

```bash
$ curl -G 'http://localhost:8086/query?db=mydb' --data-urlencode 'q=SELECT * FROM "mymeas"'

{"results":[{"statement_id":0,"series":[{"name":"mymeas","columns":["time","myfield","mytag1","mytag2"],"values":[["2017-03-01T00:16:18Z",33.1,null,null],["2017-03-01T00:17:18Z",12.4,"12","14"]]}]}]}
```

measurement `mymeas`中有两个数据点。在第一个数据点中，时间戳是2017-03-01T00:16:18Z，field key `myfield`的值是33.1，tag key `mytag1`和`mytag2`没有tag value。在第二个数据点中，时间戳是2017-03-01T00:17:18Z，field key `myfield`的值是12.4，tag key `mytag1`和`mytag2`的值分别为`12`和`14`。

相同的查询在InfluxDB的命令行界面中则返回：

```sql
name: mymeas
time                  myfield  mytag1  mytag2
----                  -------  ------  ------
2017-03-01T00:16:18Z  33.1
2017-03-01T00:17:18Z  12.4     12      14
```

##### 使用 `SELECT` 语句和 `INTO` 字句查询数据

```bash
$ curl -XPOST 'http://localhost:8086/query?db=mydb' --data-urlencode 'q=SELECT * INTO "newmeas" FROM "mymeas"'

{"results":[{"statement_id":0,"series":[{"name":"result","columns":["time","written"],"values":[["1970-01-01T00:00:00Z",2]]}]}]}
```

包含[`INTO`子句](/influxdb/v1.8/query_language/explore-data/#the-into-clause)的`SELECT`查询需要使用`POST`请求。

返回结果显示，InfluxDB写入两个数据点到measurement `newmeas`。请注意，系统使用`epoch 0`（`1970-01-01T00:00:00Z`）作为空时间戳。

##### 创建数据库

```bash
$ curl -XPOST 'http://localhost:8086/query' --data-urlencode 'q=CREATE DATABASE "mydb"'

{"results":[{"statement_id":0}]}
```

成功的 [`CREATE DATABASE` 查询](/influxdb/v1.8/query_language/manage-database/#create-database) 不返回任何信息。

#### 字符串类型的查询参数

| 字符串类型的查询参数 | 可选/必需 | 描述 |
| :--------------------- | :---------------- |:---------- |
| chunked=[true \| \<number_of_points>] | 可选 | 批量流式地返回数据点，而不是将所有数据一次性返回。如果设置为true，InfluxDB按序列或按10,000个数据点(哪个条件最先满足就以哪个条件来分块)分批返回结果。如果设置为一个特定的值，InfluxDB按序列或按指定数量的数据点分批返回结果。 |
| db=\<database_name> | 对依赖数据库的查询是必需的 （大多数 [`SELECT`](/influxdb/v1.8/query_language/spec/#select) 查询和 [`SHOW`](/influxdb/v1.8/query_language/spec/#show-continuous-queries) 查询需要此参数）。 | 设置查询的目标[数据库](/influxdb/v1.8/concepts/glossary/#database) |
| epoch=[ns,u,µ,ms,s,m,h] | 可选 | 返回具有特定精度的epoch时间戳。InfluxDB默认返回RFC3339格式的时间戳，精度为纳秒。`u`和`µ`都表示微秒。 |
| p=\<password> | 如果没有[开启认证](/influxdb/v1.8/administration/authentication_and_authorization/#set-up-authentication)，这是可选的。开启认证后，这是必需的。 | 如果开启了认证，请设置用于认证的密码。需要与参数`u`同时使用。 |
| pretty=true | 可选 | 开启JSON输出的美观打印(pretty-printed)。虽然它在调试的时候非常有用，但是不建议用于生产，因为它会消耗不必要的网络带宽。 |
| q=\<query> | 必需 | 需要执行的InfluxQL命令。另请参阅 [Request Body](/influxdb/v1.8/tools/api/#request-body). |
| u=\<username> | 如果没有 [开启认证](/influxdb/v1.8/administration/authentication_and_authorization/#set-up-authentication)，这是可选的。开启认证后，这是必需的。 | 如果开启了认证，请设置用于认证的用户名。用户必须具有读数据库的权限。需要与参数`p`同时使用。 |

\* 如果没有使用参数`chunked`， InfluxDB不会截断请求返回的行数。 此项是可配置的；请参阅[`max-row-limit`](/influxdb/v1.8/administration/config/#max-row-limit-0)配置选项以获取更多信息。

\** InfluxDB API还支持基本身份验证。如果您已[启用身份验证](/influxdb/v1.8/administration/authentication_and_authorization/#set-up-authentication) 并且未使用字符串l类型的查询参数`u`和`p`，请使用基本身份验证。请参阅下面的基本身份验证[示例](#create-a-database-using-basic-authentication)。

#### 示例

##### 使用`SELECT`语句查询数据并返回美观打印的JSON

```bash
$ curl -G 'http://localhost:8086/query?db=mydb&pretty=true' --data-urlencode 'q=SELECT * FROM "mymeas"'

{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "mymeas",
                    "columns": [
                        "time",
                        "myfield",
                        "mytag1",
                        "mytag2"
                    ],
                    "values": [
                        [
                            "2017-03-01T00:16:18Z",
                            33.1,
                            null,
                            null
                        ],
                        [
                            "2017-03-01T00:17:18Z",
                            12.4,
                            "12",
                            "14"
                        ]
                    ]
                }
            ]
        }
    ]
}
```

##### 使用`SELECT`语句查询数据并返回除纳秒外其它精度的epoch时间戳

```bash
$ curl -G 'http://localhost:8086/query?db=mydb&epoch=s' --data-urlencode 'q=SELECT * FROM "mymeas"'

{"results":[{"statement_id":0,"series":[{"name":"mymeas","columns":["time","myfield","mytag1","mytag2"],"values":[[1488327378,33.1,null,null],[1488327438,12.4,"12","14"]]}]}]}
```

##### 使用HTTP验证创建数据库

有效凭证：

```bash
$ curl -XPOST 'http://localhost:8086/query?u=myusername&p=mypassword' --data-urlencode 'q=CREATE DATABASE "mydb"'

{"results":[{"statement_id":0}]}
```

成功的 [`CREATE DATABASE` 查询](/influxdb/v1.8/query_language/manage-database/#create-database) 不返回任何信息。

无效凭证：

```bash
$ curl -XPOST 'http://localhost:8086/query?u=myusername&p=notmypassword' --data-urlencode 'q=CREATE DATABASE "mydb"'

{"error":"authorization failed"}
```

##### 使用基本身份验证创建数据库

以下示例使用有效凭证。

```bash
$ curl -XPOST -u myusername:mypassword 'http://localhost:8086/query' --data-urlencode 'q=CREATE DATABASE "mydb"'

{"results":[{"statement_id":0}]}
```

成功的 [`CREATE DATABASE` 查询](/influxdb/v1.8/query_language/manage-database/#create-database) 不返回任何信息。

以下示例使用无效凭证。

```bash
$ curl -XPOST -u myusername:notmypassword 'http://localhost:8086/query' --data-urlencode 'q=CREATE DATABASE "mydb"'

{"error":"authorization failed"}
```

#### Request body

```
--data-urlencode "q=<InfluxQL query>"
```

所有查询都必须进行URL编码，并遵循[InfluxQL语法](/influxdb/v1.8/query_language/) 。本页面的所有示例都使用了`curl`，在`curl`命令中使用参数`--data-urlencode`。

#### 选项（Options）

##### 请求多个查询

用分号（`;`）将多个查询隔开。

##### 发送文件中的查询

API支持使用multipart `POST`请求发送文件中的查询。文件中的多个查询必须用分号隔开。

语法：

```bash
curl -F "q=@<path_to_file>" -F "async=true" http://localhost:8086/query
```

##### 请求返回CSV格式的查询结果

语法：

```bash
curl -H "Accept: application/csv" -G 'http://localhost:8086/query' [...]
```

请注意，当请求中包含-H `Accept: application/csv`，系统将返回epoch格式的时间戳，而不是RFC3339格式。

##### 绑定参数

API支持将参数绑定到`WHERE`子句中特定的field value或tag value。使用语法`$<placeholder_key>`作为查询中的占位符（placeholder），并且URL会对request body中的placeholder key和placeholder value的映射(Map)进行编码：

查询语法：

```
--data-urlencode 'q= SELECT [...] WHERE [ <field_key> | <tag_key> ] = $<placeholder_key>'
```

映射语法：

```
--data-urlencode 'params={"<placeholder_key>":[ <placeholder_float_field_value> | <placeholder_integer_field_value> | "<placeholder_string_field_value>" | <placeholder_boolean_field_value> | "<placeholder_tag_value>" ]}'
```

使用逗号（`,`）将多个placeholder key-value pair隔开。

#### 示例

##### 请求多个查询

```bash
$ curl -G 'http://localhost:8086/query?db=mydb&epoch=s' --data-urlencode 'q=SELECT * FROM "mymeas";SELECT mean("myfield") FROM "mymeas"'

{"results":[{"statement_id":0,"series":[{"name":"mymeas","columns":["time","myfield","mytag1","mytag2"],"values":[[1488327378,33.1,null,null],[1488327438,12.4,"12","14"]]}]},{"statement_id":1,"series":[{"name":"mymeas","columns":["time","mean"],"values":[[0,22.75]]}]}]}
```

该请求包含两个查询：`SELECT * FROM "mymeas"`和`SELECT mean("myfield") FROM "mymeas"`。从结果中我们可以看到，系统为每个返回的查询分配一个statement标识符：`statement_id`。第一个查询返回的结果对应的`statement_id`是0，第二个查询返回的结果对应的`statement_id`是1。

##### 请求返回CSV格式的查询结果

```bash
$ curl -H "Accept: application/csv" -G 'http://localhost:8086/query?db=mydb' --data-urlencode 'q=SELECT * FROM "mymeas"'

name,tags,time,myfield,mytag1,mytag2
mymeas,,1488327378000000000,33.1,mytag1,mytag2
mymeas,,1488327438000000000,12.4,12,14
```

第一个数据点的两个 [tag keys](/influxdb/v1.8/concepts/glossary/#tag-key) `mytag1`和 `mytag2`都没有 [tag values](/influxdb/v1.8/concepts/glossary/#tag-value) 。

##### 发送文件中的查询语句

```bash
curl -F "q=@queries.txt" -F "async=true" 'http://localhost:8086/query'
```

其中，文件`queries.txt`中的查询如下：

```sql
CREATE DATABASE mydb;
CREATE RETENTION POLICY four_weeks ON mydb DURATION 4w REPLICATION 1;
```

##### 将`WHERE`子句中的参数绑定到指定的tag value

```bash
$ curl -G 'http://localhost:8086/query?db=mydb' --data-urlencode 'q=SELECT * FROM "mymeas" WHERE "mytag1" = $tag_value' --data-urlencode 'params={"tag_value":"12"}'

{"results":[{"statement_id":0,"series":[{"name":"mymeas","columns":["time","myfield","mytag1","mytag2"],"values":[["2017-03-01T00:17:18Z",12.4,"12","14"]]}]}]}
```

该请求将`$tag_value`映射到`12`。InfluxDB将tag value存储为字符串，所以必须使用双引号将请求中的tag value括起来。

##### 将`WHERE`子句中的参数绑定到数值类型的field value

```bash
$ curl -G 'http://localhost:8086/query?db=mydb' --data-urlencode 'q=SELECT * FROM "mymeas" WHERE "myfield" > $field_value' --data-urlencode 'params={"field_value":30}'

{"results":[{"statement_id":0,"series":[{"name":"mymeas","columns":["time","myfield","mytag1","mytag2"],"values":[["2017-03-01T00:16:18Z",33.1,null,null]]}]}]}
```

该请求将`$field_value`映射到30。不需要使用双引号将30括起来，因为在`myfield`中存储的是数值类型的 [field values](/influxdb/v1.8/concepts/glossary/#field-value)。

##### 将`WHERE`子句中的两个参数分别绑定到指定的tag value和数值类型的field value

```bash
$ curl -G 'http://localhost:8086/query?db=mydb' --data-urlencode 'q=SELECT * FROM "mymeas" WHERE "mytag1" = $tag_value AND  "myfield" < $field_value' --data-urlencode 'params={"tag_value":"12","field_value":30}'

{"results":[{"statement_id":0,"series":[{"name":"mymeas","columns":["time","myfield","mytag1","mytag2"],"values":[["2017-03-01T00:17:18Z",12.4,"12","14"]]}]}]}
```

该请求将`$tag_value`映射到`12`，并且将`$field_value`映射到30。

#### 状态码和响应

响应以JSON格式返回。通过添加参数`pretty=true`，可开启JSON的美观打印（pretty-print）。

##### 总结

| HTTP 状态码 | 描述 |
| :--------------- | :---------- |
| 200 OK | 成功！返回的JSON提供更多信息。 |
| 400 Bad Request | 无法处理该请求。可能是查询的语法不正确引起的。返回的JSON提供更多信息。 |
| 401 Unauthorized | 无法处理该请求。可能是认证凭证无效引起的。 |

#### 示例

##### 成功返回数据的请求

```bash
$ curl -i -G 'http://localhost:8086/query?db=mydb' --data-urlencode 'q=SELECT * FROM "mymeas"'

HTTP/1.1 200 OK
Connection: close
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 19:22:54 GMT
Transfer-Encoding: chunked

{"results":[{"statement_id":0,"series":[{"name":"mymeas","columns":["time","myfield","mytag1","mytag2"],"values":[["2017-03-01T00:16:18Z",33.1,null,null],["2017-03-01T00:17:18Z",12.4,"12","14"]]}]}]}
```

##### 成功返回错误的请求

```bash
$ curl -i -G 'http://localhost:8086/query?db=mydb1' --data-urlencode 'q=SELECT * FROM "mymeas"'

HTTP/1.1 200 OK
Connection: close
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 19:23:48 GMT
Transfer-Encoding: chunked

{"results":[{"statement_id":0,"error":"database not found: mydb1"}]}
```

##### 格式错误的查询

```bash
$ curl -i -G 'http://localhost:8086/query?db=mydb' --data-urlencode 'q=SELECT *'

HTTP/1.1 400 Bad Request
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 19:24:25 GMT
Content-Length: 76

{"error":"error parsing query: found EOF, expected FROM at line 1, char 9"}
```

##### 使用无效的验证凭证查询数据

```bash
$ curl -i  -XPOST 'http://localhost:8086/query?u=myusername&p=notmypassword' --data-urlencode 'q=CREATE DATABASE "mydb"'

HTTP/1.1 401 Unauthorized
Content-Type: application/json
Request-Id: [...]
Www-Authenticate: Basic realm="InfluxDB"
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 19:11:26 GMT
Content-Length: 33

{"error":"authorization failed"}
```

### `/write` HTTP 路径

`/write`路径接受`POST`的HTTP请求。使用这个路径，将数据写入已经创建好的数据库。

#### 定义

```
POST http://localhost:8086/write
```

#### 字符串类型的查询参数

| 字符串类型的查询参数 | 可选/必需 | 描述 |
| :--------------------- | :---------------- | :---------- |
| consistency=[any,one,quorum,all] | 可选，仅适用于 [InfluxDB 企业集群](/enterprise_influxdb/v1.6/)。 | 设置写入一致性，如果未指定，则使用`one`，有关一致性的详细说明，请参阅[InfluxDB企业文档](/enterprise_influxdb/v1.6/concepts/clustering#write-consistency) |
| db=\<database> | 可选                                                         | 设置写入的目标[数据库](/influxdb/v1.8/concepts/glossary/#database) |
| p=\<password> | 如果没有 [启用身份认证](/influxdb/v1.8/administration/authentication_and_authorization/#set-up-authentication)则为可选，如果启用了身份认证，则为必需。 | 如果开启了认证，请设置用于认证的密码。需要与参数`u`同时使用。 |
| precision=[ns,u,ms,s,m,h] | 可选 | 设置所提供的Unix时间的精度。如果您不指定精度，InfluxDB假设时间戳的精度为纳秒。 |
| rp=\<retention_policy_name> | 可选 | 设置写入的目标[保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)。如果您不指定，InfluxDB会将数据写入默认(`DEFAULT`)保留策略。 |
| u=\<username> | 如果没有 [启用身份认证](/influxdb/v1.8/administration/authentication_and_authorization/#set-up-authentication)则为可选，如果启用了身份认证，则为必需。 | 如果开启了认证，请设置用于认证的用户名。用户必须具有写数据库的权限。需要与参数`p`同时使用。 |

\* The InfluxDB API 还支持基本身份验证，如果您已[启用身份验证](/influxdb/v1.8/administration/authentication_and_authorization/#set-up-authentication) 并且未使用字符串参数`u`和`p`，请参阅下面的基本身份验证[示例](#write-a-point-to-the-database-mydb-using-basic-authentication) 

\*\* 我们建议尽量使用最低的精度，因为这可以显著提高压缩效果。

#### 示例

##### 将时间戳精确到秒的数据点写入数据库`mydb`

```bash
$ curl -i -XPOST "http://localhost:8086/write?db=mydb&precision=s" --data-binary 'mymeas,mytag=1 myfield=90 1463683075'

HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 17:33:23 GMT
```

##### 将数据点写入数据库`mydb`和保留策略`myrp`

```bash
$ curl -i -XPOST "http://localhost:8086/write?db=mydb&rp=myrp" --data-binary 'mymeas,mytag=1 myfield=90'

HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 17:34:31 GMT
```

##### 使用HTTP验证，将数据点写入数据库`mydb`

有效凭证：

```bash
$ curl -i -XPOST "http://localhost:8086/write?db=mydb&u=myusername&p=mypassword" --data-binary 'mymeas,mytag=1 myfield=91'

HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 17:34:56 GMT
```

无效凭证：

```bash
$ curl -i -XPOST "http://localhost:8086/write?db=mydb&u=myusername&p=notmypassword" --data-binary 'mymeas,mytag=1 myfield=91'

HTTP/1.1 401 Unauthorized
Content-Type: application/json
Request-Id: [...]
Www-Authenticate: Basic realm="InfluxDB"
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 17:40:30 GMT
Content-Length: 33

{"error":"authorization failed"}
```

##### 使用基本（basic）验证，将数据点写入数据库`mydb`

有效凭证

```bash
$ curl -i -XPOST -u myusername:mypassword "http://localhost:8086/write?db=mydb" --data-binary 'mymeas,mytag=1 myfield=91'

HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 17:36:40 GMT
```

无效凭证：

```bash
$ curl -i -XPOST -u myusername:notmypassword "http://localhost:8086/write?db=mydb" --data-binary 'mymeas,mytag=1 myfield=91'

HTTP/1.1 401 Unauthorized
Content-Type: application/json
Request-Id: [...]
Www-Authenticate: Basic realm="InfluxDB"
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 17:46:40 GMT
Content-Length: 33

{"error":"authorization failed"}
```

#### Request body

```bash
--data-binary '<Data in InfluxDB line protocol format>'
```

所有数据必须采用二进制编码并采用[行协议](/influxdb/v1.8/concepts/glossary/#influxdb-line-protocol)格式。本页面的所有示例都使用了`curl`，在`curl`命令中使用参数`--data-binary`。使用除`--data-binary`外的其它编码方式，可能会导致错误；`-d`、`--data-urlencode`和`--data-ascii`可能会将换行符去掉或者引入新的、非预期的格式。

选项：

* 通过用换行符分隔多个数据点，可在一个请求中将这些数据点写入数据库。

* 将文件中的数据点写入数据库，该文件需带标记`@`。文件中的数据点需要使用行协议格式。每个数据点必须占据一行，多个数据点用换行符（`\n`）隔开。文件中包含回车键会导致解析错误。



我们建议分批写入数据，每批数据5,000或10,000个数据点。如果每一批数据的数据点变少，会产生更多的HTTP请求，导致性能无法达到最优。

#### 示例

##### 将时间戳精确到纳秒的数据点写入数据库`mydb`

```bash
$ curl -i -XPOST "http://localhost:8086/write?db=mydb" --data-binary 'mymeas,mytag=1 myfield=90 1463683075000000000'

HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 18:02:57 GMT
```

##### 将使用本地服务器时间戳（精确到纳秒）的数据点写入数据库`mydb`

```bash
$ curl -i -XPOST "http://localhost:8086/write?db=mydb" --data-binary 'mymeas,mytag=1 myfield=90'

HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 18:03:44 GMT
```

##### 使用换行符，将多个数据点写入数据库`mydb`

```bash
$ curl -i -XPOST "http://localhost:8086/write?db=mydb" --data-binary 'mymeas,mytag=3 myfield=89 1463689152000000000
mymeas,mytag=2 myfield=34 1463689152000000000'

HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 18:04:02 GMT
```

##### 从文件`data.txt`中，将多个数据点写入数据库`mydb`

```bash
$ curl -i -XPOST "http://localhost:8086/write?db=mydb" --data-binary @data.txt

HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: [...]
X-Influxdb-Version: 1.4.x
Date: Wed, 08 Nov 2017 18:08:11 GMT
```

其中，文件`data.txt`中的示例数据如下：
```
mymeas,mytag1=1 value=21 1463689680000000000
mymeas,mytag1=1 value=34 1463689690000000000
mymeas,mytag2=8 value=78 1463689700000000000
mymeas,mytag3=9 value=89 1463689710000000000
```

#### 状态码和响应

一般来说，`2xx`形式的状态码表示成功，`4xx`表示InfluxDB无法理解请求，`5xx`表示系统过载或严重受损。错误以JSON格式返回。

##### 总结

| HTTP状态码 | 描述 |
| :--------------- | :------------- |
| 204 No Content   | 成功！   |
| 400 Bad Request  | 无法处理该请求。可能写协议语法错误引起的，或者是用户尝试将数据写入之前接受不同数据类型的field引起的。返回的JSON提供更多信息。 |
| 401 Unauthorized | 无法处理该请求。可能是验证凭证无效引起的。 |
| 404 Not Found    | 无法处理该请求。可能是用户尝试将数据写入不存在的数据库引起的。返回的JSON提供更多信息。 |
| 413 Request Entity Too Large | 无法接受的请求。 如果POST请求的有效负载大于允许的最大大小，则会发生这种情况。 有关更多详细信息，请参见[`max-body-size`](/ influxdb/v1.8/administration/config/＃max-body-size-25000000)参数。 |
| 500 Internal Server Error  | 系统过载或严重受损。可能是用户尝试将数据写入不存在的保留策略引起的。返回的JSON提供更多信息。 |

#### 示例

##### 写入成功

```
HTTP/1.1 204 No Content
```

##### 写入时间戳不正确的数据点

```
HTTP/1.1 400 Bad Request
[...]
{"error":"unable to parse 'mymeas,mytag=1 myfield=91 abc123': bad timestamp"}
```

##### 将整数写入到之前接受浮点数的field

```
HTTP/1.1 400 Bad Request
[...]
{"error":"field type conflict: input field \"myfield\" on measurement \"mymeas\" is type int64, already exists as type float"}
```

##### 使用无效的验证凭证写入数据

```
HTTP/1.1 401 Unauthorized
[...]
{"error":"authorization failed"}
```

##### 将数据点写入不存在的数据库

```
HTTP/1.1 404 Not Found
[...]
{"error":"database not found: \"mydb1\""}
```

##### 发送的请求正文太大

```
HTTP/2 413 Request Entity Too Large
[...]
{"error":"Request Entity Too Large"}
```

##### 将数据点写入不存在的保留策略

```
HTTP/1.1 500 Internal Server Error
[...]
{"error":"retention policy not found: myrp"}
```
