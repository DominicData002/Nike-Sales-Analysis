-- =====================================================
-- NIKE SALES DATASET — EDA & BUSINESS ANALYSIS
-- Runs against: nike_sales_clean (2,500 rows)
-- IMPORTANT: Revenue/Profit queries filter Is_Incomplete = 0
-- (only 166 of 2,500 rows have trustworthy revenue data)
-- =====================================================

USE nike_sales_db;

-- -----------------------------------------------------
-- Overall data shape / quality snapshot
-- -----------------------------------------------------
SELECT 
  COUNT(*) AS total_rows,
  SUM(Is_Incomplete = 0) AS complete_rows,
  SUM(Is_Return = 1) AS return_rows,
  SUM(Order_Date IS NULL) AS missing_date_rows,
  SUM(Discount_Applied IS NULL) AS missing_discount_rows
FROM nike_sales_clean;

-- -----------------------------------------------------
-- Revenue & Profit summary (complete records only, n=166)
-- -----------------------------------------------------
SELECT 
  COUNT(*) AS n_orders,
  SUM(Revenue) AS total_revenue,
  SUM(Profit) AS total_profit,
  ROUND(AVG(Revenue),2) AS avg_revenue_per_order,
  ROUND(SUM(Profit)/SUM(Revenue)*100,2) AS overall_margin_pct
FROM nike_sales_clean
WHERE Is_Incomplete = 0;

-- -----------------------------------------------------
-- EDA: Units sold by Product Line (full dataset, n=2500)
-- -----------------------------------------------------
SELECT Product_Line, SUM(Units_Sold) AS total_units, COUNT(*) AS order_count
FROM nike_sales_clean
GROUP BY Product_Line
ORDER BY total_units DESC;

-- -----------------------------------------------------
-- EDA: Units sold by Region (full dataset)
-- -----------------------------------------------------
SELECT Region, SUM(Units_Sold) AS total_units, COUNT(*) AS order_count
FROM nike_sales_clean
GROUP BY Region
ORDER BY total_units DESC;

-- -----------------------------------------------------
-- EDA: Revenue by Region (complete records only, n=166)
-- Small per-region sample (~25-31 orders) -- directional only
-- -----------------------------------------------------
SELECT Region, SUM(Revenue) AS total_revenue, COUNT(*) AS n_orders
FROM nike_sales_clean
WHERE Is_Incomplete = 0
GROUP BY Region
ORDER BY total_revenue DESC;

-- -----------------------------------------------------
-- EDA: Units sold by Gender Category (full dataset)
-- -----------------------------------------------------
SELECT Gender_Category, SUM(Units_Sold) AS total_units, COUNT(*) AS order_count
FROM nike_sales_clean
GROUP BY Gender_Category
ORDER BY total_units DESC;

-- -----------------------------------------------------
-- EDA: Units sold by Sales Channel (full dataset)
-- -----------------------------------------------------
SELECT Sales_Channel, SUM(Units_Sold) AS total_units, COUNT(*) AS order_count
FROM nike_sales_clean
GROUP BY Sales_Channel
ORDER BY total_units DESC;

-- -----------------------------------------------------
-- EDA: Discount distribution (rows with known discount, n=652)
-- -----------------------------------------------------
SELECT 
  CASE 
    WHEN Discount_Applied = 0 THEN 'No Discount'
    WHEN Discount_Applied <= 0.2 THEN '1-20%'
    WHEN Discount_Applied <= 0.5 THEN '21-50%'
    ELSE '50%+' 
  END AS discount_band,
  COUNT(*) AS order_count
FROM nike_sales_clean
WHERE Discount_Applied IS NOT NULL
GROUP BY discount_band;

-- -----------------------------------------------------
-- EDA: Monthly trend (rows with valid Order_Date only)
-- Reliable/comparable window: Aug 2024 - Jul 2025
-- -----------------------------------------------------
SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS month, 
       SUM(Units_Sold) AS total_units,
       COUNT(*) AS order_count
FROM nike_sales_clean
WHERE Order_Date IS NOT NULL
GROUP BY month
ORDER BY month;

-- -----------------------------------------------------
-- EDA: Top 10 products by units sold (full dataset)
-- -----------------------------------------------------
SELECT Product_Name, SUM(Units_Sold) AS total_units
FROM nike_sales_clean
GROUP BY Product_Name
ORDER BY total_units DESC
LIMIT 10;

-- -----------------------------------------------------
-- BUSINESS ANALYSIS: Return rate by Product Line (full dataset)
-- Rates are consistent (7-9%) -- not a targeted problem area
-- -----------------------------------------------------
SELECT Product_Line, 
       COUNT(*) AS total_orders,
       SUM(Is_Return = 1) AS return_count,
       ROUND(SUM(Is_Return = 1) / COUNT(*) * 100, 2) AS return_rate_pct
FROM nike_sales_clean
GROUP BY Product_Line
ORDER BY return_rate_pct DESC;

-- -----------------------------------------------------
-- BUSINESS ANALYSIS: Discount Band vs Margin (HEADLINE FINDING)
-- Complete records only (n=166). Uses SUM(Profit)/SUM(Revenue)
-- (revenue-weighted), NOT AVG(Profit/Revenue), to stay consistent
-- with the overall margin calculation above.
-- Result: 50%+ discount band shows the STRONGEST margin (+40.17%);
-- "Unknown" discount band shows a concerning -74.61% margin,
-- flagging missing discount data as a data-quality/process risk.
-- -----------------------------------------------------
SELECT 
  CASE 
      WHEN Discount_Applied IS NULL THEN 'Unknown'
      WHEN Discount_Applied <= 0.2 THEN '1-20%'
      WHEN Discount_Applied <= 0.5 THEN '21-50%'
      ELSE '50%+' 
  END AS discount_band,
  COUNT(*) AS n_orders,
  ROUND(SUM(Profit)/SUM(Revenue)*100, 2) AS margin_pct
FROM nike_sales_clean
WHERE Is_Incomplete = 0
GROUP BY discount_band;

-- =====================================================
-- KEY RESULTS SUMMARY
-- Overall margin (n=166):          30.78%
-- Discount band margin — 1-20%:    15.81%  (n=29)
-- Discount band margin — 21-50%:   19.02%  (n=43)
-- Discount band margin — 50%+:     40.17%  (n=61)
-- Discount band margin — Unknown: -74.61%  (n=33)
-- Top Product Line by units:       Training (509)
-- Top Region by units:             Mumbai (436)
-- Top Sales Channel:                Online (1,168 units)
-- =====================================================




































