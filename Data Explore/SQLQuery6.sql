--------- SQL Joins-------------

--no join- return data from tables without combining

--task * INNER  join* -onlyl matching data
--retrieve 
USE MyDatabase;
select * from orders
select * from customers

select 
	c.id, 
	c.first_name, 
	c.country,
	o.order_id, 
	o.order_date, 
	o.sales 
from customers c 
inner join orders o
On c.id = o.customer_id

--- LEFT JOIN--
select 
	c.id, 
	c.first_name,
	o.order_id, 
	o.order_date, 
	o.sales
from customers c 
left join orders o
On c.id = o.customer_id

--- RIGHT Join---

-- all the orders without matching data
select 
	c.id, 
	c.first_name,
	o.order_id, 
	o.order_date, 
	o.sales
from customers c
right join orders o
On c.id = o.customer_id

--alternatives is left join but switching table position
select 
	c.id, 
	c.first_name,
	o.order_id, 
	o.order_date, 
	o.sales
from orders o
Left join customers c
On c.id = o.customer_id


----- FUll join----
select *
from customers c
Full join orders o 
On c.id = o.customer_id


---- left anti join---
select *
from customers c
left join orders o 
On c.id = o.customer_id
where o.customer_id is null

--right anti join---
select *
from orders o
right join customers c
On c.id = o.customer_id
where o.order_id is null

--alternative
select *
from customers c
right join orders o 
On c.id = o.customer_id
where c.id is null

---full anti join ---

select *
from customers c
full join orders o 
On c.id = o.customer_id
where o.customer_id is null or c.id is null


--- task
 ---get all customers along with their orders but only for who have placed orders
 --without using inner join

 select * from customers as c

left join orders o
on c.id=o.customer_id
where o.customer_id is not null


-- cross join
-- all possible combination of customers and orders
select* from customers  cross join orders
-------------------------------------------------------------------

use SalesDB;

select 
	o.OrderID, 
	o.Sales,
	c.FirstName as customer_firstname,
	c.LastName as customer_lastname,
	p.Product as ProductName,
	p.Price,
	e.FirstName as emp_firstname,
	e.LastName as emp_lastname

from Sales.Orders as o
left join Sales.Customers as c
on o.CustomerID = c.CustomerID
left join Sales.Products as p
on o.ProductID = p.ProductID
left join Sales.Employees as e
on o.SalesPersonID =e.EmployeeID


/* select *
from Sales.Orders as o


select * 
from Sales.Customers as c

select * 
from Sales.Employees

select * 
from Sales.OrdersArchive

select * 
from Sales.Products */


----------------set operations---------------


---union (return only unique or distinct remove duplicate value)

select FirstName, LastName
from Sales.Customers
Union
select FirstName, LastName
from Sales.Employees

--union all (merge all data with duplicates)

select FirstName, LastName
from Sales.Customers
Union All
select FirstName, LastName
from Sales.Employees


--except (return only rows from the first set that doesnot exists in the second)

select FirstName, LastName
from Sales.Employees
Except
select FirstName, LastName
from Sales.Customers

--intersect ( return only that exist in both tbl)

select FirstName, LastName
from Sales.Employees
intersect
select FirstName, LastName
from Sales.Customers;


