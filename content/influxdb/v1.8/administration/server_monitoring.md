---
title: 监控 InfluxDB 服务
description: Troubleshoot and monitor InfluxDB OSS.
aliases:
    - /influxdb/v1.8/administration/statistics/
    - /influxdb/v1.8/troubleshooting/statistics/
menu:
  influxdb_1_8:
    name: InfluxDB 监控
    weight: 80
    parent: 管理
---

**本页**

* [显示统计](#show-stats)
* [显示诊断](#show-diagnostics)
* [内部监控](#internal-monitoring)
* [有用的性能指标命令](#useful-performance-metrics-commands)
* [InfluxDB `/metrics` HTTP 端点](#influxdb-metrics-http-endpoint)

InfluxDB 可以显示每个节点的统计和诊断信息，这些信息对于故障排除和性能监控非常有用。

## 显示统计

要查看节点统计信息，请执行命令“显示统计信息”，有关此命令详细信息，请参见Influxdb规范中[]

## 显示诊断

要查看节点诊断信息，请执行命令SHOW DIAGNOSTICS，这将返回诸如构建信息，正常运行的时间，主机名，服务器配置，内存使用情况以及

## 内部监控
InfluxDB还将统计和诊断信息写入名为的数据库_internal，该数据库记录有关内部运行时和服务性能的指标。该_internal数据库可以查询和操纵像任何其他InfluxDB数据库。请查看监视服务README和内部监视博客文章，以获取更多详细信息

## 有用的性能指标命令

以下是一些命令

查找每秒写入实例的点数，必须monitor启用该服务，
```bash
$ influx -execute 'select derivative(pointReq, 1s) from "write" where time > now() - 5m' -database '_internal' -precision 'rfc3339'
```

要查找自日志文件开始以来按数据库分割的写入数据
```bash
grep 'POST' /var/log/influxdb/influxd.log | awk '{ print $10 }' | sort | uniq -c
```


或者，对于记录到日志的系统


```bash
journalctl -u influxdb.service | awk '/POST/ { print $10 }' | sort | uniq -c
```

### InfluxDB `/metrics` HTTP 端点

> **注意** 没有用于/metrics终结点改进的出色PR，但是我们会在出现它们时将它们添加到CHANGELOG中。

The InfluxDB `/metrics` 端点配置为以Prometheus度量标准格式生成默认的Go度量标准


#### 使用InfluxDB `/metrics' 端点的示例

以下是使用 `/metrics`端点生成的输出的示例，请注意，可以使用HELP来解释Go度量标准.

```

# HELP go_gc_duration_seconds A summary of the GC invocation durations.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 6.4134e-05
go_gc_duration_seconds{quantile="0.25"} 8.8391e-05
go_gc_duration_seconds{quantile="0.5"} 0.000131335
go_gc_duration_seconds{quantile="0.75"} 0.000169204
go_gc_duration_seconds{quantile="1"} 0.000544705
go_gc_duration_seconds_sum 0.004619405
go_gc_duration_seconds_count 27
# HELP go_goroutines Number of goroutines that currently exist.
# TYPE go_goroutines gauge
go_goroutines 29
# HELP go_info Information about the Go environment.
# TYPE go_info gauge
go_info{version="go1.10"} 1
# HELP go_memstats_alloc_bytes Number of bytes allocated and still in use.
# TYPE go_memstats_alloc_bytes gauge
go_memstats_alloc_bytes 1.581062048e+09
# HELP go_memstats_alloc_bytes_total Total number of bytes allocated, even if freed.
# TYPE go_memstats_alloc_bytes_total counter
go_memstats_alloc_bytes_total 2.808293616e+09
# HELP go_memstats_buck_hash_sys_bytes Number of bytes used by the profiling bucket hash table.
# TYPE go_memstats_buck_hash_sys_bytes gauge
go_memstats_buck_hash_sys_bytes 1.494326e+06
# HELP go_memstats_frees_total Total number of frees.
# TYPE go_memstats_frees_total counter
go_memstats_frees_total 1.1279913e+07
# HELP go_memstats_gc_cpu_fraction The fraction of this program's available CPU time used by the GC since the program started.
# TYPE go_memstats_gc_cpu_fraction gauge
go_memstats_gc_cpu_fraction -0.00014404354379774563
# HELP go_memstats_gc_sys_bytes Number of bytes used for garbage collection system metadata.
# TYPE go_memstats_gc_sys_bytes gauge
go_memstats_gc_sys_bytes 6.0936192e+07
# HELP go_memstats_heap_alloc_bytes Number of heap bytes allocated and still in use.
# TYPE go_memstats_heap_alloc_bytes gauge
go_memstats_heap_alloc_bytes 1.581062048e+09
# HELP go_memstats_heap_idle_bytes Number of heap bytes waiting to be used.
# TYPE go_memstats_heap_idle_bytes gauge
go_memstats_heap_idle_bytes 3.8551552e+07
# HELP go_memstats_heap_inuse_bytes Number of heap bytes that are in use.
# TYPE go_memstats_heap_inuse_bytes gauge
go_memstats_heap_inuse_bytes 1.590673408e+09
# HELP go_memstats_heap_objects Number of allocated objects.
# TYPE go_memstats_heap_objects gauge
go_memstats_heap_objects 1.6924595e+07
# HELP go_memstats_heap_released_bytes Number of heap bytes released to OS.
# TYPE go_memstats_heap_released_bytes gauge
go_memstats_heap_released_bytes 0
# HELP go_memstats_heap_sys_bytes Number of heap bytes obtained from system.
# TYPE go_memstats_heap_sys_bytes gauge
go_memstats_heap_sys_bytes 1.62922496e+09
# HELP go_memstats_last_gc_time_seconds Number of seconds since 1970 of last garbage collection.
# TYPE go_memstats_last_gc_time_seconds gauge
go_memstats_last_gc_time_seconds 1.520291233297057e+09
# HELP go_memstats_lookups_total Total number of pointer lookups.
# TYPE go_memstats_lookups_total counter
go_memstats_lookups_total 397
# HELP go_memstats_mallocs_total Total number of mallocs.
# TYPE go_memstats_mallocs_total counter
go_memstats_mallocs_total 2.8204508e+07
# HELP go_memstats_mcache_inuse_bytes Number of bytes in use by mcache structures.
# TYPE go_memstats_mcache_inuse_bytes gauge
go_memstats_mcache_inuse_bytes 13888
# HELP go_memstats_mcache_sys_bytes Number of bytes used for mcache structures obtained from system.
# TYPE go_memstats_mcache_sys_bytes gauge
go_memstats_mcache_sys_bytes 16384
# HELP go_memstats_mspan_inuse_bytes Number of bytes in use by mspan structures.
# TYPE go_memstats_mspan_inuse_bytes gauge
go_memstats_mspan_inuse_bytes 1.4781696e+07
# HELP go_memstats_mspan_sys_bytes Number of bytes used for mspan structures obtained from system.
# TYPE go_memstats_mspan_sys_bytes gauge
go_memstats_mspan_sys_bytes 1.4893056e+07
# HELP go_memstats_next_gc_bytes Number of heap bytes when next garbage collection will take place.
# TYPE go_memstats_next_gc_bytes gauge
go_memstats_next_gc_bytes 2.38107752e+09
# HELP go_memstats_other_sys_bytes Number of bytes used for other system allocations.
# TYPE go_memstats_other_sys_bytes gauge
go_memstats_other_sys_bytes 4.366786e+06
# HELP go_memstats_stack_inuse_bytes Number of bytes in use by the stack allocator.
# TYPE go_memstats_stack_inuse_bytes gauge
go_memstats_stack_inuse_bytes 983040
# HELP go_memstats_stack_sys_bytes Number of bytes obtained from system for stack allocator.
# TYPE go_memstats_stack_sys_bytes gauge
go_memstats_stack_sys_bytes 983040
# HELP go_memstats_sys_bytes Number of bytes obtained from system.
# TYPE go_memstats_sys_bytes gauge
go_memstats_sys_bytes 1.711914744e+09
# HELP go_threads Number of OS threads created.
# TYPE go_threads gauge
go_threads 16
```