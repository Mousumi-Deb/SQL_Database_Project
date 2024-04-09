SELECT 
	* FROM random_tables.expenses
order by category;

select sum(amount) from expenses;

#get percentage all expenses 
SELECT 
	* ,
    amount * 100/sum(amount) over() as percentage  #over clause is window function
FROM random_tables.expenses
order by category;

# get percentage for some column by category
SELECT 
	* ,
    amount * 100/sum(amount) over(partition by category) as percentage  
FROM random_tables.expenses
order by category;

SELECT 
	sum(amount)
from expenses where category = "food";

# get total expenses by date 

select *, sum(amount)
over(partition by category order by date) as total_expense_till_date
from expenses
order by category, date









