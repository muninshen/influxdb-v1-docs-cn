---
title: 使用InfluxDB API查询数据
description: Query data with Flux and InfluxQL in the InfluxDB API.
alias:
  -/docs/v1.8/query_language/querying_data/
menu:
  influxdb_1_8:
    weight: 20
    parent: 指南
aliases:
  - /influxdb/v1.8/guides/querying_data/
---


Influxdb API是influxdb中查询数据的主要方法（有关查询数据库的替代方法，请参阅`命令行`和`客户端库`）

使用`Flux`或`InfluxQL`使用influxdb API查询数据

> **注意**: 以下示例使用`curl`，这是一个使用URL传输数据的命令行工具，学习的基础的`curl`与`HTTP脚本指南`

## 使用Flux查询数据

对于Flux查询，`/api/v2/query`端点接受`POST` HTTP请求，使用以下HTTP标头
- `Accept: application/csv`
- `Content-type: application/vnd.flux`

如果启用了身份验证，请提供influxdb用户名和密码以及Authorization标题和Token架构。例如:`Authorization: Token username:password`.

以下示例使用`Flux`查询`Telegraf`数据:

```bash
$ curl -XPOST localhost:8086/api/v2/query -sS \
  -H 'Accept:application/csv' \
  -H 'Content-type:application/vnd.flux' \
  -d 'from(bucket:"telegraf")
        |> range(start:-5m)
        |> filter(fn:(r) => r._measurement == "cpu")'  
```
Flux返回[注释的CSV](/influxdb/v2.0/reference/syntax/annotated-csv/):

```
{,result,table,_start,_stop,_time,_value,_field,_measurement,cpu,host
,_result,0,2020-04-07T18:02:54.924273Z,2020-04-07T19:02:54.924273Z,2020-04-07T18:08:19Z,4.152553004641827,usage_user,cpu,cpu-total,host1
,_result,0,2020-04-07T18:02:54.924273Z,2020-04-07T19:02:54.924273Z,2020-04-07T18:08:29Z,7.608695652173913,usage_user,cpu,cpu-total,host1
,_result,0,2020-04-07T18:02:54.924273Z,2020-04-07T19:02:54.924273Z,2020-04-07T18:08:39Z,2.9363988504310883,usage_user,cpu,cpu-total,host1
,_result,0,2020-04-07T18:02:54.924273Z,2020-04-07T19:02:54.924273Z,2020-04-07T18:08:49Z,6.915093159934975,usage_user,cpu,cpu-total,host1}
```

标题行定义了表的列标签，该`CPU`[measurement](/influxdb/v1.8/concepts/glossary/#measurement)具有四个Points，每一条记录表示一行，例如，第一个[时间戳](/influxdb/v1.8/concepts/glossary/#timestamp) 为 `2020-04-07T18:08:19`.  

### Flux

查看 [Get started with Flux](/influxdb/v2.0/query-data/get-started/) 了解有关使用`Flux`构建查询的更多信息.
请参阅 [API reference documentation](/influxdb/v1.8/tools/api/#influxdb-2-0-api-compatibility-endpoints).

## 使用InfluxQL查询数据

要执行`InfluxQL`查询，请向`/query`端点发送GET请求，将URL参数设置`db`为目标数据库，然后将URL参数设置`q`为查询，也可`POST`通过发送与URL参数相同或作为正文一部分参数来使用请求`application/x-www-form-urlencoded`.下面的示例使用Influxdb API应用编程接口来查询遇到的同一个数据库[Writing Data](/influxdb/v1.8/guides/writing_data/).

```bash
curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=mydb" --data-urlencode "q=SELECT \"value\" FROM \"cpu_load_short\" WHERE \"region\"='us-west'"
```

InfluxDB 返回 JSON:


```json
{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "cpu_load_short",
                    "columns": [
                        "time",
                        "value"
                    ],
                    "values": [
                        [
                            "2015-01-29T21:55:43.702900257Z",
                            2
                        ],
                        [
                            "2015-01-29T21:55:43.702900257Z",
                            0.55
                        ],
                        [
                            "2015-06-11T20:46:02Z",
                            0.64
                        ]
                    ]
                }
            ]
        }
    ]
}
```

> **Note:** 附加`pretty=true`到URL会启用精美打印的JSON输出，虽然这对于调试或在使用诸如之类的工具直接查询很有用`curl`，但不建议用于生产环境，因为会消耗很多不必须要的网络带宽

### InfluxQL

查看 [数据探索页面](/influxdb/v1.8/query_language/explore-data/) 去熟悉InfluxQL. 有关使用influxQL使用influxdb API 请参阅 [API参考文档](/influxdb/v1.8/tools/api/#influxdb-1-x-http-endpoints).

