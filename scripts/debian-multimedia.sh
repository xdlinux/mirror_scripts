#!/bin/bash
#
# The script to sync a local mirror of the Arch Linux repositories and ISOs
#
# Copyright (C) 2007 Woody Gilk <woody@archlinux.org>
# Modifications by Dale Blount <dale@archlinux.org>
# and Roman Kyrylych <roman@archlinux.org>
# Licensed under the GNU GPL (version 2)

source `dirname $0`/functions.d/functions
# Filesystem locations for the sync operations
SYNC_HOME="/home/bigeagle/mirror"
SYNC_LOGS="$SYNC_HOME/logs/debian-multimedia"
SYNC_FILES="/srv/ftp/debian-multimedia"
SYNC_LOCK="$SYNC_HOME/debian-multimedia.lck"
#SYNC_SERVER="rsync://ftp.tw.debian.org/debian/"
#SYNC_SERVER="rsync://debian.ustc.edu.cn/debian-multimedia/"
SYNC_SERVER="rsync://debian6.ustc.edu.cn/debian-multimedia/"
LOG_FILE="debian_$(date +%Y%m%d-%H).log"
EX_FILE="$SYNC_HOME/scripts/functions.d/debian.exclude"
STAT_FILE="$SYNC_HOME/status/debian-multimedia"
# Do not edit the following lines, they protect the sync from running more than
# one instance at a time
if [ ! -d $SYNC_HOME ]; then
  echo "$SYNC_HOME does not exist, please create it, then run this script again."
  exit 1
fi

[ -f $SYNC_LOCK ] && exit 1
touch "$SYNC_LOCK"
# End of non-editable lines

set_stat $STAT_FILE "status" "-1"
set_stat $STAT_FILE "upstream" $SYNC_SERVER
# Create the log file and insert a timestamp
touch "$SYNC_LOGS/$LOG_FILE"
echo "=============================================" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> Starting sync on $(date --rfc-3339=seconds)" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> ---" >> "$SYNC_LOGS/$LOG_FILE"
#starting rsync

rsync -6 -avz \
--exclude-from $EX_FILE \
--exclude *s390.deb  --exclude *source* \
--exclude *.iso \
--exclude *.orig.tar.gz --exclude *.diff.gz \
--exclude *.dsc \
$SYNC_SERVER $SYNC_FILES >> $SYNC_LOGS/$LOG_FILE 

set_stat $STAT_FILE "status" $?
set_stat $STAT_FILE "lastsync" `date --rfc-3339=seconds|sed 's/\ /\\ /'`
date --rfc-3339=seconds > "$SYNC_FILES/lastsync"
# Insert another timestamp and close the log file
echo ">> ---" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> Finished sync on $(date --rfc-3339=seconds)" >> "$SYNC_LOGS/$LOG_FILE"
echo "=============================================" >> "$SYNC_LOGS/$LOG_FILE"
echo "" >> "$SYNC_LOGS/$LOG_FILE"

# Remove the lock file and exit
rm -f "$SYNC_LOCK"
exit 0
