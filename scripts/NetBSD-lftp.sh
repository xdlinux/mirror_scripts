#!/bin/bash
SYNC_HOME="/home/bigeagle/mirror"
SYNC_LOGS="$SYNC_HOME/logs/NetBSD"
SYNC_DIR="/srv/ftp/NetBSD"
SYNC_LOCK="$SYNC_HOME/NetBSD.lck"
case "$1" in
	stop) 
	rm $SYNC_LOCK
	ps ax|grep -i netbsd|awk '{print $1}'|xargs kill
	;;
esac

LOG_FILE="$SYNC_LOGS/NetBSD_$(date +%Y%m%d-%H).log"
SERVER_LIST="$SYNC_HOME/mirrorlist.d/NetBSD.list"

[ -f $SYNC_LOCK ] && exit 1
touch "$SYNC_LOCK"

#SYNC_SERVER=http://ftp6.sjtu.edu.cn/NetBSD/
REPOS=("NetBSD-5.0.2" "packages/5.0")
for SERVER in `cat $SERVER_LIST|sed -e '/^#.*$/g'`;do
	for repo in ${REPOS[@]};do
		#echo $repo
		SYNC_SERVER="$SERVER$repo"
		#echo $SYNC_SERVER
		SYNC_FILES="$SYNC_DIR/$repo"		
		
		[ ! -d $SYNC_FILES ] && mkdir -p $SYNC_FILES
		cd $SYNC_FILES
		#echo "$LOG_FILE"
		lftp $SYNC_SERVER -e "mirror --only-newer --only-missing -e -P 10 --verbose --log=$LOG_FILE;exit" &
		#sleep 1
	done
	sleep 1
done
wait
rm $SYNC_LOCK
#lftp $SYNC_SERVER -e 'mirror --only-newer --only-missing -e -P 20 --verbose --log=$LOG_FILE;exit'
