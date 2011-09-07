#!/bin/bash
#
# The script to sync a local mirror of the Arch Linux repositories and ISOs
#
# Copyright (C) 2007 Woody Gilk <woody@archlinux.org>
# Modifications by Dale Blount <dale@archlinux.org>
# and Roman Kyrylych <roman@archlinux.org>
# Licensed under the GNU GPL (version 2)

# Filesystem locations for the sync operations
SYNC_HOME="/home/bigeagle/mirror"
REPONAME="rpmfusion"
SYNC_LOGS="$SYNC_HOME/logs/fedora"
SYNC_LOCK="$SYNC_HOME/$REPONAME.lck"
SYNC_REPO=(i386 x86_64)
SYNC_FREE=(free nonfree)
FVERS=(14 15)
SERVER_BASE="rsync://mirror.yandex.ru/fedora/rpmfusion/"
SYNC_DIR="/srv/ftp/fedora/rpmfusion"

# Set the format of the log file name
# This example will output something like this: sync_20070201-8.log
LOG_FILE="rpmfusion_$(date +%Y%m%d-%H).log"

# Do not edit the following lines, they protect the sync from running more than
# one instance at a time
if [ ! -d $SYNC_HOME ]; then
echo "$SYNC_HOME does not exist, please create it, then run this script again."
exit 1
fi

[ -f $SYNC_LOCK ] && exit 1
touch "$SYNC_LOCK"
# End of non-editable lines

# Create the log file and insert a timestamp
touch "$SYNC_LOGS/$LOG_FILE"
echo "=============================================" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> Starting sync on $(date --rfc-3339=seconds)" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> ---" >> "$SYNC_LOGS/$LOG_FILE"

for FVER in ${FVERS[@]};do
for FREE in ${SYNC_FREE[@]};do

	REL="releases/$FVER/Everything"
	UP="updates/$FVER"
	SYNC_FILES_REL="$SYNC_DIR/$FREE/$REL"
	SYNC_FILES_UP="$SYNC_DIR/$FREE/$UP"

	SYNC_SERVER_REL="$SERVER_BASE/$FREE/fedora/$REL"
	SYNC_SERVER_UP="$SERVER_BASE/$FREE/fedora/$UP"
	
	[ ! -d $SYNC_FILES_REL ] && mkdir -p $SYNC_FILES_REL
	[ ! -d $SYNC_FILES_UP ] && mkdir -p $SYNC_FILES_UP

	for repo in ${SYNC_REPO[@]}; do
	echo ">> Syncing $repo to $SYNC_FILES/$repo" >> "$SYNC_LOGS/$LOG_FILE"

	rsync -avrz --delete-after --exclude=debug/ $SYNC_SERVER_REL/$repo $SYNC_FILES_REL >> $SYNC_LOGS/$LOG_FILE &
	sleep 1
	
	rsync -avrz --delete-after --exclude=debug/ $SYNC_SERVER_UP/$repo $SYNC_FILES_UP >> $SYNC_LOGS/$LOG_FILE
	sleep 5 
	
	done
done
done

wait
# Insert another timestamp and close the log file
echo ">> ---" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> Finished sync on $(date --rfc-3339=seconds)" >> "$SYNC_LOGS/$LOG_FILE"
echo "=============================================" >> "$SYNC_LOGS/$LOG_FILE"
echo "" >> "$SYNC_LOGS/$LOG_FILE"

# Remove the lock file and exit
rm -f "$SYNC_LOCK"
exit 0
