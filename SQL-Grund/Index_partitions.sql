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


--HEAP structures (It is a table without a clustered index)
DROP TABLE IF EXISTS FactInternetSales_HP;
SELECT * INTO FactInternetSales_HP 
FROM FactInternetSales;

--Row Stores (It is a table with a clustered index)
DROP TABLE IF EXISTS FactInternetSales_RS;
SELECT * INTO FactInternetSales_RS
FROM FactInternetSales;

CREATE CLUSTERED INDEX idx_FactInternetSLaes_RS_PK
ON FactInternetSales_RS(SalesOrdernumber, SalesOrderLineNumber)

-----column Stores (It is a table with a clustered columnstore index)
DROP TABLE IF EXISTS FactInternetSales_CS;

SELECT * INTO FactInternetSales_CS
FROM FactInternetSales;



--CREATE CLUSTERED COLUMNSTORE INDEX idx_FactInternetSales_CS_PK
--ON FactInternetSales_CS;

--unique index ( Ensure no duplicates values exists in specific column)
use SalesDB;
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

---list all  indexs on a specific tabel
sp_helpindex 'Sales.DbCustomers'


-- Monitoring Index Usage
SELECT * from sys.indexes

SELECT 
    tbl.name as TableName,
    idx.name as Index_name,
    idx.type_desc as IndexType,
    idx.is_primary_key  as IsPrimaryKey,
    idx.is_unique as IsUnique,
    idx.is_disabled as is_disabled,
    s.user_seeks as UserSeeks,
    s.user_scans as UserScans,
    s.user_lookups as UserLook,
    s.user_updates as UserUpdates,
    COALESCE (s.last_user_seek,s.last_system_scan) LastUpdate

FROM sys.indexes idx 
JOIN sys.tables tbl 
On idx.object_id = tbl.object_id
LEFT JOIN sys.dm_db_index_usage_stats s  
On s.object_id = idx.object_id
AND s.index_id = idx.index_id

ORDER BY tbl.name, idx.name

--- Dynamic management view(DMV) provides realtime insights into database performence and system health

select * from sys.dm_db_index_usage_stats

--SELECT * FROM FactInternetSales

SELECT * from sys.dm_db_missing_index_details

USE AdventureWorksDW2022;
SELECT * FROM dbo.FactInternetSales

SELECT
    fs.SalesOrdernumber,
    dp.Color
  FROM [AdventureWorksDW2022].[dbo].[FactInternetSales] fs
INNER JOIN DimProduct dp  
On fs.ProductKey = dp.ProductKey
WHERE dp.Color ='Black'
AND fs.OrderDateKey BETWEEN 20101229 AND 20101231

SELECT * from sys.dm_db_missing_index_details 

--- updates statistics
USe SalesDB;
SELECT
    SCHEMA_NAME(t.schema_id) as SchemaName,
    t.name as tablename,
    s.name as StatisticsName,
    sp.last_updated as last_Updated,
    DATEDIFF(day, sp.last_updated,  GETDATE()) as LastUpdateDay, 
    sp.rows as 'Rows',
    sp.modification_counter as ModificationSinceLastUpdates
FROM sys.stats as s
JOIN sys.tables t 
on s.object_id = t.object_id
Cross APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) as sp  
order by 
sp.modification_counter desc;

UPDATE STATISTICS Sales.DBCustomers _WA_Sys_00000001_6EF57B66;

UPDATE STATISTICS Sales.DBCustomers;