-------------------------------------Functions---------------------------------------------------
--concat (combine multiple strings into one

use MyDatabase

select first_name,country,

concat (first_name, ' | ', country) as name_country,
upper (country) as upp_country 
from customers;

--upper and lower 

select 
 first_name,
 LOWER(first_name) as low_name,
 UPPER(first_name) as upp_name
from customers;

-- Trim 
select 
	first_name,
	country,
	len(first_name) len_name,
	len(trim(first_name)) len_trim_name,
	len(first_name) - len(trim(first_name)) as flag
from customers
--where first_name != trim(first_name) ---perfer


-- replace
select '123-345-568' as phone,
replace('123-345-568','-','/') AS CLEAN_Phn

---
select 
	'report.txt' as filee,
	replace('report.txt','.txt','.csv') as format

-- len function
select country, 
len(country) as length_country 
from customers

---2
select order_date, 
len(order_date) as length_date 
from orders

-- left function 
--tetireve the first 2 characters of each name

select 
	country,
	left(country, 3) as first_3_char
from customers
--- retrive first two characters
select 
	first_name,
	country,
	left(trim(first_name),2) first2_char
from customers

---retrive last 2 characters
select 
	first_name,
	country,
	right(first_name,2) first2_char
from customers


---substring extracts a part of string from a position
select 
	first_name,
	SUBSTRING(trim(first_name),2, 5) as part_of_name
	
from customers;

select 
	first_name,
	SUBSTRING(trim(first_name),2, len(first_name)) as sub_name
	
from customers;

---- number function

select 3.146856 as decimal_num, round(3.146856, 3) as round_num

select 3.146856 as decimal_num, round(3.146856, 1) as round_num


--- ABS
select -10 as neg_num, abs(10);

------------------------Date-------------
Use SalesDB;
select
	OrderID,
	ProductID,
	CreationTime,
	Year(CreationTime) Year,
	MONTH(CreationTime) MOnth,
	Day(CreationTime) Day
from Sales.Orders


---DatePart
select
	OrderID,
	ProductID,
	CreationTime,
	Datepart(month, CreationTime) Month_DatePart,
	Datepart(YEAR, CreationTime) year_DatePart,
	Datepart(DAY, CreationTime) DAY_DatePart,
	Datepart(QUARTER, CreationTime) QUarter_DatePart,
	Datepart(WEEK, CreationTime) Week_DatePart,
	Datepart(WEEKDAY, CreationTime) weekday_DatePart,
	Datepart(HOUR, CreationTime) Hour_DatePart
from Sales.Orders

--- DateName---
select
	OrderID,
	ProductID,
	CreationTime,
	DateName(Month, CreationTime) Mon_nm,
	DATENAME(Weekday,CreationTime) wk_nm
from Sales.Orders



----Date trunc--

select
	OrderID,
	ProductID,
	CreationTime,
	Datetrunc(Day, CreationTime) day_dt,
	Datetrunc(MINUTE, CreationTime) min_dt,
	DATENAME(Weekday,CreationTime) wk_nm
from Sales.Orders

select
	datetrunc(year,CreationTime) Creation,
	count(*)
	
from Sales.Orders
group by DATETRUNC(year, CreationTime);


--- Eomonth (End Of month)
select
	OrderID,
	CreationTime,
	eomonth(CreationTime) EndofMonth,
	cast(datetrunc(Month,CreationTime)as date )StartOfmonth
	
from Sales.Orders


----all order from feb month

select * from Sales.Orders
where Month(OrderDate) = 2

---format changing the datatypes one to another

select OrderID,CreationTime, FORMAT(CreationTime, 'ddd') dd
from Sales.Orders

--- DAy Wed JAn Q1 2025 12.34.35 pm
Select 
	OrderID, 
	CreationTime, 
	'Day ' + FORMAT(CreationTime,'ddd MMM') +
	' Q' +DATENAME(quarter, CreationTime)+ 
	' ' + Format(CreationTime,'yyyy hh: mm:ss tt') as custformat

from Sales.Orders;

---convert
select 
CreationTime,
convert(Date,CreationTime) as datetime_to_date,
Convert (varchar, CreationTime,32) as usa_std_time
from Sales.Orders

--CAST is used to convert one data type into another, like turning a number into a string, a string into a date
select 
CreationTime,
Cast('2025-08-20'as date) as string_to_date,
Cast ('2025-08-20' as datetime) as strind_to_datetime,
CAST(CreationTime as Date)as datetime_to_date
from Sales.Orders;


---dateadd (Adds or subtracts time from a date)

select OrderID, OrderDate ,
DATEADD (Day, -10,OrderDate) as ten_days_before,
DATEADD (month,3,OrderDate) as three_mon_before,
DATEADD (year,2,OrderDate) as twoyears_before
from Sales.Orders


---datediff
Select * from Sales.Employees

Select 
EmployeeID,
BirthDate,
datediff(year, BirthDate, getDate()) Age
from Sales.Employees


---find the average shipping durations in days for each month
SELECT 
 MONTH(OrderDate) AS OrderDate,
 AVG(DATEDIFF(day,OrderDate,ShipDate)) AVGSHIP
FROM Sales.Orders
group by month(OrderDate);

--(The LAG() function is a window function that lets you look at a value from a previous row 
---without joining the table to itself.)
-- find the num of days between each order and the previous order
SELECT OrderID,OrderDate CurrentOrderDate,
LAG (OrderDate) OVER (ORDER BY OrderDate) previous_date,
DATEDIFF(day, LAG(OrderDate) OVER (ORDER BY OrderDate),OrderDate) NrOfDays
From Sales.Orders


--isdate(CHeck if a value is a date) return 1 if the string value is a valied date

SELECT ISDATE('123') Datecheck,
ISDATE('2021-02-20') datecheck2,
isdate('20-02-2023') as date3

--

SELECT 
--CAST(OrderDate as Date) OrderDate
  OrderDate,
  ISDATE(OrderDate) AS IsValidDate,
  CASE 
    WHEN ISDATE(OrderDate) = 1 THEN CAST(OrderDate AS DATE)
    ELSE '9999-01-01'
  END AS NewOrderDate
FROM (
  SELECT '2022-08-20' AS OrderDate UNION
  SELECT '2022-08-21' UNION
  SELECT '2022-08-23' UNION
  SELECT '2022-08'     -- Incomplete date
) t;

--- isnull (IS NULL is a condition in 
--SQL used to check if a column or expression contains the special NULL value.


SELECT
OrderID,
OrderDate,
ShipAddress
FROM Sales.Orders
WHERE ShipAddress IS NULL

---find the average score of the customers
Select CustomerID, Score,
coalesce(Score,0) as acore_1,
avg(Score) over () AvgScores,
avg(coalesce(score,0)) over() avgScores2
from Sales.Customers;

--- display the full name of customers in a single field
-- by merging first andlastnames and add 10 bonus points to each customers

SELECT CustomerID ,
FirstName, LastName,
FirstName + ' ' +Coalesce(LastName,'')as FullName,
Score,
Coalesce(Score, 0)+10 as Score_with_bonus
from Sales.Customers


--- sort the customers from low to high scores with null appearing
Select 
CustomerID, Score,
coalesce(Score, 9999)
from Sales.Customers
Order by coalesce(Score, 9999)

---2 options
Select 
CustomerID, 
Score
from Sales.Customers
Order by case when Score is null then 1 else 0 ENd, Score


-- null if
/* The NULLIF function in SQL compares two expressions and returns:

NULL if the two expressions are equal

The first expression if they are not equal*/

-- find the sales price of each order by dividing sales by quantity
Select 
OrderID, Quantity, 
Sales/nullif(Quantity,0) as Price 
from Sales.Orders

--- LIST all customers who have scores

SELECT * FROM Sales.Customers ;

SELECT * FROM Sales.Customers 
WHERE Score is null;


SELECT * FROM Sales.Customers 
WHERE Score is not null;

---list all details foar customers wo have not places any orders 
SELECT  c.*,
o.OrderID FROM Sales.Customers as c
left join Sales.Orders o
on c.CustomerID = o.CustomerID
where o.CustomerID is null

--

with Orders as (
 select 1 id ,'a'category union
 select 2 ,null union
 select 3, '' union
 select 4, ' ')

select * , trim(category) policy1,
nullif(trim(category),'')policy2,
coalesce(nullif(trim(category),''),'unknown') policy3 from orders
