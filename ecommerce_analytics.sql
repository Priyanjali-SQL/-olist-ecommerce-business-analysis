-- =====================================================
-- OLIST E-COMMERCE SQL ANALYTICS PROJECT
-- Database: PostgreSQL
-- Tool: pgAdmin
-- Purpose: Analyze orders, revenue, payments,
-- products, customers, sellers, and customer reviews
-- =====================================================
--Create the customers table
create table public.cutomers(
 customer_id varchar (50),
 customer_unique_id varchar(50),
 customer_zip_code_prefix integer,
 customer_city varchar(100),
 customer_state varchar (10)
);
alter table public.cutomers rename to customers;
select count(*) from public.customers;
--Create the order table
create table public.order(
 order_id varchar(50),
 customer_id varchar(50),
 order_status varchar(30),
 order_purchase_timestamp timestamp,
 order_approved_at timestamp,
 order_delivered_carrier_date timestamp,
 order_delivered_customer_date timestamp,
 order_estimated_delivery_date timestamp
);
alter table public.order rename to orders;
select count(*) as total_orders from public.orders;
select order_status,count(*) as total_orders from public.orders
group by order_status
order by total_orders desc;
-- =====================================================
-- SECTION 1: CUSTOMER AND ORDER ANALYSIS
-- Business focus: Customer locations, order trends,
-- order status, cancellations, and delivery performance
-- =====================================================

--Previewing raw data from both tables
--View the first 5 row of the customers table
select * from public.customers limit 5;
--View the first 5 row of the orders table
select * from public.orders limit 5;
--Calculate total for each state
select c.customer_state,count (order_id) as total_orders 
from public.orders as o
join public.customers as c
on o.customer_id=c.customer_id
group by c.customer_state
order by total_orders desc;
--Customers are there in each state
select customer_state,count(distinct customer_unique_id) 
as total_customers
from public.customers
group by customer_state
order by total_customers desc;
--Top 5 cities have the highest num of canceled orders
select c.customer_city,count (o.order_id) as canceled_orders
from public.customers as c
join public.orders as o
 on o.customer_id=c.customer_id
where o.order_status='canceled'
group by c.customer_city
order by canceled_orders desc
limit 5;
--Clean average delivery time rounded to 1 decimal place
select c.customer_state, 
 Round( 
 avg(
     extract(epoch from (o.order_delivered_customer_date
 -o.order_purchase_timestamp))/86400)::numeric,1)
 as avg_delivery_days
 from public.orders as o
 join public.customers as c
  on o.customer_id=c.customer_id
 where o.order_status='delivered'
  and o.order_delivered_customer_date is not null
 group by c.customer_state
 order by avg_delivery_days desc;
 --Count the total number of delivered order in each customer state
 select
 c.customer_state, count(*) as total_delivered_orders
 from public.orders as o
 join public.customers as c
  on o.customer_id=c.customer_id
 where o.order_status='delivered'
 group by c.customer_state
 order by total_delivered_orders desc;
 --Count the total number of orders placed each month
 select date_trunc('month',order_purchase_timestamp) as order_month,
 count(*) as total_orders
 from public.orders
 group by order_month
 order by order_month asc;
 -- Count delivered and canceled orders by month
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS order_month,
    COUNT(CASE WHEN order_status = 'delivered' THEN 1 END) AS delivered_orders,
    COUNT(CASE WHEN order_status = 'canceled' THEN 1 END) AS canceled_orders
FROM public.orders
GROUP BY order_month
ORDER BY order_month;
 --Calculate the monthly cancellation rate as a percentage
