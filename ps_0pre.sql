REM ps_0pre.sql
SET TERM &&ps_term_off
spool off

COL ps360_time_stamp NEW_V ps360_time_stamp FOR A20
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') ps360_time_stamp FROM DUAL;

-- get rdbms version
COL db_version NEW_V db_version
SELECT version db_version FROM v$instance;

-- get database name (up to 10, stop before first '.', no special characters)
COL database_name_short NEW_V database_name_short FOR A10;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 10)) database_name_short FROM DUAL;
SELECT SUBSTR('&&database_name_short.', 1, INSTR('&&database_name_short..', '.') - 1) database_name_short FROM DUAL;
SELECT TRANSLATE('&&database_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') database_name_short FROM DUAL;

-- get host name (up to 30, stop before first '.', no special characters)
COL host_name_short NEW_V host_name_short FOR A30;

SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) host_name_short FROM DUAL;
SELECT SUBSTR('&&host_name_short.', 1, INSTR('&&host_name_short..', '.') - 1) host_name_short FROM DUAL;
SELECT TRANSLATE('&&host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') host_name_short FROM DUAL;

DEF ownerid="SYSADM"
col ownerid NEW_VALUE ownerid 
SELECT o.ownerid
FROM   ps.psdbowner o
,      v$session s
where  o.dbname = s.service_name
and    s.sid IN(SELECT sid FROM v$mystat WHERE rownum = 1)
/

ALTER SESSION SET CURRENT_SCHEMA=&&ownerid;
-- get rdbms version
COL toolsrel NEW_V toolsrel
SELECT toolsrel, ownerid FROM psstatus;

DEF lrecname="";
DEF row_num="";
DEF piespool="";
DEF linespool="";
DEF htmlspool="";

DEF report_abstract_2 = "";
DEF report_abstract_3 = "";
DEF report_abstract_4 = "";

DEF chart_foot_note_1 = "<br>";
DEF chart_foot_note_2 = ""; 
DEF chart_foot_note_3 = "";
DEF chart_foot_note_4 = "";

DEF separator="\";
DEF delete="rm";

