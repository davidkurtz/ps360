REM psserverstat.sql
DEF recname = 'PSSERVERSTAT'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT rownum, t.*
  FROM &&table_name t
ORDER BY servername
'; 
END;				
/

@@psgenerichtml.sql
