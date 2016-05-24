REM psmsgnodedefn.sql
DEF recname = 'PSMSGNODEDEFN'
@@psrecdefn

BEGIN
  :sql_text := '
SELECT row_number() over (order by MSGNODENAME) row_num
, t.*
FROM &&table_name t
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
