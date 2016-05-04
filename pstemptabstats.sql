REM pstemptabstats.sql
DEF recname = 'ALL_TAB_STATISTICS'
@@pstimestamp.sql
DEF table_name = '&&recname'
DEF lrecname = 'all_tab_statistics'
DEF recdescr = 'Unlocked Temporary Table Statistics'
DEF descrlong = 'Statistics on PeopleSoft Temporary Records should be locked and deleted, and only collected explicitly by batch processes.'
DEF report_abstract_2 = "<br>See <a target=''_blank'' href=''http://www.go-faster.co.uk/docs.htm#Managing.Statistics.11g''>http://www.go-faster.co.uk/docs.htm#Managing.Statistics.11g</a>";
REM see http://blog.psftdba.com/2009/04/statistics-management-for-peoplesoft.html
REM see http://www.go-faster.co.uk/Partition.Statistics.11gR2.pdf

BEGIN
  :sql_text := '
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
,      DECODE(r.sqltablename,'' '',''PS_''||r.recname,r.sqltablename)||n.tempinstance table_name
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
,      all_tab_statistics s
WHERE  r.table_name = s.table_name
AND    s.owner = ''&&ownerid''
AND    s.object_type = ''TABLE''
AND    s.partition_name IS NULL
AND    s.stattype_locked IS NULL /*not locked*/
ORDER BY row_num
/'; 
END;				
/
column tempinstance              heading 'Temporary|Table|Instance'
column PARTITION_POSITION        heading 'PARTITION_|POSITION'
column PARTITION_NAME            heading 'PARTITION_|NAME'
column SUBPARTITION_POSITION     heading 'SUBPARTITION_|POSITION'
column SUBPARTITION_NAME         heading 'SUBPARTITION_|NAME'
column OBJECT_TYPE               heading 'OBJECT_|TYPE'
column NUM_ROWS                  heading 'NUM_|ROWS'
column EMPTY_BLOCKS              heading 'EMPTY_|BLOCKS'
column AVG_SPACE                 heading 'AVG_|SPACE'
column CHAIN_CNT                 heading 'CHAIN_|CNT'
column AVG_ROW_LEN               heading 'AVG_|ROW_|LEN'
column AVG_SPACE_FREELIST_BLOCKS heading 'AVG_|SPACE_|FREELIST_|BLOCKS'
column NUM_FREELIST_BLOCKS       heading 'NUM_|FREELIST_|BLOCKS'
column AVG_CACHED_BLOCKS         heading 'AVG_|CACHED_|BLOCKS'
column avg_cache_hit_ratio       heading 'AVG_|CACHE_|HIT_RATIO'
column SAMPLE_SIZE               heading 'SAMPLE_|SIZE'
column LAST_ANALYZED             heading 'LAST_|ANALYZED'
column GLOBAL_STATS              heading 'GLOBAL_|STATS' format a7
column USER_STATS                heading 'USER_|STATS' format a5
column STATTYPE_LOCKED           heading 'STATTYPE_|LOCKED' format a9
column STALE_STATS               heading 'STALE_|STATS' format a6

@@psgenerichtml.sql
