REM pstreeselectnnorphan.sql
DEF recname = 'PSTREESELECTnn'
@@psrecdefn
DEF lrecname = 'pstreeselectnn_orphan'
DEF recdescr = 'Orphaned tree selctors'
DEF descrlong = 'Dynamic/Oprhaned Tree Selectors where no parent row exists on PSTREESELCTL'

DECLARE
  l_sqlc CLOB;
BEGIN
  DELETE FROM plan_table
  WHERE  statement_id = 'PSTREESELECTORPHAN';

  FOR i IN (
    SELECT table_name, TO_NUMBER(SUBSTR(table_name,-2)) length
    FROM   user_tables
    where table_name LIKE 'PSTREESELECT__'
    ORDER BY 1
  ) LOOP
    l_sqlc := 'INSERT INTO plan_table (statement_id, object_name, id, cost) 
               SELECT ''PSTREESELECTORPHAN'', :1, selector_num, count(*)
               FROM pstreeselect01
               WHERE selector_num NOT IN (SELECT selector_num FROM pstreeselctl WHERE length = :2)
               GROUP BY selector_num';
    EXECUTE IMMEDIATE l_sqlc USING i.table_name, i.length;
  END LOOP;

  :sql_text := '
SELECT row_number() over (order by object_name, id) row_num
, t.object_name PSTREESELECTOR
, t.id SELECTOR_NUM
, t.cost NUM_ROWS
  FROM plan_table t
ORDER BY row_num
'; 
END;				
/

@@psgenerichtml.sql
