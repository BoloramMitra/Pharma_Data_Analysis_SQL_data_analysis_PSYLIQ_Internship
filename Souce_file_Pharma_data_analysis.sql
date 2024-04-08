Create database Pharma_data;
use Pharma_data;

Create table Pharma(
Distributor varchar(255),
Customer_Name TEXT,
City Varchar(255),
Country Varchar(20),
Latitude Double,
Longitude Double,
Channel Varchar(20),
Sub_channel Varchar(30),
Product_Name Varchar(255),
Product_Class Varchar(255),
Quantity Double,
Price Int,
Sales Double,
Month Varchar(20),
Year Int,
Name_of_Sales_Rep Varchar(30),
Manager Varchar(30),
Sales_Team Varchar(30));


-- 1. Retrieve all columns for all records in the dataset.

Select * from Pharma;

-- 2. How many unique countries are represented in the dataset?

Select distinct Country from Pharma;

-- 3. Select the names of all the customers on the 'Retail' channel.

Select Customer_Name,Sub_channel from pharma
where Sub_channel = "Retail";

-- 4. Find the total quantity sold for the ' Antibiotics' product class.

Select count(*) as Count_Of_product_class, Product_Class
from pharma
Where Product_Class = "Antibiotics"
group by Product_Class;

-- 5. List all the distinct months present in the dataset.

Select distinct Month from pharma;

-- 6. Calculate the total sales for each year.

Select year, CEIL(Sum(Sales)) as Total_sales
from pharma
group by Year
Order by year;

-- 7. Find the customer with the highest sales value.

Select Customer_Name, MAX(Sales) as Highest_Sale
from pharma
group by Customer_Name
order by Highest_Sale DESC limit 1;

-- Get the names of all employees who are Sales Reps and are managed by 'James Goodwill'.

Select Name_of_Sales_Rep, Manager
from pharma
where Manager = 'James Goodwill' ;

-- 9. Retrieve the top 5 cities with the highest sales.

Select  City, Sum(Sales) as Total_sales
from Pharma
group by City
order by Total_sales DESC limit 5;

-- 10. Calculate the average price of products in each sub-channel

Select Sub_Channel, Round(AVG(Price),2) as Avg_Price
from pharma
group by Sub_Channel;

-- 11. Join the 'Employees' table with the 'Sales' table to get the name of the Sales Rep and the corresponding sales records.

Select Name_of_Sales_Rep, Count(Product_name) total_products,
Round(Sum(Quantity),2) total_quantities, Round(Sum(Sales),2) as total_sales
from pharma
group by Name_of_Sales_Rep;

-- 12. Retrieve all sales made by employees from ' Rendsburg ' in the year 2018.

Select Name_of_Sales_Rep, Sales, City, year
from pharma where city = "Rendsburg" and Year = 2018;

-- 13. Calculate the total sales for each product class, for each month, and order the results by year, month, and product class.

Select Product_class, Month, year, Sum(sales) as total_sales
from pharma
group by  Product_class, Month, year
order by month, year, Product_class;

-- 14. Find the top 3 sales reps with the highest sales in 2019.

Select Name_of_Sales_Rep, Year, total_sales, ranked_as_per_Sales
from
(
Select  Name_of_Sales_Rep, Year, Sum(sales) as total_sales,
Dense_rank() over (partition by Year order by Sum(sales) DESC) as ranked_as_per_Sales
from pharma
where year = 2019
group by Name_of_Sales_Rep, Year
)
as subquery
Where ranked_as_per_Sales <= 3;

-- --------------ALTERNATIVELY--------------------------------------
Select  Name_of_Sales_Rep, Year, Sum(sales) as total_sales
from pharma
where Year = 2019
group by  Name_of_Sales_Rep, Year
order by total_sales DESC limit 3;

-- 15. Calculate the monthly total sales for each sub-channel, and then calculate the average monthly sales for each sub-channel over the years.

SELECT Sub_channel, 
       YEAR, 
       Month, 
       SUM(Sales) AS Total_Sales, 
       Round(AVG(Sales),2) AS Avg_Sales
FROM pharma
GROUP BY Sub_channel, YEAR, Month;

-- 16. Create a summary report that includes the total sales, average price, and total quantity sold for each product class.

Select Product_class, Round(AVG(price),2) as Avg_Price, 
Round(Sum(Quantity),2) as total_quantity, Round(Sum(sales),2) as total_sales
from Pharma
group by Product_class;

-- 17. Find the top 5 customers with the highest sales for each year.

Select Customer_name, YEAR, Highest_sales, Highest_yearly_sales_ranked from
(
Select Customer_name, YEAR, Sum(sales) as Highest_sales,
dense_rank() over (partition by Year order by Sum(sales) DESC) as Highest_yearly_sales_ranked
from pharma
group by Customer_name, YEAR
) as subquery
where Highest_yearly_sales_ranked between 1 and 5;

-- 18. Calculate the year-over-year growth in sales for each country.

SELECT 
    Country,
    YEAR,
    SUM(Sales) AS Total_Sales,
    LAG(SUM(Sales)) OVER (PARTITION BY Country ORDER BY YEAR) AS Previous_Year_Sales,
    CASE
        WHEN LAG(SUM(Sales)) OVER (PARTITION BY Country ORDER BY YEAR) IS NOT NULL THEN
            (SUM(Sales) - LAG(SUM(Sales)) OVER (PARTITION BY Country ORDER BY YEAR)) / LAG(SUM(Sales)) OVER (PARTITION BY Country ORDER BY YEAR) * 100
        ELSE NULL
    END AS Year_Over_Year_Growth
FROM 
    pharma
GROUP BY 
    Country, YEAR
ORDER BY 
    Country, YEAR;

-- -----------------------------------------ALTERNATIVELY------------------------------------------

SELECT 
    Country,
    YEAR,
    SUM(Sales) AS Total_Sales,
    LAG(SUM(Sales)) OVER (PARTITION BY Country ORDER BY YEAR) AS Previous_Year_Sales,
    CASE
        WHEN LAG(SUM(Sales)) OVER (PARTITION BY Country ORDER BY YEAR ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) IS NOT NULL THEN
            (SUM(Sales) - LAG(SUM(Sales)) OVER (PARTITION BY Country ORDER BY YEAR ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING)) / LAG(SUM(Sales)) OVER (PARTITION BY Country ORDER BY YEAR ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) * 100
        ELSE NULL
    END AS Year_Over_Year_Growth
FROM 
    pharma
GROUP BY 
    Country, YEAR
ORDER BY 
    Country, YEAR;
    
-- 19. List the months with the lowest sales for each year

Select Year, Month, Lowest_Sales
from
(
Select Year, Month, Sum(sales) as Lowest_sales,
Dense_rank() over (partition by YEAR order by Sum(sales) ASC) as Ranked_as_per_lowest_sale
from pharma
group by Year, Month
) as Subquery
Where Ranked_as_per_lowest_sale = 1
order by Year, Month ;

-- 20. Calculate the total sales for each sub-channel in each country, 
--     and then find the country with the highest total sales for each sub-channel.

WITH cte AS (
    SELECT 
        Sub_Channel,
        Country,
        SUM(Sales) AS Total_Sales,
        RANK() OVER (PARTITION BY Sub_Channel ORDER BY SUM(Sales) DESC) AS Sales_Rank
    FROM 
        pharma
    GROUP BY 
        Sub_Channel, Country
)
SELECT 
    Sub_Channel,
    Country,
    Total_Sales
FROM 
    cte
WHERE 
    Sales_Rank = 1;


