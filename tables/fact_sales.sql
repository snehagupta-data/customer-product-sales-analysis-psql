-- ===========================================================================
-- Fact Table: Sales
-- ===========================================================================
CREATE TABLE gold.fact_sales (
    order_number  VARCHAR(50),
    product_key   INT,
    customer_key  INT,
    order_date    DATE,
    shipping_date DATE,
    due_date      DATE,
    sales_amount  INT,
    quantity      SMALLINT,
    price         INT
);
