/* This is the completed project of processing the data from a movie rental store using MySQL by Brian.
This project reveal the typical bank related case. This sript contains many steps and the function of them are
stated before each section of codes. The data used is from the AWS.*/

# explore data:
select * from base;
select * from call_record;
select * from change_record;
select * from decision;
select * from letter;
select count(*) from base;
select count(*) from call_record;
select count(*) from decision;
select count(*) from letter;
select count(*) from change_record;

select call_date, count(distinct acct_num) 
from call_record 
group by 1;

# decisions, whether approved or not:
select decision_status, count(*)
from decision group by 1;

select change_date, count(*) 
from change_record group by 1;

# check how many people called:
select c.call_date, count(distinct c.acct_num)
from call_record as c 
group by 1;

# Does each person called only once?
select c.call_date, count(c.acct_num), 
count(distinct c.acct_num)
from call_record as c
group by 1;

# Overall approval rate:
select 
sum(case when decision_status = 'AP' then 1 else 0 end) / count(acct_decision_id) as approval_rate
from decision;

# Overall decline rate:
select
sum(case when decision_status = 'DL' then 1 else 0 end) / count(acct_decision_id) as decline_rate
from decision;