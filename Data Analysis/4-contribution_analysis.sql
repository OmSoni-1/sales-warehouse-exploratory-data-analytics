/*
===================================================================================================================
			                              Part-to-whole (Contribution) Analysis 
===================================================================================================================
Here we will Analyze how an individual part is performing compared 
to the overall, allowing us to understand which category has the
greatest impact on the business.

Initial queries for analysis
-Select * from gold.dim_customers
-Select * from gold.fact_sales
*/

-- How each category cotributes to the overall Sales
WITH category_sales as(
  Select 
    p.category,
    SUM(f.sales_amount) as total_sales
  from gold.fact_sales f
  LEFT JOIN gold.dim_products p
  ON p.product_key = f.product_key
  group by category
)
Select 
  category,
  total_sales,
  SUM(total_sales) OVER() as overall_sales,
  CONCAT(ROUND((CAST(total_sales as FLOAT)/ SUM(total_sales) OVER()) * 100, 2), '%') as contribution
from category_sales
order by total_sales DESC;

----------------------------------------------------------------------------------------------------------------------

-- How each category cotributes to the overall Customers
WITH category_customers as(
  Select 
    p.category,
    COUNT(f.customer_key) as total_cust
  from gold.fact_sales f
  LEFT JOIN gold.dim_products p
  ON f.product_key = p.product_key
  group by category
)
Select 
  category,
  total_cust,
  SUM(total_cust) OVER() as overall_cust,
  CONCAT(ROUND((CAST(total_cust as FLOAT)/ SUM(total_cust) OVER()) * 100, 2), '%') as cust_base
from category_customers
order by total_cust DESC;


----------------------------------------------------------------------------------------------------------------------

-- Countries' Contribution in Sales
WITH country_sales as(
  Select 
    c.country,
    SUM(f.sales_amount) as total_sales,
    COUNT(f.customer_key) as total_cust
  from gold.fact_sales f
  LEFT JOIN gold.dim_customers c
  ON c.customer_key = f.customer_key
  group by c.country
)
Select 
  country,
  total_sales,
  SUM(total_sales) OVER() as overall_sales,
  CONCAT(ROUND((CAST(total_sales as FLOAT)/ SUM(total_sales) OVER()) * 100, 2), '%') as sales_contrib, 
  total_cust,
  SUM(total_cust) OVER() as overall_cust,
  CONCAT(ROUND((CAST(total_cust as FLOAT)/ SUM(total_cust) OVER()) * 100, 2), '%') as cust_base,
  CONCAT('$', ' ', ROUND((CAST(total_sales as FLOAT) / total_cust), 2)) as per_cust_contrib
from country_sales
order by total_sales DESC;
