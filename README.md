# Nike Sales Analysis — Retail Data Analytics Project

An end-to-end data analytics project on a messy, real-world-style Nike retail sales dataset — covering data cleaning, exploratory data analysis, SQL business analysis, and an interactive Power BI dashboard.

## Business Problem

A retail dataset of Nike orders was provided in a raw, uncleaned state. The goal was to clean it, understand sales performance across products, regions, and channels, uncover the relationship between discounting and profitability, and deliver evidence-backed business recommendations — while being transparent about data quality issues along the way rather than hiding them.

## Tools Used
- **MySQL** — data cleaning, validation, exploratory and business analysis queries
- **Power BI** — interactive 3-page dashboard
- **GitHub** — version control and project documentation

## Dataset Overview

| Attribute | Detail |
|---|---|
| Rows | 2,500 orders |
| Columns | 13 (Order ID, Gender Category, Product Line, Product Name, Size, Units Sold, MRP, Discount Applied, Revenue, Order Date, Sales Channel, Region, Profit) |
| Format | CSV |
| Condition | Uncleaned — nulls, typos, mixed data types, negative values, inconsistent date formats, invalid discount values |

## Process

### 1. Data Cleaning (01_data_cleaning . sql)
Loaded the raw CSV into a staging table and systematically diagnosed and resolved:
- **Region typos** — consolidated variants (e.g., "bengaluru" → "Bangalore", "Hyd"/"hyderbad" → "Hyderabad")
- **Inconsistent date formats** — standardized 3 different formats into a single DATE type
- **Wrong data types** — cast text columns to proper numeric/date types
- **Invalid discounts** — discovered discount was stored as a decimal fraction (not 0–100 scale), and flagged 180 rows with discount > 100% as invalid
- **Negative values** — flagged 205 rows with negative Units_Sold as likely returns rather than deleting them
- **Missing/incomplete revenue** — traced Revenue = 0 (found in 2,334 of 2,500 rows) back to its root cause: missing discount values and missing unit/price data. Attempted recomputation where possible; flagged the rest as `Is_Incomplete` rather than guessing values

All 2,500 rows were retained in the final clean table — nothing was silently deleted. Data quality issues are flagged via `Is_Return` and `Is_Incomplete` columns for full transparency.

### 2. Exploratory Data Analysis & Business Analysis ([`sql/02_eda_and_business_analysis.sql`](sql/02_eda_and_business_analysis.sql))
Analyzed sales volume by product line, region, gender category, and sales channel (using the full dataset), and analyzed revenue/margin patterns and discount impact on profitability (using only the 166 orders with complete, trustworthy revenue data).

### 3. Power BI Dashboard ([`dashboard/`](dashboard/))
A 3-page interactive dashboard:
- **Volume Overview** — order counts, units sold, returns, and breakdowns by product line, region, gender, and channel (full 2,500-row dataset)
- **Revenue & Margin Insights** — revenue, profit, overall margin, and the discount-band-vs-margin analysis (based on the 166 complete records)
- **Trends & Data Quality** — monthly order trend, top products, and a transparent summary of data quality issues found during cleaning

### 4. Business Recommendations ([`report/business_recommendations.md`](report/business_recommendations.md))
Six evidence-backed recommendations, each tied to a specific finding and its supporting sample size — including the headline discovery that missing discount data correlates with the worst-performing orders in the dataset.

## Key Insights

- Only **166 of 2,500 orders (6.6%)** had complete, trustworthy revenue data — a major data quality finding in itself
- Orders with **missing discount values showed the worst average margin (-74.61%)**, flagging a data capture issue as a priority over any pricing change
- Contrary to typical assumptions, **orders with 50%+ discounts showed the strongest margin (+40.17%)** among defined discount bands
- Sales volume is **diversified** — no single product line or region dominates
- **Online channel slightly outperforms Retail** (1,168 vs 1,117 units sold)

See [`report/business_recommendations.md`](report/business_recommendations.md) for full details and caveats on each finding.

## Data Limitations

This project deliberately documents rather than hides its data quality issues:

| Issue | Rows Affected | % of Dataset |
|---|---|---|
| Missing Order Date | 616 | 24.6% |
| Missing/Invalid Discount Value | 1,848 | 73.9% |
| Incomplete Revenue Records | 2,334 | 93.4% |
| Flagged Returns (negative units in source) | 205 | 8.2% |

All revenue and margin findings in this project are explicitly based on the 166-row complete subset and should be read as directional rather than conclusive.

## How to Reproduce

1. Load `data/nike_sales_raw.csv` into a MySQL database
2. Run `sql/01_data_cleaning.sql` to reproduce the cleaning process and build the `nike_sales_clean` table
3. Run `sql/02_eda_and_business_analysis.sql` for the analysis queries
4. Open `dashboard/Nike_Sales_Dashboard.pbix` in Power BI Desktop (connect to your local `nike_sales_clean` table) to explore the dashboard interactively

## Repository Structure

```
nike-sales-analysis/
├── README.md
├── data/
│   └── nike_sales_raw.csv
├── sql/
│   ├── 01_data_cleaning.sql
│   └── 02_eda_and_business_analysis.sql
├── dashboard/
│   ├── Nike_Sales_Dashboard.pbix
│   └── screenshots/
│       ├── page1_volume_overview.png
│       ├── page2_revenue_margin.png
│       └── page3_trends_data_quality.png
└── report/
    └── business_recommendations.md
```
