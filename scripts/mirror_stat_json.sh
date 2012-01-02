#!/bin/bash
source  `dirname $0`/functions.d/functions
STAT_DIR="$SYNC_HOME/status"
LOG_DIR="$SYNC_HOME/logs"
JSON="/srv/www/m_status.json"
SRV_ROOT="/srv/www"
LOG_URL="/index/mlog"
LOCK="/tmp/mirror_json.lck"

lockfile-create $LOCK
lockfile-touch $LOCK &
lockid="$!"
TMP="/tmp/status"
echo "{" > $JSON
for REPO in `ls $STAT_DIR`;do
	cat $STAT_DIR/$REPO> $TMP
	STATUS=`get_stat $TMP "status"`

    if [ $STATUS != '-1' ];then
		LOG=`ls -t $LOG_DIR/$REPO|head -1` 
		cp "$LOG_DIR/$REPO/$LOG" "$SRV_ROOT$LOG_URL/$REPO.log"
	fi

    set_stat $TMP "log" "$LOG_URL/$REPO.log"
	STAT=`cat $TMP`
	echo "    \"$REPO\":$STAT," >> $JSON
done
sed -i -e '$s/\(.*\)\,$/\1/g' $JSON
echo } >> $JSON

kill $lockid
lockfile-remove $LOCK
