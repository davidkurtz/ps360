REM pscolpsnotdb.sql
REM colaudit COL-05
DEF recname = 'PSRECFIELDDB'
@@psrecdefn
DEF lrecname = '&&lrecname._colpsnotdb'
DEF recdescr = '&&recdescr. not built in database.'
DEF descrlong = 'Object in PeopleSoft Data Dictionary but not in Oracle Database.'

BEGIN
  :sql_text := '
WITH n AS (
SELECT /*+MATERIALIZE*/ rownum-1 n FROM dual CONNECT BY LEVEL<=100
), o AS (
SELECT object_type, object_name
FROM   all_objects o
WHERE  owner = ''&&ownerid''
AND    object_type IN(''TABLE'',''VIEW'')
), oc AS (
SELECT /*MATERIALIZE*/ 
       table_name
,      column_name
FROM   all_tab_columns
WHERE  owner = ''&&ownerid''
), r AS (
SELECT r.recname, r.rectype
,      DECODE(r.sqltablename,'' '',''PS_''||r.recname,r.sqltablename) table_name
FROM   psrecdefn r
WHERE  r.rectype IN(0 /*TABLES*/, 1 /*views*/, 6 /*QUERY VIEWS*/)
UNION ALL
SELECT r.recname, r.rectype
,      DECODE(r.sqltablename, '' '', ''PS_''||r.recname,r.sqltablename)||DECODE(n.n,0,'''',n.n) table_name
FROM   n
,      pstemptblcntvw c
,      psrecdefn r
,      psoptions o
WHERE  r.recname = c.recname
AND    r.rectype = 7 /*TEMPORARY TABLE*/
AND    n.n <= c.temptblinstances+o.temptblinstances
), p AS (
SELECT /*+MATERIALIZE*/ r.recname, rectype
,      r.table_name
,      f.fieldname
,      f.fieldnum
FROM   r
,      psrecfielddb f
WHERE  r.recname = f.recname
)
SELECT row_number() OVER (ORDER BY p.recname, p.table_name, p.fieldnum) row_num
,      p.rectype, DECODE(p.rectype,0,''TABLE'',1,''VIEW'',6,''QUERY VIEW'',7,''TEMPORARY TABLE'') rectype_desc
,      p.recname, p.table_name, p.fieldnum, p.fieldname
FROM   p
,      o
WHERE  o.object_type = DECODE(p.rectype, 0,''TABLE'',1,''VIEW'',6,''VIEW'',7,''TABLE'')  
AND    o.object_name = p.table_name
AND NOT EXISTS(
       SELECT ''x''
       FROM   oc
       WHERE  oc.table_name = p.table_name
       AND    oc.column_name = p.fieldname)
ORDER BY row_num'; 
END;				
/

column rectype      heading 'Record|Type'
column rectype_desc heading 'Record Type|Description' format a15
column recname      heading 'PeopleSoft|Record Name'  format a15
column table_name   heading 'Table Name'              format a30
column fieldnum     heading 'Field|Num'
column fieldname    heading 'Field|Name'

@@psgenerichtml.sql
