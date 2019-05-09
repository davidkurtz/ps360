REM psinstallation.sql
DEF recname = 'PSDDLMODEL'
@@psrecdefn
DEF descrlong = 'DDL models for Oracle only.'

BEGIN
  :sql_text := '
SELECT rownum, t.*
  FROM &&table_name t
 WHERE platformid = 2
 ORDER BY statement_type
'; 
END;				
/

@@psgenerichtml.sql