select date_trunc('month',order_purchase_timestamp) as order_month,
count (*) as total_orders,
count(case when order_status='canceled' then 1 end) as canceled_orders,
round (
count (case when order_status='canceled' then 1 end)*100.0/count(*),2)
as cancellation_rate_percent from public.orders
group by order_month
order by order_month asc;
--Calculate the orders and percentage for each order status
select order_status, count(*) as total_orders,
round(
 count(*)*100.0/(select count(*) from public.orders),2
) as status_percentage
from public.orders
group by order_status
order by total_orders desc;
-- =====================================================
-- SECTION 2: ORDER ITEMS AND REVENUE ANALYSIS
-- Business focus: Items per order, product revenue,
-- monthly revenue trends, and revenue growth
-- =====================================================
--Create the order_items table
create table public.order_items(
 order_id varchar(50),
 order_item_id integer,
 product_id varchar (50),
 seller_id varchar(50),
 shipping_limit_date timestamp,
 price numeric(10,2),
 freight_value numeric(10,2)
);
--Orders are recorded in the dataset
select count(*) as total_order_items
from public.order_items;
--Average price of an individual order item
select round(avg(price),2) as average_item_price
from public.order_items;
--Order generate the highest revenue
select order_id, count(*) as total_items, round(sum(price),2)
as order_revenue
from public.order_items
group by order_id
order by order_revenue desc
limit 10;
--Orders contain each number of items
with order_sizes as (
select order_id ,count(*) as total_items
from public.order_items
group by order_id
)
select total_items,
count(*) as number_of_orders
from order_sizes
group by total_items
order by total_items;
--Percentage of all orders contain each number of item
--This helps compare order_size pattern proportionally
with order_sizes as (
select order_id,count(*) as total_items
from public.order_items
group by order_id
)
select total_items,count(*) as number_of_orders,
round(
100.0*count(*)/sum(count(*)) over(),2
) as percentage_of_orders
from order_sizes
group by total_items
order by number_of_orders desc;
--Average number of maximum number of items in each orders
select count(*) as total_order,round(avg(total_items),2) 
 as average_items_per_orders,
 Max(total_items) as max_items_in_order
 from(
select order_id, count(*) as total_items
from public.order_items
group by order_id
) as order_sizes;

--Total product revenue in the dataset
--Use product price only:exclude freight charges
select round(sum(price)::numeric,2) as total_product_revenue
from public.order_items;

--Monthly delivered product sales value and order volume
select
Date_Trunc('month',o.order_purchase_timestamp)::date
 as order_month,
round(sum(oi.price)::numeric,2)
as monthly_product_revenue,
count(distinct o.order_id)
as total_orders
from public.orders as o
join public.order_items as oi
on o.order_id=oi.order_id
where o.order_status='delivered'
and o.order_purchase_timestamp is not null
group by date_trunc('month',o.order_purchase_timestamp)
order by order_month;
--Monthly revenue change from the previous month
with monthly_revenue as (
select date_trunc('month',o.order_purchase_timestamp):: 
date as order_month,
sum(oi.price) as monthly_revenue
from public.orders o
join public.order_items oi
on o.order_id=oi.order_id
where o.order_status='delivered'
and o.order_purchase_timestamp is not null
group by 1
)
select current_month.order_month,
round(current_month.monthly_revenue::numeric,2)
as monthly_revenue,
round(previous_month.monthly_revenue::numeric,2)
as previous_month_revenue,
round (
 (
   (current_month.monthly_revenue-previous_month.monthly_revenue)
/nullif(previous_month.monthly_revenue,0)*100
 )::numeric,
 2
)as revenue_growth_percentage
from monthly_revenue current_month
left join monthly_revenue previous_month
on current_month.order_month=(previous_month.order_month+interval'1month')
::date
order by  current_month.order_month;
-- =====================================================
-- SECTION 3: PAYMENT ANALYSIS
-- Business focus: Payment methods, payment value,
-- installment patterns, and average order payment
-- =====================================================
--Create the order payments table
create table public.order_payments(
 order_id varchar(50),
 payment_sequential integer,
 payment_type varchar(50),
 payment_instalment integer,
 payment_value numeric(12,2)
 );
 --Number of payment records imported
 select count(*) as total_payment_records
 from public.order_payments;
-- Distribution of Payment Records by Payment Method
 select payment_type, count(*) as total_payments
 from public.order_payments
 group by payment_type
 order  by total_payments desc;
 -- Total Payment Value by Payment Method
 select payment_type ,
   round(sum(payment_value),2)
as total_payment_value
from public.order_payments
group by payment_type
order by total_payment_value desc;
-- Distribution of Credit Card Payment Records by Installment Count
select
 payment_instalment,count(*) as total_payment_records
 from public.order_payments
 where payment_type='credit_card'
 group by payment_instalment
 order by total_payment_records desc;
 -- Calculate the Average Total Payment Value per Order
 select round(avg(order_payment_total),2) as average_payment_per_order
 from (
select order_id,sum(payment_value) as order_payment_total
from public.order_payments
group by order_id
 ) as order_totals;
-- Calculate the Average Payment Record Value by Payment Method
select 
payment_type,
round(avg(payment_value),2) as average_payment_value
from public.order_payments
group by payment_type
order by average_payment_value;
-- Analyze Delivered Product Sales Value by Customer State
select
c.customer_state,
round(sum(oi.price)::numeric,2) as total_product_sales
from public.customers as c
join public.orders as o
 on c.customer_id=o.customer_id
