REM psrecdefn.sql
SPOOL OFF

@@pstimestamp

DEF recdescr=""
DEF descrlong=""

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

exec :sql_text := '';
DEF desc_table_name="&&table_name"