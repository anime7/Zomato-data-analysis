![png-transparent-zomato-hd-logo](https://github.com/user-attachments/assets/1a254d46-03c8-4f5f-a4d4-c74095c79b8e)

##Overview

This Zomato data analysis project leverages SQL to extract actionable insights from the restaurant dataset. We delve into restaurant ratings, cuisines, and location data to identify high-performing restaurants, understand customer preferences, and highlight opportunities for Zomato to improve its services and recommendations. The project details the SQL queries used to generate the insights and the conclusions drawn.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Objectives
* Unveiling Zomato's Culinary Landscape
* Optimizing Zomato's Operations
* Customer Loyalty Insights
* Restaurant Performance Benchmarking
* Predictive Trends in Demand
* Driving Revenue and Growth
---------------------------------------------------------------------------------------------------------------------------

Schema::

-- Zomato Data Analysis using SQL
```sql
drop table if exists deliveries;
drop table if exists customers;
drop table if exists restaurants;
drop table if exists riders;
drop table if exists orders;



create table customers
(
    customer_id INT primary key,
    customer_name varchar(25),
    reg_date date
);

create table restaurants
(
   restaurant_id INT primary key,	
   restaurant_name	varchar(55),
   city	varchar(25),
   opening_hours varchar(55)
);

create table orders
(

   order_id	int primary key,
   customer_id	int ,--coming from customers table 
   restaurantk_id int ,--coming from restaurants table	
   order_item	varchar(55),
   order_date	date,
   order_time	time,
   order_status	varchar(35),
   total_amount float
);

create table riders
(
    rider_id int primary key,
	rider_name varchar(55),
	sign_up  date
);

create table deliveries
(
     delivery_id int primary key,
	 order_id int, -- coming from orders table
	 delivery_status varchar(55),
	 delivery_time time ,
	 rider_id int ,
	 constraint fk_riders foreign key (rider_id) references riders(rider_id),
	 constraint fk_orders foreign key (order_id) references orders(order_id)
);

-- adding FK constraint
alter table orders
add constraint fk_customers
foreign key (customer_id)
references customers(customer_id);

alter table orders
add constraint fk_restaurant
foreign key(restaurant_id )
references restaurants(restaurant_id);

--end of schemas
```
## Business Problems and Solutions
###Q1. Top 5 Most Frequently Ordered Dishes
Question:
Write a query to find the top 5 most frequently ordered dishes by the customer "Arjun Mehta" in
the last 1 year.

```sql
       select t1.customer_name,
       t1.dishes,
       t1.total_orders
	   
from 
	(select c.customer_id,
	      c.customer_name,
		  o.order_item as dishes,
		  count(*) as total_orders,
		  dense_rank()over(order by count(*) desc) as rank 
	from orders as o
	join
	customers as c
	on c.customer_id=o.customer_id
	where 
	c.customer_name ='Arjun Mehta'
	and 
	o.order_date>=to_date('2024-09-02','yyyy-mm-dd') - interval '1 year'
	group by 1,2,3
	order by 1,4 desc) as t1 
where rank<=5
```

###Q2. Popular Time Slots
--Question:
--Identify the time slots during which the most orders are placed, based on 2-hour intervals.

```sql
--type 1-------------------------------------------------------------------------------------------------
select 
       count(order_id) as order_count,
       case
	      when extract(hour from order_time ) between 0 and 1 then '0-2'
		  when extract(hour from order_time)  between 2 and 3 then '2-4'
          when extract(hour from order_time)  between 4 and 5 then '4-6'
		  when extract(hour from order_time)  between 6 and 7 then '6-8'
		  when extract(hour from order_time)  between 8 and 9 then '8-10'
		  when extract(hour from order_time)  between 10 and 11 then '10-12'
		  when extract(hour from order_time)  between 12 and 13 then '12-14'
		  when extract(hour from order_time)  between 14 and 15 then '14-16'
		  when extract(hour from order_time)  between 16 and 17 then '16-18'
		  when extract(hour from order_time)  between 18 and 19 then '18-20'
		  when extract(hour from order_time)  between 20 and 21 then '20-22'
		  when extract(hour from order_time)  between 22 and 23 then '22-24'
	  end  time_slots
from orders
group by time_slots
order by order_count desc;

--type 2-------------------------------------------------------------------------------------------


select 
     floor(extract(hour from order_time)/2)*2 as st,
	 floor(extract(hour from order_time)/2)*2+2 as et,
	 count(*) as total_orders
from orders
group by 1,2 
order by 3 desc;
```
###Q3. Order Value Analysis
--Question:
--Find the average order value (AOV) per customer who has placed more than 750 orders.Return: customer_name, aov (average order value).

```sql
select customer_name , aov 
from
   (select customer_name, count(*) as total_order,avg(total_amount) as aov from customers as c 
	join 
	orders as o
	on
	c.customer_id=o.customer_id
	group by customer_name 
	order by 2 desc
	)
	where total_order>=750

```






###Q4. High-Value Customers
--Question:
--List the customers who have spent more than 100K in total on food orders.Return: customer_name, customer_id.

```sql
   select customer_name ,c.customer_id,sum(total_amount) as spent from customers as c 
	JOIN
	orders as o
	on
	c.customer_id=o.customer_id
	group by 1,2
    having sum(total_amount)>100000
```
###Q5. Orders Without Delivery
--Question:
--Write a query to find orders that were placed but not delivered.Return: restaurant_name, city, and the number of not delivered orders.
```sql

select restaurant_name,city ,count(o.order_id) as not_delivered
from orders as o 
left join
restaurants as r on o.restaurant_id=r.restaurant_id
left join deliveries as d on o.order_id=d.order_id
where d.delivery_id is null
group by 1,2
order by 3 desc
```

###Q6. Restaurant Revenue Ranking
--Question:
--Rank restaurants by their total revenue from the last year.Return: restaurant_name, total_revenue, and their rank within their city.
```sql
with ranktable as 
(
select r.restaurant_name,
       r.city,
	   sum(o.total_amount) as total_revenue ,
       rank()over(partition by r.city order by sum(o.total_amount) desc ) as rank
from restaurants as r
join 
orders as o
on r.restaurant_id=o.restaurant_id
where o.order_date>= current_date - interval '1 year 1 month'
group by 1,2
)
select *
from ranktable
where rank=1
```
###Q7. Most Popular Dish by City
--Question:
--Identify the most popular dish in each city based on the number of orders.
```sql
with temptable as
(
select r.city,o.order_item as dish ,
       count(order_id)as total_orders,
	   rank()over(partition by r.city order by count(order_id) desc )as ranking
from orders as o
     join
restaurants as r
on o.restaurant_id=r.restaurant_id
group by 1,2
)
select *
from temptable
where ranking=1
```
###Q8. Customer Churn
--Question:
--Find customers who haven’t placed an order in 2024 but did in 2023.
```sql
select distinct customer_id 
from orders
where extract(year from order_date )=2023
 and 
 customer_id not in
                  (select distinct customer_id  
				  from orders 
				  where extract(year from order_date)=2024)





```
###Q9. Cancellation Rate Comparison
--Question:
--Calculate and compare the order cancellation rate for each restaurant between the current year and the previous year.

```sql
with table24 as
(
SELECT restaurant_id,
      count(case  when d.order_id is null  then 1 else null  end) as cancel_oder_id,
      count(o.order_id) as total_order_id,
	  round((count(case  when d.order_id is null  then 1 else null  end)*100.0/count(o.order_id)),2)  as order_Cancel_rate_24
FROM orders AS o
left join
deliveries AS d
ON o.order_id=d.order_id
WHERE EXTRACT(YEAR FROM order_date)=2024
group by o.restaurant_id
),

table23 as
(
SELECT restaurant_id,
      count(case  when d.order_id is null  then 1 else null  end) as cancel_oder_id,
      count(o.order_id) as total_order_id,
	  round((count(case  when d.order_id is null  then 1 else null  end)*100.0/count(o.order_id)),2)  as order_Cancel_rate_23
FROM orders AS o
left join
deliveries AS d
ON o.order_id=d.order_id
WHERE EXTRACT(YEAR FROM order_date)=2023
group by o.restaurant_id
)

select 	 
    t2.restaurant_id,
    t2.order_Cancel_rate_23,
	t1.order_Cancel_rate_24 
from 
      table24 as t1
 right join 
      table23 as t2
on t1.restaurant_id=t2.restaurant_id


```


###Q10. Rider Average Delivery Time
--Question:
--Determine each rider's average delivery time.
```sql

select 
        o.order_id,
		d.rider_id,
       o.order_time,
	   d.delivery_time,
	   extract(epoch from (d.delivery_time-o.order_time + 
	   case 
	       when d.delivery_time<o.order_time 
		        then interval '1 day' 
				else interval '0 day' 
				end ))/60 as  avg_deliverytime_in_sec
	   
from orders as o
join
deliveries as d 
on
o.order_id=d.order_id 
where delivery_status='Delivered'




```

###Q11. Monthly Restaurant Growth Ratio
--Question:
--Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining.

```sql
with growth_table
as 
(
select 
       o.restaurant_id,
       to_char(o.order_date,'mm-yy') as month_year,
       lag( count(o.order_id),1)over(partition by o.restaurant_id order by to_char(o.order_date,'mm-yy')) as prev_order,
	   count(o.order_id) as current_order
from 
orders as o
join 
deliveries as d 
on o.order_id=d.order_id
where delivery_status='Delivered'
group by 1,2
order by 1,2
)
select 
      restaurant_id, 
	  month_year, 
	  prev_order, 
	  current_order,
	  round(((current_order::numeric-prev_order::numeric)/prev_order::numeric *100) ,2) as growth_rate
from
    growth_table 


```



###Q12. Customer Segmentation
--Question:
--Segment customers into 'Gold' or 'Silver' groups based on their total spending compared to the average order value (AOV). 
--If a customer's total spending exceeds the AOV, label them as
--'Gold'; otherwise, label them as 'Silver'.
--Return: The total number of orders and total revenue for each segment.
```sql
select cs_category,
       sum(total_spend) as total_reveue ,
	   sum(tot_order) as total_order
from
(
select customer_id,
       sum(total_amount) as total_spend,
	   count(order_id)as tot_order,
	   case
	        when sum(total_amount) > (select avg(total_amount) from orders)
			then 'Gold'
			else 'Silver'
	   end as cs_category
from orders
group by 1
) as t1
group by 1


--select avg(total_amount) from orders--322.82

```





###Q13. Rider Monthly Earnings
--Question:
--Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.
```sql
with  t1
as
(
SELECT  
        d.rider_id,
       to_char(o.order_date,'mm-yy') as month,
	   total_amount::numeric*(.08) as per_order
from orders as o 
join deliveries as d 
on o.order_id=d.order_id
--where delivery_status='Delivered'
--group by month , rider_id
order by rider_id,2 

)
select rider_id,
       month,
	   sum(per_order)as montly_earnings
from t1
group by month , rider_id
 ```

###Q14. Rider Ratings Analysis
--Question:
--Find the number of 5-star, 4-star, and 3-star ratings each rider has. Riders receive ratings based on delivery time:
--● 5-star: Delivered in less than 15 minutes
--● 4-star: Delivered between 15 and 20 minutes
--● 3-star: Delivered after 20 minutes
```sql
select 
	   rider_id,
       case
	       when sec<15 then '5-star'
		   when sec between 15 and 20 then '4-star'
		   else '3-star'
	   end as ratings,
       count(order_id)
  from (
select  o.order_id,
        o.order_time,
		d.delivery_time,
        extract(epoch from (d.delivery_time-o.order_time+
		case
		     when  d.delivery_time < o.order_time  then  interval '1 day'
             else interval'0 day'
		end
        ))/60 as sec,
		
		d.rider_id
from orders as o 
join
   deliveries as d
on o.order_id=d.order_id
where delivery_status='Delivered'
order by rider_id
)
as t1
group by 2,1
order by 1
```




###Q15. Order Frequency by Day
--Question:
--Analyze order frequency per day of the week and identify the peak day for each restaurant.
```sql
select *from
(
select restaurant_name,
       to_char(order_date,'day') as day,
	   count(order_id) as order_freq,
	   rank()over(partition by restaurant_name order by count(order_id) desc )  as ranking
from orders as o
join 
 restaurants as r 
 on o.restaurant_id=r.restaurant_id
 group by 1,2
) as t2
where ranking =1



```


###Q16. Customer Lifetime Value (CLV)
--Question:
--Calculate the total revenue generated by each customer over all their orders.
 ```sql
 select c.customer_id,
        c.customer_name,
		count(o.order_id) as total_order,
		sum(o.total_amount) as clv
		
 from orders as o
 join
 customers as c
 on o.customer_id=c.customer_id
 group by 1,2




```
###Q17. Monthly Sales Trends
--Question:
--Identify sales trends by comparing each month's total sales to the previous month.
```sql
select 
       extract(year from order_date) as year,
	   extract(month from order_date) as month,
	   sum(total_amount) as curr_sale,
	   lag( sum(total_amount),1)over(partition by extract(year from order_date) order by extract(month from order_date)) as prev_sale
from orders 
group by 1,2
order by 1,2 

```
###Q18. Rider Efficiency
--Question:
--Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages.
 ```sql

with t1 as 
(
select 
        o.order_id,
		d.rider_id,
       o.order_time,
	   d.delivery_time,
	   extract(epoch from (d.delivery_time-o.order_time + 
	   case 
	       when d.delivery_time<o.order_time 
		        then interval '1 day' 
				else interval '0 day' 
				end ))/60 as  avg_deliverytime_in_sec
	   
from orders as o
join
deliveries as d 
on
o.order_id=d.order_id 
where delivery_status='Delivered'
),
rider_avg as 
(
	select rider_id,
	       avg(avg_deliverytime_in_sec) as avg
	from t1
	group by 1
	order by 1 
)

select
       max(avg),
	   min(avg)
	  from rider_avg

```  
###Q19. Order Item Popularity
--Question:
--Track the popularity of specific order items over time and identify seasonal demand spikes.
```sql

with t1 as (
select  *,
        extract(month from order_date) as month,
        case 
		    when extract(month from order_date) between 4 and 6 then 'spring'
			when extract(month from order_date) > 6 and extract(month from order_date) <9 then 'summer'
			else 'winter'
	  end as season
from orders
order by order_item
)
select order_item,
       season,
	   count(order_id) as total_orders
from t1
 group by 1,2 
 order by 1,3 desc
	   
```   





###Q20. City Revenue Ranking
--Question:
--Rank each city based on the total revenue for the last year (2023).
```sql
with t1 
as 
(
select *, 
       extract(year from order_date) as year
from orders as o
join 
  restaurants as r
on o.restaurant_id =r.restaurant_id
)
  select sum(total_amount) as total_revenue,
       city,
	   rank()over(order by sum(total_amount) desc ) as ranking
  from t1
 group by 2
 ```
-- END---
