REM psaetemptblmgr.sql
DEF recname = 'AETEMPTBLMGR'
@@psrecdefn
DEF recdescr = '&&recdescr. after process end.'
DEF descrlong = 'When an Application Engine process crashes it can retain locks on temporary records allocated to it.  This report lists temporary tables allocated to application engines excluding running processes.'

BEGIN
  :sql_text := '
SELECT row_number() over (order by recname, curtempinstance) row_num
,      t.*
,      r.prcstype, r.prcsname, r.runstatus
FROM   PS_AETEMPTBLMGR t
LEFT OUTER JOIN psprcsrqst r
 ON r.prcsinstance = t.process_instance
WHERE  (r.runstatus != ''7'' OR r.runstatus IS NULL)
ORDER BY row_num
'; 
END;				
/

column process_instance heading 'Process|Instance'

@@psgenerichtml.sql
