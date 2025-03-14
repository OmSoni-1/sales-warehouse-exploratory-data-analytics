/*
================================================================================================================================
					                                            Performance Analysis 
================================================================================================================================
Here we will analyze the yearly performance of products by 
comparing their sales to both the average sales performance of the 
product and the previous year's sales.
*/

/*
---------------------------------------------------------------------------------------------------------------------------------
					                                                Sales Analysis 
---------------------------------------------------------------------------------------------------------------------------------
*/
                                              --		Year Over Year Analysis		--

WITH current_sales as (
  Select 
    YEAR(f.order_date) as order_year,
    p.product_name,
    SUM(f.sales_amount) as current_sales
  FROM gold.fact_sales f
  LEFT JOIN gold.dim_products p
  ON f.product_key = p.product_key
  WHERE YEAR(f.order_date) is not null
  GROUP BY YEAR(f.order_date), p.product_name
) 
Select 
  order_year,
  product_name,
  current_sales,
  AVG(current_sales) OVER(PARTITION BY product_name) as avg_sales,
  current_sales - AVG(current_sales) OVER(PARTITION BY product_name) as diff_avg,
  CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
  	 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
  	 Else 'Avg'
  END as performance,
  --		Year Over Year Analysis		--
  LAG(current_sales) OVER(PARTITION BY product_name order by order_year) as py_sales,
  current_sales - LAG(current_sales) OVER(PARTITION BY product_name order by order_year) as perf_diff,
  CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name order by order_year) > 0 THEN 'Growth'
  	 WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name order by order_year) < 0 THEN 'Degrowth'
  	 Else 'No Change'
  END as sales_perf
from current_sales
order by product_name, order_year;

---------------------------------------------------------------------------------------------------------------------------------

                                            --		Month Over Month Analysis		--

WITH current_sales as (
  Select 
    Format(DATETRUNC(MONTH, f.order_date), 'MMM - yyyy') as order_year,
    p.product_name,
    SUM(f.sales_amount) as current_sales
  FROM gold.fact_sales f
  LEFT JOIN gold.dim_products p
  ON f.product_key = p.product_key
  WHERE MONTH(f.order_date) is not null
  GROUP BY DATETRUNC(MONTH, f.order_date), p.product_name
) 
Select 
  order_year,
  product_name,
  current_sales,
  AVG(current_sales) OVER(PARTITION BY product_name) as avg_sales,
  current_sales - AVG(current_sales) OVER(PARTITION BY product_name) as diff_avg,
  CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
  	 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
  	 Else 'Avg'
  END as performance,
  --		Month Over Month Analysis		--
  LAG(current_sales) OVER(PARTITION BY product_name order by order_year) as py_sales,
  current_sales - LAG(current_sales) OVER(PARTITION BY product_name order by order_year) as perf_diff,
  CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name order by order_year) > 0 THEN 'Growth'
  	 WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name order by order_year) < 0 THEN 'Degrowth'
  	 Else 'No Change'
  END as sales_perf
from current_sales
order by product_name, order_year;

/*
---------------------------------------------------------------------------------------------------------------------------------
					                                   Product Quantity Analysis 
---------------------------------------------------------------------------------------------------------------------------------
*/

WITH current_quantity as (
  Select 
    YEAR(f.order_date) as order_year,
    p.product_name,
    SUM(f.quantity) as current_quantity
  FROM gold.fact_sales f
  LEFT JOIN gold.dim_products p
  ON f.product_key = p.product_key
  WHERE YEAR(f.order_date) is not null
  GROUP BY YEAR(f.order_date), p.product_name
) 
Select 
  order_year,
  product_name,
  current_quantity,
  AVG(current_quantity) OVER(PARTITION BY product_name) as avg_quantity,
  current_quantity - AVG(current_quantity) OVER(PARTITION BY product_name) as diff_avg,
  CASE WHEN current_quantity - AVG(current_quantity) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
  	 WHEN current_quantity - AVG(current_quantity) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
  	 Else 'Avg'
  END as performance,
  --		Year Over Year Analysis		--
  LAG(current_quantity) OVER(PARTITION BY product_name order by order_year) as py_quantity,
  current_quantity - LAG(current_quantity) OVER(PARTITION BY product_name order by order_year) as perf_diff,
  CASE WHEN current_quantity - LAG(current_quantity) OVER(PARTITION BY product_name order by order_year) > 0 THEN 'Growth'
  	 WHEN current_quantity - LAG(current_quantity) OVER(PARTITION BY product_name order by order_year) < 0 THEN 'Degrowth'
  	 Else 'No Change'
  END as quantity_perf
from current_quantity
order by product_name, order_year;
