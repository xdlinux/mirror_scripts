#!/bin/bash
STAT_DIR="/home/work/mirror/status"
JSON="/srv/www/m_status.json"
LOCK="/tmp/mirror_json.lck"

lockfile-create $LOCK
lockfile-touch $LOCK &
lockid="$!"

echo "{" > $JSON
for REPO in `ls $STAT_DIR`;do
	STAT=`cat $STAT_DIR/$REPO`
	echo "	\"$REPO\":$STAT," >> $JSON
done
sed -i -e '$s/\(.*\)\,$/\1/g' $JSON
echo } >> $JSON

kill $lockid
lockfile-remove $LOCK
