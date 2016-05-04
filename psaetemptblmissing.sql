REM psaetemptblmissing.sql
DEF recname = 'PSTEMPTBLCNTVW'
@@psrecdefn
DEF lrecname = '&&lrecname._missing'
DEF recdescr = '&&recdescr. Table defined in PeopleSoft not built'
DEF descrlong = 'Non-shared instances of temporary record not created as table in database.'

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
AND    n.n <= c.temptblinstances+o.temptblinstances
)
SELECT row_number() over (order by c.recname, c.instance) row_num
,      c.recname, c.instance, c.temptblinstances, c.table_name
FROM   c
       LEFT OUTER JOIN user_tables t
       ON t.table_name = c.table_name
WHERE c.table_name IS NULL
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
