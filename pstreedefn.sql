REM pstreedefn.sql
DEF recname = 'PSTREEDEFN'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT row_number() over (order by setid, setcntrlvalue, tree_name, effdt) row_num
, t.*
  FROM &&table_name t
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
