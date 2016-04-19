REM prcsdefn.sql
DEF recname = 'PRCSDEFN'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT row_number() over (order by prcstype, prcsname) row_num
     , t.*
  FROM &&table_name t
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
