REM pstopaestep.sql
DEF recname = 'BAT_TIMINGS_LOG'
@@psrecdefn
DEF lrecname = '&&lrecname._top&&date_filter_suffix'
DEF recdescr = '&&recdescr. Application Engine process profiled by time &&date_filter_desc'
DEF descrlong = 'Application Engine process timings, aggregated and profiled by total time &&date_filter_desc'
DEF report_abstract_2 = '<br>Requires batch timings to be written to database - set TraceAE=1024 in Process Scheduler configuration';

BEGIN
  :sql_text_stub := '
WITH a AS (
SELECT a.process_name
,      COUNT(*) executions
,      SUM(GREATEST(a.time_elapsed,0))/1000 time_elapsed
,      SUM(GREATEST(a.time_in_pc  ,0))/1000 time_in_pc
,      SUM(GREATEST(a.time_in_sql ,0))/1000 time_in_sql
,      AVG(GREATEST(a.time_elapsed,0))/1000 avg_time_elapsed
,      AVG(GREATEST(a.time_in_pc  ,0))/1000 avg_time_in_pc
,      AVG(GREATEST(a.time_in_sql ,0))/1000 avg_time_in_sql
FROM   ps_bat_timings_log a &&date_filter_sql
GROUP BY a.process_name
), b AS (
SELECT rank() OVER (ORDER BY time_elapsed desc) as stmtrank
,      a.*
,      100*RATIO_TO_REPORT(time_elapsed) OVER () as pct_time_elapsed
,      100*RATIO_TO_REPORT(time_in_pc)   OVER () as pct_time_in_pc
,      100*RATIO_TO_REPORT(time_in_sql)  OVER () as pct_time_in_sql
FROM   a
), c AS (
SELECT b.*
,      SUM(pct_time_elapsed) OVER (ORDER BY stmtrank RANGE UNBOUNDED PRECEDING) cum_pct_time_elapsed
,      SUM(pct_time_in_pc)   OVER (ORDER BY stmtrank RANGE UNBOUNDED PRECEDING) cum_pct_time_in_pc
,      SUM(pct_time_in_sql)  OVER (ORDER BY stmtrank RANGE UNBOUNDED PRECEDING) cum_pct_time_in_sql
FROM   b
), x AS (
SELECT stmtrank
,      process_name
,      executions
,      time_elapsed
,      avg_time_elapsed
,      pct_time_elapsed
,      cum_pct_time_elapsed
,      time_in_pc
,      avg_time_in_pc
,      pct_time_in_pc
,      cum_pct_time_in_pc
,      time_in_sql
,      avg_time_in_sql
,      pct_time_in_sql
,      cum_pct_time_in_sql
FROM   c
) ';
END;
/

COLUMN stmtrank             HEADING 'Stmt|Rank'                   NEW_VALUE row_num
COLUMN process_name         HEADING 'Process|Name' 
COLUMN executions           HEADING 'Num|Execs'
COLUMN time_elapsed         HEADING 'Elapsed|Time (s)'            FORMAT 999990.000
COLUMN time_in_pc           HEADING 'SQL|Time (s)'                FORMAT 999990.000
COLUMN time_in_sql          HEADING 'PeopleCode|Time (s)'         FORMAT 999990.000
COLUMN avg_time_elapsed     HEADING 'Average|Elapsed|Time (s)'    FORMAT 999990.000
COLUMN avg_time_in_pc       HEADING 'Average|SQL|Time (s)'        FORMAT 999990.000
COLUMN avg_time_in_sql      HEADING 'Average|PeopleCode|Time (s)' FORMAT 999990.000
COLUMN pct_time_elapsed     HEADING '%Elapsed|Time'               FORMAT 990.0
COLUMN pct_time_in_pc       HEADING '%SQL|Time'                   FORMAT 990.0
COLUMN pct_time_in_sql      HEADING '%PeopleCode|Time'            FORMAT 990.0
COLUMN cum_pct_time_elapsed HEADING 'Cumulative|%Elapsed|Time'    FORMAT 990.0
COLUMN cum_pct_time_in_pc   HEADING 'Cumulative|%SQL|Time'        FORMAT 990.0
COLUMN cum_pct_time_in_sql  HEADING 'Cumulative|%PeopleCode|Time' FORMAT 990.0
DEF piex="Statement ID"
DEF piey="Total Time (seconds)"

BEGIN
  :sql_text := :sql_text_stub||'
SELECT '',[''''''||x.process_name||'''''',''||x.time_elapsed||'']''
FROM   x
ORDER BY x.time_elapsed desc
'; 
END;				
/

@@psgenericpie.sql


BEGIN
  :sql_text := :sql_text_stub||'
SELECT x.*
FROM   x
ORDER BY stmtrank
'; 
END;				
/

@@psgenerichtml.sql

