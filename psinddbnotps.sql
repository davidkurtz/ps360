REM psindpsnotdb.sql
DEF recname = 'ALL_OBJECTS'
@@pstimestamp
DEF lrecname = '&&lrecname._objdbnotps'
DEF recdescr = 'Index in Oracle not PeopleSoft'
DEF descrlong = 'Index exists in database on table defined in PeopleSoft data dictionary, but is not defined in PeopleSoft.'

BEGIN
  :sql_text := '
WITH a AS ( /*alternate search indexes*/
  SELECT recname, fieldname
  ,      LTRIM(TO_CHAR(row_number() over (partition by recname order by fieldnum)-1,''9'')) indexid
  FROM   psrecfielddb
  WHERE  bitand(16,useedit)>0
), k as ( /*key index*/
  SELECT recname, fieldname
  FROM   psrecfielddb
  WHERE  bitand(3,useedit)>0
), x as (
SELECT r.recname, i.index_name
FROM  psrecdefn r
,     all_indexes i
WHERE r.rectype IN(0,7)
AND   i.owner = ''&&ownerid''
AND   i.table_owner = ''&&ownerid''
AND   i.table_name = DECODE(r.sqltablename,'' '',''PS_''||r.recname,r.sqltablename)
AND   not i.index_name like ''PS_''||r.recname
/*and not regexp_like(i.index_name,''PS[_0123456789]''||r.recname)*/
AND NOT EXISTS(
        SELECT ''x'' FROM psindexdefn u
        WHERE  u.recname = r.recname
        AND    ''PS''||u.indexid||u.recname = i.index_name
        AND    u.indexid = SUBSTR(i.index_name,3,1)
        UNION ALL
        SELECT ''x'' FROM a
        WHERE  a.recname = r.recname
        AND    ''PS''||a.indexid||a.recname = i.index_name
        AND    a.indexid = SUBSTR(i.index_name,3,1)      
        UNION ALL
        SELECT ''x'' FROM k
        WHERE  k.recname = r.recname
        AND    ''PS_''||k.recname = i.index_name
        )
)
SELECT row_number() OVER (ORDER BY recname, index_name) row_num
,      x.*
FROM   x
ORDER BY row_num'; 
END;				
/

column recname      heading 'PeopleSoft|Record Name' format a15
column index_name   heading 'Index Name'             format a30

@@psgenerichtml.sql
