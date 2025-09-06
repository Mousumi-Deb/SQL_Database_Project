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

---Cumalative analysis(aggragate the data progressively over the time
--task1: calculatethe total sales per month
--and the running total of slaes over time

SELECT 
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) as running_total_sales
FROM
    (
        select DATETRUNC(month, order_date) as order_date,
        SUM(sales_amount) as total_sales
        FROM gold.fact_sales
        WHERE order_date IS NOT NULL
        GROUP BY DATETRUNC(month, order_date)
    ) t

    --task2: calculate the total sales per month
--and the moving average of price over time

SELECT 
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) as running_total_sales,
avg(avg_price) over (ORDER BY order_date) as moving_average_sales
FROM
    (
        select DATETRUNC(month, order_date) as order_date,
        SUM(sales_amount) as total_sales,
        AVG(price) as avg_price
        FROM gold.fact_sales
        WHERE order_date IS NOT NULL
        GROUP BY DATETRUNC(month, order_date)
    ) t
/* performence analysis (Comparing the current value to a target value)

--task1:analyse teh yearly performence of the product by comparing their sales to 
both the average sales performnece of the product and the previous years sales*/

With yearly_product_sales as (
SELECT
    YEAR(f.order_date) as order_year,
    p.product_name,
    SUM(f.sales_amount) as curremt_sales
    
from gold.fact_sales f
LEFT JOIN gold.dim_products p
on f.product_key = p.product_key
WHERE order_date is NOT NULL
GROUP BY YEAR(f.order_date), p.product_name)

SELECT
    order_year,
    product_name,
    curremt_sales,
    AVG(curremt_sales) OVER (PARTITION BY product_name) avg_sales,
    curremt_sales -AVG(curremt_sales) OVER (PARTITION BY product_name) as diff_avg,
    case when  curremt_sales - AVG(curremt_sales) OVER (PARTITION BY product_name) > 0 then 'Above avg'
        when  curremt_sales - AVG(curremt_sales) OVER (PARTITION BY product_name) < 0 then 'Below avg'
        else 'Avg'
        END avg_change,
        LAG(curremt_sales) OVER (PARTITION BY product_name ORDER BY order_year) prev_sales,
        curremt_sales - LAG(curremt_sales) OVER (PARTITION BY product_name ORDER BY order_year) as diff_prev,
        case when  curremt_sales - LAG(curremt_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 then 'Increased'
        when  curremt_sales - LAG(curremt_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 then 'Descreased'
        else 'No change'
        END prev_change
from yearly_product_sales
ORDER BY product_name, order_year

--- Part to whole(proportional analysis)
--task 1 : which categories
With category_sales as (
    SELECT
        category,
        sum(sales_amount) total_sales
    from gold.fact_sales f  
    LEFT JOIN gold.dim_products p  
    on p.product_key = f.product_key
    GROUP BY category)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER() overall_sales,
    CONCAT(ROUND((CAST(total_sales as float) / sum(total_sales) over ())*100,2),'%') as percent_of_total
    from category_sales
    ORDER BY total_sales DESC