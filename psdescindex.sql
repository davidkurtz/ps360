REM psdescindex.sql
DEF recname = 'ALL_IND_EXPRESSIONS'
@@pstimestamp.sql
DEF recdescr = 'Function-based descending indexes'
DEF descrlong = 'Descending indexes have been removed since PeopleTools 8.54, and in prior releases Oracle recommends setting _ignore_desc_in_index to prevent creating new ones.  This report lists any existing descending indexes that need to be rebuilt.'
REM https://docs.oracle.com/cd/E58500_01/pt854pbh1/eng/pt/tadm/task_ConvertingDescendingIndexes.html#topofpage

BEGIN
  :sql_text := '
SELECT row_number() over (order by ie.table_name, ie.index_name, ie.column_position) row_num
,      ie.table_name, ie.index_name, ie.column_position
,      ie.column_expression, ic.descend
,      ic.column_name, ic.column_length, ic.char_length
FROM   all_ind_columns ic
,      all_ind_expressions ie
WHERE  ic.table_owner = ie.table_owner
AND    ic.table_name = ie.table_name
AND    ic.index_owner = ie.index_owner
AND    ic.index_name = ie.index_name
AND    ic.column_position = ie.column_position
AND    ic.descend = ''DESC''
AND    ic.table_owner = ''&&ownerid''
AND    NOT ic.table_name like ''BIN$%''
ORDER BY row_num'; 
END;				
/

col DESCEND format a7

@@psgenerichtml.sql
