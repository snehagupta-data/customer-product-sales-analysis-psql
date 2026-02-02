/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/
create view gold.customer_report as
-- Report : gold.dim_customer
WITH base_query AS (

    SELECT 
        s.order_number,
        s.product_key,
        s.order_date,
        s.sales_amount,
        s.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        EXTRACT(YEAR FROM AGE(current_date, c.birthdate)) AS customer_age
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c 
        ON s.customer_key = c.customer_key
    WHERE s.order_date IS NOT NULL
),

customer_aggregation AS (
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        customer_age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity_purchased,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
  EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
+ EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) + 1
AS lifespan

    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        customer_age
)


select 
customer_key,
customer_number,
customer_name,
total_sales,
total_quantity_purchased,
total_products,
last_order_date,
(EXTRACT(YEAR FROM current_date) * 12 
        + EXTRACT(MONTH FROM current_date)) - (EXTRACT(YEAR FROM last_order_date) * 12 
        + EXTRACT(MONTH FROM last_order_date)) as recency,
		
case when customer_age<=19 then 'Adult'
	 when customer_age<=20 and customer_age>=35 then 'Adult'
	 when customer_age<=36 and customer_age>=50 then 'Middle Aged'
	 else 'Old Aged'
end as age_group,
case when lifespan>12 and total_sales>5000 then 'VIP'
	 when lifespan>12 and total_sales<=5000 then 'Regular'
	 else 'New'
end as customer_segmentation,
--coumpute average order value (AOV)
case when total_orders=0 then 0
	 else total_sales/total_orders 
end as AVO,
--Compute Average Monthly Spend
CASE 
    WHEN lifespan <= 0 THEN 0
    ELSE ROUND(total_sales::numeric / lifespan, 2)
END AS avg_monthly_spend
from customer_aggregation


