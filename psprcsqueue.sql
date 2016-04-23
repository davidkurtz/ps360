REM psprcsqueue.sql
DEF recname = 'PSPRCSRQST'
@@psrecdefn
DEF lrecname = '&&lrecname._queuing&&date_filter_suffix'
DEF recdescr = '&&recdescr. &&date_filter_desc'
DEF descrlong= 'Time Process Scheduler Requests spend queued &&date_filter_desc'
DEF charttype= "ScatterChart";

BEGIN
  :sql_text_stub := '
WITH x AS (
SELECT prcsinstance, prcstype, prcsname, oprid, runcntlid, servernamerun
,      CAST(GREATEST(rqstdttm, rundttm) AS DATE) queue_dttm
,      CAST(begindttm AS DATE) begindttm
from   psprcsrqst
where  begindttm IS NOT NULL &&date_filter_sql
and    prcstype != ''PSJob''
), y AS(
select row_number() over (order by begindttm) as row_num
,      queue_dttm
,      servernamerun
,      (begindttm-queue_dttm)*86400 queue_secs
,      prcstype, prcsname, oprid, runcntlid
from   x
ORDER BY row_num
)';
END;
/

COLUMN row_num              HEADING 'Stmt|Rank'                   NEW_VALUE row_num
COLUMN queue_dttm           HEADING 'Time|Enqueued'
COLUMN servername           HEADING 'Server|Name'
COLUMN queue_secs           HEADING 'Queuing|Time (S)'


DEF piex="Statement ID"
DEF piey="Total Time (seconds)"

BEGIN
  :sql_text := :sql_text_stub||'
SELECT ''[''''Date''''';
END;
/
BEGIN
  for i in (SELECT * FROM psserverstat) LOOP
    :sql_text := :sql_text||','''''||i.servername||':'||i.SRVRHOSTNAME||'''''';
  END LOOP;

  :sql_text := :sql_text||']''
FROM DUAL
UNION ALL
SELECT '', [new Date(''||TO_CHAR(y.queue_dttm, ''YYYY'')||
       '',''||(TO_NUMBER(TO_CHAR(y.queue_dttm, ''MM'')) - 1)||
       '',''||TO_CHAR(y.queue_dttm, ''DD'')||
       '',''||TO_CHAR(y.queue_dttm, ''HH24'')||
       '',''||TO_CHAR(y.queue_dttm, ''MI'')||
       '',''||TO_CHAR(y.queue_dttm, ''SS'')||
       '')''';

  for i in (SELECT * FROM psserverstat) LOOP
  :sql_text := :sql_text||'
         ||'',''||DECODE(servernamerun,'''||i.servername||''',TO_CHAR(queue_secs),''0'')';
  END LOOP;

  :sql_text := :sql_text||'||'']''
FROM   y
'; 
END;				
/
--ORDER BY row_num
@@psgenericline.sql

BEGIN
  :sql_text := :sql_text_stub||'
SELECT row_num
, TO_CHAR(queue_dttm,''&&datetimefmt'') queue_dttm
, servernamerun, queue_secs, prcstype, prcsname, oprid, runcntlid
FROM   y
'; 
END;				
/

@@psgenerichtml.sql

