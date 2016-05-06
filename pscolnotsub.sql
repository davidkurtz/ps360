REM pscolnotsub.sql
REM colaudit COL-08
DEF recname = 'PSRECFIELDDB'
@@psrecdefn
DEF lrecname = '&&lrecname._colnotsub'
DEF recdescr = 'Record not sub-record'
DEF descrlong = 'Records referenced as, but no longer defined as subrecords.'

BEGIN
  :sql_text := '
SELECT row_number() over (order by r.recname, f.fieldname) row_num
, r.recname, f.fieldname
FROM psrecfield f
, psrecdefn r
WHERE r.recname = f.recname
and r.rectype != 3
and not exists(
 SELECT ''x''
 FROM psdbfield d
 WHERE d.fieldname = f.fieldname
 union all
 SELECT ''x''
 FROM psrecdefn r1
 WHERE r1.recname = f.fieldname
 and r1.rectype = 3)
order by row_num';
END;				
/

column recname        heading 'PeopleSoft|Record Name'  format a15
column fieldname      heading 'Field|Name'              format a18

@@psgenerichtml.sql
