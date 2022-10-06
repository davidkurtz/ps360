REM ps_0init.sql

SET TERM &&ps_term_off ECHO &&ps_echo_off


VAR old_module VARCHAR2(64)
VAR old_action VARCHAR2(64)
DEF ps_prefix = "ps360"
DEF section = "main";

BEGIN
 dbms_application_info.read_module(:old_module,:old_action);
 dbms_application_info.set_module('&&ps_prefix','&&section');
END;
/

DEF pstemp="pstemp.sql"
DEF ps_report_prefix = "PeopleSoft:"
DEF htmlsuffix = "html";
DEF max_col_number=3
DEF charttype="LineChart";

VAR sql_text_stub CLOB
VAR sql_text CLOB
VAR sql_text_display CLOB

COLUMN dbname NEW_VALUE psdbname
COLUMN ownerid NEW_VALUE sysadm
SELECT dbname 
,      ownerid
FROM   ps.psdbowner 
WHERE  rownum = 1
/
DEF ps360_main_report="&&ps_prefix._&&psdbname._0_index";

COLUMN row_num NEW_VALUE row_num HEADING '#'
COLUMN rownum NEW_VALUE row_num HEADING '#'
COLUMN file_time NEW_VALUE file_time
SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MISS') file_time
FROM   dual
/

ALTER SESSION SET CURRENT_SCHEMA=&&sysadm;

DEF zipfile="&&ps_prefix._&&psdbname._&&file_time..zip"

SET TERM &&ps_term_off HEA OFF LIN 32767 NEWP NONE PAGES 0 FEED OFF ECHO &&ps_echo_off VER OFF LONG 32000 LONGC 2000 WRA ON TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 20 SQLBL ON BLO . RECSEP OFF;
