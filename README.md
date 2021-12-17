# Chinese Documentation for InfluxDB v1.x | InfluxDB v1.x 中文文档

欢迎来到 InfluxDB v1.x 中文文档仓库！

这里存放的是 [InfluxDB v1.x 中文文档](http://influxdb-v1-docs-cn.cnosdb.com/
)的源文件。[官方英文文档](https://docs.influxdata.com/influxdb/v1.8/)的源文件则存放于 [influxdata/docs.influxdata.com-ARCHIVE](https://github.com/influxdata/docs.influxdata.com)。

如果你发现或遇到了 InfluxDB 的文档问题，可随时[提 Issue](https://github.com/muninshen/influxdb-v1-docs-cn/issues/new/) 来反馈，或者直接[提交 Pull Request](/CONTRIBUTING.md#pull-request-提交流程) 来进行修改。

> **参考:**
本文档基于最新稳定版的InfluxDB v1.8版本的官方手册进行翻译。

1. **下载并安装Hugo**

    下载地址：https://github.com/gohugoio/hugo/releases/tag/v0.75.0 根据操作系统，下载前缀为“hugo_extended_0.75.0”的压缩文件。

2. **安装NodeJS并下载需要的依赖**

    下载地址：https://nodejs.org/en/download/
    
    ```
    npm i -g postcss-cli autoprefixer
    ```

3. **启动Hugo服务**

    Linux/macOS:
    ```
    $ cd 至该repo根目录
    $ ./server_start
    ```

    Windows:
    ```
    $ cd 至该repo根目录
    $ hugo serve
    ```

    查看文档： `http://<ip_address>:<port_number>`。