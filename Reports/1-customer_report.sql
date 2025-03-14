/*
===================================================================
						          Report Generation 
===================================================================
Here we will create reports for various purpose

-------------------------------------------------------------------
						          Customer Report
-------------------------------------------------------------------
Purpose:
- This report consolidates key customer metrics and behaviors

Highlights:
1. Gathers essential fields such as names, ages, and transaction details.
2. Segments customers into categories (VIP, Regular, New) and age groups.
3. Aggregates customer-level metrics:
- total orders
- total sales
- total quantity purchased
- total products
- lifespan (in months)
4. Calculates valuable KPIs:
- recency (months since last order)
- average order value
- average monthly spend

*/

CREATE OR ALTER VIEW gold.report_customers as

WITH base_query as(
/*
--------------------------------------------------------
1. Base Query: Retrieves the base data for analysis
--------------------------------------------------------
*/
  SELECT
  	f.order_number,
  	f.product_key,
  	f.order_date,
  	f.sales_amount,
  	f.quantity,
  	c.customer_key,
  	c.customer_number,
  	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  	DATEDIFF(YEAR, c.birtddate, GETDATE()) as age
  FROM gold. fact_sales f
  LEFT JOIN gold.dim_customers c
  ON c.customer_key = f.customer_key
  WHERE order_date IS NOT NULL
), 
customer_aggregation as(
/*
---------------------------------------------------------------------
2. Customer Aggregation: Summarizes key metrics at customer level
---------------------------------------------------------------------
*/
  Select 
  	customer_key,
  	customer_number,
  	customer_name,
  	age,
  	COUNT(DISTINCT order_number) as total_orders,
  	SUM(sales_amount) as total_sales,
  	SUM(quantity) as total_quantity,
  	COUNT(DISTINCT product_key) as total_products,
  	MAX(order_date) as last_order_date,
  	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan
  from base_query
  GROUP BY 
  	customer_key,
  	customer_number,
  	customer_name,
  	age
)
Select 
  customer_key,
  customer_number,
  customer_name,
  age,
  CASE WHEN age < 20 THEN 'Under 20'
  	 WHEN age BETWEEN 20 AND 29 THEN '20 - 29'
  	 WHEN age BETWEEN 30 AND 39 THEN '30 - 39'
  	 WHEN age BETWEEN 40 AND 49 THEN '40 - 49'
  	 ELSE '50 and above'
  END as age_group,
  lifespan,
  CASE WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
  	 WHEN total_sales <= 5000 AND lifespan >= 12 THEN 'Regular'
  	 ELSE 'New'
  END as cust_segment,
  last_order_date,
  DATEDIFF(MONTH, last_order_date, GETDATE()) as recency,
  total_orders,
  total_sales,
  -- Calculating Average Value of rach Order
  -- Ensuring no error occurs when the total_orders (denominator) is 0.
  CASE WHEN total_orders = 0 THEN 0
  	 ELSE (total_sales / total_orders) 
  END as avg_order_value,
  -- Calculating Average monthly spend
  CASE WHEN lifespan = 0 THEN 0
  	 ELSE total_sales / lifespan 
  END as avg_monthly_sales,
  total_quantity,
  total_products
from customer_aggregation;
