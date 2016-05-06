REM pscoldbnotps.sql
REM colaudit COL-06
DEF recname = 'ALL_TAB_COLUMNS'
@@pstimestamp
DEF lrecname = '&&lrecname._coldbnotps'
DEF recdescr = 'Columns in Oracle not PeopleSoft'
DEF descrlong = 'Columns In Oracle Database Data Dictionary, but not in PeopleSoft.'

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
,      column_name
,      data_type
,      data_length
,      data_precision
,      data_scale
,      nullable
,      column_id
FROM   all_tab_columns
WHERE  owner = ''&&ownerid''
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
SELECT /*+MATERIALIZE*/ r.recname, rectype
,      r.table_name
,      f.fieldname
,      f.fieldnum
FROM   r
,      psrecfielddb f
WHERE  r.recname = f.recname
)
SELECT row_number() OVER (ORDER BY r.recname, o.object_name, oc.column_id) row_num
,      r.rectype, DECODE(r.rectype,0,''TABLE'',1,''VIEW'',6,''QUERY VIEW'',7,''TEMPORARY TABLE'') rectype_desc
,      r.recname
,      o.object_type, o.object_name
,      oc.column_id, oc.column_name
,      oc.data_type, oc.data_length, oc.data_precision, oc.data_scale
FROM   o
,      oc
,      r
WHERE  oc.table_name = o.object_name
AND    r.table_name = oc.table_name
AND    r.table_name = o.object_name
AND NOT (r.recname, r.rectype, r.table_name, oc.column_name) IN (
        SELECT p.recname, p.rectype, p.table_name, p.fieldname
        FROM   p)
ORDER BY row_num'; 
END;				
/

column rectype      heading 'Record|Type'
column rectype_desc heading 'Record Type|Description' format a15
column recname      heading 'PeopleSoft|Record Name'  format a15
column object_type  heading 'Oracle Object Type'  format a18
column object_name  heading 'Oracle Object Name'  format a18
column column_id    heading 'Col|ID'
column column_name  heading 'Column|Name' format a30
column data_type      heading 'Data|Type'
column data_length    heading 'Data|Length'
column data_precision heading 'Data|Precision'
column data_scale     heading 'Data|Scale'

@@psgenerichtml.sql
