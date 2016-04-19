REM psprcssystem.sql
DEF recname = 'PRCSSYSTEM'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT rownum
, t.*
  FROM &&table_name t
ORDER BY rownum
'; 
END;				
/

@@psgenerichtml.sql
