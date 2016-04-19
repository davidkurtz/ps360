
WITH n AS (
SELECT /*+MATERIALIZE*/
       rownum tempinstance
FROM   DUAL
CONNECT BY level <= 99
UNION  ALL
SELECT NULL FROM DUAL
), r AS (
SELECT /*+MATERIALIZE LEADING(o)*/
       r.recname, n.tempinstance
,      DECODE(r.sqltablename,' ','PS_'||r.recname,r.sqltablename)||n.tempinstance table_name
,      c.temptblinstances
FROM   psrecdefn r
,      psoptions o
,      n
,      pstemptblcntvw c
WHERE  r.rectype = 7
AND    c.recname = r.recname
AND   (n.tempinstance<=LEAST(99,c.temptblinstances + o.temptblinstances) OR n.tempinstance IS NULL)
)
SELECT row_number() over (order by r.recname, r.tempinstance, s.partition_position, s.subpartition_position nulls first) row_num
,      r.recname, r.tempinstance
,      s.*
FROM   r
,      user_tab_statistics s
WHERE  r.table_name = s.table_name
AND    s.object_type = 'TABLE'
AND    s.partition_name IS NULL
AND    s.stattype_locked IS NULL /*not locked*/
ORDER BY row_num
/

/
