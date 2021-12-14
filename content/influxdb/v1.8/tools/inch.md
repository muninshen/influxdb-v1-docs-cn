---
title: inch
description: >
  Use the InfluxDB inch tool to test InfluxDB performance. Adjust the number of points and tag values to test ingesting different tag cardinalities.
menu:
  influxdb_1_8:
    weight: 50
    parent: Tools
---

InfluxDB inch工具可以模拟流入到InfluxDB的数据进行性能评估。因此，请完成以下任务：

- [安装 InfluxDB inch](#install-influxdb-inch)
- [使用 InfluxDB inch](#use-influxdb-inch)

## 安装InfluxDB inch

1. 安装 `inch`，请在终端运行以下命：

    ```bash
    $ go get github.com/influxdata/inch/cmd/inch
    ```

2. 验证 `inch` 已经成功安装在`GOPATH/bin` (Unix默认为 `$HOME/go/bin`).

## 使用 InfluxDB inch

1. 登陆到要测试InfluxDB实例（对于InfluxDB企业版，请登录到要测试的data节点）

2. 运行 `inch`，指定要测试的指标 (请参阅下面的 [选项](#options) 表)。语法如下所示：

    ```bash
    inch -v -c 8 -b 10000 -t 2,5000,1 -p 100000 -consistency any
    ```

    以上示例生成带有以下内容的工作负载：

    - 8 个并发写入流 (`-c`) 
    - 每批次10000个数据点 (`-b`)
    - 10000个唯一的系列(`-t`)  (2x5000x1)
    - 每个系列10000 个数据点(`-p`) 
    - 一致性级别为`any` (`-consistency`)

    > **注意：**默认情况下，`inch`将生成的测试结果写入`stress`数据库。如需更改数据库的名称，请指定`-db string`选项，例如`inch -db test`。

3. 要查看最后50个`inch`结果，请对inch写入的数据库运行以下查询：

   ```bash
    > select * from stress limit 50
   ```

### 选项

`inch` 选项按字母顺序列出。

|选项                      | 描述                                                         |示例                              |
|------------                | ----------                                                                                                     | -------                             |
| `-b int`                   |  批处理大小（默认5000; 建议5000-10000 个数据点）                                          | `-b 10000`                          |
| `-c int`                   |  并发写入流（默认 1）                                            | `-c 8`                              |
| `-consistency string`      | 写一致性（默认 `any`）; Influxdb API 支持的值为`all`，`quorum`，或 `one` | `-consistency any`                  |
| `-db string`               |  要写入的数据库名称 （默认为"stress"）                                               | `-db stress`                        |
| `-delay duration`          |  两次写入之间的延迟 ，以`s`（秒），`m`（分钟）或h`（小时）为单位                     | `-delay 1s`                         |
| `-dry`                     |  空运行 （以尽可能多的方式写入数据）                 | `-dry`                            |
| `-f int`                   |  每个数据点的唯一键值对总数（默认1）                                    | `-f 1`                              |
|`-host string`              |  主机名称（默认http<nolink>://localhost:8086"）                                                             | `-host http://localhost:8086`       |
| `-m int`                   |  指定测量次数(默认 1)                                                       | `-m 1`                              |
| `-max-errors int`          | 终止`inch`命令之前发生的InfluxDB错误数 | `-max-errors 5`                     |
| `-p int`                   |  每个系列的数据点的数量（默认为100）                                                            | `-p 100`                            |
| `-report-host string`      |  主机将指标发送给                                                                               | `report-host http://localhost:8086` |
| `-report-tags string`      |  逗号分隔的k = v（键值？）标签与指标一起报告                     | `-report-tags cpu=cpu1`             |
| `-shard-duration string`   |  分片持续时间（默认为7d）                                                                      |`-shard-duration 7d`                 |
| `-t [string]`&ast;&ast;    |  以逗号分隔代表标签的整数                                                   | `-t [100,20,4]`                     |
| `-target-latency duration` |  如果指定，请尝试调整写延迟以满足目标                                 |                                     |
| `-time duration`           |  指定时间长度                                                                  | `-time 1h`                          |
|  `-v`                      |  冗长（verbose），在运行测试时打印出详细信息                                     | `-v`                                |

> **注意：**`-t [string]`中每个整数代表一个tag和要生成的tag value的数量（默认为[10,10,10]），将每个整数相乘计算基数，例如：`-t [100,20,4]` 具有8000个唯一系列。