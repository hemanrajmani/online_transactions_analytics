/* Online Transaction SQL Query*/

-- Creating Shell
CREATE DATABASE retail_dw;
GO
USE retail_dw;

-- Creating Schema

-- Transaction Table
CREATE TABLE otransactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    invoiceno VARCHAR(15) NOT NULL,
    stockcode VARCHAR(15) NOT NULL,
    description NVARCHAR(255),
    quantity INT,
    invoice_datetime DATETIME2,
    unitprice DECIMAL(10,2),
    customerid INT,
    country NVARCHAR(40),
    is_return BIT,
    is_cancelled_pair BIT,
    revenue AS (quantity * unitprice),
    year INT,
    month INT,
    day INT,
    hour INT,
    dayofweek VARCHAR(15));


-- Information Schema
Select column_name, data_type, character_maximum_length from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'otransactions';

-- Creating Dimension Tables
-- Customer Table
CREATE TABLE dim_customers (
    customer_id INT PRIMARY KEY,
    country NVARCHAR(50));

INSERT INTO retail_dw.dbo.dim_customers (customer_id, country)
SELECT customerid, MAX(country) AS country FROM otransactions
WHERE customerid IS NOT NULL
GROUP BY customerid;

-- Products Table
CREATE TABLE dim_products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    stockcode VARCHAR(20) UNIQUE);

INSERT INTO dim_products (stockcode)
SELECT DISTINCT stockcode FROM otransactions;

-- Date Table
CREATE TABLE dim_date (
    date_id INT IDENTITY(1,1) PRIMARY KEY,
    date_only DATE UNIQUE,
    year INT,
    month INT,
    day INT,
    month_name VARCHAR(20),
    dayofweek VARCHAR(20),
    weekday_number INT,
    quarter INT,
    week_number INT,
    is_weekend BIT);

INSERT INTO dim_date
(date_only, year, month, day, month_name, dayofweek, weekday_number, quarter, week_number, is_weekend)

SELECT DISTINCT
    CAST(invoice_datetime AS DATE),
    YEAR(invoice_datetime),
    MONTH(invoice_datetime),
    DAY(invoice_datetime),
    DATENAME(MONTH, invoice_datetime),
    DATENAME(WEEKDAY, invoice_datetime),
    DATEPART(WEEKDAY, invoice_datetime),
    DATEPART(QUARTER, invoice_datetime),
    DATEPART(WEEK, invoice_datetime),
    CASE 
        WHEN DATENAME(WEEKDAY, invoice_datetime) IN ('Saturday', 'Sunday') THEN 1
        ELSE 0
    END
FROM otransactions;

-- Creating Time table
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    hour INT,
    time_bucket VARCHAR(20));

WITH numbers AS (SELECT 0 AS n UNION ALL
                SELECT n + 1 FROM numbers WHERE n < 23)
INSERT INTO dim_time (time_id, hour, time_bucket)
SELECT n, n,
        CASE 
        WHEN n BETWEEN 6 AND 11 THEN 'Morning'
        WHEN n BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN n BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END
FROM numbers
OPTION (MAXRECURSION 100);


-- Sales (Fact) Table Retail
CREATE TABLE fact_sales (
    sales_id INT IDENTITY(1,1) PRIMARY KEY,
    invoiceno VARCHAR(15),
    customer_id INT,
    product_id INT,
    date_id INT,
    time_id INT,
    quantity INT,
    unitprice DECIMAL(10,2),
    revenue DECIMAL(10,2),
    is_return BIT,
    is_cancelled_pair BIT,

    -- Foreign Keys
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES dim_products(product_id),
    CONSTRAINT fk_date FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    CONSTRAINT fk_time FOREIGN KEY (time_id) REFERENCES dim_time(time_id));



INSERT INTO fact_sales (
    invoiceno,
    customer_id,
    product_id,
    date_id,
    time_id,
    quantity,
    unitprice,
    revenue,
    is_return,
    is_cancelled_pair)

SELECT 
    t.invoiceno,
    t.customerid,
    p.product_id,
    d.date_id,
    tm.time_id,
    t.quantity,
    t.unitprice,
    t.quantity * t.unitprice,
    t.is_return,
    t.is_cancelled_pair

FROM otransactions t
JOIN dim_products p ON t.stockcode = p.stockcode
JOIN dim_date d ON CAST(t.invoice_datetime AS DATE) = d.date_only
JOIN dim_time tm ON DATEPART(HOUR, t.invoice_datetime) = tm.hour
WHERE t.customerid IS NOT NULL;


/*   
The following queries fetch the data to show the below analysis
1. Business KPIs
2. Trends
3. Customer analysis
4. Product performance
5. Advanced
*/


