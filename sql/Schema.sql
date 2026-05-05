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

