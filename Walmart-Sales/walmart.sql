select 	count (*)
from 	walmart;

select 	* 
from 	walmart;

-- Business Problems
-- 1. Find different payment method and number of transactions, number of qty sold

select
			payment_method,
			count(invoice_id) as total_transactions,
			sum(quantity) as total_qty_sold
from 		walmart
group by 	1
;

-- 2. Identify the highest-rated category in each branch, displaying the branch, category, and avg rating

select * 
from (
	select 
				branch,
				category,
				avg(rating) as avg_rating,
				rank() over(partition by branch order by avg(rating)desc) as rank
	from 		walmart
	group by 	1,2
	order by 	1 asc
) 
where 		rank = 1
;

-- 3. Identify the busiest day for each branch based on the number of transactions

select *
from (
	select
				branch,
				to_char(to_date(date,'DD/MM/YY'), 'Day') as day_name,
				count(invoice_id) as total_trx,
				rank () over(partition by branch order by count(*) desc) as rank
	from 		walmart
	group by 	1, 2
	order by 	1, 3 desc
) 
where 			rank = 1
;

-- 4. calculate total qty of items sold per payment method
select 
			payment_method,
			count(*)
from 		walmart
group by 	1
;

-- 5. determine the avg, minimum, and max rating of category for each city

select 
			city,
			category,
			avg(rating) as avg_rating,
			min(rating) as min_rating,
			max(rating) as max_rating
from  		walmart
group by 	1,2
;

-- 6. calculate total profit for each category (unit_price * qty * profit margin)

select
			category,
			sum(total_price) as revenue,
			sum(total_price * profit_margin) as profit
from 		walmart
group by 	1
order by 	2 desc
;

-- 7. determine the most common payment method for each branch

with cte
as (
	select 
				branch,
				payment_method,
				count(*) as total_trx,
				rank() over(partition by branch order by count(*)desc)
	from 		walmart
	group by 	1,2
) 
select * 
from  cte
where rank = 1
;

-- 8. categorize sales into 3 groups morning, afternoon, evening
-- find out each of the shift and number of invoices 

select 
	branch,
	case
			when extract(hour from(time::time)) < 12 then 'Morning'
			when extract(hour from(time::time)) between 12 and 17 then 'Afternoon'
			else 'evening'
	end 	day_time,
			count(*) as total_invoices
from 		walmart
group by 	1,2
order by 	1,3 desc
;

-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

select 	
		*,
		extract(year from to_date(date, 'DD/MM/YY')) as formatted_date
from 	walmart

-- 2022 Sales
with 
revenue_2022 
as(
	select
				branch,
				sum(total_price) as revenue
	from 		walmart
	where extract(year from to_date(date,'DD/MM/YY')) = 2022
	group by 	1
),
-- 2023 Sales
revenue_2023 
as(
	select
				branch,
				sum(total_price) as revenue
	from 		walmart
	where extract(year from to_date(date,'DD/MM/YY')) = 2023
	group by 	1
)
select 
		ls.branch,
		ls.revenue as last_year_revenue,
		cs.revenue as cr_year_revenue,
		round ((ls.revenue - cs.revenue)::numeric/
				ls.revenue::numeric * 100, 2) as rev_dec_ratio
from 		revenue_2022 as ls
join 		revenue_2023 as cs
on 			ls.branch = cs.branch
where		ls.revenue > cs.revenue
order by 	4 desc
limit		5


