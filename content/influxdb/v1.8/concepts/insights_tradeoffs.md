---
title: InfluxDB设计理念
description: 简要介绍了在设计InfluxDB的时候对性能做的一些权衡。
menu:
  influxdb_1_8:
    name: InfluxDB设计理念
    weight: 40
    parent: 概念
---

InfluxDB是一个时间序列数据库。针对这种用例进行优化需要进行一些权衡，主要是以牺牲功能为代价来提高性能。以下列出了一些权衡过的设计见解：

1、对于时间序列用例，假设如果多次接收到相同的数据，则认为它是客户端多次发送的完全相同的同一笔数据。
* 优点：简化的冲突,提高写入性能。
* 缺点：无法存储重复数据，在极少数情况下可能会覆盖数据。

2、删除很少见，当他们确实发生时，肯定是针对大量的旧数据，这些数据对于写入来说是冷数据。
* 优点：限制删除操作，从而增加查询和写入性能。
* 缺点：删除功能受到很大限制。

3、对现有数据的更新是罕见的事件，持续地更新永远不会发生。时间序列数据主要是永远不更新的新数据。
* 优点：限制更新操作，从而增加查询和写入性能。
* 缺点：更新功能受到很大限制。

4、绝大多数写入都是接近当前时间戳的数据，并且数据是按时间递增的顺序添加。
* 优点：按时间递增的顺序添加数据明显更高效些。
* 缺点：随机时间或时间不按升序写入点的性能要低得多。

5、规模至关重要。数据库必须能够处理大量的读取和写入。
* 优点：数据库可以处理海量的读取和写入操作。
* 缺点：InflxuDB开发团队被迫进行权衡以提高性能

6、能够写入和查询数据比具有强一致性更重要。
* 优点：多个客户端可以在高负载的情况下完成查询和写入数据库操作。
* 缺点：如果数据库负载较重，查询返回结果可能不包括最近的点。

7、许多时间序列都是短暂的，通常时间序列只会出现几个小时，然后消失。例如，一台新主机启动并报告一段时间，然后关闭。
* 优点：InfluxDB善于管理不连续数据。
* 缺点：无模式设计意味着不支持某些数据库功能，例如：不支持JOIN操作。

8、单一的数据点point不重要（潜台词：重要的是海量的数据点）。
* 优点：InfluxDB具有非常强大的工具来处理聚合数据和大数据集。
* 缺点：数据点point没有传统意义上的ID，它们被时间戳和series区分开来。