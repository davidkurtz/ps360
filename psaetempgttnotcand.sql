REM psaetempgttnotcand.sql
DEF recname = 'PSAEAPPLTEMPTBL'
@@psrecdefn
DEF lrecname = '&&lrecname._gttcand'
REM recdescr = '&&recdescr.'
DEF descrlong = 'Temporary Records that are marked as GTTs from PeopleTools 8.54 but are assigned to restartable AEs'

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
AND    d.ae_disable_restart = ''N''
), x as (
select r.recname
,      (SELECT COUNT(DISTINCT d.ae_applid)
       FROM    psaeappltemptbl t
       ,       psaeappldefn d        
       WHERE   t.ae_applid = d.ae_applid
       AND     d.ae_disable_restart = ''N''
       AND     t.recname = r.recname
       ) numrestartae
,      (
       SELECT SUBSTR(LTRIM(MAX(SYS_CONNECT_BY_PATH(a.ae_applid||'' (''||a.temptblinstances||'')'','', '')) KEEP (DENSE_RANK LAST ORDER BY a.curr),'',''),2)
       FROM   a
       CONNECT BY a.prev = PRIOR a.curr AND a.recname = PRIOR a.recname
       START WITH a.curr = 1 AND a.recname = r.recname
       ) ae_applids
from   psrecdefn r
where  r.rectype = 7
and    bitand(auxflagmask,4194304)=4194304
)
select  recname, numrestartae, ae_applids
from    x
where   numrestartae>0
'; 
END;				
/

column numrestartae heading 'Number of|Restartable|AE programs'
column ae_applids   heading 'Restartable|Application Engines|(Number of Instances)

@@psgenerichtml.sql
