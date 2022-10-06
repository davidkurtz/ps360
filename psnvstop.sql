REM psnvstop.sql
DEF recname = 'NVS_REPORT'
@@psrecdefn
DEF lrecname = '&&lrecname._top&&date_filter_suffix'
DEF recdescr = '&&recdescr.'
DEF descrlong = ''
DEF report_abstract_2 = '<br>';

BEGIN
  :sql_text_stub := '
WITH d AS (
SELECT DISTINCT dbname FROM ps.psdbowner
), x AS (
SELECT r.prcsinstance
,      r.oprid
,      CAST(begindttm AS DATE) begindttm
,      CAST(enddttm AS DATE) enddttm
,      SUBSTR(REGEXP_SUBSTR(p.origparmlist,''-NRN[^ ]+'',1,1,''i''),5) report_id
,      SUBSTR(REGEXP_SUBSTR(p.origparmlist,''-NBU[^ ]+'',1,1,''i''),5) business_unit
FROM   d
,      psprcsrqst r
,      psprcsparms p
WHERE  r.dbname = d.dbname
AND    r.prcstype like ''nVision%''
AND    r.enddttm>=r.begindttm
AND    r.prcsinstance = p.prcsinstance
AND    p.origparmlist like ''%-NRN%'' &&date_filter_sql
), y AS (
SELECT n.layout_id, x.*
,      (x.enddttm-x.begindttm)*86400 secs
FROM   ps_nvs_report n,
       x
WHERE  n.report_id = x.report_id
), z as (
select report_id, layout_id, business_unit
,      COUNT(*) execs
,      SUM(secs) sum_secs
,      AVG(secs) avg_secs
,      MEDIAN(secs) med_secs
,      MAX(secs) max_secs
,      VARIANCE(secs) var_secs
from   y
group by report_id, layout_id, business_unit
)';
END;
/

COLUMN layout_id     heading 'Layout|ID'                    FORMAT a20
COLUMN report_id     heading 'Report|ID'                    FORMAT a8
COLUMN business_unit heading 'Business|Unit'                FORMAT a5 
COLUMN execs         heading 'Number of|Executions'
COLUMN sum_secs      heading 'Total|Execution|Time (s)'
COLUMN avg_secs      heading 'Average|Execution|Time (s)'   FORMAT   9999990.0
COLUMN med_secs      heading 'Median|Execution|Time (s)'    FORMAT   9999990.0
COLUMN var_secs      heading 'Variance|Execution|Time (s)'  FORMAT 999999990.0
COLUMN max_secs      heading 'Maximum|Execution|Time (s)'

DEF piex="Report/Layout ID"
DEF piey="Total Time (seconds)"

BEGIN
  :sql_text := :sql_text_stub||'
SELECT '',[''''''||z.report_id||'':''||z.layout_id||'':''||z.business_unit||'''''',''||z.sum_secs||'']''
FROM   z
ORDER BY z.sum_secs desc
'; 
END;				
/

@@psgenericpie.sql

BEGIN
  :sql_text := :sql_text_stub||'
SELECT row_number() over (order by sum_secs desc) row_num
,      z.*
FROM   z
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql

