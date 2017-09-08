#!/bin/bash

# index文件夹内文件数量统计
ls /data/sa/index/ | wc -l > /tmp/zabbix-asa-IndexNum

# jvm最大可用内存
ps -ef | grep java | grep 'SaServiceWebApplication-1.0.war' | grep -v grep | awk -F 'Xmx' '{print $2}' | awk '{print $1}' | sed 's/[kK]/000/g; s/[mM]/000000/g; s/[gG]/000000000/g' > /tmp/zabbix-asa-JvmXmx
# tocken文件夹大小
du -sb /data/sa/token | awk '{print $1}' > /tmp/zabbix-asa-TockenSize
