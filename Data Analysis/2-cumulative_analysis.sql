/*
===================================================================
Cumulative Sales & Prices Analysis Over Period of Time
===================================================================
Here we will have a look at the total sales amount, and the running 
sales amount over the years and months of the years, alongwith the 
moving average prices of the products.
*/

-- Over the Months
Select 
  FORMAT(order_date, 'MMM - yyyy') as order_date,
  total_sales,
  SUM(total_sales) OVER(PARTITION BY YEAR(order_date) order by order_date) as monthly_running_sales,
  AVG(average_prices) OVER(PARTITION BY YEAR(average_prices) order by order_date) as moving_average
FROM(
  Select 
    DATETRUNC(MONTH, order_date) as order_date,
    SUM(sales_amount) as total_sales,
    AVG(price) as average_prices
  from gold.fact_sales
  where order_date is not null
  group by DATETRUNC(MONTH, order_date)
)t 
order by DATETRUNC(MONTH, order_date);

--------------------------------------------------------------------

-- Over the Years
Select 
  order_date as order_date,
  total_sales,
  SUM(total_sales) OVER(order by order_date) as yearly_running_sales,
  AVG(average_price) OVER(order by order_date) as moving_average
FROM(
  Select 
    DATETRUNC(YEAR, order_date) as order_date,
    SUM(sales_amount) as total_sales,
    AVG(price) as average_price
  from gold.fact_sales
  where order_date is not null
  group by DATETRUNC(YEAR, order_date)
) t;
