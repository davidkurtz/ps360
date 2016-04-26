REM ps_0config.sql

-- working hours are defined between these two HH24MM values (i.e. 7:30AM and 7:30PM)
DEF ps360_conf_work_time_from = '0730';
DEF ps360_conf_work_time_to = '1930';

-- working days are defined between 1 (Sunday) and 7 (Saturday) (default Mon-Fri)
DEF ps360_conf_work_day_from = '2';
DEF ps360_conf_work_day_to = '6';

-- minimum size of pie segment in percent
-- see https://developers.google.com/chart/interactive/docs/gallery/piechart#slice-visibility-threshold
DEF ps_360_PieSliceVisThreshold = '.02';

--
DEF datetimefmt='dd.mm.yyyy hh24:mi:ss';
DEF datefmt='dd.mm.yyyy';

ALTER SESSION SET NLS_DATE_FORMAT='&&datetimefmt';