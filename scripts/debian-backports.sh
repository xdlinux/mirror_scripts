#!/bin/bash
#
# The script to sync a local mirror of the Arch Linux repositories and ISOs
#
# Copyright (C) 2007 Woody Gilk <woody@debian-backports.org>
# Modifications by Dale Blount <dale@debian-backports.org>
# and Roman Kyrylych <roman@debian-backports.org>
# Justin Wong <justin.w.xd@gmail.com>
# Licensed under the GNU GPL (version 2)

source `dirname $0`/functions.d/functions

# Filesystem locations for the sync operations
SYNC_LOGS="$SYNC_HOME/logs/debian-backports"
SYNC_FILES="/srv/ftp/debian-backports"
SYNC_LOCK="$SYNC_HOME/debian-backports.lck"


# Select which repositories to sync
#SYNC_REPO=(core extra community pool testing iso)

# Set the rsync server to use
# Only official public mirrors are allowed to use rsync.debian-backports.org

#SYNC_SERVER=rsync.debian-backports.org::ftp
#SYNC_SERVER=distro.ibiblio.org::distros/debian-backports
#SYNC_SERVER=rsync://mirror.rit.edu/debian-backports/
#SYNC_SERVER=rsync://mirror6.bjtu.edu.cn/debian-backports/
#SYNC_SERVER=rsync://mirror.yandex.ru/debian-backports/
SYNC_SERVER=rsync://mirrors6.ustc.edu.cn/debian-backports/

# Set the format of the log file name
# This example will output something like this: sync_20070201-8.log

LOG_FILE="sync_$(date +%Y%m%d-%H).log"
STAT_FILE="$SYNC_HOME/status/debian-backports"

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
set_stat $STAT_FILE "-1"

rsync -6 -av --delete-after --exclude *.~tmp~* \
    --delete-after \
    --exclude *ia64.deb \
    --exclude *alpha.deb \
    --exclude *hppa.deb \
    --exclude *s390.deb  \
    --exclude *kfreebsd.deb \
    --exclude *powerpc.deb  \
    --exclude *hurd.deb  \
    --exclude *.iso \
	$SYNC_SERVER "$SYNC_FILES" >> "$SYNC_LOGS/$LOG_FILE"

    # Create $repo.lastsync file with timestamp like "2007-05-02 03:41:08+03:00"
    # which may be useful for users to know when the repository was last updated

#wait background updates to finish
set_stat $STAT_FILE $?

date --rfc-3339=seconds > "$SYNC_FILES/lastsync"

# Insert another timestamp and close the log file
echo ">> ---" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> Finished sync on $(date --rfc-3339=seconds)" >> "$SYNC_LOGS/$LOG_FILE"
echo "=============================================" >> "$SYNC_LOGS/$LOG_FILE"
echo "" >> "$SYNC_LOGS/$LOG_FILE"

# Remove the lock file and exit
rm -f "$SYNC_LOCK"
exit 0
