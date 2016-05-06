REM pscoldiffpos.sql
REM colaudit COL-09
DEF recname = 'PSRECFIELDDB'
@@psrecdefn
DEF lrecname = '&&lrecname._coldiffpos'
DEF recdescr = 'Column Position Difference'
DEF descrlong = 'Tables/Views where column exists in both Oracle and PeopleSoft, but in different Positions.'

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
SELECT /*+MATERIALIZE*/ 
       table_name
,      column_id
,      column_name
FROM   all_tab_columns
WHERE  owner = ''&&ownerid''
), r AS (
SELECT /*+MATERIALIZE*/ r.recname, r.rectype
,      DECODE(r.sqltablename,'' '',''PS_''||r.recname,r.sqltablename) table_name
FROM   psrecdefn r
WHERE  r.rectype IN(0 /*TABLES*/, 1 /*views*/, 6) /*QUERY VIEWS*/
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
SELECT /*+MATERIALIZE*/ r.recname, rectype
,      r.table_name
,      f.fieldname
,      f.fieldnum
FROM   r
,      psrecfielddb f
WHERE  r.recname = f.recname
)
SELECT row_number() OVER (ORDER BY p.recname, o.object_name, oc.column_id) row_num
,      p.rectype, DECODE(p.rectype,0,''TABLE'',1,''VIEW'',6,''QUERY VIEW'',7,''TEMPORARY TABLE'') rectype_desc
,      p.recname
,      o.object_type, o.object_name, oc.column_name
,      oc.column_id, p.fieldnum
FROM   o
,      oc
,      p
WHERE  oc.table_name = o.object_name
AND    o.object_type = DECODE(p.rectype, 0,''TABLE'',1,''VIEW'',6,''VIEW'',7,''TABLE'')  
AND    o.object_name = p.table_name
AND    oc.table_name = p.table_name
AND    oc.column_name = p.fieldname
AND    p.fieldnum != oc.column_id
ORDER BY row_num';
END;				
/

column rectype        heading 'Record|Type'
column rectype_desc   heading 'Record Type|Description' format a15
column recname        heading 'PeopleSoft|Record Name'  format a15
column object_type    heading 'Oracle Object Type'      format a18
column object_name    heading 'Oracle Object Name'      format a18
column column_name    heading 'Column Name'             format a18
column column_id      heading 'Col|ID'
column fieldnum       heading 'Field|Num'

@@psgenerichtml.sql
