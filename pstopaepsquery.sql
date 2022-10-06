REM pstopaepsquery.sql
DEF recname = 'PSPRCSRQST'
@@psrecdefn
DEF lrecname = '&&lrecname._topquery&&date_filter_suffix'
DEF recdescr = 'Scheduled PS/Queries by execution time &&date_filter_desc'
DEF descrlong = 'Execution time of PS/Queries schedued to run on the process scheduler &&date_filter_desc'
DEF report_abstract_2 = '<br>Batch timings used if available, otherwise timings taken scheduler request';

BEGIN
  :sql_text_stub := '
WITH d AS (
SELECT DISTINCT dbname FROM ps.psdbowner
), r AS (
SELECT r.prcsinstance
,      CAST(NVL(r.begindttm,l.begindttm) AS DATE) begindttm
,      CAST(NVL(r.enddttm  ,l.enddttm  ) AS DATE) enddttm
FROM   d
,      psprcsrqst r
  LEFT OUTER JOIN ps_bat_timings_log l
  ON     l.process_instance = r.prcsinstance
WHERE  p.dbname = t.dbname
AND    r.prcsname = ''PSQUERY''
AND    r.runstatus = ''9'' &&date_filter_sql
), x AS (
SELECT r.prcsinstance
,      f.cdm_file_type
,      REGEXP_SUBSTR(f.filename,''[^-]+'') qryname
,      86400*(r.enddttm-r.begindttm) secs
FROM   r
,      ps_cdm_file_list f
WHERE  r.prcsinstance = f.prcsinstance
AND    NOT f.cdm_file_type IN(''AET'',''TRC'',''LOG'',''STDOUT'')
), y AS (
SELECT qryname
,      COUNT(*) execs
,      SUM(secs) sum_secs
,      AVG(secs) avg_secs
,      MEDIAN(secs) med_secs
,      VARIANCE(secs) var_secs
,      MAX(secs) max_secs
FROM   x
GROUP BY qryname
)';
END;
/

column qryname  heading 'Query|Name'
column execs    heading 'Number of|Executions'
column sum_secs heading 'Total|Execution|Time (s)'
column avg_secs heading 'Average|Execution|Time (s)'   format 999990.0
column med_secs heading 'Median|Execution|Time (s)'    format 999990.0
column var_secs heading 'Variance|Execution|Time (s)'  format 999990.0
column max_secs heading 'Maximum|Execution|Time (s)'

DEF piex="Query Name"
DEF piey="Total Time (seconds)"

BEGIN
  :sql_text := :sql_text_stub||'
SELECT '',[''''''||y.qryname||'''''',''||y.sum_secs||'']''
FROM   y
ORDER BY y.sum_secs desc
'; 
END;				
/

@@psgenericpie.sql


BEGIN
  :sql_text := :sql_text_stub||'
SELECT row_number() over (order by sum_secs desc) row_num
,      y.*
FROM   y
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql

