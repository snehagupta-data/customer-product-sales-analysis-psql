/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
create view gold.product_report as 
-- Create Report: gold.report_products
with base_query as (
select 
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost,
s.order_number,
s.order_date,
s.sales_amount,
s.quantity,
s.price,
s.customer_key
from 
gold.fact_sales s left join
gold.dim_products p
on s.product_key=p.product_key
where order_date is not null
),

product_aggregation as (
select
product_key,
product_name,
category,
subcategory,
cost,
extract(year from age(max(order_date),min(order_date)))*12 +
extract(month from age(max(order_date),min(order_date))) +1
as lifespan,
max(order_date) as last_order_date,
count(distinct order_number) as total_orders,
count(distinct customer_key) as total_customers,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity
from
base_query
group by
product_key,
product_name,
category,
subcategory,
cost
)

--3) Final Query: Combines all product results into one output

select 
product_key,
product_name,
category,
subcategory,
cost,
last_order_date,
case when total_sales>50000 then 'High Perfomance'
	 when total_sales>=10000 then  'Mid Perfomance'
else 'Low Perfomace'
end as product_segmentation,
lifespan,
total_sales,
total_orders,
total_quantity
total_customers,

--Average Order Revenue (AOR)
case when total_orders=0 then 0
	 else total_sales/total_orders 
end as avg_order_revenue,

--Average Monthly Revenue
case when lifespan=0 then 0
	   else total_sales/lifespan
end as avg_monthly_revenue

from product_aggregation










