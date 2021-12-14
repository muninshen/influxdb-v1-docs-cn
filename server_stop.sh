#!/bin/bash

# 停止docs-v2服务

kill -9 `ps -ef | grep "hugo server" | awk 'NR==1' | awk '{ print $2 }'`
