TRUNCATE TABLE sales_clean;

INSERT INTO sales_clean (
    row_id, order_id, order_date, ship_date, ship_mode, 
    customer_id, customer_name, segment, country, city, state, 
    postal_code, region, product_id, category, sub_category, 
    product_name, sales, quantity, discount, profit,
    order_year, order_quarter, order_month, year_month, 
    ship_days, profit_margin, discount_band, is_loss_making
)
SELECT 
    row_id::INTEGER,
    order_id,
    TO_DATE(order_date, 'DD-MM-YYYY'), 
    TO_DATE(ship_date, 'DD-MM-YYYY'),
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    LPAD(TRIM(postal_code), 5, '0'),    
    region,
    product_id,
    category,
    sub_category,
    product_name,
    REPLACE(sales, ',', '')::NUMERIC,   
    quantity::INTEGER,
    discount::NUMERIC,
    REPLACE(profit, ',', '')::NUMERIC,
    
    -- Derived Columns
    EXTRACT(YEAR FROM TO_DATE(order_date, 'DD-MM-YYYY'))::SMALLINT,
    EXTRACT(QUARTER FROM TO_DATE(order_date, 'DD-MM-YYYY'))::SMALLINT,
    EXTRACT(MONTH FROM TO_DATE(order_date, 'DD-MM-YYYY'))::SMALLINT,
    TO_CHAR(TO_DATE(order_date, 'DD-MM-YYYY'), 'YYYY-MM'),
    (TO_DATE(ship_date, 'DD-MM-YYYY') - TO_DATE(order_date, 'DD-MM-YYYY')),
    (REPLACE(profit, ',', '')::NUMERIC / REPLACE(sales, ',', '')::NUMERIC),
    
    CASE 
        WHEN discount::NUMERIC = 0 THEN '0% (none)'
        WHEN discount::NUMERIC <= 0.10 THEN '1-10%'
        WHEN discount::NUMERIC <= 0.20 THEN '11-20%'
        WHEN discount::NUMERIC <= 0.40 THEN '21-40%'
        ELSE '41%+'
    END,
    
    CASE WHEN REPLACE(profit, ',', '')::NUMERIC < 0 THEN 1 ELSE 0 END
    
FROM raw_superstore;