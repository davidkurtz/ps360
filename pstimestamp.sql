REM pstimestamp.sql
SPOOL OFF
exec dbms_application_info.set_action('&&recname');

col ps360_time_stamp NEW_VALUE ps360_time_stamp
COL hh_mm_ss         NEW_VALUE hh_mm_ss
col lrecname         NEW_VALUE lrecname 

SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') ps360_time_stamp 
,      TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss 
,      LOWER('&&recname') lrecname
FROM   DUAL;

DEF desc_table_name="&&recname"