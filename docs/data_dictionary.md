# Data Dictionary: Superstore Dataset

## 1. Layer 1: `raw_superstore`
The raw CSV data loaded exactly as delivered, all columns typed as `TEXT`.

## 2. Layer 2: `sales_clean`
The typed, cleaned, and enriched table for analysis.

| Column | Type | Description |
| :--- | :--- | :--- |
| `row_id` | INTEGER | Unique identifier for the line item |
| `order_id` | TEXT | Order ID (count distinct for total orders) |
| `order_date` | DATE | Date the order was placed |
| `ship_date` | DATE | Date the order was shipped |
| `ship_mode` | TEXT | Shipping method (Standard, First, etc.) |
| `customer_id` | TEXT | Unique customer identifier |
| `customer_name` | TEXT | Name of the customer |
| `segment` | TEXT | Consumer, Corporate, or Home Office |
| `country` | TEXT | Country of shipping address |
| `city` | TEXT | City of shipping address |
| `state` | TEXT | State of shipping address |
| `postal_code` | TEXT | 5-digit ZIP code (leading zeros restored) |
| `region` | TEXT | East, West, Central, or South |
| `product_id` | TEXT | Unique product identifier |
| `category` | TEXT | Main product category |
| `sub_category` | TEXT | Product sub-category |
| `product_name` | TEXT | Full name of the product |
| `sales` | NUMERIC | Revenue for this line item |
| `quantity` | INTEGER | Number of units sold |
| `discount` | NUMERIC | Discount fraction (e.g., 0.20 = 20%) |
| `profit` | NUMERIC | Profit for this line item |
| `order_year` | SMALLINT | Extracted from order_date |
| `order_quarter` | SMALLINT | Extracted from order_date (1-4) |
| `order_month` | SMALLINT | Extracted from order_date (1-12) |
| `year_month` | CHAR(7) | Format 'YYYY-MM' for grouping |
| `ship_days` | INTEGER | Days between order and ship date |
| `profit_margin`| NUMERIC | Profit / Sales for this specific line |
| `discount_band` | TEXT | Categorized discount levels |
| `is_loss_making`| SMALLINT | 1 if profit < 0, else 0 |
