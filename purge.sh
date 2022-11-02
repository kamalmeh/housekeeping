#!/usr/bin/ksh


. $HOME/.profile

ROOT_DIR=$HOME/software/ifxSWVersions/admin/purge
DATUM=`date "+%d.%m.%y %H:%M"`
BASE=`basename $0`

LOG_PATH=$ROOT_DIR/log
LOGFILE=$LOG_PATH/purge.log_`date +"%Y%m%d"`

cd $ROOT_DIR
mkdir -p $LOG_PATH >/dev/null 2>&1

#-------------------
# Start of Script
#-------------------

if [ -s $ROOT_DIR/$BASE.pid ]
then
  pid=`cat $ROOT_DIR/$BASE.pid`
  ps -fp $pid|grep $BASE
  if [ $? -eq 0 ]; then
     echo "Another job is running now!" | tee -a ${logfile}
     exit 10
  fi
fi

echo $$>$ROOT_DIR/$BASE.pid

# Execute purge.pl script
$ROOT_DIR/purge.pl | tee -a $LOGFILE

# housekeeping, remove old log file more than 30 days
echo "Delete logging..."
find $LOG_PATH -mtime +30 -exec rm {} \; >/dev/null 2>&1

#-------------------
# End of Script
#-------------------

rm $ROOT_DIR/$BASE.pid
exit 0
