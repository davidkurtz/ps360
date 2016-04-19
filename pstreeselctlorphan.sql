REM pstreeselctlorphan.sql
DEF recname = 'PSTREESELCTL'
@@psrecdefn
DEF lrecname = '&&lrecname._orphan'
DEF recdescr = '&&recdescr - where tree does not exist'

BEGIN
  :sql_text := '
SELECT row_number() over (order by setid, setcntrlvalue, tree_name, effdt) row_num
, t.*
  FROM &&table_name t
 WHERE NOT EXISTS(
  SELECT ''x''
  FROM   pstreedefn d
  WHERE  d.setid = t.setid
  AND    d.setcntrlvalue = t.setcntrlvalue
  AND    d.tree_name = t.tree_name
  AND    d.effdt = t.effdt)
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
