REM psstatus.sql
DEF recname = 'PSSTATUS'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT rownum, t.*
  FROM &&table_name t
'; 
END;				
/

@@psgenerichtml.sql
