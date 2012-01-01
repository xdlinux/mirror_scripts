#!/bin/bash
# The script to sync a local mirror of the Arch Linux repositories and ISOs
# Modified to sync mirror of various repositories of Linux distributions 
# Copyright (C) 2007 Woody Gilk <woody@archlinux.org>
# Modifications by Dale Blount <dale@archlinux.org>
# and Roman Kyrylych <roman@archlinux.org>
# and Justin Wong <bigeagle@xdlinux.info>
# Licensed under the GNU GPL (version 2)

source  `dirname $0`/functions.d/functions

# Filesystem locations for the sync operations

SYNC_LOGS="$SYNC_HOME/logs/centos"
SYNC_FILES="/srv/ftp/centos"
SYNC_LOCK="$SYNC_HOME/centos.lck"

# Select which repositories to sync
SYNC_REPO=(5 5.7 6 6.1 6.2)

# Set the rsync server to use
# Only official public mirrors are allowed to use rsync.centos.org
#SYNC_SERVER=rsync.centos.org::ftp
#SYNC_SERVER=distro.ibiblio.org::distros/centos
#SYNC_SERVER=rsync://mirror.rit.edu/centos/
#SYNC_SERVER=rsync://oss.ustc.edu.cn/pub/centos/
#SYNC_SERVER=rsync://oss6.ustc.edu.cn/pub/centos/
SYNC_SERVER=rsync://mirrors6.ustc.edu.cn/centos/
#SYNC_SERVER=rsync://mirror.yandex.ru/centos/


# Set the format of the log file name
# This example will output something like this: sync_20070201-8.log
LOG_FILE="sync_$(date +%Y%m%d-%H).log"
STAT_FILE="$SYNC_HOME/status/centos"

# Do not edit the following lines, they protect the sync from running more than
# one instance at a time

check_dirs

[ -f $SYNC_LOCK ] && exit 1
touch "$SYNC_LOCK"
# End of non-editable lines

# Create the log file and insert a timestamp
touch "$SYNC_LOGS/$LOG_FILE"
echo "=============================================" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> Starting sync on $(date --rfc-3339=seconds)" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> ---" >> "$SYNC_LOGS/$LOG_FILE"

set_stat $STAT_FILE "status" "-1"
set_stat $STAT_FILE "upstream" $SYNC_SERVER

if [ -z $SYNC_REPO ]; then
  # Sync a complete mirror

  rsync -6 -av --delete-after --exclude *.~tmp~* $SYNC_SERVER "$SYNC_FILES" >> "$SYNC_LOGS/$LOG_FILE" &
else
  # Sync each of the repositories set in $SYNC_REPO
  for repo in ${SYNC_REPO[@]}; do
	#repo=$(echo $repo | tr [:upper:] [:lower:])
    echo ">> Syncing $repo to $SYNC_FILES/$repo" >> "$SYNC_LOGS/$LOG_FILE"
	
    rsync -6 -av --delete-after --exclude *.~tmp~*  $SYNC_SERVER/$repo "$SYNC_FILES" >> "$SYNC_LOGS/$LOG_FILE" &
     
	# Sleep 5 seconds after each repository to avoid too many concurrent connections
    # to rsync server if the TCP connection does not close in a timely manner
    
	sleep 5 
  done
fi

waitall `jobs -p`
set_stat $STAT_FILE "status" $?
set_stat $STAT_FILE "lastsync" `date --rfc-3339=seconds`

date --rfc-3339=seconds > "$SYNC_FILES/lastsync"

# Insert another timestamp and close the log file
echo ">> ---" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> Finished sync on $(date --rfc-3339=seconds)" >> "$SYNC_LOGS/$LOG_FILE"
echo "=============================================" >> "$SYNC_LOGS/$LOG_FILE"
echo "" >> "$SYNC_LOGS/$LOG_FILE"

# Remove the lock file and exit
rm -f "$SYNC_LOCK"
exit 0
