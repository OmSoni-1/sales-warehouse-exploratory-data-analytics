/*
=============================================================================================
		               Customer Segmentation and Segment Analysis 
=============================================================================================
Here we will Segment products into cost ranges and count how many 
products fall into each segment and analyze how an individual 
segment is performing compared to the overall, allowing us to 
understand which segment has the greatest impact on the business.
*/
=============================================================================================
--                             Product Segmentation  
=============================================================================================

WITH prod_segment as(
  Select
    product_key,
    product_name,
    cost,
    CASE WHEN cost < 100 THEN 'Below 100'
    	 WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
    	 WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
    	 ELSE 'Above 1000'
    END as cost_segment
  from gold.dim_products
)
Select 
  cost_segment,
  COUNT(product_key) as total_products
from prod_segment
GROUP BY cost_segment
order by total_products DESC;

/*
=============================================================================================
                                  Customer Segmentation  
=============================================================================================
Group customers into three segments based on their spending behavior:
- VIP: Customers with at least 12 months of history and spending more than €5,000.
- Regular: Customers with at least 12 months of history but spending €5,000 or less
- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group

Queries for Initial Analysis
- Select * from gold.dim_customers;
- Select * from gold.fact_sales;
*/

WITH cust_segmentation as(
  Select 
    c.customer_key,
    --c.first_name, c.last_name,
    SUM(f.sales_amount) as total_expenditure,
    DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) as lifespan
  from gold.dim_customers c
  LEFT JOIN gold.fact_sales f
  on c.customer_key = f.customer_key
  group by c.customer_key
)
Select 
  cust_segment,
  COUNT(customer_key) as total_customers
from(
  Select 
    customer_key, 
    total_expenditure,
    lifespan,
    CASE WHEN total_expenditure > 5000 AND lifespan >= 12 THEN 'VIP'
    	 WHEN total_expenditure <= 5000 AND lifespan >= 12 THEN 'Regular'
    	 ELSE 'New'
    END as cust_segment
  from cust_segmentation
) t
GROUP by cust_segment
order by total_customers desc;
