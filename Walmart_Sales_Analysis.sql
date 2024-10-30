CREATE DATABASE WALMART_SALES_ANALYSIS;

-- Table Creation -- 

CREATE TABLE sales_data (
                         invoice_id 	  VARCHAR(15)   NOT NULL PRIMARY KEY,
                         branch 		  VARCHAR(5)    NOT NULL,
                         city			  VARCHAR(20)   NOT NULL,
                         customer_type	  VARCHAR(20)   NOT NULL,
                         gender			  VARCHAR(10)   NOT NULL,
                         product_line	  VARCHAR(30)   NOT NULL,
                         unit_price		  DECIMAL(10,2) NOT NULL,
                         quantity		  INT			NOT NULL,
                         VAT			  FLOAT(6,4)    NOT NULL,
                         total			  DECIMAL(12,4) NOT NULL,
                         date			  DATETIME	 	NOT NULL,
                         time			  TIME 		    NOT NULL,
                         payment_method   VARCHAR(20)   NOT NULL,
                         cogs			  DECIMAL(10,2) NOT NULL,
                         gross_margin_pct FLOAT(11,9)   NOT NULL,
                         gross_income	  FLOAT(11,4)	NOT NULL,
                         rating			  FLOAT(2,1)	NOT NULL
						);
                        
SELECT count(*) FROM sales_data where rating is null;

 -- checking if any null values are present.

																	-- FEATURE ENGINEERING --

-- creating a new column for time (time_of_day)

SELECT time,
		   (CASE
				WHEN HOUR(time) < 12 THEN 'Morning'
                WHEN HOUR(time) BETWEEN 12 AND 16 THEN 'Afternoon'
                ELSE 'Evening'
				END
			) as 'time_of_day'
FROM sales_data;

-- creating a new column for time (time_of_day)

ALTER TABLE sales_data ADD COLUMN time_of_day VARCHAR(15);

-- Adding values in that column

UPDATE sales_data 
SET time_of_day = (
					CASE
					WHEN HOUR(time) < 12 THEN 'Morning'
					WHEN HOUR(time) BETWEEN 12 AND 16 THEN 'Afternoon'
					ELSE 'Evening'
					END
					);
                    
-- Create a New Column as Day to extarct Day from date

SELECT date, DAYNAME(date) as Day
FROM sales_data;

ALTER TABLE sales_data ADD COLUMN Day VARCHAR(15);

UPDATE sales_data
SET Day = DAYNAME(date);

-- -- Create a New Column as Month to extract Month from date

SELECT date,
	   MONTHNAME(date) as Month
FROM sales_data;

-- Adding Column into Table

ALTER TABLE sales_data ADD COLUMN Month VARCHAR(15);

-- Adding Values into the Columns

UPDATE sales_data
SET Month = MONTHNAME(date);

																-- EDA --
                                                            -- Basic Questions --
-- 1) How many unique cities does the data have?

SELECT count(distinct city) as "Total Cities"
From sales_data;

-- 2) In which city is each branch?

SELECT city, branch
FROM sales_data
GROUP BY 1,2;

															-- Product Analysis --
                                                            
-- 1) How many unique product lines does the data have?

SELECT DISTINCT product_line
FROM sales_data;

-- 2) What is the most common payment method?

SELECT DISTINCT (payment_method), count(invoice_id) as Total_Transaction
FROM sales_data
GROUP BY 1
ORDER BY count(invoice_id) DESC LIMIT 1;

-- 3) What is the most selling product line?

SELECT product_line, count(product_line) as Count
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC LIMIT 1;

-- 4) What is the total revenue by month?

SELECT Month, SUM(total) as 'Total Revenue'
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC;

-- 5) What month had the largest COGS?

SELECT Month, SUM(cogs) as 'Total Cogs'
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC LIMIT 1;

-- 6) What product line had the largest revenue?

SELECT product_line, SUM(total) as 'Total Revenue'
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC LIMIT 1;

-- 7) Which city with the largest revenue?

SELECT city, SUM(total) as "Total Revenue"
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC LIMIT 1;

-- 8) What product line had the largest VAT?

SELECT product_line, AVG(VAT) as 'AVG VAT'
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC LIMIT 1;

-- 9) Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT product_line,AVG(total),(
		CASE 
			WHEN AVG(total) > 322.49888894 THEN 'GOOD'
            ELSE 'BAD'
            END
	   ) as 'Sentiment'
FROM Sales_data
GROUP BY 1;


-- 10) Which branch sold more products than average product sold?

SELECT branch, sum(quantity) as Qty
FROM sales_data
GROUP BY 1
HAVING SUM(quantity) > ( SELECT AVG(quantity) FROM sales_data);

-- 11) What is the most common product line by gender?

SELECT product_line, gender,COUNT(product_line) as 'Product Count'
FROM sales_data
GROUP BY 1,2
ORDER BY 3 DESC;

-- 12) What is the average rating of each product line?

SELECT product_line, CAST(AVG(rating) AS DECIMAL (10,2)) as 'Avg Rating'
FROM sales_data
GROUP BY 1;
 
															-- Sales Analysis --
                                                            

-- 1) Number of sales made in each time of the day per weekday


SELECT COUNT(*) as 'Number of Sales', time_of_day
FROM sales_data
WHERE Day = 'Tuesday'
GROUP BY 2
ORDER BY FIELD(time_of_day, 'Morning', 'Afternoon','Evening');

-- 2) Which of the customer types brings the most revenue?

SELECT customer_type, ROUND(SUM(total),2) as 'Total Revenue'
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC;
                        
-- 3) Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT city, ROUND(MAX(vat),2) as 'VAT'
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC LIMIT 1;

-- 4) Which customer type pays the most in VAT?

SELECT customer_type, ROUND(MAX(VAT),2) as 'AVG VAT'
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC LIMIT 1;

															-- Customer Analysis --
                                                            

-- 1) How many unique customer types does the data have?

SELECT DISTINCT customer_type, COUNT(customer_type) as "Customer Type Count"
FROM sales_data
GROUP BY 1;

-- 2) How many unique payment methods does the data have?

SELECT DISTINCT payment_method, COUNT(payment_method) as "No. of payment methods"
FROM sales_data
GROUP BY 1;

-- 3) What is the most common customer type?

SELECT customer_type, COUNT(quantity) as "QUANTITY"
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC;

-- 4) Which customer type buys the most?

SELECT customer_type, ROUND(SUM(total),2) as 'Total Purchase'
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC;

-- 5) What is the gender of most of the customers?

SELECT gender, COUNT(gender) as "cnt_cust"
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC;

-- 6) What is the gender distribution per branch?

SELECT branch, gender, count(gender) as 'Gender Count'
FROM sales_data
GROUP BY 1,2
ORDER BY 1,2;

-- 7) Which time of the day do customers give most ratings?

SELECT time_of_day, COUNT(rating) as 'Most Rating'
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC;

-- 8) Which time of the day do customers give most ratings per branch?

SELECT branch, time_of_day, COUNT(rating) as "Most Ratings"
FROM sales_data
GROUP BY 1,2
ORDER BY 3 DESC;

-- 9) Which day of the week has the best avg ratings?

SELECT Day, ROUND(AVG(rating),2) as 'Avg Ratings'
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC;

-- 10) Which day of the week has the best average ratings per branch?

SELECT day, branch, ROUND(AVG(rating),2) as 'Avg Ratings'
FROM sales_data
GROUP BY 1,2
ORDER BY 3 DESC;












