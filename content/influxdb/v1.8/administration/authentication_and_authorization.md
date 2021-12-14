---
title: InfluxDB 中的身份认证和授权
description: Set up and manage authentication and authorization in InfluxDB OSS.
aliases:
    - influxdb/v1.8/administration/authentication_and_authorization/
menu:
  influxdb_1_8:
    name: 身份认证和授权
    weight: 20
    parent: 管理
---

本文当介绍在Influxdb中设置和管理身份验证和授权

- [认证方式](#authentication)
  - [设置身份验证](#set-up-authentication")
  - [验证请求](#authenticate-requests)
- [授权](#authorization)
  - [用户类型和权限](#user-types-and-privileges)
  - [用户管理命令](#user-management-commands)
- [HTTP 错误](#authentication-and-authorization-http-errors)

> **Note:** 不应该以身份验证和授权来防止访问并保护数据免受恶意行为者的侵害，如果需要其他安全性或者合规性功能，则Influxdb应该在第三方服务之后运行。如果将Influxdb部署在可公开访问的端点上，强烈建议启用身份验证，否则，任何未经身份验证的用户都可以访问并获得数据

## 认证方式

Influxdb API和使用API连接到数据库的命令行界面（CLI）包括基本用户凭证的简单内置身份验证后，启用身份验证后，Influxdb仅执行使用有效凭据发送的HTTP请求.

> **Note:** 验证仅在HTTP请求范围内进行。插件当前不具有对请求进行身份验证的能力，并且服务端点（例如Graphite，collected等）不经过身份验证。

### 

#### 1. 创建至少一个管理员用户，有关如何创建管理员用户，请参见授权部分 [admin user](#admin-users).
通过在配置文件的部分中将auth-enabled选项设置为启用身份验证：true [http]

> **Note:** 如果启用身份验证并且没有用户，则Influxdb将不强制执行身份验证，并且仅接受创建admin用户的查询

#### 一旦有管理员用户，Influxdb将强制执行身份验证

#### 2. 默认情况下，配置文件中禁用身份验证.

通过在配置文件的部分中将 `auth-enabled`选项设置为来启用身份验证：true[http]:

```toml
[http]
  enabled = true
  bind-address = ":8086"
  auth-enabled = true # ✨
  log-enabled = true
  write-tracing = false
  pprof-enabled = true
  pprof-auth-enabled = true
  debug-pprof-enabled = false
  ping-auth-enabled = true
  https-enabled = true
  https-certificate = "/etc/ssl/influxdb.pem"
```

{{% note %}}
如果pprof-enabled设置为true，设定pprof-auth-enabled并ping-auth-enabled以true要求在剖析和ping端点认证.
{{% /note %}}

#### 3. 重新启动过程

现在，Influxdb将检查每个请求的用户凭据，并将仅处理具有针对现有用户的有效凭据的请求

### 验证请求

#### 使用InfluxDB API进行身份验证有两个选项

使用 [InfluxDB API](/influxdb/v1.8/tools/api/).进行身份验证有两个选项

如果同时使用基本身份验证和URL查询参数进行身份验证，则查询参数中指定的用户凭据优先，以下示例中查询假定该用户是admin用户，有关不同用户类型，其特权以及有关用户管理的更多信息，请参见授权的部分

> **Note:** 启用身份验证后，Influxdb会编辑密码

##### 如 [RFC 2617, 第 2节所示，使用基本身份验证进行身份验证](http://tools.ietf.org/html/rfc2617)

这是提供用户凭据的首选方法.

例:

```bash
curl -G http://localhost:8086/query -u todd:influxdb4ever --data-urlencode "q=SHOW DATABASES"
```

##### 通过在URL或者请求正文中提供查询参数进行身份验证

设置u为用户名和p密码. 

###### 使用查询参数的示例

```bash
curl -G "http://localhost:8086/query?u=todd&p=influxdb4ever" --data-urlencode "q=SHOW DATABASES"
```

###### 使用请求正文的示例

```bash
curl -G http://localhost:8086/query --data-urlencode "u=todd" --data-urlencode "p=influxdb4ever" --data-urlencode "q=SHOW DATABASES"
```

#### 使用CLI进行身份验证

使用 [CLI](/influxdb/v1.8/tools/shell/).进行身份验证有三个选项

##### 使用 `INFLUX_USERNAME` 和 `INFLUX_PASSWORD` 环境变量进行身份验证

例:

```bash
export INFLUX_USERNAME=todd
export INFLUX_PASSWORD=influxdb4ever
echo $INFLUX_USERNAME $INFLUX_PASSWORD
todd influxdb4ever

influx
Connected to http://localhost:8086 version 1.4.x
InfluxDB shell 1.4.x
```

##### 在启动CLI时通过username和password标志进行身份验证

例:

```bash
influx -username todd -password influxdb4ever
Connected to http://localhost:8086 version 1.4.x
InfluxDB shell 1.4.x
```

##### auth <username> <password>启动CLI后进行身份验证

例:

```bash
influx
Connected to http://localhost:8086 version 1.4.x
InfluxDB shell 1.4.x
> auth
username: todd
password:
>
```

#### 使用JWT令牌进行身份验证
在每个请求中传递JWT令牌是使用密码的一种更安全的选择，当前，这仅可通过 [InfluxDB HTTP API来实现](/influxdb/v1.8/tools/api/).

##### 1. 在influxdb配置文件中添加一个共享密钥
InfluxDB 使用共享密钥对JWT签名进行编码，默认情况下，shared-sectet设置为空字符串，在这种情况下不会进行JWT身份验证，在Influxdb配置文件中添加一个自定义的共享密钥，密码字符串越长，则它越安全

```
[http]
  shared-secret = "my super secret pass phrase"
```

另外.为避免在Influxdb配置文件中将秘密短语保留为纯文本格式，使用INFLUXDB_HTTP_SHARWS_SECRET环境变量设置该值


##### 2. 生成令牌
使用身份验证服务使用Influxdb用户名，到期时间和共享密钥来生成安全令牌，在一些在线工具，例如https://jwt.io/，可以完成此任务

The payload (or claims) of the token must be in the following format:

```
{
  "username": "myUserName",
  "exp": 1516239022
}
```
◦ **username** -Influxdb用户的名称  
◦ **exp** - 在UNIX信号出现时间的令牌的到期时间，为了提高安全性，请缩短令牌到期时间，为了进行测试，可以使用 [https://www.unixtimestamp.com/index.php](https://www.unixtimestamp.com/index.php).手动生成进行此操作

生成的令牌遵循以下格式：`<header>.<payload>.<signatrue>`

##### 3. 在HTTP请求中包含令牌
Authorization在HTTP请求中将生成的令牌为标头的一部分包含在内，使用Bearer授权方案:

```
Authorization: Bearer <myToken>
```
{{% note %}}
只有未过期的令牌才能成功进行身份验证，确保令牌尚未过期
{{% /note %}}

###### 使用JWT身份验证的示例查询请求

```bash
curl -G "http://localhost:8086/query?db=demodb" \
  --data-urlencode "q=SHOW DATABASES" \
--header "Authorization: Bearer <header>.<payload>.<signature>"
```

## 向Influxdb验证Telegraf请求

认证Telegraf请求与验证的Influxdb实例启用要一些额外的步骤，在Telegraf配置文件（/etc/telegraf/telegraf.conf）中，取消注释并编辑username和password设置

```toml
>
    ###############################################################################
    #                            OUTPUT PLUGINS                                   #
    ###############################################################################
>
    [...]
>
    ## Write timeout (for the InfluxDB client), formatted as a string.
    ## If not provided, will default to 5s. 0s means no timeout (not recommended).
    timeout = "5s"
    username = "telegraf" #💥
    password = "metricsmetricsmetricsmetrics" #💥
>
    [...]

```

接下来，重新启动Telegraf，一切就绪！

## 授权

启用身份验证后，才会强制[授权](#set-up-authentication)，默认情况下，身份验证是禁用的，所有凭据都将被忽略，并且所有用户都具有所有权限

### 用户类型和特权

#### 管理员用户

管理员用户拥有READ并WRITE访问所有数据库，并具有对以下管理查询的完全访问权限:

数据库管理:  
&nbsp;&nbsp;&nbsp;◦&nbsp;&nbsp;&nbsp;`CREATE DATABASE`, and `DROP DATABASE`  
&nbsp;&nbsp;&nbsp;◦&nbsp;&nbsp;&nbsp;`DROP SERIES` and `DROP MEASUREMENT`  
&nbsp;&nbsp;&nbsp;◦&nbsp;&nbsp;&nbsp;`CREATE RETENTION POLICY`, `ALTER RETENTION POLICY`, and `DROP RETENTION POLICY`  
&nbsp;&nbsp;&nbsp;◦&nbsp;&nbsp;&nbsp;`CREATE CONTINUOUS QUERY` and `DROP CONTINUOUS QUERY`  

有关上面列出的命令的完整讨论，请参见数据库管理和连续查询的页面

用户管理:  
&nbsp;&nbsp;&nbsp;◦&nbsp;&nbsp;&nbsp;Admin 用户管理t:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[`CREATE USER`](#user-management-commands), [`GRANT ALL PRIVILEGES`](#grant-administrative-privileges-to-an-existing-user), [`REVOKE ALL PRIVILEGES`](#revoke-administrative-privileges-from-an-admin-user), 和 [`SHOW USERS`](#show-all-existing-users-and-their-admin-status)  
&nbsp;&nbsp;&nbsp;◦&nbsp;&nbsp;&nbsp;Non-admin user management:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[`CREATE USER`](#user-management-commands), [`GRANT [READ,WRITE,ALL]`](#grant-read-write-or-all-database-privileges-to-an-existing-user), [`REVOKE [READ,WRITE,ALL]`](#revoke-read-write-or-all-database-privileges-from-an-existing-user), and [`SHOW GRANTS`](#show-a-user-s-database-privileges)  
&nbsp;&nbsp;&nbsp;◦&nbsp;&nbsp;&nbsp;General user management:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[`SET PASSWORD`](#re-set-a-user-s-password) and [`DROP USER`](#drop-a-user)  

请参阅下面的有关用户管理命令的完整讨论

#### 非管理员用户

非管理用户可以拥有的每个数据库以下三个特权之一：
&nbsp;&nbsp;&nbsp;◦&nbsp;&nbsp;&nbsp;`READ`  
&nbsp;&nbsp;&nbsp;◦&nbsp;&nbsp;&nbsp;`WRITE`  
&nbsp;&nbsp;&nbsp;◦&nbsp;&nbsp;&nbsp;`ALL` （包括 `READ` 和 `WRITE` 访问)  

`READ`, `WRITE`, and `ALL` 权限由每个用户每个数据库控制，新的非管理员用户无权访问任何数据库，除非管理员用户明确授予他们对数据库特权

### 用户管理命令

#### 管理员用户管理

启用HTTP身份验证后，Influxdb要求至少创建一个管理员用户，然后才能与系统交互。

`CREATE USER admin WITH PASSWORD '<password>' WITH ALL PRIVILEGES`

##### `CREATE` 另一个管理员用户

```sql
CREATE USER <username> WITH PASSWORD '<password>' WITH ALL PRIVILEGES
```

CLI example:

```sql
> CREATE USER paul WITH PASSWORD 'timeseries4days' WITH ALL PRIVILEGES
>
```

> **Note:** 重复精确的`CREATE USER`语句是幂等的，如果任何值更改，数据库将返回重复的用户错误，有关详细信息，请参见`GitHub Lssue`[#6890](https://github.com/influxdata/influxdb/pull/6890)
>
> ```
> CLI 示例:
> CREATE USER todd WITH PASSWORD '123456' WITH ALL PRIVILEGES
> CREATE USER todd WITH PASSWORD '123456' WITH ALL PRIVILEGES
> CREATE USER todd WITH PASSWORD '123' WITH ALL PRIVILEGES
> ERR: user already exists
> CREATE USER todd WITH PASSWORD '123456'
> ERR: user already exists
> CREATE USER todd WITH PASSWORD '123456' WITH ALL PRIVILEGES
> ```

##### `GRANT` 现有的用户管理权限

```sql
GRANT ALL PRIVILEGES TO <username>
```

CLI 示例:

```sql
> GRANT ALL PRIVILEGES TO "todd"
>
```

##### `REVOKE` 管理员用户的管理权限

```sql
REVOKE ALL PRIVILEGES FROM <username>
```

CLI 示例:

```sql
> REVOKE ALL PRIVILEGES FROM "todd"
>
```

##### `SHOW` 所有现有用户及其管理员状态

```sql
SHOW USERS
```

CLI 示例:

```sql
> SHOW USERS
user 	 admin
todd     false
paul     true
hermione false
dobby    false
```

#### 非管理员用户

##### `CREATE` 新的非管理员用户

```sql
CREATE USER <username> WITH PASSWORD '<password>'
```

CLI 示例:

```sql
> CREATE USER todd WITH PASSWORD 'influxdb41yf3'
> CREATE USER alice WITH PASSWORD 'wonder\'land'
> CREATE USER "rachel_smith" WITH PASSWORD 'asdf1234!'
> CREATE USER "monitoring-robot" WITH PASSWORD 'XXXXX'
> CREATE USER "$savyadmin" WITH PASSWORD 'm3tr1cL0v3r'
>
```

> **Notes:**
* 如果用户值以数字开头、是InfluxQL关键字、包含连字符和/或包含任何特殊字符，则必须用双引号括起来，例如: `!@#$%^&*()-`
* 密码 [字符串](/influxdb/v1.8/query_language/spec/#strings)必须用单引号括起来.
  验证请求时不要包括单引号.
  我们建议避免使用单引号 (`'`) 和反斜杠 (`\`)字符密码.
  对于包含这些字符的密码，在创建密码和提交身份验证请求时，请使用反斜杠 (例如： (`\'`) 对特殊字符进行转义.
* 重复准确的 `CREATE USER` 语句时幂等的，.如果任何值发生变化，数据库将返回重复的用户错误，详见 GitHub 问题 [#6890](https://github.com/influxdata/influxdb/pull/6890) .
>`CLI example`:
>
    > CREATE USER "todd" WITH PASSWORD '123456'
    > CREATE USER "todd" WITH PASSWORD '123456'
    > CREATE USER "todd" WITH PASSWORD '123'
    ERR: user already exists
    > CREATE USER "todd" WITH PASSWORD '123456'
    > CREATE USER "todd" WITH PASSWORD '123456' WITH ALL PRIVILEGES
    ERR: user already exists
    CREATE USER "todd" WITH PASSWORD '123456'


##### `GRANT` `READ`, `WRITE` or `ALL` database 现有用户的数据库特权

```sql
GRANT [READ,WRITE,ALL] ON <database_name> TO <username>
```

CLI 示例:

`GRANT` `READ` 授权给todd读权限访问 `NOAA_water_database` 数据库:

```sql
> GRANT READ ON "NOAA_water_database" TO "todd"
>
```

`GRANT` `ALL` 授权`todd`对`NOAA_water_database` 数据库所有权限:

```sql
> GRANT ALL ON "NOAA_water_database" TO "todd"
>
```

##### `REVOKE` `READ`, `WRITE`, or `ALL` 现有用户的数据库特权

```
REVOKE [READ,WRITE,ALL] ON <database_name> FROM <username>
```

CLI 示例:

`REVOKE` `ALL` 授权`todd`用户对NOAA_water_database所有权限：

```sql
> REVOKE ALL ON "NOAA_water_database" FROM "todd"
>
```

`REVOKE` `WRITE` `todd`用户对 `NOAA_water_database` 数据库的写权限:

```sql
> REVOKE WRITE ON "NOAA_water_database" FROM "todd"
>
```

>**Note:** 如果ALL具有WRITE特权的用户被撤销特权，则他们将拥有READ特权，反之亦然.

##### `SHOW` a user's database privileges

```sql
SHOW GRANTS FOR <user_name>
```

CLI 示例:

```sql
> SHOW GRANTS FOR "todd"
database		            privilege
NOAA_water_database	        WRITE
another_database_name	      READ
yet_another_database_name   ALL PRIVILEGES
one_more_database_name      NO PRIVILEGES
```

#### 普通管理员和非管理员用户管理

##### Re`SET` a user's password

```sql
SET PASSWORD FOR <username> = '<password>'
```

CLI example:

```sql
> SET PASSWORD FOR "todd" = 'influxdb4ever'
>
```

{{% note %}}
**Note:** 密码字符串必须用单引号引起来，验证请求时，清湖包含单引号

建议避免在密码中使用单引号（‘）和反斜杠（\）字符对于包含这些字符\’的密码，在创建密码和提交身份验证请求时，请使用反斜杠对特殊字符进行转义，（例如（））
{{% /note %}}

##### `DROP` a user

```sql
DROP USER <username>
```

CLI example:

```sql
> DROP USER "todd"
>
```

## 身份验证和授权HTTP错误

没有身份验证凭据或者凭据不正确的将产生`HTTP 401 Unauthorized`响应

未经授权的用户的请求将产生`HTTP 403 Forbidden`响应。