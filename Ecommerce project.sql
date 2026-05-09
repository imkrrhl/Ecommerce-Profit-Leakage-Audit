==========================================================
-- PROJECT: E-commerce Profit Leakage Audit
-- PURPOSE: Identify margin erosion and calculate break-even thresholds
==========================================================

1. DATA ARCHITECTURE: Adding the Audit Logic Column
 Adding a column to store the calculated maximum allowable discount
ALTER TABLE world.`ecommerce project`
ADD COLUMN Max_Discount INT;

2. CALCULATING BREAK-EVEN THRESHOLDS
 Logic: Max Discount = (1 - (Cost / MRP)) * 100
UPDATE world.`ecommerce project`
SET Max_Discount = (1 - (Cost_per_item / MRP)) * 100;

3. CORE AUDIT: Identifying "Leakage Traps"
 Finding specific orders where discounts exceeded the safety threshold
SELECT 
    Category, 
    Sub_Category, 
    Region, 
    Discount AS Actual_Discount, 
    Max_Discount,
    Profit
FROM world.`ecommerce project`
WHERE Discount > Max_Discount
ORDER BY Profit ASC;

 4. STRATEGIC INSIGHT: Regional Value Erosion
 Using CASE WHEN to group performance and identify high-risk regions
SELECT 
    Region,
    COUNT(*) as Total_Orders,
    SUM(CASE WHEN Discount > Max_Discount THEN 1 ELSE 0 END) as Leakage_Orders,
    ROUND(SUM(CASE WHEN Discount > Max_Discount THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as Failure_Rate_Percentage
FROM world.`ecommerce project`
GROUP BY Region
ORDER BY Failure_Rate_Percentage DESC;

 5. EXECUTIVE SUMMARY: Total Recoverable Profit
 Calculating the exact dollar amount lost to excessive discounting
SELECT 
    SUM(ABS(Profit)) AS Total_Recoverable_Profit
FROM world.`ecommerce project`
WHERE Discount > Max_Discount AND Profit < 0;