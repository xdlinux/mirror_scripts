#!/bin/bash
SYNC_HOME="/home/bigeagle/mirror"
SYNC_LOGS="$SYNC_HOME/logs/debian"
SYNC_DIR="/srv/ftp/debian"
SYNC_LOCK="$SYNC_HOME/debian.lck"
case "$1" in
	stop) 
	rm $SYNC_LOCK
	ps ax|grep -i debian|awk '{print $1}'|xargs kill
	;;
esac

LOG_FILE="$SYNC_LOGS/debian_$(date +%Y%m%d-%H).log"
SERVER_LIST="$SYNC_HOME/mirrorlist.d/debian.list"

[ -f $SYNC_LOCK ] && exit 1
touch "$SYNC_LOCK"

#SYNC_SERVER=http://ftp6.sjtu.edu.cn/debian/
for SERVER in `cat $SERVER_LIST|sed -e '/^#.*$/g'`;do
		#echo $repo
		SYNC_SERVER="$SERVER"
		#echo $SYNC_SERVER
		SYNC_FILES="$SYNC_DIR"		
		
		[ ! -d $SYNC_FILES ] && mkdir -p $SYNC_FILES
		cd $SYNC_FILES
		#echo "$LOG_FILE"
		lftp $SYNC_SERVER -e "mirror --only-newer --only-missing --parallel=7 --verbose --log=$LOG_FILE --exclude .*ia64.* --exclude .*_alpha.* --exclude .*hppa.* --exclude .*s390.*  --exclude .*armel.*  --exclude .*kfreebsd.* --exclude .*powerpc.*  --exclude .*sparc.*  --exclude .*mipsel.* --exclude .*_hurd.* --exclude .*.orig.tar.gz --exclude .*.orig.tar.bz2 --exclude .*.diff.gz --exclude .*.dsc --exclude .*.iso ;exit" &
		#sleep 1
	sleep 1
done
wait
rm $SYNC_LOCK
#lftp $SYNC_SERVER -e 'mirror --only-newer --only-missing -e -P 20 --verbose --log=$LOG_FILE;exit'