join public.order_items as oi
 on o.order_id=oi.order_id
 where o.order_status='delivered'
group by c.customer_state
order by total_product_sales desc;
-- =====================================================
-- SECTION 4: PRODUCT CATEGORY ANALYSIS
-- Business focus: Top revenue categories, items sold,
-- average product prices, and freight costs
-- =====================================================
--Create the product table
create table public.products(
 product_id varchar(50),
 product_category_name varchar(100),
 product_name_length integer,
 product_description_lenght integer,
 product_photos_qty integer,
 product_weight_g integer,
 product_length_cm integer,
 product_width_cm integer
);
alter table public.products add column product_height_cm integer;
select count(*) as total_products from public.products;
-- Identify product categories with the highest delivered product sales value
SELECT
    COALESCE(p.product_category_name, 'unknown') AS product_category,
    ROUND(SUM(oi.price)::numeric, 2) AS delivered_product_sales
FROM public.order_items AS oi
JOIN public.orders AS o
    ON oi.order_id = o.order_id
LEFT JOIN public.products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY COALESCE(p.product_category_name, 'unknown')
ORDER BY delivered_product_sales DESC
LIMIT 10;
-- =====================================================
--Business Question :
-- What is the average selling price of products
-- across different product categories?
--
-- Business Purpose:
-- To compare the average selling price across product
-- categories and identify high-value product categories.
-- ====================================================

SELECT
    COALESCE(p.product_category_name, 'unknown') AS product_category,
    COUNT(*) AS total_items_sold,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM public.order_items AS oi
LEFT JOIN public.products AS p
    ON oi.product_id = p.product_id
GROUP BY
    COALESCE(p.product_category_name, 'unknown')
ORDER BY average_item_price DESC;
-- Analyze the Average Freight Cost by Product Category
 select
 coalesce (p.product_category_name,'unknown') as product_category,
 round(avg(oi.freight_value)::numeric,2) as average_freight_cost
 from public.order_items as oi
 left join public.products as p
  on oi.product_id=p.product_id
  group by coalesce(p.product_category_name,'unknown')
  order by average_freight_cost desc;
 -- Analyze the total Freight Cost by Product Category
  select
 coalesce (p.product_category_name,'unknown') as product_category,
 round(sum(oi.freight_value)::numeric,2) as total_freight_cost
 from public.order_items as oi
 left join public.products as p
  on oi.product_id=p.product_id
  group by coalesce(p.product_category_name,'unknown')
 order by total_freight_cost desc;
  -- =====================================================
-- SECTION 5: CUSTOMER REVIEW ANALYSIS
-- Business focus: Review scores, customer satisfaction,
-- negative reviews, and delivery experience
-- =====================================================
 --Create the order reviews table
 create table public.order_reviews(
review_id varchar(50),
order_id varchar(50),
review_score integer,
review_comment_title text,
review_creation_date timestamp,
review_answer_timestamp timestamp
 );
alter table public.order_reviews
add column review_comment_message text;
alter table public.order_reviews
 alter column review_id type varchar(100),
 alter column order_id type varchar(100);
 --Create a temporary table with column in the csv's exact order
create table public.order_reviews_import(
 review_id varchar(100),
 order_id varchar(100),
 review_score integer,
 review_comment_title text,
 review_comment_message text,
 review_creation_date timestamp,
 review_answer_timestamp timestamp
 );
--Copy review data into the final table using matching column names
insert into public.order_reviews(
 review_id,
 order_id,
 review_score,
 review_comment_title,
 review_creation_date,
 review_answer_timestamp,
 review_comment_message
 )
 select 
  review_id,
  order_id,
  review_score,
  review_comment_title,
  review_creation_date,
  review_answer_timestamp,
  review_comment_message
from public.order_reviews_import;
select count(*) as total_reviews from public.order_reviews; 
--Reviews were received for each review score
select 
review_score,count(*) as total_reviews
from public.order_reviews
group by review_score
order by total_reviews desc;
--Calculate the overall average customer review score
select round(avg(review_score),2) as average_review_score
from public.order_reviews;
--Average review scores across order status
select o.order_status,count(r.review_id) as total_reviews,
round(avg(r.review_score),2) as average_review_score
from public.orders as o
join public.order_reviews as r
  on o.order_id=r.order_id
