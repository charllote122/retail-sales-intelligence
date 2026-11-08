# Retail Sales Intelligence

An end-to-end data pipeline and dashboard for a retail Superstore dataset using PostgreSQL and Power BI.

## 📊 Project Overview
This project takes a raw, messy CSV file (Windows-1252 encoded) and builds a robust 3-layer SQL pipeline to clean, validate, and analyze over 9,900 retail orders.

## 🛠️ Tech Stack
* **Database:** PostgreSQL
* **Language:** SQL, Bash (Terminal)
* **Visualization:** Power BI

## 🗂️ Project Structure
* `sql/schema.sql`: Creates the raw and clean tables, indexes, and reporting views.
* `sql/data_cleaning.sql`: Moves data from raw to clean, handling date parsing and numeric casting.
* `sql/analysis.sql`: 12 business intelligence queries.
* `data/processed/superstore_clean.csv`: Cleaned dataset ready for Power BI/Excel.
* `powerbi/sales_dashboard.pbix`: Interactive executive dashboard.

## 💡 Key Insights Discovered
* **Total Revenue:** $2.29M with a 12.47% overall profit margin.
* **The Discount Problem:** Orders with 41%+ discounts have a -77.4% profit margin.
* **Geographic Losses:** Texas is a top market ($170K in sales) but loses the most money (-$25.7K).
* **Loss Leaders:** The "Cubify CubeX 3D Printer" is the single most unprofitable product.

## 🚀 How to Run
1. Create a PostgreSQL database named `superstore_db`.
2. Run `schema.sql` to build the tables.
3. Load the raw CSV using `\copy`.
4. Run `data_cleaning.sql` to populate the clean table.
5. Run `analysis.sql` to generate insights.
