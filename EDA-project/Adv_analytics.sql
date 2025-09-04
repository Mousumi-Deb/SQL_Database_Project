use DataWarehouseAnalytics;
GO
/* Change Over Time trends
(Analyze how a measure evolves over time help track and identify seasonality in your data)*/
SELECT 
    year(order_date) as order_year,
    MONTH(order_date) as order_month,
    SUM(sales_amount) as total_sales,
    COUNT(distinct customer_key) as total_customers,
    SUM(quantity) as total_quantity 

from gold.fact_sales
WHERE order_date is NOT NULL
GROUP BY year(order_date),MONTH(order_date)
ORDER BY year(order_date),MONTH(order_date)

--alternatives 2:
SELECT 
    DATETRUNC(MONTH, order_date) as order_date,
    SUM(sales_amount) as total_sales,
    COUNT(distinct customer_key) as total_customers,
    SUM(quantity) as total_quantity 
    
from gold.fact_sales
WHERE order_date is NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date)

---alternative 3:
SELECT 
    FORMAT(order_date, 'yyyy-MMM') as order_date,
    SUM(sales_amount) as total_sales,
    COUNT(distinct customer_key) as total_customers,
    SUM(quantity) as total_quantity 
    
from gold.fact_sales
WHERE order_date is NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM')

--- how many new custoemrs were added each year
SELECT 
    DATETRUNC(YEAR, create_date) as create_year,
    COUNT(customer_key) as total_customers    
from gold.dim_customers
GROUP BY DATETRUNC(YEAR, create_date)
ORDER BY DATETRUNC(YEAR, create_date)

---Cumalative analysis(aggragate the data progressively over time)
