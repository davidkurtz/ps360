set echo &&ps_echo_off
SPOOL OFF
DEF sleep_secs=".2";
EXEC dbms_lock.sleep(&&sleep_secs);
HOS zip -m9 &&zipfile &&linespool &&htmlspool &&piespool
EXEC dbms_lock.sleep(&&sleep_secs);
HOS zip -q  &&zipfile &&ps360_main_report..html
EXEC dbms_lock.sleep(&&sleep_secs);
SPOOL &&ps360_main_report..html APP
PRO <li title="&&section">&&report_title
SELECT ' <a href="&&htmlspool">html</a>' FROM dual WHERE '&&htmlspool' IS NOT NULL;
SELECT ' <a href="&&piespool">pie</a>'  FROM dual WHERE '&&piespool'  IS NOT NULL;
SELECT ' <a href="&&linespool">line</a>' FROM dual WHERE '&&linespool' IS NOT NULL;
PRO (&&row_num)</li>
SPOOL OFF
DEF htmlspool="";
DEF linespool="";
DEF piespool="";
DEF row_num="";
/
