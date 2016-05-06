REM psobjcoldiff.sql
REM colaudit COL-04
DEF recname = 'PSRECDEFN'
@@psrecdefn
DEF lrecname = '&&lrecname._objcoldiff'
DEF recdescr = '&&recdescr. not built in database.'
DEF descrlong = 'Corresponding PeopleSoft and Oracle Tables and Views with different numbers of columns.'

BEGIN
  :sql_text := '
WITH n AS (
SELECT /*+MATERIALIZE*/ rownum-1 n FROM dual CONNECT BY LEVEL<=100
), o AS (
SELECT /*+MATERIALIZE*/ 
       c.table_name, count(*) dbcols
FROM   all_tab_columns c
WHERE  c.owner = ''&&ownerid''
GROUP BY c.table_name
), r AS (
SELECT /*+MATERIALIZE*/ r.recname, r.rectype
,      DECODE(r.sqltablename,'' '',''PS_''||r.recname,r.sqltablename) table_name
FROM   psrecdefn r
WHERE  r.rectype IN(0 /*TABLES*/, 1 /*views*/, 6 /*QUERY VIEWS*/) 
UNION ALL
SELECT /*+MATERIALIZE*/ r.recname, r.rectype
,      DECODE(r.sqltablename, '' '', ''PS_''||r.recname,r.sqltablename)||DECODE(n.n,0,'''',n.n) table_name
FROM   n
,      pstemptblcntvw c
,      psrecdefn r
,      psoptions o
WHERE  r.recname = c.recname
AND    r.rectype = 7 /*TEMPORARY TABLE*/
AND    n.n <= c.temptblinstances+o.temptblinstances
), p AS (
SELECT /*+MATERIALIZE*/ r.recname
,      r.rectype
,      DECODE(r.rectype,0,''TABLE'',1,''VIEW'',6,''QUERY VIEW'',7,''TEMPORARY TABLE'') rectype_desc
,      r.table_name
,      count(*) pscols
FROM   r
,      psrecfielddb f
WHERE  r.recname = f.recname
GROUP BY r.recname, r.rectype, r.table_name
)
SELECT  row_number() OVER (ORDER BY p.recname, p.table_name) row_num
,       p.rectype, p.rectype_desc
,       p.recname, p.table_name, p.pscols, o.dbcols
FROM    o
,       p
WHERE   o.table_name = p.table_name
AND     o.dbcols != p.pscols
ORDER BY row_num'; 
END;				
/

column rectype      heading 'Record|Type'
column rectype_desc heading 'Record Type|Description' format a15
column recname      heading 'PeopleSoft|Record Name'  format a15
column table_name   heading 'Table Name'              format a30
column pscols       heading 'Columns in|PeopleSoft|Definition'
column dbcols       heading 'Columns in|Database|Object'

@@psgenerichtml.sql
