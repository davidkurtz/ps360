REM prcsdefn.sql
DEF recname = 'PRCSDEFN'
@@psrecdefn
DEF lrecname = '&&lrecname._trace'
DEF recdescr = '&&recdescr - where trace has been set in the process definition parameters'
DEF descrlong = 'Setting trace on the process definition overrides the definition in the process scheduler configuration file'

BEGIN
  :sql_text := '
SELECT rownum, t.*
  FROM &&table_name t
 WHERE UPPER(parmlist) LIKE ''%-%TRACE%''
   AND parmlisttype IN(''1'',''2'',''3'')
ORDER BY prcstype, prcsname
'; 
END;				
/

@@psgenerichtml.sql
