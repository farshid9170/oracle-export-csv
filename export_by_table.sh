#!/bin/bash

# Prerequisite before oracle connection
source /home/oracle/env.sh

# Load database connection info
ORACLE_HOST="oc-scan"
ORACLE_PORT="1521"
ORACLE_DATABASE="ibsdb"
ORACLE_USERNAME="ibsuser"
ORACLE_PASSWORD="grrboorah22"

EXPORT_PATH="/tmp"








START_FROM_DATE=$(date --date="114 day ago - $i days" +"%Y%m%d")
START_TO_DATE=$(date --date="113 day ago - $i days" +"%Y%m%d")
SESSION_GROUP_ID=24692
ISP_ID=36


export_conlog () {
	export_path=$1
	start_from_date=$2
	start_to_date=$3
	isp_id=$4
	group_id=$5

	template_sql=$(cat <<-END
	set heading off
	set linesize 250
	set long 9999
	set feedback off
	SET  MARKUP  CSV ON
    ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

	spool EXPORT_PATH/START_FROM_DATE.csv
	select * from connection_log where session_start_time >= to_date('START_FROM_DATE 00:00','YYYYMMDD  HH24:MI') and session_start_time < to_date('START_TO_DATE 00:00','YYYYMMDD  HH24:MI') and isp_id=ISP_ID and session_group_id=GROUP_ID;
	spool off
	exit
	END
	)

	sql="${template_sql//START_FROM_DATE/$start_from_date}"
	sql="${sql//START_TO_DATE/$start_to_date}"
	sql="${sql//EXPORT_PATH/$export_path}"
	sql="${sql//GROUP_ID/$group_id}"
	sql="${sql//ISP_ID/$isp_id}"

	echo -e "Running query $sql"
	# Connect to the database, run the query, then disconnect
	time echo -e "$sql" | \
	sqlplus -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))"  > /dev/null
}

export_conlog $EXPORT_PATH $START_FROM_DATE $START_TO_DATE $ISP_ID $SESSION_GROUP_ID

