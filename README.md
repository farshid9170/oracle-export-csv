**Introduction**
this script will help you to export csv from oralce database day by day
if you need to export all tables in oracle you need to use this script: export_all_csv.sh

and if you want to export data from specific table in oracle use this script:
export_by_table.sh

**Requirements**

none



**How to run**

incase of you need all tables just edit oracle username-password-database in export_all_csv.sh and start with bash
./export_all_csv.sh

incase of you need scpecific table edit oracle username-password-database and  your tables in file export_by_table.sh ( in this samle specific tables are : SESSION_GROUP_ID and ISP_ID
