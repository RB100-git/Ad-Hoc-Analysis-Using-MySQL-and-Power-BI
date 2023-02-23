# Consumer-Goods--Business-Insights
## Overview:
Atliq Hardwares (Imaginary Company) is a leading computer hardware producer in India and is expanding globally. 
However, the management noticed that they do not get enough insights to make quick and smart data-informed decisions. The management recognizes the importance of data analytics in driving informed business decisions and has decided to strengthen their data analytics team by hiring several junior data analysts. To achieve this goal, the company's data analytics director has decided to conduct a SQL challenge to evaluate the technical and soft skills of potential candidates. The challenge will assess their SQL proficiency, ability to work within strict deadline, communication skills, and collaboration skills. The results of the challenge will be used to make informed hiring decisions and build a strong and effective data analytics team that will support Atliq Hardwares in making data-driven decisions and expanding its reach in the global market.

## Requirements:
Let’s be more precise about the requirements for this project through the following points:

•Atliq Hardwares is seeking insights on 10 ad hoc requests for their business purpose.

•A SQL query-based solution is required to answer the requests.

•Creativity in presenting insights.

•Ability to effectively communicate technical information to the top-level management.


## Tools:
• **SQL**: To extract and manipulate data from the database to answer the 10 ad-hoc requests for insights.

• **Power BI**: As a visualization tool to present my findings.(you can use other tools too e.g Excel)



## 1)	Setup ‘atliq_hardware_db’file in MySQL

Firstly, download ‘atliq_hardware_db’ file. Open MySQL Workbench and set up the connection with user name and password. To import the file, click on **Server > Data Import**.

![s11](https://user-images.githubusercontent.com/102472369/221019016-8922b962-565b-4bba-8af0-442f92059134.png)

Choose the option Import from Self-Contained File and click on the three dots to select the file.

![s12](https://user-images.githubusercontent.com/102472369/221019162-51dcfe4a-c0a8-4fc5-b1f9-35bc1418d5ea.png)

Once the import is completed, you should see the below table *'gdb041'*:

![s13](https://user-images.githubusercontent.com/102472369/221019280-0a883ebc-a021-4d5a-9cc8-3acdd8d5d5c7.png)




## 2)	 Connect MySQL database with Power BI:
Open Power BI Desktop app and click on **Get data > more > MySQL database** and fill out the informations.

![po2 (2)](https://user-images.githubusercontent.com/102472369/221025238-842970d3-8f32-4e12-a6fb-3481682a882e.PNG)

After writing the sql statement you will be able to see the output. Now you just have to load the data and proceed with the visualization.

![po4 (2)](https://user-images.githubusercontent.com/102472369/221025878-11f2efd9-9adc-47ee-b902-1f1852dc2c93.PNG)









##  About the database schema:
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
![d3](https://user-images.githubusercontent.com/102472369/221018407-f8176fdc-4961-44b7-8f0d-6b33accd0631.PNG)

4. fact_manufacturing_cost: contains the cost incurred in the production of each product
```
SELECT * FROM gdb041.fact_manufacturing_cost;
```
![d4](https://user-images.githubusercontent.com/102472369/221018505-3925c32d-48ce-4da3-8d52-9a849f4683d7.PNG)

5. fact_pre_invoice_deductions: contains pre-invoice deductions information for each product
```
SELECT * FROM gdb041.fact_pre_invoice_deductions;
```
![d5](https://user-images.githubusercontent.com/102472369/221018657-02b30ecc-5091-4ffc-98c3-f185d1e42dab.PNG)

6. fact_sales_monthly: contains monthly sales data for each product.
```
SELECT * FROM gdb041.fact_sales_monthly;
```
![d6](https://user-images.githubusercontent.com/102472369/221018723-78c6a8e5-743e-4a1c-ae21-d6dfeb859d49.PNG)

## Ad-Hoc requests:
Now it’s time to check all the requests that we need to solve one by one.
## Question 1.

**Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.**

```
SELECT DISTINCT market FROM dim_customer WHERE customer = 'Atliq Exclusive' AND region = 'APAC';
```
![q1](https://user-images.githubusercontent.com/102472369/221028776-7ed8e679-d6e5-49c4-8974-dc132c17fed6.PNG)


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
![q2](https://user-images.githubusercontent.com/102472369/221028832-8369ea32-2a67-4e41-ac88-7f1ddb31b04d.PNG)

## Question 3.
**Provide a report with all the unique product counts for each segment and sort them in descending order of product counts.
The final output contains 2 fields:
a) segment 
b) product_count**

```
SELECT segment, COUNT(DISTINCT product_code) as product_count FROM dim_product GROUP BY segment ORDER BY product_code DESC
```
![q3](https://user-images.githubusercontent.com/102472369/221028897-503f5d56-710d-4e16-819e-35f607e65d67.PNG)

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
![x](https://user-images.githubusercontent.com/102472369/221028962-5b3e418a-e176-4f2e-94a0-ae2f2b99da6c.PNG)

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
![q5](https://user-images.githubusercontent.com/102472369/221029063-ee032aa3-d800-4b88-952b-43bae276dc96.png)

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
![q6](https://user-images.githubusercontent.com/102472369/221029211-b4ce984f-3ff2-4019-b035-f388c90165e8.png)


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

![q7](https://user-images.githubusercontent.com/102472369/221029267-99f8feda-fa04-4c14-a7d3-8c81a12c7f9e.PNG)

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

![q8](https://user-images.githubusercontent.com/102472369/221029316-e5c011b6-6337-4beb-9594-84b86138c10c.PNG)

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
![q9](https://user-images.githubusercontent.com/102472369/221029368-a35c3810-15d0-4e38-b7e8-2630a70cb88a.PNG)


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

![q10](https://user-images.githubusercontent.com/102472369/221029469-c460c99e-8285-4d04-99c6-a541e8a858ad.PNG)


















































































