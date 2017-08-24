#!/bin/bash

#function:      get data on thrift servers for zabbix
#author:        YuanTong
#date:          2017.8.5
#version:       2.3

day_last=`date -d "-1 day" +%Y-%m-%d`
time_h=`date +%H`
time_m=`date +%M`

source /etc/profile

# thrift日志报错
if [ $time_h -eq 01 -a $time_m -eq 00 ]
then
	grep "^$day_last" /log/server.log | grep ' ERROR ' > /tmp/server.log.tmp
	error_num=`wc -l /tmp/server.log.tmp | awk '{print $1}'`

	echo -e "日期:$day_last" > /tmp/zabbix-Thrift-LogErrorTxt
	echo -e "ERROR数量:$error_num" >> /tmp/zabbix-Thrift-LogErrorTxt
	echo -e "\nERROR详情" >> /tmp/zabbix-Thrift-LogErrorTxt

	awk '{$1="";$2="";$3="";print $0}' /tmp/server.log.tmp \
| sed 's/ERROR c.w.h.l.s.impl.CaseLawServiceImpl.getRefrenceCount 525 - law section referencd cache is null, cacheKey = .*,law section uuid = .*/ERROR c.w.h.l.s.impl.CaseLawServiceImpl.getRefrenceCount 525 - law section referencd cache is null, cacheKey = (省略),law section uuid = (省略)/g' \
| sed 's/ERROR c.w.h.data.builder.LeftTreeBuilder.compare 854 - #### rr2.id:.*/ERROR c.w.h.data.builder.LeftTreeBuilder.compare 854 - #### rr2.id:(省略)/g' \
| sed "s/ERROR c.w.h.l.service.impl.LawServiceImpl.getRefrenceCounts 660 - getLawDetailByLawno referenceCount'cache is null, cacheKey = .*,lawNo = .*/ERROR c.w.h.l.service.impl.LawServiceImpl.getRefrenceCounts 660 - getLawDetailByLawno referenceCount'cache is null, cacheKey = (省略),lawNo = (省略)/g" \
| sed 's/ERROR c.w.h.d.u.ConditionIsForbiddenUtil.pageSizeAndIndexIsAllow 73 - ########index,size不合法：.* \&\& .* ########/ERROR c.w.h.d.u.ConditionIsForbiddenUtil.pageSizeAndIndexIsAllow 73 - ########index,size不合法：(省略) \&\& (省略) ########/g' \
| sed 's/ERROR c.w.h.d.u.ConditionIsForbiddenUtil.conditionIsAllow 92 - ########Condition不合法，只有一个条件：.* \&\& .* \&\& .* 不允许查！########/ERROR c.w.h.d.u.ConditionIsForbiddenUtil.conditionIsAllow 92 - ########Condition不合法，只有一个条件：(省略) \&\& (省略) \&\& (省略) 不允许查！########/g' \
| sed 's/ERROR c.w.h.d.u.ConditionIsForbiddenUtil.isForbidden 123 - ########查询条件不合法，.*出现了两个值：.* \&\& .* ########/ERROR c.w.h.d.u.ConditionIsForbiddenUtil.isForbidden 123 - ########查询条件不合法，(省略)出现了两个值：(省略) \&\& (省略) ########/g' \
| sed 's/ERROR c.w.h.s.SuffixArraySearchTask.call 81 - ### 结点 .* 消耗时间为: .*毫秒, ID: .*/ERROR c.w.h.s.SuffixArraySearchTask.call 81 - ### 结点 (省略) 消耗时间为: (省略)毫秒, ID: (省略)/g' \
| sed 's/ERROR c.w.h.l.l.LawSuffixArraySearchTask.call 61 - ### 法律法规搜索 结点 .* 消耗时间为:.*毫秒,搜索ID = law-.*超过10s/ERROR c.w.h.l.l.LawSuffixArraySearchTask.call 61 - ### 法律法规搜索 结点 (省略) 消耗时间为:(省略)毫秒,搜索ID = law-(省略)超过10s/g' \
| sed 's/ERROR c.w.h.l.s.impl.CaseLawServiceImpl.getRefrenceCount 563 - law section referencd cache is null, cacheKey = .*, law section uuids = \[.*\]/ERROR c.w.h.l.s.impl.CaseLawServiceImpl.getRefrenceCount 563 - law section referencd cache is null, cacheKey = (省略), law section uuids = \[(省略)\]/g' \
| sed 's/ERROR c.w.h.l.s.impl.CaseLawServiceImpl.getRegulations 433 - getRegulations from case occurs Exception, caseId:.*/ERROR c.w.h.l.s.impl.CaseLawServiceImpl.getRegulations 433 - getRegulations from case occurs Exception, caseId:(省略)/g' \
| sort | uniq -c | sort -nr | head -n 100 >> /tmp/zabbix-Thrift-LogErrorTxt
fi

# thrift日志报错(java.util.concurrent.CancellationException)
grep -c 'java.util.concurrent.CancellationException' /tmp/zabbix-thrift-LogLast.tmp > /tmp/zabbix-thrift-LogError-java.util.concurrent.CancellationException

# thrift查询asa的平均时间，thrift查询耗时异常的asa节点
grep -v '法律法规' /tmp/zabbix-thrift-LogLast.tmp | grep '消耗时间为' |  awk -F '毫秒,' '{print $1}' | sed 's/消耗时间为://g' | awk '{print $1,$2,$NF,$(NF-1)}' | sort -k 4,4n -k 1,1r -k 2,2r | uniq -f 3 > /tmp/zabbix-thrift-AsaTime.tmp
if [ -s /tmp/zabbix-thrift-AsaTime.tmp ]
then
    awk '{sum+=$3} END {print sum/NR}' /tmp/zabbix-thrift-AsaTime.tmp > /tmp/zabbix-thrift-AsaTimeAvg
    awk '{if ($3 > 10000) {print $1,$2"\tasa"$4"\t"$3"ms"}}' /tmp/zabbix-thrift-AsaTime.tmp > /tmp/zabbix-thrift-AsaTimeout
else
    echo 0 > /tmp/zabbix-thrift-AsaTimeAvg
fi

# thrift查询rsa的平均时间，thrift查询耗时异常的rsa节点
grep '法律法规' /tmp/zabbix-thrift-LogLast.tmp | grep '消耗时间为' |  awk -F '毫秒,' '{print $1}' | sed 's/消耗时间为://g' | awk '{print $1,$2,$NF,$(NF-1)}' | sort -k 4,4n -k 1,1r -k 2,2r | uniq -f 3 > /tmp/zabbix-thrift-RsaTime.tmp
if [ -s /tmp/zabbix-thrift-RsaTime.tmp ]
then
    awk '{sum+=$3} END {print sum/NR}' /tmp/zabbix-thrift-RsaTime.tmp > /tmp/zabbix-thrift-RsaTimeAvg
    awk '{if ($3 > 10000) {print $1,$2"\trsa"$4"\t"$3"ms"}}' /tmp/zabbix-thrift-RsaTime.tmp > /tmp/zabbix-thrift-RsaTimeout
else
    echo 0 > /tmp/zabbix-thrift-RsaTimeAvg
fi

# thrift对所有sa服务器ping相应时间平均值
grep '[[:space:]][alr]sa' /etc/hosts | awk '{print $1}' > /tmp/ip-sa
fping -qs -c 1 -f /tmp/ip-sa > /tmp/zabbix-thrift-SaPing.tmp 2>&1
grep '(avg round trip time)' /tmp/zabbix-thrift-SaPing.tmp | awk '{print $1}' > /tmp/zabbix-thrift-SaPingAvg
grep '(max round trip time)' /tmp/zabbix-thrift-SaPing.tmp | awk '{print $1}' > /tmp/zabbix-thrift-SaPingMax
