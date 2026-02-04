-- ===========================================================================
-- Q6: Customer Segmentation based on Spending Behavior
-- VIP: >12 months & spending >5000
-- Regular: >12 months & spending <=5000
-- New: <12 months
-- ===========================================================================
WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM(s.sales_amount) AS total_spending,
        (EXTRACT(YEAR FROM AGE(MAX(s.order_date), MIN(s.order_date))) * 12
 + EXTRACT(MONTH FROM AGE(MAX(s.order_date), MIN(s.order_date)))
 + CASE WHEN EXTRACT(DAY FROM AGE(MAX(s.order_date), MIN(s.order_date))) > 0 THEN 1 ELSE 0 END
) AS life_span
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
