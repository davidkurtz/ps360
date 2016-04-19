REM psgenericpie.sql
set head off
break on report

SPOOL &&pstemp
PRINT :sql_text
PRO /
SPOOL OFF

EXEC :sql_text_display := REPLACE(REPLACE(TRIM(CHR(10) FROM :sql_text)||';', '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;');

PRO
DEF dbname = "''";
DEF section = "&&lrecname._pie";
DEF piespool = "&&ps_prefix._&&psdbname._&&repcol._&&section..&&htmlsuffix";

DEF report_title = "&&section: &&recdescr";
DEF report_abstract_1 = "<br>&&descrlong";
DEF report_abstract_2 = "";
DEF report_abstract_3 = "";
DEF report_abstract_4 = "";

DEF chart_title = "&&report_title";
DEF chart_foot_note_1 = "<br>";
DEF chart_foot_note_2 = ""; 
DEF chart_foot_note_3 = "";
DEF chart_foot_note_4 = "";
DEF report_foot_note = "This is a Google piechart report.";


SPO &&piespool;
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
PRO ['&&piex.', '&&piey.']
/****************************************************************************************/
@@&&pstemp
/****************************************************************************************/
PRO ]);

PRO var options = {
PRO is3D: true,
PRO backgroundColor: {fill: '#fcfcf0', stroke: '#336699', strokeWidth: 1},
PRO title: '&&chart_title.',
PRO titleTextStyle: {fontSize: 16, bold: false},
PRO legend: {position: 'right', textStyle: {fontSize: 12}},
PRO tooltip: {textStyle: {fontSize: 14}},
PRO sliceVisibilityThreshold: &&ps_360_PieSliceVisThreshold
PRO };

PRO var chart = new google.visualization.PieChart(document.getElementById('piechart_3d'));
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
PRO <div id="piechart_3d" style="width: 900px; height: 500px;"></div>
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
ROLLBACK;
