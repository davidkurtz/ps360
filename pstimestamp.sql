REM pstimestamp.sql
SPOOL OFF
exec dbms_application_info.set_action('&&recname');

column ps360_time_stamp NEW_VALUE ps360_time_stamp
COLUMN hh_mm_ss   NEW_VALUE hh_mm_ss

SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') ps360_time_stamp FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
