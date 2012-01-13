#!/bin/bash
#
# The script to sync a local mirror of the Arch Linux repositories and ISOs
#
# Copyright (C) 2007 Woody Gilk <woody@archlinux.org>
# Modifications by Dale Blount <dale@archlinux.org>
# and Roman Kyrylych <roman@archlinux.org>
# Licensed under the GNU GPL (version 2)

# Filesystem locations for the sync operations
source `dirname $0`/functions.d/functions

SYNC_LOGS="$SYNC_HOME/logs/deepin"
SYNC_FILES="/srv/ftp/deepin"
SYNC_LOCK="$SYNC_HOME/deepin.lck"
#SYNC_SERVER=rsync://deepin.dormforce.net/ubuntu
#SYNC_SERVER=rsync://debian.ustc.edu.cn/deepin
SYNC_SERVER=rsync://mirrors6.ustc.edu.cn/deepin
#SYNC_SERVER=rsync://mirrors.xmu6.edu.cn/deepin-archive
LOG_FILE="deepin_$(date +%Y%m%d-%H).log"

STAT_FILE="$SYNC_HOME/status/deepin"
# Do not edit the following lines, they protect the sync from running more than
# one instance at a time
check_dirs


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

rsync -6 -av --delete-after $SYNC_SERVER $SYNC_FILES >> $SYNC_LOGS/$LOG_FILE

set_stat $STAT_FILE "status" $?
set_stat $STAT_FILE "lastsync" "`date --rfc-3339=seconds|sed 's/\ /\\ /'`"

date --rfc-3339=seconds > "$SYNC_FILES/lastsync"

# Insert another timestamp and close the log file
echo ">> ---" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> Finished sync on $(date --rfc-3339=seconds)" >> "$SYNC_LOGS/$LOG_FILE"
echo "=============================================" >> "$SYNC_LOGS/$LOG_FILE"
echo "" >> "$SYNC_LOGS/$LOG_FILE"

# Remove the lock file and exit
rm -f "$SYNC_LOCK"
exit 0
