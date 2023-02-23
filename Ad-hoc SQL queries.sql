SELECT * FROM gdb041.dim_customer;
SELECT * FROM gdb041.dim_product;
SELECT * FROM gdb041.fact_gross_price;
SELECT * FROM gdb041.fact_manufacturing_cost;
SELECT * FROM gdb041.fact_pre_invoice_deductions;
SELECT * FROM gdb041.fact_sales_monthly;

SELECT DISTINCT market FROM dim_customer WHERE customer = 'Atliq Exclusive' AND region = 'APAC';

SELECT 
COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END) AS unique_products_2020,
COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code END) AS unique_products_2021,
((COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code END) - COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END)) / COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END)) * 100 AS percentage_chg
FROM fact_sales_monthly
 
SELECT segment, COUNT(DISTINCT product_code) as product_count FROM dim_product GROUP BY segment ORDER BY product_code DESC

WITH merged_table AS (SELECT dim_product.*,fact_sales_monthly.fiscal_year FROM dim_product JOIN fact_sales_monthly ON dim_product.product_code = fact_sales_monthly.product_code), 
unique_count_table AS (SELECT segment,fiscal_year,COUNT(DISTINCT product_code) as product_count FROM merged_table GROUP BY segment, fiscal_year), fiscal_year_count_table AS (SELECT segment,SUM(CASE WHEN fiscal_year = 2020 THEN product_count ELSE 0 END) as product_count_2020,SUM(CASE WHEN fiscal_year = 2021 THEN product_count ELSE 0 END) as product_count_2021
FROM unique_count_table GROUP BY segment) SELECT segment,product_count_2020,product_count_2021,product_count_2021 - product_count_2020 as difference FROM fiscal_year_count_table

WITH merged_table AS (SELECT dim_product.product_code, dim_product.product, dim_product.variant, fact_manufacturing_cost.manufacturing_cost
FROM dim_product JOIN fact_manufacturing_cost ON dim_product.product_code = fact_manufacturing_cost.product_code)
SELECT * FROM merged_table WHERE manufacturing_cost = (SELECT MAX(manufacturing_cost) FROM merged_table) OR manufacturing_cost = (SELECT MIN(manufacturing_cost) FROM merged_table) ORDER BY manufacturing_cost DESC, product_code

SELECT fact_pre_invoice_deductions.customer_code, dim_customer.customer, AVG(fact_pre_invoice_deductions.pre_invoice_discount_pct) AS average_discount_percentage
FROM dim_customer INNER JOIN fact_pre_invoice_deductions ON dim_customer.customer_code = fact_pre_invoice_deductions.customer_code WHERE fact_pre_invoice_deductions.fiscal_year = '2021' AND dim_customer.market = 'India' GROUP BY fact_pre_invoice_deductions.customer_code, dim_customer.customer ORDER BY average_discount_percentage DESC
LIMIT 5

SELECT monthname(fact_sales_monthly.date) AS month,YEAR(fact_sales_monthly.date) year, SUM(fact_gross_price.gross_price * fact_sales_monthly.sold_quantity) gross_sales_amount 
FROM fact_sales_monthly LEFT JOIN fact_gross_price ON fact_gross_price.product_code = fact_sales_monthly.product_code
LEFT JOIN dim_customer ON dim_customer.customer_code = fact_sales_monthly.customer_code 
WHERE dim_customer.customer = "Atliq Exclusive" GROUP BY month, year ORDER BY year, month

SELECT CONCAT(QUARTER(date), 'Q', YEAR(date)) AS Quarter, SUM(sold_quantity) AS Total_Sold_Quantity FROM fact_sales_monthly WHERE YEAR(date) = 2020
GROUP BY QUARTER(date), YEAR(date)
ORDER BY Total_Sold_Quantity DESC
LIMIT 1;


WITH cte AS(SELECT dim_customer.channel channel,SUM(fact_sales_monthly.sold_quantity * fact_gross_price.gross_price) AS gross_sales_mln
FROM fact_sales_monthly LEFT JOIN fact_gross_price ON fact_sales_monthly.product_code = fact_gross_price.product_code
LEFT JOIN dim_customer ON fact_sales_monthly.customer_code = dim_customer.customer_code WHERE fact_sales_monthly.fiscal_year = 2021 GROUP BY dim_customer.channel)
SELECT channel, gross_sales_mln, ROUND(gross_sales_mln*100/(SELECT SUM(gross_sales_mln) FROM cte),2)percentage FROM cte
GROUP BY channel, gross_sales_mln 
ORDER BY gross_sales_mln DESC

WITH merged_data AS (SELECT dim_product.division, dim_product.product_code, dim_product.product, fact_sales_monthly.sold_quantity, fact_sales_monthly.fiscal_year
FROM dim_product INNER JOIN fact_sales_monthly ON dim_product.product_code = fact_sales_monthly.product_code),
aggregated_data AS (SELECT division, MAX(Total_Sold_Quantity) AS Max_Total_Sold_Quantity FROM (SELECT product_code, product, division, fiscal_year, 
SUM(sold_quantity) AS Total_Sold_Quantity FROM merged_data WHERE fiscal_year = 2021 GROUP BY product_code, product, division, fiscal_year) subquery GROUP BY division), ranked_data AS (SELECT division, product_code, product, fiscal_year, Total_Sold_Quantity, ROW_NUMBER() OVER (ORDER BY Total_Sold_Quantity DESC) AS rank_order
FROM (SELECT division, product_code, product, fiscal_year, Total_Sold_Quantity FROM (SELECT product_code, product, division, fiscal_year, 
SUM(sold_quantity) AS Total_Sold_Quantity FROM merged_data WHERE fiscal_year = 2021 GROUP BY product_code, product, division, fiscal_year) subquery
WHERE Total_Sold_Quantity = (SELECT Max_Total_Sold_Quantity FROM aggregated_data WHERE division = subquery.division)) subquery2) 
SELECT division, product_code, product, fiscal_year, Total_Sold_Quantity, rank_order FROM ranked_data
