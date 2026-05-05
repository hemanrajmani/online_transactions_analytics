**Project: Online Retail Analytics Dashboard (Using Power BI + SQL +
Python)**

------------------------------------------------------------------------

**Project Overview:**

This project analyzes online retail transaction data to uncover key
business insights related to revenue, customer behavior, product
performance, and order cancellations.

The solution follows a complete data pipeline approach:

  - Data extraction from external source (UCI Machine Learning Repository)

  - Data cleaning using Python

  - Data modeling using SQL

  - Interactive dashboard creation using Power BI

------------------------------------------------------------------------

**Objectives**

  - Analyze revenue trends (YoY, QoQ, MoM)

  - Identify top-performing products and countries

  - Detect peak sales periods (hour/day/month)

  - Perform customer segmentation using RFM analysis

  - Analyze order cancellations and identify risk factors

  - Build dynamic, filter-driven business insights

------------------------------------------------------------------------

**Tech Stack**

| **Tool**       | **Purpose**                    |
|----------------|--------------------------------|
| Python         | Data cleaning & preprocessing  |
| SQL            | Data modeling & transformation |
| Power BI       | Data visualization & dashboard |
| DAX            | Dynamic measures & insights    |
| Excel/Web Data | Raw data source                |

------------------------------------------------------------------------

**Data Pipeline**

  ***1. Data Extraction***

  - Data sourced from online retail dataset (web source)

------------------------------------------------------------------------

  ***2. Data Cleaning (Python)***

  - Handled missing values

  - Converted date formats

  - Removed duplicates

  - Created structured dataset

  *File: Python_Online Retail Transaction.ipynb*

------------------------------------------------------------------------

  ***3. Data Modeling (SQL)***

  - Created fact and dimension tables:

    - fact_sales

    - dim_date

    - dim_products

    - dim_customers

  - Applied relationships and constraints

  *File: SQL_Online Retail Transaction.sql*

------------------------------------------------------------------------

***4. Data Visualization (Power BI)***

  - Built interactive dashboards with:

    - KPI cards

    - Trend analysis

    - Heatmaps

    - RFM segmentation

    - Cancellation analysis

------------------------------------------------------------------------

**Dashboard Pages**

  ***1. Metrics Overview***

  - Revenue, Orders, Quantity KPIs

  - YoY, QoQ, MoM comparison

  - Country & category filters

------------------------------------------------------------------------

  ***2. Revenue Analysis***

  - Monthly revenue trends

  - Revenue by country

  - Weekday vs weekend comparison

------------------------------------------------------------------------

  ***3. Product Analysis***

  - Top-selling products

  - Sales trends

  - Product performance by region

------------------------------------------------------------------------

  ***4. Peak Period Analysis***

  - Heatmaps for:

    - Hourly sales

    - Weekly trends

  - Identifies peak demand periods

------------------------------------------------------------------------

  ***5. RFM Analysis***

  - Customer segmentation:

    - Champions

    - At Risk

    - Loyal Customers

  - Recency, Frequency, Monetary insights

------------------------------------------------------------------------

  ***6. Cancelled Orders Analysis***

  - Cancellation rate & volume

  - Monthly cancellation trends

  - Cancellation by product & country

  - Dynamic insights for business actions

------------------------------------------------------------------------

**Key Business Insights**

  - Revenue shows seasonal spikes, especially in Q4

  - A smart product contributes majority of revenue

  - Peak sales occur during mid-day hours

  - High-value customers (Champions) drive most revenue

  - Significant number of at-risk customers identified

  - Cancellation rate highlights potential issues in Product quality,
  Pricing strategy, Delivery performance

------------------------------------------------------------------------

**Dynamic Features**

  - Fully interactive filters:

    - Year, Month, Country, Product

  - Dynamic DAX-based insights

  - Context-aware calculations (auto-adjust with slicers)

  - Drill-through and tooltip enhancements

------------------------------------------------------------------------

**Advanced Techniques Used**

  - DAX:

    - AGGREGATED DAX, CALCULATE, TOPN, SUMMARIZE, DIVIDE, RANKX,
    REMOVEFILTERS, DISTINCT, ALL, SELECTEDVALUE, SWITCH, IF and DATE &
    TIME DAX

  - Dynamic insight generation using text measures

  - RFM segmentation logic

  - Time intelligence (YoY, MoM)

  - Heatmap visualization for peak analysis

------------------------------------------------------------------------

**How to Use**

<!-- -->

  1.  Open the .pbix file in Power BI

  2.  Use slicers to filter data

  3.  Navigate across dashboard pages

  4.  Hover over visuals for detailed insights

  5.  Review dynamic insight panels
