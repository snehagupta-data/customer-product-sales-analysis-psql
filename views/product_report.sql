-- ===========================================================================
-- Product Report View
-- ===========================================================================
CREATE VIEW gold.product_report AS
WITH base_query AS (
    SELECT 
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,
        s.order_number,
        s.order_date,
        s.sales_amount,
        s.quantity,
        s.customer_key
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
),
product_aggregation AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        (EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
 + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))
 + CASE WHEN EXTRACT(DAY FROM AGE(MAX(order_date), MIN(order_date))) > 0 THEN 1 ELSE 0 END
) AS lifespan,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity
    FROM base_query
    GROUP BY product_key, product_name, category, subcategory, cost
)
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_order_date,
    CASE 
        WHEN total_sales > 50000 THEN 'High Performance'
        WHEN total_sales >= 10000 THEN 'Mid Performance'
        ELSE 'Low Performance'
    END AS product_segmentation,
    lifespan,
    total_sales,
    total_orders,
    total_quantity,
    total_customers,
    CASE WHEN total_orders=0 THEN 0 ELSE total_sales/total_orders END AS avg_order_revenue,
    CASE WHEN lifespan=0 THEN 0 ELSE total_sales/lifespan END AS avg_monthly_revenue
FROM product_aggregation;
