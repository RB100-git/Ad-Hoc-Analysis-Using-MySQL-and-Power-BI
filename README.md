# Consumer-Goods--Business-Insights

SELECT * FROM gdb041.dim_customer;
SELECT * FROM gdb041.dim_product;
SELECT * FROM gdb041.fact_gross_price;
SELECT * FROM gdb041.fact_manufacturing_cost;
SELECT * FROM gdb041.fact_pre_invoice_deductions;

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






















































































