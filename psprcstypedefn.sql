REM prcstypedefn.sql
DEF recname = 'PRCSTYPEDEFN'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT row_number() over (order by dbtype, opsys, prcstype) row_num
     , t.*
  FROM &&table_name t
WHERE  dbtype = ''2''
ORDER BY row_num'; 
END;				
/

@@psgenerichtml.sql
