REM pstopprcs.sql
DEF recname = 'PSPRCSRQST'
@@psrecdefn
DEF lrecname = '&&lrecname._top&&date_filter_suffix'
DEF recdescr = '&&recdescr. &&date_filter_desc'
DEF descrlong = 'Process Scheduler Requests, aggregated and profiled by total time &&date_filter_desc'

BEGIN
  :sql_text_stub := '
WITH a AS (
SELECT prcstype, prcsname, runstatus
,      CAST(begindttm AS DATE) begindttm
,      DECODE(runstatus,''7'',SYSDATE,CAST(enddttm AS DATE)) enddttm
FROM   psprcsrqst
WHERE  begindttm < DECODE(runstatus,''7'',sysdate,enddttm)
AND    runstatus IN(''7'',''9'',''11'',''14'') &&date_filter_sql
AND    prcstype != ''PSJob''
), b AS (
SELECT prcstype, prcsname
,      COUNT(*) executions
,      sum(enddttm-begindttm)*86400 dur
,      avg(enddttm-begindttm)*86400 avg_dur
FROM   a
GROUP BY prcstype, prcsname
), c AS (
SELECT rank() over (order by dur desc) prcrank
,      b.*
,      100*ratio_to_report(dur) OVER () pct_dur
FROM   b
), x AS (
SELECT c.*
,      SUM(pct_dur) OVER (ORDER BY prcrank RANGE UNBOUNDED PRECEDING) cum_pct_dur
FROM c
  LEFT OUTER JOIN ps_prcsdefn p
  ON c.prcstype = p.prcstype 
  AND c.prcsname = p.prcsname
)
';
END;
/

COLUMN prcrank              HEADING 'Stmt|Rank'                   NEW_VALUE row_num
COLUMN executions           HEADING 'Num|Execs'
COLUMN prcstype             HEADING 'Process|Type'
COLUMN prcsname             HEADING 'Process|Name'
COLUMN dur                  HEADING 'Total|Duration|(s)'
COLUMN avg_dur              HEADING 'Average|Duration|(s)'        FORMAT 999990.0
COLUMN pct_dur              HEADING '%Total|Duration'             FORMAT 990.0
COLUMN cum_pct_dur          HEADING 'Cumulative|%Total|Duration'  FORMAT 990.0
DEF piex="Statement ID"
DEF piey="Total Time (seconds)"

BEGIN
  :sql_text := :sql_text_stub||'
SELECT '',[''''''||x.prcstype||'':''||x.prcsname||'''''',''||x.dur||'']''
FROM   x
ORDER BY x.dur desc
'; 
END;				
/

@@psgenericpie.sql


BEGIN
  :sql_text := :sql_text_stub||'
SELECT x.*
FROM   x
ORDER BY prcrank
'; 
END;				
/

@@psgenerichtml.sql

