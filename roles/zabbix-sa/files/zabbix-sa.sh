#!/bin/bash

# author: YuanTong
# data: 2017.09.08
# version: 1.2


# index文件夹内文件数量统计
ls -l /data/sa/index{,_law,_article}/ 2>/dev/null | grep -c '^-' > /tmp/zabbix-sa-IndexNum

# jvm最大可用内存
ps -ef | grep java | grep 'SaServiceWebApplication-1.0.war' | grep -v grep | awk -F 'Xmx' '{print $2}' | awk '{print $1}' | sed 's/[kK]/000/g; s/[mM]/000000/g; s/[gG]/000000000/g' > /tmp/zabbix-sa-JvmXmx
# tocken文件夹大小
du -sb /data/sa/token | awk '{print $1}' > /tmp/zabbix-sa-TockenSize
