-- ===========================================================================
-- Q3: Yearly Product Performance Analysis
-- Compare each product's sales with its average and previous year
-- ===========================================================================
WITH yearly_product_sales AS (
    SELECT 
        EXTRACT(YEAR FROM f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    JOIN gold.dim_products p
      ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM f.order_date), p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    ROUND(AVG(current_sales) OVER(PARTITION BY product_name), 0) AS avg_sales,
    current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name), 0) AS avg_performance,
    CASE 
        WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name), 0) < 0 THEN 'Below Average'
        WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name), 0) > 0 THEN 'Above Average'
        ELSE 'Average'
    END AS avg_change,
    LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) AS prev_year_sales
FROM yearly_product_sales
ORDER BY product_name, order_year;
