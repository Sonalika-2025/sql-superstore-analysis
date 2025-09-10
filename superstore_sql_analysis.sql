/* ========================================
   SUPERSTORE SQL ANALYSIS
   Author: Sonalika MR
   Database: SuperstoreDB
   Table: dbo.super_store
   ======================================== */



-- 1. Total number of unique orders
SELECT COUNT(DISTINCT Order_ID) AS Total_Orders
FROM dbo.super_store;

-- 2. Total sales, profit, and average discount
SELECT 
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    AVG(Discount) AS Avg_Discount
FROM dbo.super_store;

-- 3. Total sales by region
SELECT Region, SUM(Sales) AS Total_Sales
FROM dbo.super_store
GROUP BY Region
ORDER BY Total_Sales DESC;

-- 4. Count of customers by segment
SELECT Segment, COUNT(DISTINCT Customer_ID) AS Unique_Customers
FROM dbo.super_store
GROUP BY Segment;

-- 5. Total sales by ship mode
SELECT Ship_Mode, SUM(Sales) AS Total_Sales
FROM dbo.super_store
GROUP BY Ship_Mode;

-- 6. Average profit by category
SELECT Category, AVG(Profit) AS Avg_Profit
FROM dbo.super_store
GROUP BY Category;



-- 7. Top 10 customers by sales
SELECT TOP 10 Customer_Name, SUM(Sales) AS Total_Sales
FROM dbo.super_store
GROUP BY Customer_Name
ORDER BY Total_Sales DESC;

-- 8. Sales by sub-category
SELECT Sub_Category, SUM(Sales) AS Total_Sales
FROM dbo.super_store
GROUP BY Sub_Category
ORDER BY Total_Sales DESC;

-- 9. Profit by state (Top 10)
SELECT TOP 10 State, SUM(Profit) AS Total_Profit
FROM dbo.super_store
GROUP BY State
ORDER BY Total_Profit DESC;

-- 10. Year-wise total sales
SELECT YEAR(Order_Date) AS Order_Year, SUM(Sales) AS Total_Sales
FROM dbo.super_store
GROUP BY YEAR(Order_Date)
ORDER BY Order_Year;

-- 11. Sales trend by month (overall)
SELECT FORMAT(Order_Date, 'yyyy-MM') AS Order_Month, SUM(Sales) AS Total_Sales
FROM dbo.super_store
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY Order_Month;

-- 12. Total sales and profit by category
SELECT Category, SUM(Sales) AS Total_Sales, SUM(Profit) AS Total_Profit
FROM dbo.super_store
GROUP BY Category;

-- 13. Top 5 products by sales
SELECT TOP 5 Product_Name, SUM(Sales) AS Total_Sales
FROM dbo.super_store
GROUP BY Product_Name
ORDER BY Total_Sales DESC;

-- 14. Average discount by region
SELECT Region, AVG(Discount) AS Avg_Discount
FROM dbo.super_store
GROUP BY Region;

-- 15. Customer segmentation by sales
SELECT Segment, SUM(Sales) AS Total_Sales, SUM(Profit) AS Total_Profit
FROM dbo.super_store
GROUP BY Segment;

-- 16. Sales vs Profit by category
SELECT Category, SUM(Sales) AS Total_Sales, SUM(Profit) AS Total_Profit
FROM dbo.super_store
GROUP BY Category
ORDER BY Total_Sales DESC;


-- 17. Cumulative sales over time (monthly) --
WITH MonthlySales AS (
    SELECT 
        CAST(YEAR(Order_Date) AS VARCHAR(4)) + '-' + 
        RIGHT('0' + CAST(MONTH(Order_Date) AS VARCHAR(2)), 2) AS Order_Month,
        YEAR(Order_Date) AS Order_Year,
        MONTH(Order_Date) AS Order_MonthNum,
        SUM(Sales) AS Monthly_Sales
    FROM dbo.super_store
    GROUP BY YEAR(Order_Date), MONTH(Order_Date)
)
SELECT 
    Order_Month,
    Monthly_Sales,
    SUM(Monthly_Sales) OVER (ORDER BY Order_Year, Order_MonthNum) AS Cumulative_Sales
FROM MonthlySales
ORDER BY Order_Year, Order_MonthNum;

-- 18. Yearly sales growth %
WITH YearlySales AS (
    SELECT YEAR(Order_Date) AS Year, SUM(Sales) AS Total_Sales
    FROM dbo.super_store
    GROUP BY YEAR(Order_Date)
)
SELECT 
    Year,
    Total_Sales,
    LAG(Total_Sales) OVER (ORDER BY Year) AS Prev_Year_Sales,
    ( (Total_Sales - LAG(Total_Sales) OVER (ORDER BY Year)) * 100.0 
        / LAG(Total_Sales) OVER (ORDER BY Year) ) AS Growth_Percent
FROM YearlySales
ORDER BY Year;

-- 19. Top 3 sub-categories by sales in each region
WITH SubCatSales AS (
    SELECT 
        Region,
        Sub_Category,
        SUM(Sales) AS Total_Sales
    FROM dbo.super_store
    GROUP BY Region, Sub_Category
)
SELECT Region, Sub_Category, Total_Sales
FROM (
    SELECT 
        Region,
        Sub_Category,
        Total_Sales,
        ROW_NUMBER() OVER (PARTITION BY Region ORDER BY Total_Sales DESC) AS RowNum
    FROM SubCatSales
) AS RankedData
WHERE RowNum <= 3
ORDER BY Region, Total_Sales DESC;

-- 20. Profit contribution % of each category
SELECT 
    Category,
    SUM(Profit) AS Total_Profit,
    (SUM(Profit) * 100.0 / (SELECT SUM(Profit) FROM dbo.super_store)) AS Profit_Percent
FROM dbo.super_store
GROUP BY Category
ORDER BY Profit_Percent DESC;
