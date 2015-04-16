#!/bin/bash
 
MyUSER="root"     # USERNAME
MyPASS="password"       # PASSWORD 
MyHOST="localhost"          # Hostname
 
# Linux bin paths, change this if it can not be autodetected via which command
#MYSQL="$(which mysql)"
#MYSQLDUMP="$(which mysqldump)"
#CHOWN="$(which chown)"
#CHMOD="$(which chmod)"
#GZIP="$(which gzip)"
 
MYSQL="/usr/bin/mysql"
MYSQLDUMP="/usr/bin/mysqldump"
CHOWN="/bin/chown"
CHMOD="/bin/chmod"
GZIP="/bin/gzip"

# Backup Dest directory, change this if you have someother location
DEST="/var/warehouse/mysql-backup"
 
# Get hostname
HOST="$(hostname)"
 
# Get data in dd-mm-yyyy format
NOW="$(date +"%d-%m-%Y")"
 
# File to store current backup file
BKP_FILE=""
# Store list of databases 
DB_LIST=""
 
# DO NOT BACKUP these databases
do_not_backup="test"
 
[ ! -d $DEST ] && mkdir -p $DEST || :
 
# Only root can access it!
$CHOWN 0.0 -R $DEST
$CHMOD 0600 $DEST
 
# Get all database list first
DB_LIST="$($MYSQL -u $MyUSER -h $MyHOST -p$MyPASS -Bse 'show databases')"
 
for db in $DB_LIST
do
    skipdb=-1
    if [ "$do_not_backup" != "" ];
    then
	for i in $do_not_backup
	do
	    [ "$db" == "$i" ] && skipdb=1 || :
	done
    fi
 
    if [ "$skipdb" == "-1" ] ; then
	BKP_FILE="$DEST/$db.$HOST.$NOW.gz"
	# do all inone job in pipe,
	# connect to mysql using mysqldump for select mysql database
	# and pipe it out to gz file in backup dir :)
        $MYSQLDUMP -u $MyUSER -h $MyHOST -p$MyPASS $db | $GZIP -9 > $BKP_FILE
    fi
done
