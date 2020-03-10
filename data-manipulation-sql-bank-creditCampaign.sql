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

# check how many people called:
select call_date, count(distinct acct_num) 
from call_record 
group by 1;

# decisions, whether approved or not:
select decision_status, count(*)
from decision group by 1;

select change_date, count(*) 
from change_record group by 1;