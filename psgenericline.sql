REM psgenericline.sql
set head off
break on report

SPOOL &&pstemp
PRINT :sql_text
PRO /
SPOOL OFF

EXEC :sql_text_display := REPLACE(REPLACE(TRIM(CHR(10) FROM :sql_text)||';', '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;');

PRO
DEF dbname = "''";
DEF section = "&&lrecname._line";
DEF linespool = "&&ps_prefix._&&psdbname._&&repcol._&&section..&&htmlsuffix";

DEF report_title = "&&section: &&recdescr";
DEF report_abstract_1 = "<br>&&descrlong";

DEF chart_title = "&&report_title";
DEF report_foot_note = "This is a Google scratter chart report.";

SPO &&linespool;
PRO <head>
PRO <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
PRO <title>&&report_title</title>

@@pshtmlstyle

PRO
PRO <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
PRO <script type="text/javascript">
PRO google.charts.load("current", {packages:["corechart"]});
PRO google.charts.setOnLoadCallback(drawChart);
PRO function drawChart() {
PRO var data = google.visualization.arrayToDataTable([
/****************************************************************************************/
@@&&pstemp
/****************************************************************************************/
PRO ]);

PRO var options = {
PRO backgroundColor: {fill: '#fcfcf0', stroke: '#336699', strokeWidth: 1},
PRO explorer: {actions: ['dragToZoom', 'rightClickToReset'], maxZoomIn: 0.1},
PRO keepInBounds: true,
PRO title: '&&chart_title.',
PRO titleTextStyle: {fontSize: 16, bold: false},
PRO legend: {position: 'right', textStyle: {fontSize: 12}},
PRO tooltip: {textStyle: {fontSize: 14}},
PRO focusTarget: 'category',
PRO };

PRO var chart = new google.visualization.&&charttype.(document.getElementById('chart_div'));
PRO chart.draw(data, options);
PRO }

PRO </script>
PRO </head>
PRO <body>
PRO <h1>&&ps_report_prefix &&report_title.</h1>
PRO &&report_abstract_1.
PRO &&report_abstract_2.
PRO &&report_abstract_3.
PRO &&report_abstract_4.
PRO <div id="chart_div" style="width: 900px; height: 500px;"></div>
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