-- Total Revenue by customers
SELECT c.customer_id, SUM(f.revenue) AS total_revenue FROM fact_sales f
JOIN dim_customers c ON f.customer_id = c.customer_id
WHERE is_return = 0
GROUP BY c.customer_id
ORDER BY total_revenue DESC;


-- Total Revenue
SELECT FORMAT(SUM(revenue), 'C', 'en-US') AS total_revenue FROM fact_sales WHERE is_return = 0;

-- Monthly Revenue Trend
SELECT d.year, d.month, SUM(f.revenue) AS revenue FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
WHERE is_return = 0
GROUP BY d.year, d.month
ORDER BY d.year, d.month;


-- Weekend vs Weekdays
SELECT d.year, d.month_name,
SUM(CASE WHEN d.is_weekend = 0 THEN f.revenue
    ELSE 0 END) AS weekday_revenue,
SUM(CASE WHEN d.is_weekend = 1 THEN f.revenue
    ELSE 0 END) AS weekend_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
WHERE is_return = 0
GROUP BY d.year, d.month_name
ORDER BY d.year, d.month_name;

--Quarterly Sales
SELECT d.year, d.quarter, SUM(f.revenue) AS revenue FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
WHERE is_return = 0
GROUP BY d.year, d.quarter;

-- Top 10 products by Revenue
SELECT TOP 10 p.stockcode, SUM(f.revenue) AS revenue FROM fact_sales f
JOIN dim_products p ON f.product_id = p.product_id
WHERE is_return = 0
GROUP BY p.stockcode
ORDER BY revenue DESC;

-- Top Customers
SELECT TOP 10 f.customer_id, SUM(f.revenue) AS total_spent FROM fact_sales f
WHERE is_return = 0
GROUP BY f.customer_id
ORDER BY total_spent DESC;

--Sales by Region
SELECT c.country, SUM(f.revenue) AS revenue FROM fact_sales f
JOIN dim_customers c ON f.customer_id = c.customer_id
WHERE is_return = 0
GROUP BY c.country
ORDER BY revenue DESC;

-- Average Order Value
SELECT SUM(revenue) / COUNT(DISTINCT invoiceno) AS avg_order_value FROM fact_sales WHERE is_return = 0;

-- Daily Sales Trend
SELECT d.date_only, SUM(f.revenue) AS revenue FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
WHERE is_return = 0
GROUP BY d.date_only
ORDER BY d.date_only;

--Repeat customer analysis
SELECT customer_id, COUNT(DISTINCT invoiceno) AS total_orders FROM fact_sales
WHERE is_return = 0
GROUP BY customer_id HAVING COUNT(DISTINCT invoiceno) >= 5
ORDER BY total_orders DESC;


-- RFM Analysis
WITH rfm AS (SELECT customer_id,
                    MAX(d.date_only) AS last_purchase,
                    COUNT(DISTINCT invoiceno) AS frequency,
                    SUM(revenue) AS monetary
                    FROM fact_sales f
            JOIN dim_date d ON f.date_id = d.date_id
            WHERE is_return = 0
            GROUP BY customer_id)

SELECT * FROM rfm ORDER BY monetary DESC;

--Top Selling Hour
SELECT t.hour, SUM(f.revenue) AS revenue FROM fact_sales f
JOIN dim_time t ON f.time_id = t.time_id
WHERE is_return = 0
GROUP BY t.hour
ORDER BY t.hour;

----------------------
--Revenue by Day of Week
SELECT d.dayofweek, SUM(f.revenue) AS revenue FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
WHERE is_return = 0
GROUP BY d.dayofweek
ORDER BY revenue DESC;

-- Return analysis
SELECT 
    SUM(CASE WHEN is_return = 1 AND is_cancelled_pair = 1 THEN revenue ELSE 0 END) AS returns,
    SUM(CASE WHEN is_return = 0 THEN revenue ELSE 0 END) AS sales
FROM fact_sales;

--Product performance trend by month and year
SELECT d.year, d.month, p.stockcode, SUM(f.revenue) AS revenue FROM fact_sales f
JOIN dim_products p ON f.product_id = p.product_id
JOIN dim_date d ON f.date_id = d.date_id
WHERE is_return = 0
GROUP BY d.year, d.month, p.stockcode
ORDER BY d.year, d.month, p.stockcode DESC;


--Customer segment
SELECT customer_id, CASE
                    WHEN SUM(revenue) > 5000 THEN 'High Value'
                    WHEN SUM(revenue) > 2000 THEN 'Medium Value'
                    ELSE 'Low Value'
                    END AS segment
FROM fact_sales
WHERE is_return = 0
GROUP BY customer_id
ORDER BY segment;




