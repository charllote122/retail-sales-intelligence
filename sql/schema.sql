-- =====================================================================
-- schema.sql  |  Retail Sales Intelligence  |  PostgreSQL 13+
--
-- Layer 1  raw_superstore : the CSV exactly as delivered, every column TEXT
-- Layer 2  sales_clean    : typed, constrained, enriched table for analysis
-- Layer 3  vw_*           : three reporting views for BI tools
--
-- Run order: schema.sql -> load CSV into raw_superstore -> data_cleaning.sql
--            -> analysis.sql
--
-- Load the raw data with psql (client side, so no server file permissions needed):
--   \copy raw_superstore FROM 'data/raw/Superstore.csv' WITH (FORMAT csv, HEADER true, ENCODING 'WIN1252')
--
-- Note: We are using the file in the data/raw/ folder. Because that specific file 
-- is Windows-1252 encoded, we must explicitly tell Postgres to read it as WIN1252 
-- to prevent errors on special characters.
--
-- Everything runs in one transaction: either the whole schema is created or nothing is.
-- =====================================================================

BEGIN;

-- Drop existing tables/views if they exist (to allow re-running this file safely)
DROP VIEW  IF EXISTS vw_monthly_kpis;
DROP VIEW  IF EXISTS vw_product_performance;
DROP VIEW  IF EXISTS vw_region_performance;
DROP TABLE IF EXISTS sales_clean;
DROP TABLE IF EXISTS raw_superstore;

-- ---------------------------------------------------------------------
-- Layer 1: raw landing table (no typing, no cleaning)
-- Column order must match the header of Superstore.csv.
-- ---------------------------------------------------------------------
CREATE TABLE raw_superstore (
    row_id        TEXT,
    order_id      TEXT,
    order_date    TEXT,   -- dd-mm-yyyy text in the source file
    ship_date     TEXT,   -- dd-mm-yyyy text in the source file
    ship_mode     TEXT,
    customer_id   TEXT,
    customer_name TEXT,
    segment       TEXT,
    country       TEXT,
    city          TEXT,
    state         TEXT,
    postal_code   TEXT,   -- leading zeros are missing for New England ZIPs
    region        TEXT,
    product_id    TEXT,
    category      TEXT,
    sub_category  TEXT,
    product_name  TEXT,
    sales         TEXT,
    quantity      TEXT,
    discount      TEXT,
    profit        TEXT
);

-- ---------------------------------------------------------------------
-- Layer 2: clean analytical table
-- Money is NUMERIC (exact), not floating point, so sums reconcile to the cent.
-- ---------------------------------------------------------------------
CREATE TABLE sales_clean (
    row_id          INTEGER       PRIMARY KEY,
    order_id        TEXT          NOT NULL,
    order_date      DATE          NOT NULL,
    ship_date       DATE          NOT NULL,
    ship_mode       TEXT          NOT NULL,
    customer_id     TEXT          NOT NULL,
    customer_name   TEXT          NOT NULL,
    segment         TEXT          NOT NULL,
    country         TEXT          NOT NULL,
    city            TEXT          NOT NULL,
    state           TEXT          NOT NULL,
    postal_code     TEXT          NOT NULL,   -- 5-digit text, zeros restored
    region          TEXT          NOT NULL,
    product_id      TEXT          NOT NULL,
    category        TEXT          NOT NULL,
    sub_category    TEXT          NOT NULL,
    product_name    TEXT          NOT NULL,
    sales           NUMERIC(12,4) NOT NULL,
    quantity        INTEGER       NOT NULL,
    discount        NUMERIC(4,2)  NOT NULL,   -- fraction: 0.20 = 20%
    profit          NUMERIC(12,4) NOT NULL,
    -- derived columns
    order_year      SMALLINT      NOT NULL,
    order_quarter   SMALLINT      NOT NULL,
    order_month     SMALLINT      NOT NULL,
    year_month      CHAR(7)       NOT NULL,   -- 'YYYY-MM'
    ship_days       INTEGER       NOT NULL,
    profit_margin   NUMERIC(8,4)  NOT NULL,   -- profit / sales, one line only
    discount_band   TEXT          NOT NULL,
    is_loss_making  SMALLINT      NOT NULL,   -- 1 / 0, kept numeric so AVG() works

    -- Data quality checks (the "bouncers")
    CONSTRAINT ck_sales_positive     CHECK (sales > 0),
    CONSTRAINT ck_quantity_positive  CHECK (quantity > 0),
    CONSTRAINT ck_discount_range     CHECK (discount BETWEEN 0 AND 1),
    CONSTRAINT ck_ship_after_order   CHECK (ship_date >= order_date),
    CONSTRAINT ck_ship_days          CHECK (ship_days >= 0),
    CONSTRAINT ck_postal_5_digits    CHECK (postal_code ~ '^[0-9]{5}$'),
    CONSTRAINT ck_quarter            CHECK (order_quarter BETWEEN 1 AND 4),
    CONSTRAINT ck_month              CHECK (order_month   BETWEEN 1 AND 12),
    CONSTRAINT ck_year_month_format  CHECK (year_month ~ '^[0-9]{4}-[0-9]{2}$'),
    CONSTRAINT ck_loss_flag          CHECK (is_loss_making IN (0, 1)),
    CONSTRAINT ck_discount_band      CHECK (discount_band IN ('0% (none)', '1-10%', '11-20%', '21-40%', '41%+'))
);

