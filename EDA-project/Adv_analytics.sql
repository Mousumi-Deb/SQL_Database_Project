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

--- data segmentation (group the data based on the specific range)
--task1: segment products into cost ranges and count how many products fall into each segment
With product_segment as (
SELECT
    product_key,
    product_name,
    cost,
    case when cost < 100 then 'Below 100'
        when cost between 100 and 500 THEN '100-500'
        when cost between 500 and 1000 THEN '500-1000'
        else 'Above 1000'
    End cost_range
FROM gold.dim_products )

SELECT
    cost_range,
    COUNT(product_key) as total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC


/* group customers into three segments based on their spendings behavior:
-VIP: Customers with at least 12 months of history and spendings more than $5000.
- regular: custoers with at least 12 months of history but spending  $5000 or less.
-- new: Customers with a life span less than 12 months.
and find the total number of the customers by each group 
*/
with customer_spending as (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) as total_spendings,
        MIN(order_date) as first_order,
        MAX(order_date) as last_orders,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan
    FROM gold.fact_sales f  
    LEFT JOIN gold.dim_customers c  
    on f.customer_key = c.customer_key
    group by c.customer_key)

SELECT 
    customer_segment,
    COUNT(customer_key) as total_customers 
    FROM (
        SELECT
            customer_key,
            case when lifespan >= 12 and total_spendings > 5000 then 'VIP'
                when lifespan >= 12 and total_spendings <= 5000 then 'Regular'
                else 'New'
            END customer_segment
        FROM customer_spending) t 
    GROUP BY customer_segment
    ORDER BY total_customers desc;



/* --===================================================================
                 Build Customers Report
====================================================================
HIGHLIGHTS:
    1. gathers all essensial field s such as names, ages and transaction details
    2.segments customers into categories(VIP, regular, new) and age group
    3.agregates customers level metrics:
        -total orders
        -total sales
        -total quantity purchased
        -lifespan
    4. calculates valuable KPIs:
        -recency(months since last order)
       - average order value
        -average monthly spendings

======================================================================== */
GO
CREATE VIEW gold.report_customers AS
WITH base_query as (
-- 1. gathers all essensial field s such as names, ages and transaction details
SELECT
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ',c.last_name) as customer_name,
    DATEDIFF(YEAR, c.birthdate, GETDATE()) as age
from gold.fact_sales f
LEFT JOIN gold.dim_customers c  
ON c.customer_key = f.customer_key
WHERE order_date is NOT NULL)

,customer_aggregation as (
/* ---------------------
2. customer aggregation: summerizes key metrics at the customer level
---------------------------------------------------------------*/

SELECT 
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) as total_orders,
SUM(sales_amount) as total_sales,
SUM(quantity) as total_quantity,
COUNT(distinct product_key) as total_products,
MAX(order_date) as last_order_date,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan
from base_query
GROUP BY
    customer_key, 
    customer_number, 
    customer_name, 
    age)

SELECT
    customer_key, 
    customer_number, 
    customer_name, 
    age,
    --- 2.segments customers into categories(VIP, regular, new) and age group
    CASE 
        when age < 20 then 'Under 20'
        when age between 20 and 29 then '20-29'
        when age between 30 and 39 then '30-39'
        when age between 40 and 49 then '40-49'
        when age between 50 and 65 then '50-65'
        else 'Above 65'
    END as age_group,
    CASE 
        when lifespan >= 12 and total_sales > 5000 then 'VIP'
        when lifespan >= 12 and total_sales <= 5000 then 'Regular'
        else 'New'
    END as customer_segment,
    --compute recency of last order date
    last_order_date,
    datediff(MONTH, last_order_date, GETDATE()) as recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    ---compute aveg order value
    case when total_orders = 0 then 0
        else total_sales / total_orders 
    end as avg_order_value,
    ---compute avg monthly spendings
    case when lifespan = 0 then total_sales
        else total_sales / lifespan 
    end as avg_monthly_spendings
from customer_aggregation;
GO;

---get the age distribution of customers
select
    age_group,
    COUNT(customer_key) as total_customers,
    SUM(total_sales) as total_sales,
    AVG(avg_order_value) as avg_order_value
from gold.report_customers
GROUP BY age_group 
ORDER BY age_group DESC;