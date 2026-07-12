
-- =====================================================
-- NIKE SALES DATASET — DATA CLEANING SCRIPT
-- 2,501 raw rows (incl. header) -> 2,500 data rows
-- Tool: MySQL
-- =====================================================

-- -----------------------------------------------------
-- STEP 1: Create database and staging table, then load CSV
-- (Loaded via MySQL Workbench Import Wizard, which auto-
-- created table 'nike_sales_uncleaned' with these types)
-- -----------------------------------------------------
CREATE DATABASE IF NOT EXISTS nike_sales_db;
USE nike_sales_db;

-- Resulting structure from Import Wizard:
-- Order_ID INT, Gender_Category TEXT, Product_Line TEXT,
-- Product_Name TEXT, Size TEXT, Units_Sold TEXT, MRP TEXT,
-- Discount_Applied TEXT, Revenue DOUBLE, Order_Date TEXT,
-- Sales_Channel TEXT, Region TEXT, Profit DOUBLE

SET SQL_SAFE_UPDATES = 0;

-- -----------------------------------------------------
-- STEP 2: Diagnose data quality issues before cleaning
-- -----------------------------------------------------
SELECT Region, COUNT(*) FROM nike_sales_uncleaned GROUP BY Region ORDER BY Region;
SELECT DISTINCT Order_Date FROM nike_sales_uncleaned LIMIT 30;

SELECT 
  SUM(Gender_Category IS NULL) AS null_gender,
  SUM(Product_Line IS NULL) AS null_product_line,
  SUM(Region IS NULL) AS null_region,
  SUM(Units_Sold IS NULL) AS null_units,
  SUM(MRP IS NULL) AS null_mrp,
  SUM(Discount_Applied IS NULL) AS null_discount,
  SUM(Sales_Channel IS NULL) AS null_channel
FROM nike_sales_uncleaned;

SELECT * FROM nike_sales_uncleaned WHERE Revenue < 0 OR Profit < 0;
SELECT * FROM nike_sales_uncleaned WHERE CAST(Discount_Applied AS DECIMAL(10,2)) > 100;

-- -----------------------------------------------------
-- STEP 3: Fix Region typos
-- Found: 'Bangalore'/'bengaluru' and 'Hyd'/'Hyderabad'/'hyderbad'
-- -----------------------------------------------------
UPDATE nike_sales_uncleaned SET Region = 'Bangalore' WHERE Region IN ('Bangalore', 'bengaluru');
UPDATE nike_sales_uncleaned SET Region = 'Hyderabad' WHERE Region IN ('Hyd', 'Hyderabad', 'hyderbad');

-- Verify: should show 6 clean regions
SELECT Region, COUNT(*) FROM nike_sales_uncleaned GROUP BY Region ORDER BY Region;

-- -----------------------------------------------------
-- STEP 4: Standardize Order_Date
-- Found 3 formats: YYYY-MM-DD, DD-MM-YYYY, YYYY/MM/DD
-- 616 rows have a genuinely blank Order_Date (documented limitation)
-- -----------------------------------------------------
ALTER TABLE nike_sales_uncleaned ADD COLUMN Order_Date_Clean DATE;

UPDATE nike_sales_uncleaned
SET Order_Date_Clean = 
    CASE 
        WHEN Order_Date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' 
            THEN STR_TO_DATE(Order_Date, '%Y-%m-%d')
        WHEN Order_Date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' 
            THEN STR_TO_DATE(Order_Date, '%d-%m-%Y')
        WHEN Order_Date REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' 
            THEN STR_TO_DATE(Order_Date, '%Y/%m/%d')
        ELSE NULL
    END;

-- Confirm: 1,884 valid dates, 616 missing (blank strings in source data)
SELECT 
  SUM(Order_Date_Clean IS NOT NULL) AS valid_dates,
  SUM(Order_Date_Clean IS NULL) AS missing_dates
FROM nike_sales_uncleaned;

-- -----------------------------------------------------
-- STEP 5: Fix numeric data types
-- Units_Sold, MRP, Discount_Applied came in as TEXT
-- Use NULLIF to safely convert blank strings before casting
-- -----------------------------------------------------
ALTER TABLE nike_sales_uncleaned 
  ADD COLUMN Units_Sold_Clean DECIMAL(10,2),
  ADD COLUMN MRP_Clean DECIMAL(10,2),
  ADD COLUMN Discount_Clean DECIMAL(10,2);

UPDATE nike_sales_uncleaned
SET 
  Units_Sold_Clean = CAST(NULLIF(Units_Sold, '') AS DECIMAL(10,2)),
  MRP_Clean = CAST(NULLIF(MRP, '') AS DECIMAL(10,2)),
  Discount_Clean = CAST(NULLIF(Discount_Applied, '') AS DECIMAL(10,2));

