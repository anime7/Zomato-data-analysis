-- Zomato Data Analysis using SQL
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








