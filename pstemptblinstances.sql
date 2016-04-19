REM pstemptblinstances.sql
DEF recname = 'MESSAGE_LOG'
@@psrecdefn
DEF recdescr = '&&recdescr - Application Engine has run out of non-shared temporary table instances'
DEF descrlong = 'When an AE process cannot obtain a private instance of a temporary record it writes a message (108,544) to the message log. This query reports on the records/processes which required additional instances.'
REM see http://blog.psftdba.com/2009/02/do-you-need-more-temporary-table.html
REM see http://www.go-faster.co.uk/scripts/tr_moreinst.sql

BEGIN
  :sql_text := '
SELECT p.message_parm recname, r.prcsname
,      count(*) occurances
,      max(l.dttm_stamp_sec) last_occurance
,      max(p.process_instance) process_instance
from   ps_message_log l
,      ps_message_logparm p
         left outer join psprcsrqst r
         on r.prcsinstance = p.process_instance
where l.message_set_nbr = 108
and   l.message_nbr = 544
and   p.process_instance = l.process_instance
and   p.message_seq = l.message_seq
group by p.message_parm, r.prcsname
order by 1,2'; 
END;				
/

@@psgenerichtml.sql
