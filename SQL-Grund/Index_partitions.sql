--- Index (data sturestures provides faster access to data optimizing performance of queries)
/* B -Tree index(hierarchical tree structure,storing data at leaf nodes to help quickly locate data)
*/
--crate a clustered indesx
--
use SalesDB;
DROP TABLE IF EXISTS Sales.DBCustomers;
select * into Sales.DBCustomers from Sales.Customers;

CREATE CLUSTERED INDEX idx_DBCustomers_customerID
ON Sales.DBCustomers(CustomerID);

/*CREATE CLUSTERED INDEX idx_DBCustomers_FirstName
ON Sales.DBCustomers(FirstName);

drop INDEX idx_DBCustomers_FirstName on Sales.DBCustomers*/

Select * from Sales.DBCustomers
where LastName='Brown'

CREATE NONCLUSTERED INDEX idx_DBCustomers_LastName
ON Sales.DBCustomers(LastName);

----without mentioning which index
Select 
    * 
from Sales.DBCustomers
where FirstName='Kevin'

CREATE INDEX idx_DBCustomers_FirstName
ON Sales.DBCustomers(FirstName);

--- created a index which store 2 filterd column
SELECT *
FROM Sales.DBCustomers
WHERE Country ='USA' AND Score > 500

CREATE INDEX idx_DBCustomers_CountryScore
ON Sales.DBCustomers(Country, Score)

--Columnstore index(for large data warehouse tables,improving performance of analytical queries)
DROP INDEX [idx_DBCustomers_customerID] on Sales.DBCustomers;

CREATE NONCLUSTERED COLUMNSTORE INDEX idx_DBCustomers_CS_FirstNAMe on sales.DBCustomers(FirstName)


-----
USE AdventureWorksDW2022;

DROP TABLE IF EXISTS dbo.FactInternetSales ;

--HEAP structures (It is a table without a clustered index)

SELECT * INTO FactInternetSales_HP 
FROM FactInternetSales;

--Row Stores (It is a table with a clustered index)
SELECT * INTO FactInternetSales_RS
FROM FactInternetSales;

CREATE CLUSTERED INDEX idx_FactInternetSLaes_RS_PK
ON FactInternetSales_RS(SalesOrdernumber, SalesOrderLineNumber)

-----column Stores (It is a table with a clustered columnstore index)
SELECT * INTO FactInternetSales_CS
FROM FactInternetSales;

CREATE CLUSTERED COLUMNSTORE INDEX idx_FactInternetSales_CS_PK
ON FactInternetSales_CS

--unique index ( Ensure no duplicates values exists in specific column)
create UNIQUE NONCLUSTERED index idx_Products_products  
on Sales.Products (Product)


--- Filter index
Use SalesDB;
SELECT *
FROM Sales.Customers 
WHERE Country = 'USA'

CREATE NONCLUSTERED INDEX idx_DBCustomers_Country
ON Sales.Customers (Country)
WHERE Country = 'USA'

---