REM psdescindex.sql
DEF recname = 'USER_IND_EXPRESSIONS'
@@pstimestamp.sql
DEF table_name = '&&recname'
DEF lrecname = 'user_ind_expressions'
DEF recdescr = 'Function-based indexes'
DEF descrlong = 'Descending indexes have been removed since PeopleTools 8.54, and in prior releases Oracle recommends setting _ignore_desc_in_index to prevent creating new ones.  This report lists any existing descending indexes that need to be rebuilt.'
REM https://docs.oracle.com/cd/E58500_01/pt854pbh1/eng/pt/tadm/task_ConvertingDescendingIndexes.html#topofpage

BEGIN
  :sql_text := '
SELECT row_number() over (order by uie.table_name, uie.index_name, uie.column_position) row_num
,      uie.table_name, uie.index_name, uie.column_position
,      uie.column_expression
,      uic.column_name, uic.column_length, uic.char_length
FROM   user_ind_columns uic
,      user_ind_expressions uie
WHERE  uic.table_name = uie.table_name
AND    uic.indeX_name = uie.index_name
AND    uic.column_position = uie.column_position
AND    uic.descend = ''DESC''
ORDER BY row_num'; 
END;				
/

@@psgenerichtml.sql
