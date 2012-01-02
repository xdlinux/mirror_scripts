#!/bin/bash
#
# The script to sync a local mirror of the Arch Linux repositories and ISOs
#
# Copyright (C) 2007 Woody Gilk <woody@epel.org>
# Modifications by Dale Blount <dale@epel.org>
# and Roman Kyrylych <roman@epel.org>
# Justin Wong <bigeagle@xdlinux.info>
# Licensed under the GNU GPL (version 2)

source `dirname $0`/functions.d/functions

# Filesystem locations for the sync operations
SYNC_LOGS="$SYNC_HOME/logs/epel"
SYNC_FILES="/srv/ftp/epel"
SYNC_LOCK="$SYNC_HOME/epel.lck"


# Select which repositories to sync
SYNC_REPO=(5 6)

# Set the rsync server to use
# Only official public mirrors are allowed to use rsync.epel.org

#SYNC_SERVER=rsync.epel.org::ftp
#SYNC_SERVER=distro.ibiblio.org::distros/epel
#SYNC_SERVER=rsync://mirror.rit.edu/epel/
#SYNC_SERVER=rsync://mirror6.bjtu.edu.cn/epel/
#SYNC_SERVER=rsync://mirror.yandex.ru/epel/
SYNC_SERVER=rsync://mirror6.bjtu.edu.cn/fedora-epel

# Set the format of the log file name
# This example will output something like this: sync_20070201-8.log

LOG_FILE="sync_$(date +%Y%m%d-%H).log"
STAT_FILE="$SYNC_HOME/status/epel"

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

if [ -z $SYNC_REPO ]; then
  # Sync a complete mirror

  rsync -6 -av --delete-after --exclude *.~tmp~* --exclude *ppc64* $SYNC_SERVER "$SYNC_FILES" >> "$SYNC_LOGS/$LOG_FILE"
else
  # Sync each of the repositories set in $SYNC_REPO
  for repo in ${SYNC_REPO[@]}; do
    #repo=$(echo $repo | tr [:upper:] [:lower:])
    echo ">> Syncing $repo to $SYNC_FILES/$repo" >> "$SYNC_LOGS/$LOG_FILE"

    rsync -6 -av --delete-after --exclude *.~tmp~* --exclude *ppc64* $SYNC_SERVER/$repo "$SYNC_FILES" >> "$SYNC_LOGS/$LOG_FILE" &

    # Create $repo.lastsync file with timestamp like "2007-05-02 03:41:08+03:00"
    # which may be useful for users to know when the repository was last updated

    sleep 5 
  done
fi

#wait background updates to finish
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
