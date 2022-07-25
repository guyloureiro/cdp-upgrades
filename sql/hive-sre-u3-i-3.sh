time mysql -D hive -u hive -p --batch -N -e \
"select concat(\"ALTER TABLE \",d.name,\".\",t.tbl_name,\" SET TBLPROPERTIES('EXTERNAL'='TRUE','external.table.purge'='true');\") 
from DBS d join TBLS t 
on (t.db_id = d.db_id and t.tbl_type = 'MANAGED_TABLE')
where not exists (select null
                  from TABLE_PARAMS tp 
                  where t.tbl_id = tp.tbl_id
                  and lower(tp.param_key) = 'transactional');" | \
gzip -c > hdp02_u3_1_3_db.sql.gz
