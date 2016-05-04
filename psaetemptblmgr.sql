REM psaetemptblmgr.sql
DEF recname = 'AETEMPTBLMGR'
@@psrecdefn
DEF recdescr = '&&recdescr. after process end.'
DEF descrlong = 'When an Application Engine process crashes it can retain locks on temporary records allocated to it.  This report lists temporary tables allocated to application engines excluding running processes.'

BEGIN
  :sql_text := '
SELECT row_number() over (order by recname, curtempinstance) row_num
, t.*
  FROM &&table_name t
 WHERE NOT EXISTS(
     SELECT ''x''
     FROM   psprcsrqst r 
     WHERE  r.prcsinstance = t.process_instance
     AND    r.runstatus = ''7'')
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
