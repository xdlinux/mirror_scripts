#!/bin/sh

source  `dirname $0`/functions.d/functions
amd64_LOG_FILE="freebsd_amd64_$(date +%Y%m%d-%H).log"
i386_LOG_FILE="freebsd_i386_$(date +%Y%m%d-%H).log"
sparc64_LOG_FILE="freebsd_sparc64_$(date +%Y%m%d-%H).log"
powerpc_LOG_FILE="freebsd_powerpc_$(date +%Y%m%d-%H).log"
STAT_FILE="$SYNC_HOME/status/FreeBSD"
#SYNC_SERVER=ftp6.tw.FreeBSD.org
#SYNC_SERVER=freebsd.mirrors.es.net
SYNC_SERVER=ftp.ipv6.heanet.ie

set_stat $STAT_FILE "status" "-1"
set_stat $STAT_FILE "upstream" $SYNC_SERVER
rsync -6 -avz --delete-after rsync://$SYNC_SERVER/FreeBSD/ports/amd64/packages-8-stable /srv/ftp/freebsd/ports/amd64/ >>/home/bigeagle/mirror/logs/FreeBSD/$amd64_LOG_FILE & 

rsync -6 -avz --delete-after rsync://$SYNC_SERVER/FreeBSD/ports/i386/packages-8-stable /srv/ftp/freebsd/ports/i386/ >>/home/bigeagle/mirror/logs/FreeBSD/$i386_LOG_FILE & 

rsync -6 -avz --delete-after rsync://$SYNC_SERVER/FreeBSD/ports/sparc64/packages-8-stable /srv/ftp/freebsd/ports/sparc64/ >>/home/bigeagle/mirror/logs/FreeBSD/$sparc64_LOG_FILE & 

rsync -6 -avz --delete-after rsync://$SYNC_SERVER/FreeBSD/ports/powerpc/packages-8-stable /srv/ftp/freebsd/ports/powerpc/ >>/home/bigeagle/mirror/logs/FreeBSD/$powerpc_LOG_FILE & 

waitall `jobs -p`
set_stat $STAT_FILE "status" $?
set_stat $STAT_FILE "lastsync" `date --rfc-3339=seconds`
