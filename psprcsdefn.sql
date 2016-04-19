REM prcsdefn.sql
DEF recname = 'PRCSDEFN'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT rownum, t.*
  FROM &&table_name t
ORDER BY prcstype, prcsname
'; 
END;				
/

@@psgenerichtml.sql
