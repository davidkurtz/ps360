REM psaetemptblexcess.sql
DEF recname = 'PSTEMPTBLCNTVW'
@@psrecdefn
DEF lrecname = '&&lrecname._excess'
DEF recdescr = '&&recdescr. More tables built than defined in PeopleSoft'
DEF descrlong = 'More instances of non-shared temporary records created as tables in database than required.'

set lines 200 pages 99
BEGIN
  :sql_text := '
WITH n AS (
SELECT /*+MATERIALIZE*/ rownum-1 n FROM dual CONNECT BY LEVEL<=100
), c AS (
SELECT /*+MATERIALIZE*/ c.recname
,      n.n instance
,      DECODE(r.sqltablename, '' '', ''PS_''||r.recname,r.sqltablename)||DECODE(n.n,0,'''',n.n) table_name
,      c.temptblinstances
      +o.temptblinstances temptblinstances
FROM   n
,      pstemptblcntvw c
,      psrecdefn r
,      psoptions o
WHERE  r.recname = c.recname
AND    n.n > c.temptblinstances+o.temptblinstances
)
SELECT row_number() over (order by c.recname, c.instance) row_num
,      c.recname, c.instance, c.temptblinstances, c.table_name
FROM   c
,      all_tables t
WHERE  t.owner = ''&&ownerid''
AND    t.table_name = c.table_name
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
