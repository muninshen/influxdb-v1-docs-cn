---
title: InfluxDB 安全管理
description: Protect the data in your InfluxDB OSS instance.
menu:
  influxdb_1_8:
    name: 安全管理
    weight: 70
    parent: 管理
---

一些客户可能选择通过公共互联网访问来安装Influxdb,但是这样做可能会无意间暴露您的数据并在您的数据库上发起不受欢迎的攻击，请查看以下部分，了解如何保护Influxdb实例中的数据

## 启用身份验证

密码保护您的Influxdb实例，以防止任何未经授权的个人访问您的数据

参考资料:
[设置身份验证](/influxdb/v1.8/administration/authentication_and_authorization/#set-up-authentication)

## 管理用户和权限

通过创建个人用户并为他们分配相关的读取和/或写入权限来限制访问.

参考资料:
[用户类型和特权](/influxdb/v1.8/administration/authentication_and_authorization/#user-types-and-privileges),
[用户管理命令](/influxdb/v1.8/administration/authentication_and_authorization/#user-management-commands)

## 启用 HTTPS

启用HTTPS会加密客户端与Influxdb服务器之间的通信，HTTPS还可以验证Influxdb服务器对连接客户端的真实性；

参考资料:
[配置HTTP标头](/influxdb/v1.8/administration/https_setup/)

## 配置安全标头

HTTP头允许服务器和客户端随请求一起传递附加信息。 某些标头有助于实施安全属性。

参考资料:
[配置HTTP标头](/influxdb/v1.8/administration/config/#http-headers)

## 保护主机

### 端口
如果只运行Influxdb ，请关闭主机上除端口8086之外的端口
也可以使用 `8086`端口的代理.

InfluxDB使用端口8088进行远程备份和恢复。 我们强烈建议关闭该端口，如果执行远程备份， 仅给予远程机器特定的权限。

### AWS 建议

我们建议实施磁盘加密，Influxdb不提供内置支持来加密数据；
