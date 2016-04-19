REM psprcssystem.sql
DEF recname = 'PRCSSYSTEM'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT row_number() over (order by opsys) row_num
, t.*
  FROM &&table_name t
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
