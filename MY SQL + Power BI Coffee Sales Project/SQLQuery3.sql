USE coffee_shop_sales_db; -- Switch to the coffee_shop_sales_db database
GO


SELECT * FROM coffee_shop_sales; -- Retrieve all records from the coffee_shop_sales table

-- Total Sales for May

SELECT SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5

-- Monthly Sales Comparison for April and May

SELECT 
    MONTH(transaction_date) AS month,--Number of month
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)--Total sales
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1)--
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

-- Total Orders for May

SELECT COUNT(transaction_id) as Total_Orders
FROM coffee_shop_sales 
WHERE MONTH (transaction_date)= 5 -- for month of (CM-May)


-- Monthly Orders Comparison for April and May

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id), 2) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);


-- Total Quantity Sold for May

SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM coffee_shop_sales 
WHERE MONTH(transaction_date) = 5 -- for month of (CM-May)


-- Monthly Quantity Comparison for April and May

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty), 2) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);


-- Sales Data for 18th May 2023

SELECT
    ROUND(SUM(unit_price * transaction_qty)/1000,1) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(transaction_id) AS total_orders
FROM 
    coffee_shop_sales
WHERE 
    transaction_date = '2023-05-18'; --For 18 May 2023

-- Sales Data for Weekends and Weekdays on 18th May 2023
--Weekends = saturday and sunday
--Weekdays = Monday to Friday

SELECT
    CASE 
        WHEN DATEPART(WEEKDAY, transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty) / 1000.0, 1) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(transaction_id) AS total_orders
FROM 
    coffee_shop_sales
WHERE 
    transaction_date = '2023-05-18' -- For 18 May 2023
GROUP BY
    CASE 
        WHEN DATEPART(WEEKDAY, transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;


-- Sales by Store Location for May

SELECT
	store_location,
	ROUND(SUM(unit_price * transaction_qty), 2) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC



-- Average Sales for May

SELECT AVG(unit_price * transaction_qty) AS Avg_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5


-- Average Daily Sales for May

SELECT 
	ROUND(AVG(total_sales),1) AS Avg_Sales
FROM
	(
	SELECT SUM(unit_price * transaction_qty) AS total_sales
	FROM coffee_shop_sales
	WHERE MONTH(transaction_date) = 5
	GROUP BY transaction_date
	) AS Internal_query

-- Daily Sales for May

SELECT 
	DAY(transaction_date) AS day_of_month,
	SUM(unit_price * transaction_qty) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date)



-- Sales Status Compared to Average for May

SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
		SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;


-- Sales by category

SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP by product_category
ORDER by SUM(unit_price * transaction_qty) DESC

--TOP 10 products by sales

SELECT TOP 10
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP by product_type
ORDER by SUM(unit_price * transaction_qty) DESC

--Sales anlaysis for days and hours

SELECT 
    ROUND(SUM(unit_price * transaction_qty), 1) AS Total_sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_orders
FROM 
    coffee_shop_sales
WHERE 
    DATEPART(WEEKDAY, transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND DATEPART(HOUR, transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)


--TO GET SALES FOR ALL HOURS FOR MONTH OF MAY

SELECT 
    DATEPART(HOUR, transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty), 0) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    DATEPART(HOUR, transaction_time)
ORDER BY 
    Hour_of_Day;

--TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY


WITH SalesByDay AS (
    SELECT 
        CASE 
            WHEN DATEPART(WEEKDAY, transaction_date) = 2 THEN 'Monday'
            WHEN DATEPART(WEEKDAY, transaction_date) = 3 THEN 'Tuesday'
            WHEN DATEPART(WEEKDAY, transaction_date) = 4 THEN 'Wednesday'
            WHEN DATEPART(WEEKDAY, transaction_date) = 5 THEN 'Thursday'
            WHEN DATEPART(WEEKDAY, transaction_date) = 6 THEN 'Friday'
            WHEN DATEPART(WEEKDAY, transaction_date) = 7 THEN 'Saturday'
            ELSE 'Sunday'
        END AS Day_of_Week,
        unit_price * transaction_qty AS Sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5
)
SELECT 
    Day_of_Week,
    ROUND(SUM(Sales), 0) AS Total_Sales
FROM 
    SalesByDay
GROUP BY 
    Day_of_Week
ORDER BY 
    Total_Sales DESC;



