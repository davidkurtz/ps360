
REM prcsdefn.sql
DEF recname = 'PRCSDEFN'
@@psrecdefn
DEF lrecname = '&&lrecname._trace'
DEF recdescr = '&&recdescr - where trace has been set in the process definition parameters'
DEF descrlong = 'Setting trace on the process definition overrides the definition in the process scheduler configuration file'

BEGIN
  :sql_text := '
WITH x as (
  SELECT x.*
  FROM psxlatitem x, psrecfielddb f
  WHERE x.effdt = (
    SELECT MAX(x1.effdt)
    FROM psxlatitem x1
    WHERE x1.fieldname = x.fieldname
    AND x1.fieldvalue = x.fieldvalue
    AND x1.effdt <= SYSDATE)
  AND x.fieldname = f.fieldname
  AND f.recname = ''PRCSDEFN''
)
SELECT row_number() over (order by prcstype, prcsname) row_num
     , t.prcstype, t.prcsname, t.version
     , t.parmlist, t.parmlisttype, x6.xlatshortname
     , t.cmdline, t.cmdlinetype, x2.xlatshortname
     , t.workingdir, t.workingdirtype, x3.xlatshortname
     , t.outdesttype, x5.xlatshortname
     , t.outdest
     , t.outdestsrc, x4.xlatshortname
     , t.sqrrtflag, t.logrqst, t.apiaware, x1.xlatshortname
     , t.prcspriority, x7.xlatshortname
     , t.runlocation, x8.xlatshortname
     , t.servername, t.mvsshellid, t.msglogtbl, t.recurname, t.descr
     , t.lastupddttm, t.lastupdoprid, t.recvryprcstype, t.recvryprcsname
     , t.retentiondays, t.pt_retentiondays, t.outdestformat, t.psrf_folder_name
     , t.restartenabled, t.retrycount, t.timeoutminutes, t.maxconcurrent
     , t.prcscategory, t.timeoutmaxmins, t.prcsshowurl, t.pt_prcs_en_gen_run
     , t.pt_prcs_runcntlsec, x9.xlatshortname
     , t.prcsreadonly, t.timestenmode, t.ptschdl_name
     , t.emailid, t.ptprcsibmsgsloglev, t.descrlong
  FROM ps_prcsdefn t
    LEFT OUTER JOIN x x1 ON x1.fieldname = ''APIAWARE'' AND x1.fieldvalue = t.apiaware
    LEFT OUTER JOIN x x2 ON x2.fieldname = ''CMDLINETYPE'' AND x2.fieldvalue = t.cmdlinetype
    LEFT OUTER JOIN x x3 ON x3.fieldname = ''WORKINGDIRTYPE'' AND x3.fieldvalue = t.workingdirtype
    LEFT OUTER JOIN x x4 ON x4.fieldname = ''OUTDESTSRC'' AND x4.fieldvalue = t.outdestsrc
    LEFT OUTER JOIN x x5 ON x5.fieldname = ''OUTDESTTYPE'' AND x5.fieldvalue = t.outdesttype
    LEFT OUTER JOIN x x6 ON x6.fieldname = ''PARMLISTTYPE'' AND x6.fieldvalue = t.parmlisttype
    LEFT OUTER JOIN x x7 ON x7.fieldname = ''PRCSPRIORITY'' AND x7.fieldvalue = t.prcspriority
    LEFT OUTER JOIN x x8 ON x8.fieldname = ''RUNLOCATION'' AND x8.fieldvalue = t.runlocation
    LEFT OUTER JOIN x x9 ON x9.fieldname = ''PT_PRCS_RUNCNTLSEC'' AND x9.fieldvalue = t.pt_prcs_runcntlsec
 WHERE UPPER(parmlist) LIKE ''%-%TRACE%''
   AND parmlisttype IN(''1'',''2'',''3'')
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
