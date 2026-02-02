--Q1. Change Over Time
select extract(year from order_date) as year,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customer,
sum(quantity) as total_customer
from gold.fact_sales where order_date is not null
group by extract(year from order_date)
order by extract(year from order_date) asc

--Q2. Calculate Total Sales for Each Month and Running Total of of Sales over Time

SELECT
    month_start,
    TO_CHAR(month_start, 'Mon YYYY') AS month_name,
    total_sales,
    SUM(total_sales) OVER (
        PARTITION BY EXTRACT(YEAR FROM month_start)
        ORDER BY month_start
    ) AS running_total,
	round(avg(avg_sales) OVER (
        PARTITION BY EXTRACT(YEAR FROM month_start)
        ORDER BY month_start
    ),2) AS moving_average
	
FROM (
    SELECT
        DATE_TRUNC('month', order_date) AS month_start,
        SUM(sales_amount) AS total_sales,
		avg(sales_amount) as avg_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
) t
ORDER BY month_start;

--Q3. Analyze the Yearly Perfomance of the Products by Comparing each Products sales with to both its average Perfomance
--and Previous Year Sales.

with yearly_product_sales as(
select extract(year from f.order_date) as order_year,
p.product_name as product_name,sum(f.sales_amount) as current_sales from 
gold.fact_sales f join gold.dim_products p
on f.product_key = p.product_key
where order_date is not null
group by extract(year from f.order_date),p.product_name
) 

select 
order_year,product_name,current_sales,
round(avg(current_sales) over(partition by product_name),0) as avg_sales,
current_sales - round(avg(current_sales) over(partition by product_name),0) as avg_perfomance,
case when current_sales - round(avg(current_sales) over(partition by product_name),0)<0 then 'Below Average'
	 when current_sales - round(avg(current_sales) over(partition by product_name),0)>0 then 'Above Average'
	 else 'Average'
end as avg_change,
lag(current_sales) over(partition by product_name order by order_year asc ) as pre_year_sales
from yearly_product_sales
order by product_name,order_year

--Q4. Which Category Contribute Most to overall Sales

with category_sales as (
select category,sum(sales_amount) as total_sales from gold.fact_sales f join gold.dim_products p on
p.product_key=f.product_key
group by category
)
select category,
total_sales,
sum(total_sales) over(),
concat(round((total_sales/sum(total_sales) over()) * 100,2),' %') as percentage_of_total
from category_sales

--Data Segmentation
--(Group the data based on specific range Helps to Understand the Correlation between two measure!)

--Q5. Segment Products into cost range and count ho many products falls into each segment

SELECT cost_range, COUNT(*) AS product_count
FROM (
    SELECT
        CASE
            WHEN cost < 100 THEN 'Low Cost'
            WHEN cost BETWEEN 100 AND 500 THEN 'Medium Cost'
            WHEN cost BETWEEN 501 AND 1000 THEN 'High Cost'
            ELSE 'Premium'
        END AS cost_range
    FROM gold.dim_products
) t
GROUP BY cost_range;


/*Q6. Group Customer into three segments based on their spending behavior
	 -VIP :Customer with alteast 12 months of history and spending more than 5000.
	 -Regular :Customer with alteast 12 months of history and spending 5000 or less than 5000.
	 -New :customers with lifespan less than 12 months
and Find total no of customer by each Group!
*/

WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM(s.sales_amount) AS total_spending,
        EXTRACT(YEAR FROM AGE(MAX(s.order_date), MIN(s.order_date))) * 12
        + EXTRACT(MONTH FROM AGE(MAX(s.order_date), MIN(s.order_date))) AS life_span
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    GROUP BY c.customer_key
),
customer_segmentation AS (
    SELECT
        CASE 
            WHEN life_span >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN life_span >= 12 AND total_spending <= 5000 THEN 'Regular'
            WHEN life_span < 12 THEN 'New'
            ELSE 'Unknown'
        END AS customer_segment
    FROM customer_spending
)

SELECT
    customer_segment,
    COUNT(*) AS total_no_of_customers
FROM customer_segmentation
GROUP BY customer_segment;










