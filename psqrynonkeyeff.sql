REM psqrynonkeyeff.sql
DEF recname = 'PSQRYCRITERIA'
@@psrecdefn
DEF recdescr = '&&recdescr. Effective date/sequence criteria on non-key columns'
DEF descrlong = 'PS/Query automatically adds date/sequence criteria on non-key columns.  It is likely that these are unnecessary.'
DEF report_abstract_2 = "<br>See <a target=''_blank'' href=''http://blog.psftdba.com/2010/01/performance-metrics-and-xml-reporting.html''>http://blog.psftdba.com/2010/01/performance-metrics-and-xml-reporting.html</a>";
REM see http://blog.psftdba.com/2010/01/performance-metrics-and-xml-reporting.html

BEGIN
  :sql_text := '
SELECT  row_number() over (order by c.oprid, c.qryname, f.fieldname) row_num
,       c.oprid, c.qryname, r.selnum, r.recname, r.corrname, f.fieldname 
FROM    psqrycriteria c /*query crieria*/
,       psqryrecord r   /*records in queries*/
,       psqryfield f    /*fields in a queries*/
,       psrecfielddb d  /*fields on records, with sub-records fully expanded*/
WHERE   c.condtype BETWEEN 20 AND 25 /*effdt criteria, so no need to specify column name*/
AND     c.lcrtfldnum = f.fldnum 
AND     r.oprid = c.oprid 
AND     r.qryname = c.qryname 
AND     r.selnum = c.selnum 
AND     f.oprid = c.oprid 
AND     f.qryname = c.qryname 
AND     f.selnum = c.selnum 
AND     f.oprid = r.oprid 
AND     f.qryname = r.qryname 
AND     f.selnum = r.selnum 
AND     f.recname = r.recname 
AND     d.recname = f.recname 
AND     d.fieldname = f.fieldname 
AND     BITAND(d.useedit,1) = 0 /*a non-key field*/ 
ORDER BY row_num'; 
END;				
/

column oprid     heading 'Operator ID'
column qryanme   heading 'Query|Name'
column recname   heading 'Record|name'
column corrname  heading 'Correlation|Name'
column fieldname heading 'Field|Name'

@@psgenerichtml.sql
