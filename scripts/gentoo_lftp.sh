SYNC_HOME="/home/bigeagle/mirror"
SYNC_LOGS="$SYNC_HOME/logs/gentoo"
SYNC_FILES="/srv/ftp/gentoo"
SYNC_LOCK="$SYNC_HOME/gentoo.lck"

LOG_FILE="$SYNC_LOGS/gentoo_$(date +%Y%m%d-%H).log"
SYNC_SERVER=http://ftp.ipv6.heanet.ie/pub/gentoo/

cd $SYNC_FILES

lftp $SYNC_SERVER -e "mirror --only-newer -P 10 --exclude .*~tmp~.* --verbose --log=$LOG_FILE $SYNC_SERVER $SYNC_FILES"
