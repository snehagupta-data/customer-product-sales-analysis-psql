-- ===========================================================================
-- Q5: Segment Products by Cost
-- ===========================================================================
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
