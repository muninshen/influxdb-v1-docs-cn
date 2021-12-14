---
title: InfluxQL 查询语言
description: >
  Influx Query Language (InfluxQL) is Influx DB's SQL-like query language.
menu:
  influxdb_1_8:
    weight: 70
    identifier: InfluxQL
---

本章节介绍InfluxQL，这是一种类SQL语言的查询语言，用于处理InfluxDB数据中的数据。

## InfluxQL 教程


本章节的前7个小节提供了InfluxQL的教程式。[示例中数据](/influxdb/v1.8/query_language/data_download/)提供的数据集可以随意下载。

#### 数据探索

[数据探索](/influxdb/v1.8/query_language/explore-data/)涵盖InfluxQL查询语言基础知识，包括 [`SELECT`](/influxdb/v1.8/query_language/explore-data/#the-basic-select-statement)， [`GROUP BY`](/influxdb/v1.8/query_language/explore-data/#the-group-by-clause)， [`INTO`](/influxdb/v1.8/query_language/explore-data/#the-into-clause)等。请参阅数据探索以了解查询中的[time语法](https://docs.influxdata.com/influxdb/v1.8/query_language/explore-data/#time-syntax)和 [正则表达式](https://docs.influxdata.com/influxdb/v1.8/query_language/explore-data/#regular-expressions)。

#### Schema探索

[Schema探索](https://docs.influxdata.com/influxdb/v1.8/query_language/explore-schema/)涵盖了对探索[Schema](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#schema)的查询 。有关语法说明和InfluxQL`SHOW` 查询的示例，请参见[Schema探索]()。

#### 数据库管理

[数据库管理](https://docs.influxdata.com/influxdb/v1.8/query_language/manage-database/)涵盖了InfluxQL用于管理 InfluxDB中的[数据库](/influxdb/v1.8/concepts/glossary/#database)和 [保留策略](/influxdb/v1.8/concepts/glossary/#retention-policy-rp)。有关创建和删除数据库和保留策略以及删除和删除数据的信息，请参阅数据库管理。

#### InfluxQL函数

涵盖所有 [InfluxQL函数](/influxdb/v1.8/query_language/functions/).

#### InfluxQL连续查询

[InfluxQL连续查询](https://docs.influxdata.com/influxdb/v1.8/query_language/continuous_queries/)涵盖了[基本语法](/influxdb/v1.8/query_language/continuous_queries/#basic-syntax) ， [高级语法](/influxdb/v1.8/query_language/continuous_queries/#advanced-syntax) ，以及 [常见用例](/influxdb/v1.8/query_language/continuous_queries/#continuous-query-use-cases)，。此页面还描述了如何进行 [`SHOW`](/influxdb/v1.8/query_language/continuous_queries/#listing-continuous-queries)和 [`DROP`](/influxdb/v1.8/query_language/continuous_queries/#deleting-continuous-queries) `continuous queries`。

#### InfluxQL数学运算符

[InfluxQL数学运算符](/influxdb/v1.8/query_language/math_operators/) 涵盖了InfluxQL中数学运算符的使用。

#### 认证与授权

[身份认证与授权](/influxdb/v1.8/administration/authentication_and_authorization/)涵盖了如何在InfluxDB中
[设置身份认证](/influxdb/v1.8/administration/authentication_and_authorization/#set-up-authentication)以及如何对请求进行身份认证，此页面还描述了不同的[用户类型](/influxdb/v1.8/administration/authentication_and_authorization/#user-types-and-privileges)以及[管理数据库用户](/influxdb/v1.8/administration/authentication_and_authorization/#user-management-commands)的InfluxQL。

## InfluxQL参考

[InfluxQL参考文档](/influxdb/v1.8/query_language/spec/)。