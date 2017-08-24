#!/usr/bin/python
# -*- coding: UTF-8 -*-

import os
import time
import subprocess

file = open("/log/server.log","r")
file_size_old = 0

while True:
    print "---- %s ----" % time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())

    # 判断日志是否重置
    file_size = os.path.getsize("/log/server.log")
    print "file_size_old\t", file_size_old
    print "file_size\t", file_size
    if file_size < file_size_old:
        file.close()
        file = open("/log/server.log", "r")

    # 提取日志中的新记录
    print "%s : new file save" % time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
    file_new = open("/tmp/zabbix-thrift-LogLast.tmp", "w")
    file_new.write("%s" % file.read())
    file_new.close()

    # 执行分析脚本
    print "%s : bash zabbix-thrift.sh" % time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
    subprocess.call("/App/script/zabbix-thrift.sh", shell=True)

    file_size_old = file_size
    print "%s : end" % time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
    time.sleep(56)
