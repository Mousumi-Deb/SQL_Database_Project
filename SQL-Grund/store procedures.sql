
---Store procedures---
--write a query 
--for us customers find the total number of customers and the average Score

SELECT 
	COUNT(*) TOTAL_Customers,
	AVG(Score) AvgScores
from Sales.Customers
where Country ='USA'

---step2
CREATE PROCEDURE GetCustomersSummary as 
BEGIN
SELECT 
	COUNT(*) totalCustomers,
	AVG(Score) AVgScore
from Sales.Customers
where Country='USA'
END

---step 3
EXEC GetCustomersSummary

---parameters
--For german Customers find the total number and average 

Alter PROCEDURE GetCustomersSummary @Country NVARCHAR(50)= 'USA'
AS 
BEGIN
	begin try
		Declare @TotalCustomers Int, @AvgScore Float;
		--==========================================
		--step 1 : prepare and clean up the data
		--==========================================

		if exists (select 1 from Sales.Customers where Score is Null and Country =@Country) 
		begin
			print('Updating Null Scores to 0');
			update Sales.Customers
			set Score= 0
			where Score is NUll and Country=@Country;
		end 

		else
		begin
			print('No Null Scores Found')
		end;

		--=================================
		-- step 2:Generating the summary reports
		--=====================================
		--- Calculate total customer and average for specific country

		Select
			@TotalCustomers = Count(*),
			@AvgScore = AVG(Score)
		From Sales.Customers
		where Country = @Country;

		Print 'Total Customers from '+ @Country + ':'+ CAST(@TotalCustomers as nvarchar);
		Print 'Average Score from ' + @Country+ ':'+ CAST(@AvgScore as nvarchar);


		-- find all the total Nr. of Orders and total Sales for specific country
		Select
			Count(OrderID) TotalOrders,
			Sum(Sales) TotalSales
		from Sales.Orders o
		Join Sales.Customers c
		On c.CustomerID =o.CustomerID
		where c.Country = @Country;
	END try
	Begin Catch
		----==============================
		--Error handling
		--=============================
		print('AN Error occured');
		print('Error Message: '+ Error_message());
		print('Error Number: '+ Cast(error_number() as Nvarchar));
		print('Error Line: '+ cast(Error_line() as nvarchar));
		print('Error procedure ' +Error_Procedure());
	End Catch
	end
go

EXEC GetCustomersSummary 
EXEC GetCustomersSummary @Country= 'USA'