-- Indexes to make queries faster
CREATE INDEX idx_sales_order_id  ON sales_clean (order_id);
CREATE INDEX idx_sales_order_dt  ON sales_clean (order_date);
CREATE INDEX idx_sales_customer  ON sales_clean (customer_id);
CREATE INDEX idx_sales_product   ON sales_clean (product_name);
CREATE INDEX idx_sales_geo       ON sales_clean (region, state, city);
CREATE INDEX idx_sales_cat       ON sales_clean (category, sub_category);

-- Comments for documentation
COMMENT ON TABLE  raw_superstore IS 'Superstore.csv exactly as delivered. All text. Never edited.';
COMMENT ON TABLE  sales_clean    IS 'Cleaned order lines. One row per product line, so count orders with COUNT(DISTINCT order_id).';
COMMENT ON COLUMN sales_clean.profit_margin  IS 'profit / sales for this line. For groups use SUM(profit) / SUM(sales).';
COMMENT ON COLUMN sales_clean.is_loss_making IS '1 when profit < 0. Negative profits are real losses and are kept.';

-- ---------------------------------------------------------------------
-- Layer 3: reporting views (point Power BI / Excel at these if preferred)
-- ---------------------------------------------------------------------
CREATE VIEW vw_monthly_kpis AS
SELECT  year_month,
        order_year,
        order_month,
        ROUND(SUM(sales), 2)                                   AS sales,
        ROUND(SUM(profit), 2)                                  AS profit,
        ROUND(100.0 * SUM(profit) / SUM(sales), 2)             AS margin_pct,
        COUNT(DISTINCT order_id)                               AS orders,
        SUM(quantity)                                          AS units
FROM    sales_clean
GROUP BY year_month, order_year, order_month;

CREATE VIEW vw_product_performance AS
SELECT  category,
        sub_category,
        product_name,
        ROUND(SUM(sales), 2)                                   AS sales,
        ROUND(SUM(profit), 2)                                  AS profit,
        ROUND(100.0 * SUM(profit) / SUM(sales), 2)             AS margin_pct,
        SUM(quantity)                                          AS units,
        ROUND(AVG(discount), 4)                                AS avg_discount
FROM    sales_clean
GROUP BY category, sub_category, product_name;

CREATE VIEW vw_region_performance AS
SELECT  region,
        state,
        city,
        ROUND(SUM(sales), 2)                                   AS sales,
        ROUND(SUM(profit), 2)                                  AS profit,
        ROUND(100.0 * SUM(profit) / SUM(sales), 2)             AS margin_pct,
        COUNT(DISTINCT order_id)                               AS orders,
        ROUND(AVG(discount), 4)                                AS avg_discount
FROM    sales_clean
GROUP BY region, state, city;

COMMIT;