group by o.order_status
order by average_review_score desc;
--Calculate  the percentage of negative review(1-and 2-star ratings)
select 
count(*) filter (
 where review_score in(1,2)
) as negative_reviews,
count(*) as total_reviews, 
round(
100.0*count(*) filter(
  where review_score in (1,2)
)/ count(*),2
) as negative_review_percentage
from public.order_reviews;
--Create the sellers table
-- =====================================================
-- SECTION 6: SELLER ANALYSIS
-- Business focus: Seller locations, revenue,
-- order volume, and customer review performance
-- =====================================================
create table public.sellers(
 seller_id varchar(50),
 seller_zip_code_prefix varchar(10),
 seller_city varchar(100),
 seller_state varchar (2)
 );
select count(*) total_sellers from public.sellers; 
--States with the highest number of sellers
select seller_state,
 count(*) as total_sellers
from public.sellers
group by seller_state
order by total_sellers desc;
-- Which sellers generate the highest delivered product sales value?

SELECT
    s.seller_id,
    s.seller_state,
    ROUND(SUM(oi.price)::numeric, 2) AS delivered_product_sales
FROM public.sellers AS s
JOIN public.order_items AS oi
    ON s.seller_id = oi.seller_id
JOIN public.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    s.seller_id,
    s.seller_state
ORDER BY delivered_product_sales DESC;
  --Sellers by number of unique orders
 select 
  oi.seller_id,
  s.seller_state,
  count(distinct oi.order_id) as total_orders
 from public.order_items as oi
 join public.sellers as s
    on oi.seller_id=s.seller_id
 group by
   oi.seller_id,
   s.seller_state
 order by total_orders desc;
-- Identify sellers with the lowest average customer review scores
-- Count each seller-order combination only once to avoid duplicate reviews
-- Consider only sellers with at least 20 reviews

WITH seller_orders AS (
    SELECT DISTINCT
        seller_id,
        order_id
    FROM public.order_items
)

SELECT
    so.seller_id,
    s.seller_state,
    COUNT(DISTINCT r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM seller_orders AS so
JOIN public.sellers AS s
    ON so.seller_id = s.seller_id
JOIN public.order_reviews AS r
    ON so.order_id = r.order_id
WHERE r.review_score IS NOT NULL
GROUP BY
    so.seller_id,
    s.seller_state
HAVING COUNT(DISTINCT r.review_id) >= 20
ORDER BY average_review_score ASC;
--Count delivered orders that also have a valid customer review
select count(*) as matched_review_rows
from public.orders as o
join public.order_reviews as r
   on o.order_id=r.order_id
where
   order_status='delivered'
 and o.order_delivered_customer_date is not null
 and o.order_estimated_delivery_date is not null
 and r.review_score is not null;
--Compare customer review scores for on-time and late deliveries
--Included only delivered orders with availblen dates and review scores
with order_delivery as(
select
o.order_id,
 case
   when o.order_delivered_customer_date
	<=o.order_estimated_delivery_date
   Then 'On Time'
   Else 'Late'
 End as delivery_status
from public.orders as o
where o.order_status='delivered'
  and o.order_delivered_customer_date is not null
  and o.order_estimated_delivery_date is not null
  ),
 order_review as(
--Calculate one average review score per order
select 
 order_id,
 avg(review_score) as average_review_score
from public.order_reviews
where review_score is not null
group by order_id
)
select
  od.delivery_status,
  count(*) as total_orders,
  round(avg(orv.average_review_score),2)
   as average_review_score
from order_delivery as od
join order_review as orv
  on od.order_id=orv.order_id
group by od.delivery_status
order by average_review_score desc;
--create the product category name  translation table
create table public.product_category_name_translation(
  product_category_name varchar(100) primary key,
  product_category_name_english varchar(100)
);
select count(*) as total_rows
from public.product_category_name_translation;
--Create the geolocation table
create table public.geolocation(
 geolocation_zip_code_prefix integer,
 geolocation_lat double precision,
 geolocation_lng double precision,
 geolocation_city varchar(100),
 geolocation_state varchar(2)
 );
 select count(*) as total_rows,
 count (distinct( geolocation_zip_code_prefix,
 geolocation_lat,
 geolocation_lng,
 geolocation_city,
 geolocation_state
 )) as unique_rows
  from public.geolocation;
  --Check the range of zip-code perfixes in geolocation
  select
   min(geolocation_zip_code_prefix) as min_zip_code,
   max(geolocation_zip_code_prefix)  as max_zip_code,
   count(distinct geolocation_zip_code_prefix) as unique_zip_codes
  from public.geolocation;
-- Find the most frequently repeated exact geolocation records.
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS repeat_count
FROM public.geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
HAVING COUNT(*) > 1
ORDER BY repeat_count DESC
LIMIT 10;
 
 
 


 
 
 
 
 







 






 