-- Verify no casting failures (excluding known blanks)
SELECT Units_Sold, Units_Sold_Clean FROM nike_sales_uncleaned 
WHERE Units_Sold IS NOT NULL AND Units_Sold != '' AND Units_Sold_Clean IS NULL;
SELECT MRP, MRP_Clean FROM nike_sales_uncleaned 
WHERE MRP IS NOT NULL AND MRP != '' AND MRP_Clean IS NULL;
SELECT Discount_Applied, Discount_Clean FROM nike_sales_uncleaned 
WHERE Discount_Applied IS NOT NULL AND Discount_Applied != '' AND Discount_Clean IS NULL;

-- -----------------------------------------------------
-- STEP 6: Fix Discount > 100% (discovered stored as decimal
-- fraction, e.g. 1.01 = 101%, not a 0-100 scale)
-- 180 rows had Discount_Clean > 1 -> set to NULL (invalid/unrecoverable)
-- -----------------------------------------------------
SELECT COUNT(*) FROM nike_sales_uncleaned WHERE Discount_Clean > 1;      -- 180
SELECT COUNT(*) FROM nike_sales_uncleaned WHERE Units_Sold_Clean < 0;    -- 205
SELECT COUNT(*) FROM nike_sales_uncleaned WHERE Discount_Clean > 1 AND Units_Sold_Clean < 0; -- 11 overlap

UPDATE nike_sales_uncleaned
SET Discount_Clean = NULL
WHERE Discount_Clean > 1;

-- -----------------------------------------------------
-- STEP 7: Flag negative Units_Sold as returns (205 rows),
-- then convert to positive so unit totals remain usable
-- -----------------------------------------------------
ALTER TABLE nike_sales_uncleaned ADD COLUMN Is_Return TINYINT DEFAULT 0;

UPDATE nike_sales_uncleaned
SET Is_Return = 1
WHERE Units_Sold_Clean < 0;

UPDATE nike_sales_uncleaned
SET Units_Sold_Clean = ABS(Units_Sold_Clean)
WHERE Units_Sold_Clean < 0;

-- -----------------------------------------------------
-- STEP 8: Investigate and flag incomplete revenue records
-- Root cause tracing showed Revenue = 0 for 2,334 rows (93.4%),
-- almost all caused by missing Discount_Applied (1,815 rows) or
-- missing Units_Sold/MRP (remaining rows). Attempted recompute
-- (Revenue = Units_Sold x MRP x (1 - Discount)) only applied to
-- 31 rows where all 3 inputs existed -- all resolved to 0 because
-- Units_Sold_Clean = 0 for those rows (genuine non-sales, not errors).
-- Conclusion: Revenue=0 rows are NOT recoverable and must be flagged.
-- -----------------------------------------------------
ALTER TABLE nike_sales_uncleaned ADD COLUMN Is_Incomplete TINYINT DEFAULT 0;

UPDATE nike_sales_uncleaned
SET Is_Incomplete = 1
WHERE Revenue = 0;

-- Verify: 2,334 incomplete, 166 complete (adds to 2,500)
SELECT COUNT(*) FROM nike_sales_uncleaned WHERE Is_Incomplete = 1;
SELECT COUNT(*) FROM nike_sales_uncleaned WHERE Is_Incomplete = 0;

-- -----------------------------------------------------
-- STEP 9: Build final clean table
-- All 2,500 rows retained; nulls and flags preserved for
-- transparency rather than silently dropped
-- -----------------------------------------------------
CREATE TABLE nike_sales_clean AS
SELECT 
    Order_ID,
    Gender_Category,
    Product_Line,
    Product_Name,
    Size,
    Units_Sold_Clean AS Units_Sold,
    MRP_Clean AS MRP,
    Discount_Clean AS Discount_Applied,
    Revenue,
    Profit,
    Order_Date_Clean AS Order_Date,
    Sales_Channel,
    Region,
    Is_Return,
    Is_Incomplete
FROM nike_sales_uncleaned;

-- Final check: should return 2500
SELECT COUNT(*) FROM nike_sales_clean;

-- =====================================================
-- DATA QUALITY SUMMARY
-- Missing Order Date:              616  (24.6%)
-- Missing/Invalid Discount Value:  1,848 (73.9%)  [1,668 blank + 180 >100%]
-- Flagged Returns (neg. units):    205  (8.2%)
-- Incomplete Revenue Records:      2,334 (93.4%)
-- Complete, trustworthy records:   166  (6.6%)
-- =====================================================











