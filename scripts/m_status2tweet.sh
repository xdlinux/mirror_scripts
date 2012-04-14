#!/bin/bash
source  `dirname $0`/functions.d/functions
STAT_DIR="$SYNC_HOME/status"
FAIL=""
INPRO=""
for REPO in `ls $STAT_DIR`;do
    STAT=$(get_stat $STAT_DIR/$REPO "status")
	if [ $STAT -gt 0 ];then
		FAIL="$REPO,$FAIL"
	elif [ $STAT == '-1' ];then
		INPRO="$REPO,$INPRO"	
	fi
done

FAIL=`echo $FAIL|sed '$s/\(.*\)\,$/\1/' `
INPRO=`echo $INPRO|sed '$s/\(.*\)\,$/\1/' `

month=`date +%m`
day=`date +%d`

if [ -z $FAIL ];then
	if [ -z $INPRO ];then
		TWEET="昨晚工作好辛苦阿,所有同步都成功了!好高兴阿!%20%23xdlinux"
	fi
else
	TWEET=$month"月"$day"日的"$FAIL"源同步失败了,好伤心,好郁闷,下次我一定努力!%20%23xdlinux"
fi

KEY=`cat $SYNC_HOME/KEY`
URL='http://xdtuxbot.appspot.com/tweet?msg='$TWEET'&key='$KEY
echo $TWEET
curl $URL
if [ ! -z $INPRO ];then
	TWEET="为何"$INPRO"源到现在还没同步完...好不给力的校园网%20%23xdlinux""
	URL='http://xdtuxbot.appspot.com/tweet?msg='$TWEET'&key='$KEY
	echo $TWEET
	curl $URL
fi
