-- ===========================================================================
-- Customer Report View
-- ===========================================================================
CREATE VIEW gold.customer_report AS
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
		(EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
 + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))
 + CASE WHEN EXTRACT(DAY FROM AGE(MAX(order_date), MIN(order_date))) > 0 THEN 1 ELSE 0 END
) AS lifespan


		
    FROM base_query
    GROUP BY customer_key, customer_number, customer_name, customer_age
)
SELECT 
    customer_key,
    customer_number,
    customer_name,
    total_sales,
    total_quantity_purchased,
    total_products,
    last_order_date,
    (EXTRACT(YEAR FROM current_date)*12 + EXTRACT(MONTH FROM current_date)) -
    (EXTRACT(YEAR FROM last_order_date)*12 + EXTRACT(MONTH FROM last_order_date)) AS recency,
    CASE 
        WHEN customer_age <= 19 THEN 'Young'
        WHEN customer_age <= 35 THEN 'Adult'
        WHEN customer_age <= 50 THEN 'Middle Aged'
        ELSE 'Senior'
    END AS age_group,
    CASE 
        WHEN lifespan > 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan > 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segmentation,
    CASE WHEN total_orders=0 THEN 0 ELSE total_sales/total_orders END AS avg_order_value,
    CASE WHEN lifespan=0 THEN 0 ELSE ROUND(total_sales::numeric / lifespan, 2) END AS avg_monthly_spend
FROM customer_aggregation;



