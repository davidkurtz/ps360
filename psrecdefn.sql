REM psrecdefn.sql
SPOOL OFF

@@pstimestamp

COLUMN table_name NEW_VALUE table_name
COLUMN lrecname   NEW_VALUE lrecname
COLUMN recdescr   NEW_VALUE recdescr
COLUMN descrlong  NEW_VALUE descrlong

SELECT DECODE(r.sqltablename,' ','PS_'||r.recname,r.sqltablename) table_name
,      lower(r.recname) lrecname
,      r.recdescr
,      r.descrlong
FROM	  psrecdefn r
WHERE  r.recname = '&&recname'
/
BEGIN
  :sql_text := '
SELECT *
  FROM &&table_name
'; 
END;				
/
