--•	See all the data imported:
SELECT * FROM BlinkIT_Grocery_Data;

/*•	Data Cleaning – Standardizing Item_Fat_Content Field
To ensure consistency and accuracy in our dataset, it's important to clean the Item_Fat_Content column. 
This field contains multiple variations of the same category, such as 'LF', 'low fat', and 'Low Fat', which all represent the same concept. 
Similarly, 'reg' and 'Regular' refer to the same category. Such inconsistencies can lead to incorrect reporting, faulty aggregations, and filtering issues.
By standardizing these values, we enhance data quality, improve the reliability of insights, and maintain uniformity across the dataset.*/

UPDATE BlinkIT_Grocery_Data
SET Item_Fat_Content = 
    CASE 
        WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
        WHEN Item_Fat_Content = 'reg' THEN 'Regular'
        ELSE Item_Fat_Content
    END;

--•	To confirm the field has been cleaned and standardized correctly, run the following query:
SELECT DISTINCT Item_Fat_Content FROM BlinkIT_Grocery_Data;


--A. KPI’s
--1. TOTAL SALES:
SELECT CAST(SUM(Sales) / 1000000.0 AS DECIMAL(10,2)) 
AS Total_Sales_Million
FROM BlinkIT_Grocery_Data;


--2. AVERAGE SALES
SELECT CAST(AVG(Sales) AS INT) AS Avg_Sales
FROM BlinkIT_Grocery_Data;

--3. NO OF ITEMS
SELECT COUNT(*) AS No_of_Orders
FROM BlinkIT_Grocery_Data;

--4. AVG RATING
SELECT CAST(AVG(Rating) AS DECIMAL(10,1)) AS Avg_Rating
FROM BlinkIT_Grocery_Data;

--B. Total Sales by Fat Content:
SELECT Item_Fat_Content, CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM BlinkIT_Grocery_Data
GROUP BY Item_Fat_Content;

--C. Total Sales by Item Type
SELECT Item_Type, CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM BlinkIT_Grocery_Data
GROUP BY Item_Type
ORDER BY Total_Sales DESC;


--D. Fat Content by Outlet for Total Sales
SELECT Outlet_Location_Type, 
       ISNULL([Low Fat], 0) AS Low_Fat, 
       ISNULL([Regular], 0) AS Regular
FROM 
(
    SELECT Outlet_Location_Type, Item_Fat_Content, 
           CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales
    FROM BlinkIT_Grocery_Data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) AS SourceTable
PIVOT 
(
    SUM(Total_Sales) 
    FOR Item_Fat_Content IN ([Low Fat], [Regular])
) AS PivotTable
ORDER BY Outlet_Location_Type;

/*
Query Explanations
This query aims to transform the blinkit_data table to display total sales (Total_Sales) for each combination of Outlet_Location_Type and Item_Fat_Content. 
The result will show Outlet_Location_Type as rows and Item_Fat_Content categories ("Low Fat" and "Regular") as columns. 
If there are no sales for a particular combination, the query will display 0 instead of NULL.
Detailed Explanation:
Subquery
Aggregation:
sql
CopyEdit
SELECT 
    Outlet_Location_Type, 
    Item_Fat_Content, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM 
    blinkit_data
GROUP BY 
    Outlet_Location_Type, 
    Item_Fat_Content

Purpose: This subquery groups the data by Outlet_Location_Type and Item_Fat_Content, calculating the total sales for each combination.
CAST(SUM(Total_Sales) AS DECIMAL(10,2)): Sums the Total_Sales for each group and casts the result to a decimal with two decimal places for precision.

PIVOT Operation:
Pivoting:
sql
CopyEdit
PIVOT 
(
    SUM(Total_Sales) 
    FOR Item_Fat_Content IN ([Low Fat], [Regular])
) AS PivotTable

Purpose: Transforms the rows of Item_Fat_Content into columns ([Low Fat] and [Regular]).

SUM(Total_Sales): Aggregates the Total_Sales for each Item_Fat_Content category within each Outlet_Location_Type.

Main Query:
Selecting and Handling NULLs:
sql
CopyEdit
SELECT 
    Outlet_Location_Type, 
    ISNULL([Low Fat], 0) AS Low_Fat, 
    ISNULL([Regular], 0) AS Regular
FROM 
    PivotTable
ORDER BY 
    Outlet_Location_Type;

ISNULL([Low Fat], 0) AS Low_Fat: Replaces any NULL values in the [Low Fat] column with 0 and renames the column to Low_Fat.
ISNULL([Regular], 0) AS Regular: Similarly, replaces NULL values in the [Regular] column with 0.

ORDER BY Outlet_Location_Type: Sorts the final result set by Outlet_Location_Type.

Why Use ISNULL?
When performing a PIVOT operation, if a particular combination of Outlet_Location_Type and Item_Fat_Content doesn't exist in the data, 
the resulting cell will contain a NULL value. Using ISNULL(column)
*/


--E. Total Sales by Outlet Establishment
SELECT Outlet_Establishment_Year, CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM BlinkIT_Grocery_Data
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year;

--F. Percentage of Sales by Outlet Size
SELECT 
    Outlet_Size, 
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM BlinkIT_Grocery_Data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

--G. Sales by Outlet Location
SELECT Outlet_Location_Type, CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM BlinkIT_Grocery_Data
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC;

--H. All Metrics by Outlet Type:
SELECT Outlet_Type, 
CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
		CAST(AVG(Sales) AS DECIMAL(10,0)) AS Avg_Sales,
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
		CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility
FROM BlinkIT_Grocery_Data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;

