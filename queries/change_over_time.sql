-- ===========================================================================
-- Q1: Change Over Time
-- Analyze sales trend and total customers per year
-- ===========================================================================
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year ASC;
