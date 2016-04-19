REM psserverdefn.sql
DEF recname = 'SERVERDEFN'
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
