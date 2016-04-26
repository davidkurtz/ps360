REM psnvstop.sql
DEF recname = 'NVS_REPORT'
@@psrecdefn
DEF lrecname = '&&lrecname._top&&date_filter_suffix'
DEF recdescr = '&&recdescr.'
DEF descrlong = ''
DEF report_abstract_2 = '<br>';

BEGIN
  :sql_text_stub := '
WITH x AS (
SELECT r.prcsinstance
,      r.oprid
,      CAST(begindttm AS DATE) begindttm
,      CAST(enddttm AS DATE) enddttm
,      SUBSTR(REGEXP_SUBSTR(p.origparmlist,''-NRN[^ ]+'',1,1,'i'),5) report_id
,      SUBSTR(REGEXP_SUBSTR(p.origparmlist,''-NBU[^ ]+'',1,1,'i'),5) business_unit
FROM   psprcsrqst r
,      psprcsparms p
WHERE  r.prcstype like ''nVision%''
AND    r.enddttm>=r.begindttm
AND    r.prcsinstance = p.prcsinstance
AND    p.origparmlist like ''%-NRN%''
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
,      VARIANCE(secs) max_secs
from   y
group by report_id, layout_id, business_unit
)';
END;
/

COLUMN layout_id     heading 'Layout|ID' format a20
COLUMN report_id     heading 'Report|ID' format a8
COLUMN business_unit heading 'Business|Unit' format a5 
column execs         heading 'Number of|Executions'
column sum_secs      heading 'Total|Execution|Time (s)'
column avg_secs      heading 'Average|Execution|Time (s)' format 99999.9
column med_secs      heading 'Median|Execution|Time (s)'  format 99999.9
column var_secs      heading 'Variance|Execution|Time (s)'  format 99999.9
column max_secs      heading 'Maximum|Execution|Time (s)'

DEF piex="Report/Layout ID"
DEF piey="Total Time (seconds)"

BEGIN
  :sql_text := :sql_text_stub||'
SELECT '',[''''''||y.report_id||'':''||y.layout_id||'':''||y.business_unit||'''''',''||y.sum_secs||'']''
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

