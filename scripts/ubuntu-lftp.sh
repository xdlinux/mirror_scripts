
SYNC_HOME="/home/bigeagle/mirror"
SYNC_LOGS="$SYNC_HOME/logs/ubuntu"
SYNC_FILES="/srv/ftp/ubuntu"
SYNC_LOCK="$SYNC_HOME/ubuntu.lck"

LOG_FILE="$SYNC_LOGS/ubuntu_$(date +%Y%m%d-%H).log"
SYNC_SERVER=http://ftp6.sjtu.edu.cn/ubuntu/

cd $SYNC_FILES

lftp $SYNC_SERVER -e "mirror --only-newer -P 5 --exclude .*ia64.* --exclude .*powerpc.* --exclude .*sparc.* --exclude .*dapper.* --exclude .*hardy.* --exclude .*intrepid.* --exclude .*jaunty.* --exclude .*karmic.* --exclude .*.iso --exclude .*.orig.tar.gz --exclude .*.diff.gz  --exclude .*.dsc --verbose --log=$LOG_FILE $SYNC_SERVER"
