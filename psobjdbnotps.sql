REM psobjpsnotdb.sql
REM colaudit COL-02
DEF recname = 'ALL_OBJECTS'
@@pstimestamp
DEF lrecname = '&&lrecname._objdbnotps'
DEF recdescr = 'Object in Oracle not PeopleSoft'
DEF descrlong = 'Object exists in Oracle Database, but not defined in PeopleSoft Data Dictionary.'

BEGIN
  :sql_text := '
WITH n AS (
SELECT /*+MATERIALIZE*/ rownum-1 n FROM dual CONNECT BY LEVEL<=100
), x AS (
SELECT object_type, object_name
FROM   all_objects o
WHERE  o.object_type IN(''TABLE'',''VIEW'',''MATERIALIZED VIEW'')
AND    o.owner = ''&&ownerid''
AND    NOT object_name IN(''MV_CAPABILITIES_TABLE'')
minus
SELECT CASE WHEN r.rectype IN(0,7) THEN ''TABLE''
            WHEN BITAND(r.auxflagmask,16777216) = 16777216 THEN ''TABLE''
            WHEN r.rectype IN(1,6) THEN ''VIEW''
       END as object_type
,      DECODE(r.sqltablename,'' '',''PS_''||r.recname,r.sqltablename)
FROM   psrecdefn r
WHERE  r.rectype IN(0,1,6,7)
MINUS
SELECT ''MATERIALIZED VIEW'' object_type
,      DECODE(r.sqltablename,'' '',''PS_''||r.recname,r.sqltablename)
FROM   psrecdefn r
WHERE  r.rectype = 1 /*views*/
AND    BITAND(r.auxflagmask,16777216) = 16777216 /*MV*/
MINUS
SELECT ''TABLE'' object_type
,      DECODE(r.sqltablename, '' '', ''PS_''||r.recname,r.sqltablename)||DECODE(n.n,0,'''',n.n) table_name
FROM   n
,      pstemptblcntvw c
,      psrecdefn r
,      psoptions o
WHERE  r.recname = c.recname
AND    r.rectype = 7 /*TEMPORARY TABLE*/
AND    n.n <= c.temptblinstances+o.temptblinstances
)
SELECT row_number() OVER (ORDER BY object_name, object_type) row_num
,      x.*
FROM   x
ORDER BY row_num'; 
END;				
/

column object_type  heading 'Oracle Object Type'  format a18
column object_name  heading 'Oracle Object Name'  format a18
column table_name   heading 'Table Name'          format a30

@@psgenerichtml.sql
