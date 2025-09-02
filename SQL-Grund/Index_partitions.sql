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
-------------------------------------------------------------------------------------


--- SQL Partitioning

CREATE PARTITION FUNCTION PartitionByYear (Date)
AS RANGE LEFT FOR VALUES ('2023-12-31','2024-12-31','2025-12-31')

---query lists all existing partiotion Function

SELECT 
    name,
    function_id,
    type,
    type_desc,
    boundary_value_on_right
from sys.partition_functions

---step 2: create FILE Groups
ALTER DATABASE SalesDB add FILEGROUP FG_2023;
ALTER DATABASE SalesDB add FILEGROUP FG_2024;
ALTER DATABASE SalesDB add FILEGROUP FG_2025;
ALTER DATABASE SalesDB add FILEGROUP FG_2026;

--- query lists all exsting Filegroups

SELECT * From sys.filegroups
WHERE [type] = 'FG'

--step 3: add. ndf Files to Each fiels
ALTER DATABASE SalesDB ADD FILE
(
    NAME = p_2023,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\p_2023.ndf'
) TO FILEGROUP FG_2023;

ALTER DATABASE SalesDB ADD FILE
(
    NAME = p_2024,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\p_2024.ndf'
) TO FILEGROUP FG_2024;


ALTER DATABASE SalesDB ADD FILE
(
    NAME = p_2025,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\p_2025.ndf'
) TO FILEGROUP FG_2025;

ALTER DATABASE SalesDB ADD FILE
(
    NAME = p_2026,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\p_2026.ndf'
) TO FILEGROUP FG_2026;


-----query file group
SELECT 
    fg.name as FileGroupName,
    mf.name as LogicalFileName,
    mf.physical_name as PhysicalFilePath,
    mf.size / 128 as SizeInMB
FROM 
    sys.filegroups fg
JOIN 
    sys.master_files mf 
On 
    fg.data_space_id = mf.data_space_id
WHERE 
    mf.database_id = DB_ID('SalesDB');


----- step 4: cerate partition Scheme

CREATE PARTITION Scheme SchemePartitionByYear
as PARTITION PartitionByYear 
TO (FG_2023, FG_2024, FG_2025, FG_2026)


--- query all partition scheme

SELECT
    ps.name as PartitionSchemeName,
    pf.name as PartitonFunctionName,
    ds.destination_id as PartitionNumber,
    fg.name as FileGroupName
From sys.partition_schemes ps

JOIN sys.partition_functions pf 
    on ps.function_id =pf.function_id
JOIN sys.destination_data_spaces ds 
    On ps.data_space_id =ds.partition_scheme_id
JOIN sys.filegroups fg 
    ON ds.data_space_id = fg.data_space_id


--- step 5: Create teh partitioned Table
CREATE TABLE Sales.Orders_Partitioned
(
    OrderID INT,
    OrderDate Date,
    Sales INT
)
On SchemePartitionByYear (OrderDate)


--step 6: insert data into Partiton Table
Insert Into Sales.Orders_Partitioned VALUES
(1,'2023-05-15', 100);

SELECT * from Sales.Orders_Partitioned