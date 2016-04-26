REM psgenerichtml.sql
set head off
break on report
SPOOL OFF

EXEC :sql_text_display := REPLACE(REPLACE(TRIM(CHR(10) FROM :sql_text)||';', '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;');

PRO
DEF dbname = "''";
DEF section = "&&lrecname";
DEF htmlspool = "&&ps_prefix._&&psdbname._&&repcol._&&section..&&htmlsuffix";

DEF report_title = "&&section: &&recdescr";
DEF report_abstract_1 = "<br>&&descrlong";
DEF report_abstract_2 = "";
DEF report_abstract_3 = "";
DEF report_abstract_4 = "";

COLUMN remarks ENTMAP OFF heading 'XLAT Values'
SPOOL &&pstemp
select 'COLUMN '||f.fieldname||' FORMAT A'||LENGTH(f.fieldname)
from   psrecfielddb f
,      psdbfield d
where f.recname = '&&recname'
and   f.fieldname = d.fieldname
and   d.fieldtype IN(0,1,8,9) /*VARCHAR2*/
and   d.length >0
and   d.length <LENGTH(f.fieldname)
order by f.fieldnum
/
select 'COLUMN '||f.fieldname||' FORMAT '||RPAD('9',LENGTH(f.fieldname)-d.decimalpos,'9')
||CASE WHEN d.decimalpos>0 THEN RPAD('.',d.decimalpos+1,'9') END 
from   psrecfielddb f
,      psdbfield d
where f.recname = '&&recname'
and   f.fieldname = d.fieldname
and   d.fieldtype IN (2,3) /*NUMBER*/
and   d.length >0
and   d.length <LENGTH(f.fieldname)
order by f.fieldnum
/
Spool off
@@&&pstemp

SPOOL &&pstemp
PRINT :sql_text
PRO /
SPOOL OFF

SPO &&htmlspool;
PRO <head>
PRO <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
PRO <title>&&report_title</title>

@@pshtmlstyle

PRO <script type="text/javascript" src="sorttable.js"></script>

PRO </head>
PRO <body>
PRO <h1>&&ps_report_prefix &&report_title.</h1>
PRO &&report_abstract_1
PRO &&report_abstract_2
PRO &&report_abstract_3
PRO &&report_abstract_4
PRO <br />

-- body
SET head on pages 50000 MARK HTML ON TABLE "class=sortable" ENTMAP ON
@@&&pstemp
SET pages 0 head off MARK HTML OFF 

PRO <p>

PRO  #: click on a column heading to sort on it
PRO <pre>
COLUMN descrlong FORMAT a50 wrap on
SET head on pages 50000 MARK HTML ON TABLE "class=sortable" ENTMAP ON
COLUMN remarks ENTMAP OFF heading 'XLAT Values'
WITH x AS (
SELECT /*+MATERIALIZE*/ x.fieldname, x.fieldvalue, x.xlatshortname, x.xlatlongname
,      ROW_NUMBER() OVER (PARTITION BY x.fieldname ORDER BY x.fieldvalue) AS curr
,      ROW_NUMBER() OVER (PARTITION BY x.fieldname ORDER BY x.fieldvalue)-1 AS prev
FROM   psxlatitem x
WHERE  x.eff_status = 'A'
AND    x.effdt = (SELECT MAX(x1.effdt)
                  FROM   psxlatitem x1
                  WHERE  x1.fieldname = x.fieldname
                  AND    x1.effdt <= SYSDATE)
)
select f.fieldnum, f.fieldname, l.longname
,      RTRIM(d.descrlong) descrlong
,      (
       SELECT SUBSTR(LTRIM(MAX(SYS_CONNECT_BY_PATH(fieldvalue||'='||xlatlongname,'<br/>')) KEEP (DENSE_RANK LAST ORDER BY curr),','),6)
       FROM   x
       CONNECT BY prev = PRIOR curr AND fieldname = PRIOR fieldname
       START WITH curr = 1 AND x.fieldname = f.fieldname
       ) remarks
from   psrecfielddb f
	   left outer join psdbfldlabl l
	   on l.fieldname = f.fieldname
	   and l.default_label = 1         
,      psdbfield d
where f.recname = '&&recname'
and   f.fieldname = d.fieldname
order by f.fieldnum
/
SET lines 80 pages 0 head off MARK HTML OFF 

DESC &&table_name
SET LIN 32767 
PRINT :sql_text
PRO /
PRO </pre>

PRO </body>
PRO </html>

SPO OFF;
DEF report_abstract_2 = "";
DEF report_abstract_3 = "";
DEF report_abstract_4 = "";

ROLLBACK;
@@pszipit
REM HOS del &&pstemp
