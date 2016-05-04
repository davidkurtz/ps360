REM psaetempgttnotcand.sql
DEF recname = 'PSAEAPPLTEMPTBL'
@@psrecdefn
DEF lrecname = '&&lrecname._gttnotcand'
DEF recdescr = '&&recdescr. must be permanent tables'
DEF descrlong = 'Temporary Records that are marked as GTTs from PeopleTools 8.54 but are assigned to restartable AEs'

set lines 200 pages 99
BEGIN
  :sql_text := '
WITH x as (
select r.recname
,      (SELECT COUNT(DISTINCT d.ae_applid)
       FROM    psaeappltemptbl t
       ,       psaeappldefn d        
       WHERE   t.ae_applid = d.ae_applid
       AND     d.ae_disable_restart = ''N''
       AND     t.recname = r.recname
       ) numrestartae
,      (
       SELECT LISTAGG(t.ae_applid||'' (''||d.temptblinstances||'')'','', '') WITHIN GROUP (ORDER BY t.ae_applid)
       FROM   psaeappltemptbl t
       ,      psaeappldefn d
       WHERE  t.ae_applid = d.ae_applid
       AND    d.ae_disable_restart = ''N''
       AND    t.recname = r.recname
       ) ae_applids
from   psrecdefn r
where  r.rectype = 7
and    bitand(auxflagmask,4194304)=4194304 /*marked as GTT*/
)
select  recname, numrestartae, ae_applids
from    x
where   numrestartae>0
'; 
END;				
/

column numrestartae heading 'Number of|Restartable|AE programs'
column ae_applids   heading 'Restartable|Application Engines|(Number of Instances)'

@@psgenerichtml.sql
