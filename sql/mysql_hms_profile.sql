-- Program: mysql_hms_profile.sql
-- Version: 0.1 gloureiro 16-Jul-2022 Based on versions that have been around some time
-- Description: Run this during an upgrade pre-engagement or at the start of an upgrade
--              E.g. cat mysql_hms_profile.sql | mysql --batch -s -v -D hive -u hive -h <hostname> -f -p 2>&1 | tee /tmp/mysql_hms_profile.out
--                   -v prints the commands -s removes the +-----+ -D to set the database -u <mysql db user> -h <mysql db server> -f to force script to continue if errors -p password

-- set this to the hive metastore database
use hive;

-- How many databases
select count(*) from DBS;

-- breakdown of Hive table types: MANAGED, EXTERNAL, VIEW
select tbl_type, count(*) from TBLS group by tbl_type;

-- Table properties x table type
select t.tbl_type, count(*) from TBLS t join TABLE_PARAMS tp on t.tbl_id = tp.tbl_id where lower(tp.param_key) = 'transactional' group by t.tbl_type;

-- SERDE queries
-- #File types x table type
select t.tbl_type, s.input_format, s.output_format, count(*) from SDS s join TBLS t on t.sd_id = s.sd_id group by t.tbl_type, s.input_format, s.output_format;
select slib, count(*) from SERDES group by slib;
select t.tbl_type, se.slib, count(*) from TBLS t join SDS s on (t.sd_id = s.sd_id) join SERDES se on (s.serde_id = se.serde_id) group by t.tbl_type, se.slib;

-- checks if event notifications logs are in play - could point to Hive DLM - caveat DLM/Hive replication functionality not yet available
select count(*) from NOTIFICATION_LOG;

-- old std SQL authorization model - now use Ranger
select count(*) from ROLES;

-- #UDFs - these might need testing during upgrade
select count(*) from FUNCS;

-- location-based queries
select substring_index(s.location,'/',3), count(*) from SDS s group by substring_index(s.location,'/',3);
select substring_index(d.db_location_uri,'/',3), count(*) from DBS d group by substring_index(d.db_location_uri,'/',3);

-- misc queries

-- Any specific DB parameters/properties
-- select * from DATABASE_PARAMS limit;

-- Total number of columns
-- select count(*) from COLUMNS_V2;

-- Total columns x table type - the avg columns per table could be interesting (could do this at a DB level)
-- select t.tbl_type, count(*) from COLUMNS_V2 c join SDS s on s.cd_id = c.cd_id join TBLS t on t.sd_id = s.sd_id group by t.tbl_type;

-- Total number of partitions
-- select count(*) from PARTITIONS p join TBLS t on p.tbl_id = t.tbl_id;

-- Total #partitions x table type
-- select t.tbl_type, count(*) from PARTITIONS p join TBLS t on p.tbl_id = t.tbl_id group by t.tbl_type;

-- Table property counts - gives indication of interesting settings
-- select param_key, count(*) from TABLE_PARAMS group by param_key;

