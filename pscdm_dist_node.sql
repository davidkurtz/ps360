REM pscdm_dist_node.sql
DEF recname = 'CDM_DIST_NODE'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT row_number() over (order by distnodename) row_num
, t.*
  FROM &&table_name t
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
