# Consumer-Goods--Business-Insights

1)	Setup ‘atliq_hardware_db’file in MySQL

Firstly, download ‘atliq_hardware_db’ file. Open MySQL Workbench and set up the connection with user name and password. To import the file, click on Server > Data Import.

 












Choose the option Import from Self-Contained File and click on the three dots to select the file.


 

Once the import is completed, you should see the below table 'gdb041':



 

1. dim_customer: contains customer-related data
```
SELECT * FROM gdb041.dim_customer;
```
![d1](https://user-images.githubusercontent.com/102472369/221017970-9effe72b-9159-4b20-8bf1-083e017ac49b.PNG)


2. dim_product: contains product-related data
```
SELECT * FROM gdb041.dim_product;
```
![d2](https://user-images.githubusercontent.com/102472369/221018186-85189655-c57b-4eeb-a5f7-dc160ddb89c3.PNG)


3. fact_gross_price: contains gross price information for each product
```
SELECT * FROM gdb041.fact_gross_price;
```
4. fact_manufacturing_cost: contains the cost incurred in the production of each product
```
SELECT * FROM gdb041.fact_manufacturing_cost;
```
5. fact_pre_invoice_deductions: contains pre-invoice deductions information for each product
```
SELECT * FROM gdb041.fact_pre_invoice_deductions;
```
6. fact_sales_monthly: contains monthly sales data for each product.
```
SELECT * FROM gdb041.fact_sales_monthly;
```


## Question 1.

**Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.**

```
SELECT DISTINCT market FROM dim_customer WHERE customer = 'Atliq Exclusive' AND region = 'APAC';
```


## Question 2.

**What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields:
 a) unique_products_2020
 b) unique_products_2021
 c) percentage_chg**

```
SELECT 
COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END) AS unique_products_2020,
COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code END) AS unique_products_2021,
((COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code END) - COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END)) / COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END)) * 100 AS percentage_chg
FROM fact_sales_monthly
``` 

## Question 3.
**Provide a report with all the unique product counts for each segment and sort them in descending order of product counts.
The final output contains 2 fields:
a) segment 
b) product_count**

```
SELECT segment, COUNT(DISTINCT product_code) as product_count FROM dim_product GROUP BY segment ORDER BY product_code DESC
```

## Question 4.

**Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields: 
a) segment 
b) product_count_2020 
c) product_count_2021 
d) difference**

```
WITH merged_table AS (SELECT dim_product.*,fact_sales_monthly.fiscal_year FROM dim_product JOIN fact_sales_monthly ON dim_product.product_code = fact_sales_monthly.product_code), 
unique_count_table AS (SELECT segment,fiscal_year,COUNT(DISTINCT product_code) as product_count FROM merged_table GROUP BY segment, fiscal_year), fiscal_year_count_table AS (SELECT segment,SUM(CASE WHEN fiscal_year = 2020 THEN product_count ELSE 0 END) as product_count_2020,SUM(CASE WHEN fiscal_year = 2021 THEN product_count ELSE 0 END) as product_count_2021
FROM unique_count_table GROUP BY segment) SELECT segment,product_count_2020,product_count_2021,product_count_2021 - product_count_2020 as difference FROM fiscal_year_count_table
```

## Question 5.

**Get the products that have the highest and lowest manufacturing costs. The final output should contain these fields:
a) product_code 
b) product 
c) manufacturing_cost**
```
WITH merged_table AS (SELECT dim_product.product_code, dim_product.product, dim_product.variant, fact_manufacturing_cost.manufacturing_cost
FROM dim_product JOIN fact_manufacturing_cost ON dim_product.product_code = fact_manufacturing_cost.product_code)
SELECT * FROM merged_table WHERE manufacturing_cost = (SELECT MAX(manufacturing_cost) FROM merged_table) OR manufacturing_cost = (SELECT MIN(manufacturing_cost) FROM merged_table) ORDER BY manufacturing_cost DESC, product_code
```

## Question 6.

**Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct  for the fiscal year 2021 and in the Indian market. The final output contains these fields:
a) customer_code 
b) customer 
c) average_discount_percentage**
```
SELECT fact_pre_invoice_deductions.customer_code, dim_customer.customer, AVG(fact_pre_invoice_deductions.pre_invoice_discount_pct) AS average_discount_percentage
FROM dim_customer INNER JOIN fact_pre_invoice_deductions ON dim_customer.customer_code = fact_pre_invoice_deductions.customer_code WHERE fact_pre_invoice_deductions.fiscal_year = '2021' AND dim_customer.market = 'India' GROUP BY fact_pre_invoice_deductions.customer_code, dim_customer.customer ORDER BY average_discount_percentage DESC
LIMIT 5
```

## Question 7.

**Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low and high-performing months and take strategic decisions. The final report contains these columns: 
a) Month 
b) Year 
c) Gross sales Amount**
```
SELECT monthname(fact_sales_monthly.date) AS month,YEAR(fact_sales_monthly.date) year, SUM(fact_gross_price.gross_price * fact_sales_monthly.sold_quantity) gross_sales_amount 
FROM fact_sales_monthly LEFT JOIN fact_gross_price ON fact_gross_price.product_code = fact_sales_monthly.product_code
LEFT JOIN dim_customer ON dim_customer.customer_code = fact_sales_monthly.customer_code WHERE dim_customer.customer = "Atliq Exclusive"
GROUP BY month, year 
ORDER BY year, month
```

## Question 8.

**In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields:
a) (sorted by) total_sold_quantity
b) Quarter **
```
SELECT CONCAT(QUARTER(date), 'Q', YEAR(date)) AS Quarter, SUM(sold_quantity) AS Total_Sold_Quantity FROM fact_sales_monthly WHERE YEAR(date) = 2020
GROUP BY QUARTER(date), YEAR(date)
ORDER BY Total_Sold_Quantity DESC
LIMIT 1;
```

## Question 9.

**Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? The final output contains these fields:
a) channel 
b) gross_sales_mln 
c) percentage**
```
WITH cte AS(SELECT dim_customer.channel channel,SUM(fact_sales_monthly.sold_quantity * fact_gross_price.gross_price) AS gross_sales_mln
FROM fact_sales_monthly LEFT JOIN fact_gross_price ON fact_sales_monthly.product_code = fact_gross_price.product_code
LEFT JOIN dim_customer ON fact_sales_monthly.customer_code = dim_customer.customer_code WHERE fact_sales_monthly.fiscal_year = 2021 GROUP BY dim_customer.channel)
SELECT channel, gross_sales_mln, ROUND(gross_sales_mln*100/(SELECT SUM(gross_sales_mln) FROM cte),2)percentage FROM cte
GROUP BY channel, gross_sales_mln 
ORDER BY gross_sales_mln DESC
```

## Question 10.

**Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? The final output contains these fields:
a) division 
b) product_code 
c) product 
d) total_sold_quantity 
e) rank_order**
```
WITH merged_data AS (SELECT dim_product.division, dim_product.product_code, dim_product.product, fact_sales_monthly.sold_quantity, fact_sales_monthly.fiscal_year
FROM dim_product INNER JOIN fact_sales_monthly ON dim_product.product_code = fact_sales_monthly.product_code),
aggregated_data AS (SELECT division, MAX(Total_Sold_Quantity) AS Max_Total_Sold_Quantity FROM (SELECT product_code, product, division, fiscal_year, 
SUM(sold_quantity) AS Total_Sold_Quantity FROM merged_data WHERE fiscal_year = 2021 GROUP BY product_code, product, division, fiscal_year) subquery GROUP BY division), ranked_data AS (SELECT division, product_code, product, fiscal_year, Total_Sold_Quantity, ROW_NUMBER() OVER (ORDER BY Total_Sold_Quantity DESC) AS rank_order
FROM (SELECT division, product_code, product, fiscal_year, Total_Sold_Quantity FROM (SELECT product_code, product, division, fiscal_year, 
SUM(sold_quantity) AS Total_Sold_Quantity FROM merged_data WHERE fiscal_year = 2021 GROUP BY product_code, product, division, fiscal_year) subquery
WHERE Total_Sold_Quantity = (SELECT Max_Total_Sold_Quantity FROM aggregated_data WHERE division = subquery.division)) subquery2) 
SELECT division, product_code, product, fiscal_year, Total_Sold_Quantity, rank_order FROM ranked_data
```



















































































