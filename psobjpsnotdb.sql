REM psobjpsnotdb.sql
REM colaudit COL-01
DEF recname = 'PSRECDEFN'
@@psrecdefn
DEF lrecname = '&&lrecname._objpsnotdb'
DEF recdescr = '&&recdescr. not built in database.'
DEF descrlong = 'Object in PeopleSoft Data Dictionary but not in Oracle Database.'

BEGIN
  :sql_text := '
WITH x AS (
SELECT r.*
,      DECODE(r.rectype,0,''TABLE'',1,''VIEW'',6,''QUERY VIEW'',7,''TEMPORARY TABLE'') rectype_desc
,      DECODE(r.sqltablename,'' '',''PS_''||r.recname,r.sqltablename) object_name
,      CASE WHEN r.rectype IN(0,7) THEN ''TABLE''
            WHEN BITAND(r.auxflagmask,16777216) = 16777216 THEN ''TABLE''
            WHEN r.rectype IN(1,6) THEN ''VIEW''
       END as object_type
FROM   psrecdefn r
WHERE  r.rectype IN(0 /*TABLES*/, 1 /*views*/, 6 /*QUERY VIEWS*/, 7 /*TEMPORARY TABLE*/)
UNION ALL
SELECT r.*
,      DECODE(r.rectype,0,''TABLE'',1,''VIEW'',6,''QUERY VIEW'',7,''TEMPORARY TABLE'') rectype_desc
,      DECODE(r.sqltablename,'' '',''PS_''||r.recname,r.sqltablename) object_name
,      ''MATERIALIZED VIEW'' object_type
FROM   psrecdefn r
WHERE  r.rectype = 1 /*views*/
AND    BITAND(r.auxflagmask,16777216) = 16777216 /*MV*/
)
SELECT row_number() OVER (ORDER BY x.recname, x.object_name) row_num
,      x.rectype, x.rectype_desc
,      x.recname, x.sqltablename
,      x.object_name
FROM   x
WHERE NOT EXISTS(
       SELECT ''x''
       FROM   all_objects o
       WHERE  o.object_type = x.object_type
       AND    o.object_name = x.object_name
       AND    o.owner = ''&&ownerid'')
order by row_num'; 
END;				
/

column rectype      heading 'Record|Type'
column rectype_desc heading 'Record Type|Description' format a15
column recname      heading 'PeopleSoft|Record Name'  format a15
column sqltablename heading 'SQL Table Name'          format a18
column object_name  heading 'Oracle Object Name'      format a18

@@psgenerichtml.sql
