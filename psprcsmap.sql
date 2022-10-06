REM psprcsmap.sql
REM timeline map of PeopleSoft Process Scheduler Processes
DEF recname = 'PSPRCSRQST'
@@psrecdefn
DEF lrecname = '&&lrecname._timeline&&date_filter_suffix'
DEF recdescr = '&&recdescr. &&date_filter_desc'
DEF descrlong = 'Timeline Map of Process Scheduler Processes &&date_filter_desc'
DEF maxrows = 10000

BEGIN
  :sql_text := '
WITH d AS (
SELECT DISTINCT dbname FROM ps.psdbowner
), x as (
SELECT r.prcsname, r.prcstype, r.prcsinstance
,      r.prcsinstance||'':''||r.oprid||'':''||r.runcntlid tooltip
,      CAST(r.begindttm AS DATE) begindttm
,      CASE r.runstatus 
         WHEN ''7'' THEN sysdate
         ELSE CAST(r.enddttm AS DATE) 
       END AS enddttm
FROM   psprcsrqst r, d
WHERE  r.dbname = d.dbname
AND    (r.runstatus = ''7'' OR &&date_filter_sql)
AND    r.begindttm IS NOT NULL
), q AS (
SELECT x.*
,      row_number() over (order by x.begindttm DESC) row_num
,      SUM(x.enddttm-x.begindttm) OVER (PARTITION BY x.prcsname, x.prcstype) process_cum_duration
FROM   x
WHERE  x.begindttm <= x.enddttm
ORDER BY process_cum_duration DESC, x.prcsname, x.prcsinstance
)
SELECT DECODE(rownum,1,''['','','')||
''[''''''||q.prcsname||''''''''||
'', ''''''''''||
'', ''''''||q.tooltip||''''''''||
'', new Date(''||
TO_CHAR(q.begindttm, ''YYYY'')|| /* year */
'',''||(TO_NUMBER(TO_CHAR(q.begindttm, ''MM'')) - 1)|| /* month - 1 */
'',''||TO_CHAR(q.begindttm, ''DD,HH24,MI,SS'')|| /* second */
'')''||
'', new Date(''||
TO_CHAR(q.enddttm, ''YYYY'')|| /* year */
'',''||(TO_NUMBER(TO_CHAR(q.enddttm, ''MM'')) - 1)|| /* month - 1 */
'',''||TO_CHAR(q.enddttm, ''DD,HH24,MI,SS'')|| /* second */
'')''||
'']''
FROM q
WHERE row_num <= &&maxrows
';
END;
/
--do not put an order by clause in query because it will affect the rownum processing in the select clause
SPOOL &&pstemp
PRINT :sql_text
PRO /
SPOOL OFF

EXEC :sql_text_display := REPLACE(REPLACE(TRIM(CHR(10) FROM :sql_text)||';', '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;');

PRO
DEF section = "&&lrecname._map";
DEF linespool = "&&ps_prefix._&&psdbname._&&repcol._&&section..&&htmlsuffix";

DEF report_title = "&&section: &&recdescr";
DEF report_abstract_1 = "<br>&&descrlong";
DEF report_abstract_4 = "<br>Limited to &&maxrows most recent process requests";

DEF chart_title = "&&report_title";
DEF chart_foot_note_1 = "<br>1) Hover over bar for Process Instance number";

SPO &&linespool
PRO <head>
PRO <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
PRO <title>&&report_title</title>

@@pshtmlstyle.sql

PRO
PRO <script type="text/javascript" src="https://www.google.com/jsapi"></script>
PRO <script type="text/javascript">
PRO google.load("visualization", "1", {packages:["timeline"]})
PRO google.setOnLoadCallback(drawChart)
PRO
PRO function drawChart() {
PRO var container = document.getElementById('timeline');
PRO var chart = new google.visualization.Timeline(container);
PRO var dataTable = new google.visualization.DataTable();

PRO dataTable.addColumn({ type: 'string', id: 'Process Name' });
PRO dataTable.addColumn({ type: 'string', id: 'dummy bar label' });
PRO dataTable.addColumn({ type: 'string', role: 'tooltip' });
PRO dataTable.addColumn({ type: 'date', id: 'Begin Date/Time' });
PRO dataTable.addColumn({ type: 'date', id: 'End Date/Time' });
PRO dataTable.addRows(
/****************************************************************************************/
@@&&pstemp
/****************************************************************************************/
PRO ]);

PRO var options = {
PRO backgroundColor: {fill: '#fcfcf0', stroke: '#336699', strokeWidth: 1},
PRO explorer: {actions: ['dragToZoom', 'rightClickToReset'], maxZoomIn: 0.1},
PRO title: '&&chart_title.',
PRO titleTextStyle: {fontSize: 16, bold: false},
PRO legend: {position: 'right', textStyle: {fontSize: 12}},
PRO tooltip: {textStyle: {fontSize: 14}},
PRO focusTarget: 'category',
PRO };

PRO chart.draw(dataTable);
PRO }

PRO </script>
PRO </head>
PRO <body>
PRO <h1>&&ps_report_prefix &&report_title.</h1>
PRO &&report_abstract_1.
PRO &&report_abstract_2.
PRO &&report_abstract_3.
PRO &&report_abstract_4.
PRO <div id="timeline" style="width: 900px; height: 500px;"></div>
PRO <font class="n">Notes:</font>
PRO <font class="n">&&chart_foot_note_1.</font>
PRO <font class="n">&&chart_foot_note_2.</font>
PRO <font class="n">&&chart_foot_note_3.</font>
PRO <font class="n">&&chart_foot_note_4.</font>
PRO <pre>

SET lines 80 
DESC &&table_name
SET LIN 32767 
PRINT :sql_text

REM 1 rows selected.
PRO </pre>

PRO </body>
PRO </html>

SPO OFF;

DEF chart_foot_note_1 = "<br>";
DEF chart_foot_note_2 = ""; 
DEF chart_foot_note_3 = "";
DEF chart_foot_note_4 = "";

ROLLBACK;
@@pszipit
REM HOS del &&pstemp
