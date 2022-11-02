#!/bin/bash

# Prerequisite before oracle connection
source /home/oracle/env.sh

# Load database connection info
ORACLE_HOST="localhost"
ORACLE_PORT="1521"
ORACLE_DATABASE="ibs"
ORACLE_USERNAME="ibsuser"
ORACLE_PASSWORD="grrboorah22"

EXPORT_PATH="/mnt"


for i in {1..62}; do

#Date1=$(date --date="143 day ago - $i days" +"%Y%m%d")
#Date2=$(date --date="142 day ago - $i days" +"%Y%m%d")


STOP_FROM_DATE=$(date --date="142 day ago - $i days" +"%Y%m%d")
STOP_TO_DATE=$(date --date="142 day ago - $i days + 1 day" +"%Y%m%d")
START_FROM_DATE=$(date --date="143 day ago - $i days" +"%Y%m%d")
START_TO_DATE=$STOP_TO_DATE

export_conlog () {
	export_path=$1
	stop_from_date=$2
	stop_to_date=$3
	start_from_date=$4
	start_to_date=$5

	template_sql=$(cat <<-END
	set heading off
	set linesize 250
	set long 9999
	set feedback off
	SET  MARKUP  CSV ON
    ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

	spool EXPORT_PATH/STOP_FROM_DATE.csv
	select * from connection_log where session_stop_time >= to_date('STOP_FROM_DATE 00:00','YYYYMMDD  HH24:MI') and session_stop_time < to_date('STOP_TO_DATE 00:00','YYYYMMDD  HH24:MI')  and session_start_time >= to_date('START_FROM_DATE 00:00','YYYYMMDD  HH24:MI') and session_start_time < to_date('START_TO_DATE 00:00','YYYYMMDD  HH24:MI');
	spool off
	exit
	END
	)

	sql="${template_sql//STOP_FROM_DATE/$stop_from_date}"
	sql="${sql//STOP_TO_DATE/$stop_to_date}"
	sql="${sql//START_FROM_DATE/$start_from_date}"
	sql="${sql//START_TO_DATE/$start_to_date}"
	sql="${sql//EXPORT_PATH/$export_path}"

	echo -e "Running query $sql"
	# Connect to the database, run the query, then disconnect
	time echo -e "$sql" | \
	sqlplus -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" > /dev/null
}

export_conlog $EXPORT_PATH $STOP_FROM_DATE $STOP_TO_DATE $START_FROM_DATE $START_TO_DATE

done
