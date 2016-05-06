REM psobjcoldiff.sql
REM colaudit COL-07
DEF recname = 'PSRECFIELDDB'
@@psrecdefn
DEF lrecname = '&&lrecname._objcoldiff'
DEF recdescr = 'Column Definition Difference'
DEF descrlong = 'Columns in both Oracle and PeopleSoft, but different definitions.'

BEGIN
  :sql_text := '
WITH n AS (
SELECT /*+MATERIALIZE*/ rownum-1 n FROM dual CONNECT BY LEVEL<=100
), u AS (
SELECT s.unicode_enabled
,      SIGN(BITAND(s.database_options,2)) dbopt_clob
,      SIGN(BITAND(s.database_options,48)) dbopt_ts
,      CASE WHEN s.unicode_enabled = 0 THEN 1
            WHEN n.value = ''AL32UTF8'' THEN 4
            ELSE 3
       END as unicode_factor
,      CASE WHEN TO_NUMBER(s.toolsrel) >= 8.52 THEN 4000 ELSE 2000 END as max_long_length
FROM   psstatus s
,      nls_database_parameters n
WHERE  n.parameter = ''NLS_CHARACTERSET''
AND    TO_NUMBER(s.toolsrel) >= 8.4
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
,      r.systemidfieldname
,      DECODE(r.sqltablename,'' '',''PS_''||r.recname,r.sqltablename) table_name
FROM   psrecdefn r
WHERE  r.rectype = 0 /*TABLES*/
UNION ALL
SELECT /*+MATERIALIZE*/ r.recname, r.rectype
,      r.systemidfieldname
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
,      r.systemidfieldname
,      r.table_name
,      f.fieldname
,      d.fieldnum
,      f.fieldtype
,      f.length
,      f.decimalpos
,      f.format
,      d.useedit
FROM   r
,      psrecfielddb d
,      psdbfield f
WHERE  r.recname = d.recname
AND    f.fieldname = d.fieldname
)
SELECT row_number() OVER (ORDER BY p.recname, o.object_name, oc.column_id) row_num
,      p.rectype, DECODE(p.rectype,0,''TABLE'',1,''VIEW'',6,''QUERY VIEW'',7,''TEMPORARY TABLE'') rectype_desc
,      p.recname
,      oc.table_name, oc.column_name
,      oc.data_type, oc.data_length, oc.data_precision, oc.data_scale
,      DECODE(oc.nullable, ''Y'',''nullable'', ''N'',''Not Null'') nullable
,      p.fieldtype
,      DECODE(p.fieldtype,	0,''Character'',	1,''Long Char'',	2,''Number'',	
                3,''Sign Num'',	4,''Date'',	5,''Time'',	6,''DateTime'',	
                8,''Image'',	9,''ImageRef''	) fieldtype_desc
,      p.length
,      p.decimalpos
,      DECODE(mod(p.useedit/256,2), 1,''Required'',0,''Not Req'') required
FROM   u
,      o
,      oc
,      p
WHERE  oc.table_name = o.object_name
AND    o.object_type = ''TABLE''
AND    o.object_name = p.table_name
AND    oc.table_name = p.table_name
AND    oc.column_name = p.fieldname
--definition diff--
AND	(	(	mod(p.useedit/256,2) = 1 /*required*/
		AND	oc.nullable =''Y''	)
	or	(	p.fieldtype IN(0,2,3) /*number or character*/
		AND	oc.nullable = ''Y''
		AND	NOT 	(	p.fieldname = p.systemidfieldname /*new in PT8.44 - system id fields can be nullable*/
				OR	p.fieldname = ''PTUPDSYSTEMID''
				)
		)
	or	(	oc.data_type = ''VARCHAR2'' /*length mis match match*/
		AND	p.fieldtype = 0
		AND	oc.data_length != LEAST(u.max_long_length,p.length*u.unicode_factor) /*note unicode adjustment*/
		) 
	or	(	p.fieldtype = 1 /*long char data type*/
		AND	p.length*3 BETWEEN 1 and u.max_long_length-1 /*PS still allowing 3 bytes per char*/
		AND	NOT (   oc.data_type = ''VARCHAR2''
                            AND oc.data_length = LEAST(u.max_long_length,p.length*u.unicode_factor)
                            )
                )
	or	(	p.fieldtype = 1 /*long*/
		AND	not p.length*3 BETWEEN 1 and u.max_long_length-1
		AND	p.format = 0 /*just long*/
		AND	oc.data_type != DECODE(u.dbopt_clob,1,''CLOB'',''LONG''))
	or	(	p.fieldtype = 1 /*long*/
		AND	p.format = 7
		AND	oc.data_type != DECODE(u.dbopt_clob,1,''BLOB'',''LONG RAW''))
	or	(	p.fieldtype = 2 /*number*/
		AND	not (	oc.data_type = ''NUMBER''
			    AND	oc.data_scale = p.decimalpos
			    AND	(	oc.data_precision + 1 = p.length
				or	p.decimalpos = 0
                                )
                        )
                )
	or	(	p.fieldtype = 3 /*signed number*/
		AND	not
			(	oc.data_type = ''NUMBER''
			AND	oc.data_scale = p.decimalpos
			AND	(	oc.data_precision + 2 = p.length
				or	p.decimalpos = 0
                                )
                        )
                )
	or 	(	p.fieldtype = 4
		AND	oc.data_type != ''DATE'')	
	or 	(	p.fieldtype IN(5,6)
		AND	NOT oc.data_type LIKE DECODE(u.dbopt_ts,1,''TIMESTAMP%'',''DATE''))	
	or	(	p.fieldtype = 8 /*image*/
		AND	oc.data_type != DECODE(u.dbopt_clob,1,''BLOB'',''LONG RAW''))
	or	(	p.fieldtype = 9 /*image ref*/
		AND	not 	(	oc.data_type = ''VARCHAR2''
				AND	oc.data_length = 30*u.unicode_factor)))
ORDER BY row_num
END;				
/

column rectype        heading 'Record|Type'
column rectype_desc   heading 'Record Type|Description' format a15
column recname        heading 'PeopleSoft|Record Name'  format a15
column table_name     heading 'Table Name'              format a30
column column_name    heading 'Column Name'             format a18
column data_type      heading 'Data|Type'
column data_length    heading 'Data|Length'
column data_precision heading 'Data|Precision'
column data_scale     heading 'Data|Scale'
column nullable       heading 'Nullable'                format a8
column fielddesc      heading 'PeopleSoft|Field|Type'   format a9
column decimalpos     heading 'Decimal|Positions|in PS' 
column required       heading 'Field|Required|in PS'    format a8

@@psgenerichtml.sql
