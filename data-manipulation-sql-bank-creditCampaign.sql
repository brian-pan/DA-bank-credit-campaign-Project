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

# check whether the credit limits for the customers have been changed correctly based on the offer_amount:
SELECT t.* from 
(select b.acct_num, b.credit_limit, b.offer_amount,
d.decision_status, c.credit_limit_after,
(b.credit_limit + b.offer_amount - credit_limit_after) as amount_of_mismatch
from
base as b left join decision as d 
on b.acct_num = d.acct_decision_id
left join change_record as c
on b.acct_num = c.account_number
where decision_status = 'AP') as t
WHERE amount_of_mismatch <> 0;

# Check the letters status:
-- Check the letters are successfully sent or not:
select t.* from
(select b.acct_num, d.decision_status, d.decision_date,
l.Letter_trigger_date, l.letter_code,
datediff(decision_date, Letter_trigger_date) as days_delayed
from
base as b left join decision as d
on d.acct_decision_id = b.acct_num
left join letter as l
on l.account_number = d.acct_decision_id
where decision_status is not null) as t
where days_delayed > 0;

-- Check the sent letters match the customers' language preferences or not, notice that
-- there are four types of letters (English approved/rejected, French approved/rejected): 
select * from
(select 
base.acct_num, base.offer_amount, 
d.acct_decision_id, d.decision_status,
l.language, l.letter_code,
case when decision_status = "AP" and language = "English" then "AE001"
	 when decision_status = "DL" and language = "English" then "AE002"
     when decision_status = "AP" and language = "French" then "RE001"
     when decision_status = "DL" and language = "French" then "RE002"
     end as letter_code_2
from 
base left join decision as d
on d.acct_decision_id = base.acct_num 
left join letter as l
on d.acct_decision_id = l.account_number
where decision_status is not null) as T
where letter_code_2 <> letter_code;

# Final monitoring report:
SELECT 
b.acct_num, b.credit_limit, b.offer_amount,
ch.credit_limit_after - ch.credit_limit_before as increased_amount,
ch.credit_limit_after,
d.decision_status, d.decision_date,
l.Letter_trigger_date, l.letter_code, l.language,
# incorrect credit limit given:
case when d.decision_status = "AP" and (b.credit_limit + b.offer_amount - ch.credit_limit_after) <> 0 then 'yes'
else 'no' end as wrong_amount,
# the letter is missing:
case when datediff(decision_date,Letter_trigger_date) > 0 then 'yes' else 'no' 
end as missing_letter,
# Sent wrong letter:
case when decision_status='DL' and language='French' and l.letter_code <> 'RE002' then 'yes'
	 when decision_status='AP' and language='French' and l.letter_code <> 'AE002' then 'yes'
     when decision_status='DL' and language='English' and l.letter_code <> 'RE001' then 'yes'
     when decision_status='AP' and language='English' and l.letter_code <> 'AE001' then 'yes'
     else 'no'
     end as sent_wrong_letter
from
base as b left join decision d
on b.acct_num = d.acct_decision_id
left join change_record as ch
on b.acct_num = ch.account_number
left join letter as l
on ch.account_number = l.account_number
where decision_status is not null;