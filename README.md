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
