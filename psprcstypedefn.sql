REM prcstypedefn.sql
DEF recname = 'PRCSTYPEDEFN'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT rownum, t.*
  FROM &&table_name t
WHERE dbtype = ''2''
ORDER BY dbtype, opsys, prcstype'; 
END;				
/

@@psgenerichtml.sql
