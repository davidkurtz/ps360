REM pstreestrct.sql
DEF recname = 'PSTREESTRCT'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT row_number() over (order by tree_strct_id) row_num
, t.*
  FROM &&table_name t
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
