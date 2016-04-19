REM psinstallation.sql
DEF recname = 'INSTALLATION'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT rownum, t.*
  FROM &&table_name t
'; 
END;				
/

@@psgenerichtml.sql
