-- =====================================================================
-- analysis.sql | Retail Sales Intelligence
-- 
-- This file contains 12 business queries designed to extract actionable
-- insights from the clean Superstore dataset.
-- 
-- Run this file via terminal: 
-- psql -U postgres -d superstore_db -f sql/analysis.sql
-- =====================================================================

-- =====================================================================
-- 1. EXECUTIVE OVERVIEW (The Big Picture)
-- =====================================================================

-- Q1: Overall Health. What is our total revenue, profit, and overall margin?
SELECT 
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100.0 * SUM(profit) / SUM(sales), 2) AS overall_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units_sold
FROM sales_clean;

-- Q2: Loss Impact. What percentage of our individual line items are losing money?
SELECT 
    SUM(is_loss_making) AS total_loss_making_lines,
    COUNT(*) AS total_lines,
    ROUND(100.0 * SUM(is_loss_making) / COUNT(*), 2) AS pct_of_lines_losing_money
FROM sales_clean;


-- =====================================================================
-- 2. TIME SERIES & TRENDS
-- =====================================================================

-- Q3: Monthly Performance. How do sales and profit trend month-over-month?
-- (This queries the view we created in schema.sql)
SELECT * FROM vw_monthly_kpis
ORDER BY year_month;

-- Q4: Yearly Growth. Which years were our best?
SELECT 
    order_year,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM sales_clean
GROUP BY order_year
ORDER BY order_year;


-- =====================================================================
-- 3. PRODUCT & CATEGORY ANALYSIS
-- =====================================================================

-- Q5: Category Performance. Which categories and sub-categories drive profit?
SELECT 
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100.0 * SUM(profit) / SUM(sales), 2) AS margin_pct
FROM sales_clean
GROUP BY category, sub_category
ORDER BY total_profit DESC;

-- Q6: The "Loss Leaders". Which top 10 specific products are actively losing us the most money? 
-- (Great for discontinuing or repricing)
SELECT 
    product_name,
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_loss,
    SUM(quantity) AS units_sold
FROM sales_clean
GROUP BY product_name, category
HAVING SUM(profit) < 0
ORDER BY total_loss ASC
LIMIT 10;

-- Q7: Discount Impact. Are our discounts helping or hurting?
SELECT 
    discount_band,
    COUNT(*) AS total_line_items,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100.0 * SUM(profit) / SUM(sales), 2) AS margin_pct
FROM sales_clean
GROUP BY discount_band
ORDER BY margin_pct DESC;


-- =====================================================================
-- 4. GEOGRAPHIC PERFORMANCE
-- =====================================================================

-- Q8: Regional Overview. Which regions are our strongest markets?
SELECT 
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100.0 * SUM(profit) / SUM(sales), 2) AS margin_pct,
    COUNT(DISTINCT order_id) AS total_orders
FROM sales_clean
GROUP BY region
ORDER BY total_profit DESC;

-- Q9: Problem States. Which states have the highest average discount, 
-- and are those discounts causing them to lose money?
SELECT 
    state,
    ROUND(AVG(discount) * 100, 2) AS avg_discount_pct,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM sales_clean
GROUP BY state
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;


-- =====================================================================
-- 5. CUSTOMER & LOGISTICS ANALYSIS
-- =====================================================================

-- Q10: VIP Customers. Who are our top 10 highest-spending customers?
SELECT 
    customer_id,
    customer_name,
    segment,
    ROUND(SUM(sales), 2) AS total_spent,
    ROUND(SUM(profit), 2) AS profit_generated,
    COUNT(DISTINCT order_id) AS total_orders
FROM sales_clean
GROUP BY customer_id, customer_name, segment
ORDER BY total_spent DESC
LIMIT 10;

-- Q11: Segment Performance. Do Consumers, Corporate, or Home Office generate the best margins?
SELECT 
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100.0 * SUM(profit) / SUM(sales), 2) AS margin_pct
FROM sales_clean
GROUP BY segment
ORDER BY total_profit DESC;

-- Q12: Shipping Efficiency. Does the shipping mode impact our profitability?
SELECT 
    ship_mode,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(ship_days), 1) AS avg_shipping_days,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM sales_clean
GROUP BY ship_mode
ORDER BY total_profit DESC;