#!/bin/bash
#
# The script to sync a local mirror of the Arch Linux repositories and ISOs
#
# Copyright (C) 2007 Woody Gilk <woody@debian-security.org>
# Modifications by Dale Blount <dale@debian-security.org>
# and Roman Kyrylych <roman@debian-security.org>
# Justin Wong <bigeagle@xdlinux.info>
# Licensed under the GNU GPL (version 2)

source `dirname $0`/functions.d/functions

# Filesystem locations for the sync operations
SYNC_LOGS="$SYNC_HOME/logs/debian-security"
SYNC_FILES="/srv/ftp/debian-security"
SYNC_LOCK="$SYNC_HOME/debian-security.lck"


# Select which repositories to sync
#SYNC_REPO=(core extra community pool testing iso)

# Set the rsync server to use
# Only official public mirrors are allowed to use rsync.debian-security.org

#SYNC_SERVER=rsync.debian-security.org::ftp
#SYNC_SERVER=distro.ibiblio.org::distros/debian-security
#SYNC_SERVER=rsync://mirror.rit.edu/debian-security/
#SYNC_SERVER=rsync://mirror6.bjtu.edu.cn/debian-security/
#SYNC_SERVER=rsync://mirror.yandex.ru/debian-security/
SYNC_SERVER=rsync://mirrors6.ustc.edu.cn/debian-security/

# Set the format of the log file name
# This example will output something like this: sync_20070201-8.log

LOG_FILE="sync_$(date +%Y%m%d-%H).log"
EX_FILE="$SYNC_HOME/scripts/functions.d/debian.exclude"
STAT_FILE="$SYNC_HOME/status/debian-security"

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

# Set SYNC status to syncing
set_stat $STAT_FILE "status" "-1"
set_stat $STAT_FILE "upstream" $SYNC_SERVER

rsync -6 -av --delete-after --exclude *.~tmp~* \
    --delete-after \
	--exclude-from $EX_FILE \
	$SYNC_SERVER "$SYNC_FILES" >> "$SYNC_LOGS/$LOG_FILE"

    # Create $repo.lastsync file with timestamp like "2007-05-02 03:41:08+03:00"
    # which may be useful for users to know when the repository was last updated

#wait background updates to finish
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
