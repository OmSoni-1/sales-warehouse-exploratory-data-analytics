/*
============================================================================================
                                    Product Report
============================================================================================
Purpose:
- This report consolidatas key product metrics and behaviors.

Highlights:
1. Gathers essential fields such as product name, category, subcategory, and cost. ♥
2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
3. Aggregates product-level metrics: ♥
- total orders
- total sales
- total quantity sold
- total customers (unique)
- lifespan (in months)
4. Calculates valuable KPIs:
- recency (months since last sale)
- average order revenue (AOR)
- average monthly revenue

============================================================================================
*/

--Select * from gold.fact_sales
--Select * from gold.dim_products

CREATE OR ALTER VIEW gold.report_products as

WITH base_query as(
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
	Select
		p.product_key,
		p.product_name, 
		p.category,
		p.subcategory,
		p.cost,
		f.order_number,
		f.sales_amount,
		f.quantity,
		f.customer_key,
		p.start_date,
		f.order_date
	from gold.dim_products p
	LEFT JOIN gold.fact_sales f
	ON p.product_key = f.product_key
	WHERE order_date IS NOT NULL
), 
product_aggregation as(
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
	Select 
		product_key,
		product_name, 
		category,
		subcategory,
		cost,
		COUNT(DISTINCT order_number) as total_orders,
		SUM(sales_amount) as total_sales,
		SUM(quantity) as total_quantity_sold,
		COUNT(DISTINCT customer_key) as total_customers,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan,
		ROUND((SUM(CAST(sales_amount as FLOAT)) / SUM(quantity)), 2) as avg_revenue,
		MAX(order_date) as last_sale_date
	from base_query
	GROUP BY
		product_key,
		product_name, 
		category,
		subcategory,
		cost
)
/*---------------------------------------------------------------------------
  3) Final Query
---------------------------------------------------------------------------*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity_sold,
	total_customers,
	avg_revenue,
	-- Average Order Revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,

	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue

FROM product_aggregation
