/* Case Statements---
The CASE statement in SQL allows you to apply if-then-else logic in queries.
-CASE Rules (data types in betwenn then and else must be matching)*/

use SalesDB

--use case (Case Statement)'
/*Create a report showing total sales for each of the follwing categories:
-high (sales over 50) ,-medium(sales21-50),low (sales20 or less)
--sort then categories form highest sales to lowest*/
select Category, Sum(Sales)as  TotalSales
from(
	SELECT OrderID, Sales,
	case
		when sales > 50 then 'High'
		when sales > 20 then 'Medium'
		else 'Low'
		end Category
	from Sales.Orders
)t
group by Category 
Order By TotalSales Desc

--- case statement (mapping)->transform the values form one form to another
--retwieve employee details with gender displayed as full text

select EmployeeID,FirstName, LastName,Gender,
Case
when Gender = 'F' then 'Female'
when Gender = 'M' then 'Male'
ELse 'Not Available'
End  genderFulltext
from Sales.Employees

--retrieve employee details based on abbriviated country code

select 
	CustomerID,
	FirstName, 
	LastName,
	Country, 
	case 
		when Country = 'Germany' then 'GE'
		when Country ='USA' then 'US'
		else 'n/a'
	end Countryabr,

	case Country					--- if you have many value then this case
		when 'Germany' then 'GE'
		when 'USA' then 'US'
		else 'n/a'
	end Countryabr2
from Sales.Customers

--- find the average scores of customers and treat Nulls as 0
-- additionallly provide details such CustomersID and LAstname
SELECT 
	CustomerID,
	LastName,
	Score,
	Case
		when Score is Null then 0
		else Score
	End ScoreClean,
	AVG(Case
		when Score is Null then 0
		else Score
	End) Over() AvgCustomerClean,
	avg(Score) Over() AvgCustomer
from Sales.Customers

--- COnditional aggregation 
--(apply aggregation functions only on subset o fdatat taht fulfil certain condition)

---task
--Count how many times each customers has made an order with sales greater tahn 30

select 
	OrderID,
	CustomerID,
	Sales,
	Case
		when Sales >30 then 1
		else 0
		end orderFLag
from Sales.Orders 
order by CustomerID

---alternatives but with (Group)

select 
	CustomerID,
	SUM(Case
		when Sales >30 then 1
		else 0
		end) highsalestotalorders,
		COunt(*) Totalorders
from Sales.Orders 
Group by CustomerID

--- Window functions--
--find the ttotal sales of all orders

use MyDatabase

SELECT 
customer_id,
COUNT(*) AS	total_orders,
SUM(sales) as total_sales,
AVG(sales) as avg_sales,
Max(sales) as highest_sales,
Min(sales)as lowest_sales
from orders
group by customer_id

-- find all total sales accross all orders
use SalesDB

Select
	ProductID,
	SUM(Sales) totalSales
from Sales.Orders
group by ProductID

--- additionally provides details such order id, order date */

SELECT
       [OrderID],[ProductID],[OrderDate],
   sum(sales) over (partition by ProductID) totalsalesByproducts
  FROM [SalesDB].[Sales].[Orders]

