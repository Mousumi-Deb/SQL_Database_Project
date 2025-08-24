--- Index (data sturestures provides faster access to data optimizing performance of queries)
/* B -Tree index(hierarchical tree structure,storing data at leaf nodes to help quickly locate data)
*/
--crate a clustered indesx
--
use SalesDB
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

