REM psprcspurgelist.sql
DEF recname = 'PRCSPURGELIST'
@@psrecdefn
DEF report_abstract_2 = "Process Scheduler Purge Settings";

BEGIN
  :sql_text := '
SELECT row_number() over (order by LPAD(runstatus,4,'' '')) row_num
, t.runstatus
, (SELECT x.xlatshortname
   FROM   psxlatitem x
   WHERE  x.fieldname = ''RUNSTATUS''
   AND    x.fieldvalue = t.runstatus
   AND    x.effdt = (SELECT /*+PUSH_SUBQ*/ MAX(x1.effdt)
                     FROM   psxlatitem x1
                     WHERE  x1.fieldname = x.fieldname
                     AND    x1.fieldvalue = t.runstatus
                     AND    x1.effdt <= SYSDATE)
   AND    x.eff_status = ''A''
   AND    rownum <= 1
  ) descr
, t.daysbeforepurge
, t.enabled
FROM &&table_name t
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