--syntax (
--find the total sales across all orders additionally provide details such
-- order id & order date

select 
OrderID,
OrderDate,
ProductID,
OrderStatus,
Sales,
SUm(Sales) over() totalsales,
SUm(Sales) over(partition by ProductID) totalsales_byproducts,
SUm(Sales) over(partition by ProductID, OrderStatus) totalsales_byproducts_Status
from Sales.Orders

--rank each order based sales from high to low and 
--provide details order id and order date

SELECT 
	OrderID,
	OrderDate,
	Sales,
	Rank() over(order By Sales) rank_sales
from Sales.Orders


---window frame
Select 
orderID, 
OrderDate, 
OrderStatus,
Sales,
Sum(Sales) over (partition by OrderStatus Order by OrderDate
Rows 2 Preceding) TotalSales
From Sales.Orders

---rank customers based on their total sales
SELECT 
	OrderID,
	OrderDate,
	Sales,
	ROW_NUMBER() over(order by Sales DESC) SalesRank_Row, 
	Rank()		over(order By Sales desc) rank_sales_rank,
	DENSE_RANK() Over(order by Sales Desc) SAles_dense
from Sales.Orders

---find the top highest sales for each product
Select *
From (
select 
	OrderID, 
	ProductId,
	Sales, 
	ROW_NUMBER() over(Partition by ProductID Order By Sales DESC) Ránkbyproduct
from Sales.Orders
)t 
where Ránkbyproduct = 1

--- find low 2customer  based in their total sales 
select * from(
SELECT 
	CustomerID,
	SUM(Sales) total_Sales,
	ROW_NUMBER() Over(order by SUM(Sales)) rank_customers
from Sales.Orders
Group by CUstomerID)t where rank_customers <= 2


---assign unique ids for each rows 'Orders Archieve' tota

SELECT 
	ROW_NUMBER() Over(order By OrderID, OrderDate) UniqueID,
	*
FROM Sales.OrdersArchive


--identify duplicates and return the clean result 
SELECT 
* FROM (
SELECT 
	ROW_NUMBER() OVER(partition by OrderID Order BY CreationTime DESC) rn,
	*
FROM Sales.OrdersArchive)t
where rn > 1

---cumetative  rank
SELECT * from (
Select CUME_DIST() over (order By Sales DESC) cms,
* from Sales.Orders)t where cms >=1

--Cume rank
SELECT *, CONCAT(DistRAnk *100,'%') as percentage_distrank
FROM(
SELECT 
	Product,
	Price,
	CUME_DIST() Over (Order By Price DESC) DistRAnk
from Sales.Products)T WHERE DistRAnk <= 0.4

---percentage rank

SELECT *, CONCAT(DistRank *100,'%') as percentage_distrank
FROM(
SELECT 
	Product,
	Price,
	Percent_Rank() Over (Order By Price DESC) DistRank
from Sales.Products)T WHERE DistRank <= 0.4


---NTILE (Divide the rows into a specififed num of approx, equal groups(Buckets)

SELECT 
	OrderID,
	Sales, 
	NTILE(1) over(Order BY Sales DESC) Onebuc
from Sales.Orders

-- segment all orders into 3 categories : high, medium and low
SELECT *,
case when Buckets = 1 then 'High'
	when Buckets = 2 then 'Medium'
	when Buckets = 3 then 'Low'
END SalesSegmentations
from(
	SELECT 
		OrderID,
		Sales,
		NTILE(3) Over (Order BY Sales DESC) Buckets
	from Sales.Orders)t

---value ´Functions
--LEAD(access a value from the next row within a window) and LAG functions(Previous rows in a window)

SELECT
	ProductID,
	OrderDate,
	Sales,
	LEAD(Sales, 2,10) over(Partition by ProductID Order By OrderDate)as leadvalue
FROM Sales.Orders

---Time series analysis
--task 1
--analze the Month over mmonth perofrmenceby finding the percentage change in sales btw the current and previous month

SELECT 
	*,
	CurrentMonthSales - PreviousMonthSales as MoM_change,
Round(
	cast(
		(CurrentMonthSales - PreviousMonthSales) as float)/PreviousMonthSales *100,1) as MoM_Perc
FROM (

SELECT 
	MONTH(OrderDate) OrdMonth,
	SUM(Sales) CurrentMonthSales,
	LAG(SUM(Sales)) over(order by Month(OrderDate)) PreviousMonthSales

from Sales.Orders
Group By 
	MONTH(OrderDate))t

--- Customer Analysis

SELECT
	OrderID,
	CustomerID,
	OrderDate currentDate,
	LEAD(OrderDate) OVER(Partition BY CustomerID Order By OrderDate) NextOrder
FROM Sales.Orders
Order by CustomerID, OrderDate