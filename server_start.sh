#!/bin/bash

# 启动docs-v2服务

nohup hugo server --bind=0.0.0.0 -p=80 &
