---
title: InfluxDB中的日志与跟踪
description: >
  Structured logging, access logging, tracing, and logging locations in InfluxDB.
menu:
  influxdb_1_8:
    name: 日志和跟踪
    weight: 40
    parent: 管理
---

**Content**

* [记录位置](#logging-locations)
* [HTTP访问记录](#http-access-logging)
* [结构化日志](#structured-logging)
* [跟踪](#tracing)


## 记录位置

默认情况下，Influxd将日志输出写入stderr，根据用例，可以将此日志信息写入其他位置.

### 直接运行Influxdb

当直接使用运行Influxdb时influxd,所有日志都将写入stderr，还可以将日志输出重定向，就像将任何输出重定向到stderr一样，如一下示例所示：

```
influxd 2>$HOME/my_log_file
```

### 作为服务推出

<!--------------------------- BEGIN TABS  ---------------------->
{{< tabs-wrapper >}}
{{% tabs %}}
[systemd](#)
[sysinit](#)
{{% /tabs %}}
<!--------------------------- BEGIN systemd  ------------------->
{{% tab-content %}}

#### systemd

大多数Linux系统将日志定向到systemd日志，要访问这些日志，请使用以下命令

```sh
sudo journalctl -u influxdb.service
```

有关更多信息，请参见 [`journald.conf` manual page](https://www.freedesktop.org/software/systemd/man/journald.conf.html).
{{% /tab-content %}}
<!--------------------------- END systemd  --------------------->
<!--------------------------- BEGIN sysvinit  ------------------>
{{% tab-content %}}

#### sysvinit

在linux systems不使用systemd，influxdb写入所有的日志数据，并以stderr以 `/var/log/influxdb/influxd.log`.
可以通过STDERR在启动脚本中将环境变量设置为来覆盖此位置/etc/default/influxdb。

For example, if `/etc/default/influxdb` contains:

```sh
STDERR=/dev/null
```

所有日志数据都将被丢弃，同样可以stdout通过stdout来讲输出重定向到STDOUT.

当InfluxDB作为服务器重启时，默认情况下stdout被发送到  `/etc/default/influxdb`.
{{% /tab-content %}}
<!--------------------------- END sysvinit --------------------->
{{< /tabs-wrapper >}}
<!--------------------------- END TABS  ------------------------>

> #### Mac OS macOS日志位置
> 在Mac OS上， `/usr/local/var/log/influxdb.log` 默认情况下，Influxdb存储日志

### 使用 logrotate

可以将日志写入平面文件的系统上使用Logrotate旋转Influxdb生成的日志文件，如果在sysvinit系统上使用软件包安装，则logrotate的配置文件安装在/etc/logrotate.d、


## HTTP 访问日志

使用HTTP访问日志与其他influxdb日志输出分开记录HTTP请求流量

### HTTP 访问日志格式

以下是HTTP访问日志格式的示例，下表描述了HTTP访问日志的每个组件

```
172.13.8.13,172.39.5.169 - - [21/Jul/2019:03:01:27 +0000] "GET /query?db=metrics&q=SELECT+MEAN%28value%29+as+average_cpu%2C+MAX%28value%29+as+peak_cpu+FROM+%22foo.load%22+WHERE+time+%3E%3D+now%28%29+-+1m+AND+org_id+%21%3D+%27%27+AND+group_id+%21%3D+%27%27+GROUP+BY+org_id%2Cgroup_id HTTP/1.0" 200 11450 "-" "Baz Service" d6ca5a13-at63-11o9-8942-000000000000 9337349
```



| 组成                     | Example                                                      |
| ------------------------ | ------------------------------------------------------------ |
| 主机                     | `172.13.8.13,172.39.5.169`                                   |
| 记录事件时间             | `[21/Jul/2019:03:01:27 +0000]`                               |
| 申请方法                 | `GET`                                                        |
| 用户名                   | `user`                                                       |
| 进行HTTP API调用&ast;    | `/query?db=metrics%26q=SELECT%20used_percent%20FROM%20%22telegraf.autogen.mem%22%20WHERE%20time%20%3E=%20now()%20-%201m%20	` |
| 请求协议                 | `HTTP/1.0`                                                   |
| HTTP响应码               | `200`                                                        |
| 响应大小（以字节为单位） | `11450`                                                      |
| 推荐人                   | `-`                                                          |
| 用户代理                 | `Baz Service`                                                |
| 要求编号                 | `d4ca9a10-ab63-11e9-8942-000000000000`                       |
| 响应时间                 | `9357049`                                                    |
&在字段显示正在访问的数据库和正在运行的查询，有关更多详细信息，请参阅, see [InfluxDB API参考](/influxdb/v1.8/tools/api/). 请注意，此字段是URL编码的

### 重定向HTTP访问日志

启用HTTP请求日志记录后，默认情况下，HTTP日志与内部Influxdb日志记录混合在一起，通过将HTTP请求日志条目重定向到单独的文件，两个日志文件都更易于读取，监视和调试。.

**要重定向HTTP请求日志记录:**

找到【http】你的Influxdb配置文件的部分，并设置access-log-path选项以指定应在其中写入HTTP日志条目的路径

**Notes:**

* 如果influxdb无法访问指定的路径.并设置access-log-path选项以指定应在写入HTTP日志条目的路径
* 在【httpd】当HTTP请求日志记录被重定向到一个单独的文件前缀被剥离，允许访问日志分析工具（如LNAV）来渲染文件，而无需额外的更改
* 要旋转HTTP请求日志文件，请使用或类似copytruncate方法logrotate将原始文件保留在原位；


## 结构化日志

结构化日志支持机器可读和更友好的开发人员日志输出格式，logfmt和json这两种结构化日志格式通过外部工具提供了更简单的过滤和搜索，并简化了Influxdb日志与Splunk、Papertail、弹性搜索和其他第三方工具的集成；

Influxdb日志配置选项（在日志部分）现在包含以下选项:

* `格式`: `auto` (默认) | `logfmt` | `json`
* `级别`: `error` | `warn` | `info` (默认) | `debug`
* `suppress-logo`: `false` (默认) | `true`

有关这些日志配置选项及其相应环境变量的详细信息，请参见配置文件文档中的日志选项。.

### 日志格式

有三种日志格式选项可用：auto、logfmt、json,默认的日志记录格式设置“格式=自动”，允许Influxdb自动管理日志编码格式

* 当记录到文件时，使用logfmt

* 当登录到终端（或其他TTY设备）时，使用用户友好的控制台格式.

指定时，json格式可用

### 日志输出示例:

**日志文件**

```
ts=2018-02-20T22:48:11.291815Z lvl=info msg="InfluxDB starting" version=unknown branch=unknown commit=unknown
ts=2018-02-20T22:48:11.291858Z lvl=info msg="Go runtime" version=go1.10 maxprocs=8
ts=2018-02-20T22:48:11.291875Z lvl=info msg="Loading configuration file" path=/Users/user_name/.influxdb/influxdb.conf
```

**JSON**

```
{"lvl":"info","ts":"2018-02-20T22:46:35Z","msg":"InfluxDB starting, version unknown, branch unknown, commit unknown"}
{"lvl":"info","ts":"2018-02-20T22:46:35Z","msg":"Go version go1.10, GOMAXPROCS set to 8"}
{"lvl":"info","ts":"2018-02-20T22:46:35Z","msg":"Using configuration at: /Users/user_name/.influxdb/influxdb.conf"}
```

**Console/TTY**

```
2018-02-20T22:55:34.246997Z     info    InfluxDB starting       {"version": "unknown", "branch": "unknown", "commit": "unknown"}
2018-02-20T22:55:34.247042Z     info    Go runtime      {"version": "go1.10", "maxprocs": 8}
2018-02-20T22:55:34.247059Z     info    Loading configuration file      {"path": "/Users/user_name/.influxdb/influxdb.conf"}
```

### 记录级别

该 `level`选项设置要发出的日志级别，有效的日志记录级别设置为error，warn`, `info`(default), 和 `debug`. 等于或高于指定级别的日志将被发出

### Logo 隐藏

“抑制标志”选项可用于抑制程序启动时打印的标志输出，如果“标准输出”不是TTY，则标志总是被隐藏

## 追踪

日志记录功能得到了增强，可以跟踪重要的数据库操作，跟踪对于错误报告和发现性能瓶颈很有用；

### 跟踪中使用的日志键

#### 跟踪标识符关键字

trace_id键为跟踪的特定实例指定唯一标识符。您可以使用此键来筛选和关联操作的所有相关日志条目.

所有操作跟踪都包括一致的开始和结束日志条目，使用相同的消息(msg)描述操作(例如，“TSM压缩”)，但添加适当的op_event上下文(开始或结束)。有关示例，请参见查找InfluxDB操作的所有跟踪日志条目。 see [Finding all trace log entries for an InfluxDB operation](#finding-all-trace-log-entries-for-an-influxdb-operation).

**Example:** `trace_id=06R0P94G000`

#### 操作键

以下操作键标识操作的名称，开始和结束时间戳以及经过的执行时间

##### `op_name`
操作的唯一标识符，可以筛选特定名称的所有操作.

**Example:** `op_name=tsm1_compact_group`

##### `op_event`
指定事件的开始和结束，两个可能的值（开始）或（结束）用于指示操作开始或者结束的时间，例如，可以通过op_name和op_event中的值来查找所有启动操作日志条目。有关这方面的示例请参考查找所有起始日志条目, see [Finding all starting log entries](#finding-all-starting-operation-log-entries).

**Example:** `op_event=start`

##### `op_elapsed`
操作执行花费的时间，使用结束跟踪日志条目记录，显示的时间单位取决于经过的时间-如果是秒，将以秒为后缀，有效的时间单位是秒、毫秒、分钟

**Example:** `op_elapsed=0.352ms`


#### 日志表示符上下文关键字

日志表示符键 (`log_id`)可以轻松的为一次执行influxd进程识别_every_log条目，还有其他方法可以通过单次执行来拆分日志文件，但是一致的log_id简化了日志聚合服务的搜索

**Example:** `log_id=06QknqtW000`

#### 日志表示符上下文关键字

`db_instance（数据库实例）`: Database name

`db_rp`: Retention policy name

`db_shard_id`: Shard identifier

`db_shard_group` Shard group identifier

### 工具

这里有几个流行的工具可以用来处理和过滤logfmt或json格式的日志文件输出

#### hutils

由Heroku提供的hutils是一组命令行实用程序，用于使用logfmt编码处理日志，包括:

* `lcut`: 根据指定的字段名从logfmt跟踪中提取价值.
* `lfmt`: 当线条从溪流中出现时，美化它们，并突出它们的关键部分.
* `ltap`: 以一致的方式访问来自日志提供者的消息，以允许操作logfmt跟踪的其他实用程序轻松解析
* `lviz`: 通过从数据集构建一棵树，将常见的键值对集合组成共享的父节点，可视化logfmt输出

#### lnav (Log File Navigator)

[lnav(Log File Navigator)](http://lnav . org)是一个高级日志文件查看器，可用于从终端查看和分析日志文件。lnav查看器提供了单一日志视图、自动日志格式检测、过滤、时间线视图、漂亮打印视图和使用SQL查询日志。

### 操作

下列操作按其操作名（op_name）列出，在Influxdb内部日志进行跟踪，无需更改日志记录级别即可使用

#### 数据文件初始打开

tsdb_open操作跟踪包括与tsdb_store的初始打开相关的所有事件。


#### 保留策略shards删除

retention.delete_check操作包括与保留策略相关的所有shards删除

#### TSM 将内存缓存快照到磁盘

The `tsm1_cache_snapshot` 操作表示将内存中的tsm缓存快照到磁盘

#### TSM 压缩策略

“tsm1_compact_group”操作包括与tsm压缩策略相关的所有跟踪日志条目，并显示相关的TSM压缩策略关键字:

* `tsm1_strategy`: `level` | `full`
* `tsm1_level`: `1` | `2` | `3`
* `tsm1_optimize`: `true` | `false`

#### 系列文件压缩

The `series_partition_compaction` 操作包括与系列文件压缩相关的所有跟踪日志条目

连续查询执行(如果启用了日志记录)：

连续查询执行(如果启用了日志记录) 如果启用了日志记录，则`continuous _ querier _ execute`操作包括所有连续的查询执行

#### TSI 日志文件压缩

The `tsi1_compact_log_file`

#### TSI 压缩级

The `tsi1_compact_to_level操作包括tsi级压缩的所有跟踪日志条目


### 追踪例子

#### 查找Influxdb操作的所有跟踪日志条目

 在下面的示例中，您可以看到与“TSM压缩”过程相关的所有跟踪操作的日志条目。请注意，初始条目显示消息“TSM压缩(开始)”，最终条目显示消息“TSM压缩(结束)”。[注意:使用trace_id值对日志条目进行grep，然后使用lcut(一个hutils工具)显示指定的键值。]

```
$ grep "06QW92x0000" influxd.log | lcut ts lvl msg strategy level
2018-02-21T20:18:56.880065Z	info	TSM compaction (start)	full
2018-02-21T20:18:56.880162Z	info	Beginning compaction	full
2018-02-21T20:18:56.880185Z	info	Compacting file	full
2018-02-21T20:18:56.880211Z	info	Compacting file	full
2018-02-21T20:18:56.880226Z	info	Compacting file	full
2018-02-21T20:18:56.880254Z	info	Compacting file	full
2018-02-21T20:19:03.928640Z	info	Compacted file	full
2018-02-21T20:19:03.928687Z	info	Finished compacting files	full
2018-02-21T20:19:03.928707Z	info	TSM compaction (end)	full
```


#### 查找所有启动操作日志条目

要查找所有启动操作日志条目，您可以通过“op_name”和“op_event”中的值进行grep。在下面的例子中，grep返回了101个条目，所以下面的结果只显示了第一个条目。在示例结果条目中，包括时间戳、级别、策略、trace_id、op_name和op_event值

```
$ grep -F 'op_name=tsm1_compact_group' influxd.log | grep -F 'op_event=start'
ts=2018-02-21T20:16:16.709953Z lvl=info msg="TSM compaction" log_id=06QVNNCG000 engine=tsm1 level=1 strategy=level trace_id=06QV~HHG000 op_name=tsm1_compact_group op_event=start
...
```

使用“lcut”实用程序(在hutils中)，下面的命令使用前面的“grep”命令，但添加了一个“lcut”命令，以便只显示所有条目中不相同的键及其值。以下示例包括显示选定键的唯一日志条目的19个示例:` ts '、` strategy '、` level '和` trace_id '

```
$ grep -F 'op_name=tsm1_compact_group' influxd.log | grep -F 'op_event=start' | lcut ts strategy level trace_id | sort -u
2018-02-21T20:16:16.709953Z	level	1	06QV~HHG000
2018-02-21T20:16:40.707452Z	level	1	06QW0k0l000
2018-02-21T20:17:04.711519Z	level	1	06QW2Cml000
2018-02-21T20:17:05.708227Z	level	2	06QW2Gg0000
2018-02-21T20:17:29.707245Z	level	1	06QW3jQl000
2018-02-21T20:17:53.711948Z	level	1	06QW5CBl000
2018-02-21T20:18:17.711688Z	level	1	06QW6ewl000
2018-02-21T20:18:56.880065Z	full		06QW92x0000
2018-02-21T20:20:46.202368Z	level	3	06QWFizW000
2018-02-21T20:21:25.292557Z	level	1	06QWI6g0000
2018-02-21T20:21:49.294272Z	level	1	06QWJ_RW000
2018-02-21T20:22:13.292489Z	level	1	06QWL2B0000
2018-02-21T20:22:37.292431Z	level	1	06QWMVw0000
2018-02-21T20:22:38.293320Z	level	2	06QWMZqG000
2018-02-21T20:23:01.293690Z	level	1	06QWNygG000
2018-02-21T20:23:25.292956Z	level	1	06QWPRR0000
2018-02-21T20:24:33.291664Z	full		06QWTa2l000
2018-02-21T21:12:08.017055Z	full		06QZBpKG000
2018-02-21T21:12:08.478200Z	full		06QZBr7W000
```
