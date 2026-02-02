-- ===========================================================================
-- Q2: Total Sales per Month with Running Total and Moving Average
-- ===========================================================================
SELECT
    month_start,
    TO_CHAR(month_start, 'Mon YYYY') AS month_name,
    total_sales,
    SUM(total_sales) OVER (
        PARTITION BY EXTRACT(YEAR FROM month_start)
        ORDER BY month_start
    ) AS running_total,
    ROUND(AVG(avg_sales) OVER (
        PARTITION BY EXTRACT(YEAR FROM month_start)
        ORDER BY month_start
    ), 2) AS moving_average
FROM (
    SELECT
        DATE_TRUNC('month', order_date) AS month_start,
        SUM(sales_amount) AS total_sales,
        AVG(sales_amount) AS avg_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
) t
ORDER BY month_start;
