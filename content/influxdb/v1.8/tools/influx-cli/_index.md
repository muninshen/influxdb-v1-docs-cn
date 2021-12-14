---
title: influx - InfluxDB command line interface
menu:
  influxdb_1_8:
    name: influx
    weight: 10
    parent: Tools
---

`influx`命令行界面（CLI）包含InfluxDB管理的诸多方面，包括数据库，组织，用户和任务的命令。


## 用法

```
influx [标识]
```


## 标识

| 标识           | 描述                                                  |
| -------------- | ----------------------------------------------------- |
| `-version`     | 显示版本并退出                                        |
| `-url-prefix`  | 在主机和端口之后添加URL的路径，指定要连接的自定义端点 |
| `-host`        | InfluxDB的HTTP地址 (默认: `http://localhost:8086`)    |
| `-port`        | 指定连接的端口                                        |
| `-socket`      | Unix 套接字连接                                       |
| `-database`    | 指定要连接的数据库名称                                |
| `-password`    | 连接服务器的密码，保留为空白将提示输入密码            |
| `-username`    | 连接服务器的用户名                                    |
| `-ssl`         | 使用https进行请求                                     |
| `-unsafessl`   | 使用https连接到集群时进行设置                         |
| `-execute`     | 执行命令并退出                                        |
| `-type`        | 指定用于执行命令或调用REPL的查询语言                  |
| `-format`      | 执行服务器响应的格式： json， csv， 或 column         |
| `-precision`   | 指定时间戳格式： rfc3339，h， m， s， ms， u 或 ns    |
| `-consistency` | 设置写入一致性级别： any，one，quorum，或 all         |
| `-pretty`      | 以Json格式返回可读性较高的结果                        |
| `-import`      | 导入数据（以influx_inspect expor方式导出的数据）      |
| `-pps`         | 导入时允许的每秒point数量，默认为`0`即不限制数量      |
| `-path`        | 指定被导入数据的路径                                  |
| `-compressed`  | 如果被导入文件已压缩，则设置为true                    |
