/*
===================================================================
Analysis of Change in Sales & Other Metrices Over Periods of Time
===================================================================
Here we will have a look at the total sales amount, the total 
number of customers and the order quantity over the years and 
months of the years.
*/

-- Change Analysis by Year
Select 
  YEAR(order_date) as order_year, 
  SUM(sales_amount) as total_sales,
  COUNT(DISTINCT customer_key) as total_customers,
  SUM(quantity) as order_quantity
from gold.fact_sales
where order_date is not null
group by YEAR(order_date)
order by YEAR(order_date);

--------------------------------------------------------------------

-- Change Analysis by Month
Select 
  MONTH(order_date) as order_month, 
  SUM(sales_amount) as total_sales,
  COUNT(DISTINCT customer_key) as total_customers,
  SUM(quantity) as order_quantity
from gold.fact_sales
where order_date is not null
group by MONTH(order_date)
order by MONTH(order_date);

--------------------------------------------------------------------

-- Using DateTrunc and Format
Select 
  Format(DATETRUNC(month, order_date), 'MMM-yyyy') as order_date, 
  SUM(sales_amount) as total_sales,
  COUNT(DISTINCT customer_key) as total_customers,
  SUM(quantity) as order_quantity
from gold.fact_sales
where order_date is not null
group by DATETRUNC(month, order_date)
order by DATETRUNC(month, order_date);
