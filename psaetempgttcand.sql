REM psaetempgttcand.sql
DEF recname = 'PSAEAPPLTEMPTBL'
@@psrecdefn
DEF lrecname = '&&lrecname._gttcand'
DEF recdescr = '&&recdescr. Global Temporary Candidates'
DEF descrlong = 'Temporary Records that are assigned to a non-restartable AE, but not to a restartable AE and so could be marked as GTTs from PeopleTools 8.54.'

set lines 200 pages 99
BEGIN
  :sql_text := '
WITH a AS (
SELECT /*+MATERIALIZE*/ t.recname, t.ae_applid, d.temptblinstances
,      ROW_NUMBER() OVER (PARTITION BY t.recname ORDER BY t.ae_applid) AS curr
,      ROW_NUMBER() OVER (PARTITION BY t.recname ORDER BY t.ae_applid)-1 AS prev
FROM   psaeappltemptbl t
,      psaeappldefn d        
WHERE  t.ae_applid = d.ae_applid
AND    d.ae_disable_restart = ''Y''
), x as (
select r.recname
,      CASE WHEN bitand(auxflagmask,4194304)=4194304 THEN ''Y'' ELSE ''N'' END auxflaggtt
,      (SELECT COUNT(DISTINCT d.ae_applid)
       FROM    psaeappltemptbl t
       ,       psaeappldefn d        
       WHERE   t.ae_applid = d.ae_applid
       AND     d.ae_disable_restart = ''N''
       AND     t.recname = r.recname
       ) numrestartae
,      (SELECT COUNT(DISTINCT d.ae_applid)
       FROM    psaeappltemptbl t
       ,       psaeappldefn d        
       WHERE   t.ae_applid = d.ae_applid
       AND     d.ae_disable_restart = ''Y''
       AND     t.recname = r.recname
       ) numnorestartae
,      (
       SELECT SUBSTR(LTRIM(MAX(SYS_CONNECT_BY_PATH(a.ae_applid||'' (''||a.temptblinstances||'')'','', '')) KEEP (DENSE_RANK LAST ORDER BY a.curr),'',''),2)
       FROM   a
       CONNECT BY a.prev = PRIOR a.curr AND a.recname = PRIOR a.recname
       START WITH a.curr = 1 AND a.recname = r.recname
       ) ae_applids
from	psrecdefn r
where 	r.rectype = 7
)
select  row_number() over (order by recname) row_num
,       recname, auxflaggtt, numnorestartae, ae_applids
from    x
where   numrestartae=0
and	numnorestartae>0
and	auxflaggtt=''N''
order by row_num
'; 
END;				
/

column numnorestartae heading 'Number of|Non-Restartable|AE programs'
column ae_applids     heading 'Non-Restartable|Application Engines|(Number of Instances)'
column auxflaggtt     heading 'AUXFLAGMASK|Marked as GTT|(PT>=8.54)' format a15

@@psgenerichtml.sql
