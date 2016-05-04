REM psaetempgttcand.sql
DEF recname = 'PSAEAPPLTEMPTBL'
@@psrecdefn
DEF lrecname = '&&lrecname._gttcand'
DEF recdescr = '&&recdescr. Global Temporary Candidates'
DEF descrlong = 'Temporary Records that are assigned to a non-restartable AE, but not to a restartable AE and so could be marked as GTTs from PeopleTools 8.54.'

set lines 200 pages 99
BEGIN
  :sql_text := '
WITH x as (
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
       SELECT LISTAGG(t.ae_applid||'' (''||d.temptblinstances||'')'','', '') WITHIN GROUP (ORDER BY t.ae_applid)
       FROM   psaeappltemptbl t
       ,      psaeappldefn d
       WHERE  t.ae_applid = d.ae_applid
       AND    d.ae_disable_restart = ''Y''
       AND    t.recname = r.recname
       ) ae_applids
from   psrecdefn r
where  r.rectype = 7
)
select row_number() over (order by recname) row_num
,      recname, auxflaggtt, numnorestartae, ae_applids
from   x
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
