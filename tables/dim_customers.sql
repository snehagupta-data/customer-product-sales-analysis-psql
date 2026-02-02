-- ===========================================================================
-- Dimension Table: Customers
-- ===========================================================================
CREATE TABLE gold.dim_customers (
    customer_key     INT PRIMARY KEY,
    customer_id      INT,
    customer_number  VARCHAR(50),
    first_name       VARCHAR(50),
    last_name        VARCHAR(50),
    country          VARCHAR(50),
    marital_status   VARCHAR(50),
    gender           VARCHAR(50),
    birthdate        DATE,
    create_date      DATE
);
