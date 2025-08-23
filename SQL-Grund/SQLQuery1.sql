/* 
this
is a DDL and DML of data */
use MyDatabase;
---retrieve customers data
select * from customers;

--retrieve all data 
select *from orders;

-- retrieve the specific column
select
	first_name,
	country,
	score
from customers;

--- where clause

--retrieve customer with score not = 0

select 
	* 
from customers
where score !=0;

--customer is from germany

select 
	first_name, 
	country 
from customers 
where country = 'Germany';

--- order by
--organize the data according to the highest score
select * from customers 
order by score desc

--lowest score
select * from customers 
order by score asc

--order by country and then highest score

select * 
from customers 
order by 
	country asc,
	score desc

--- group by
--find the total score for each country
select 
	country,
	Sum(score) as total_score
from customers
group by country

--find total country for each country
select 
	country,
	first_name,
	count(score)as count_country
from customers
group by country,first_name ;

--find the total score and total numbers of customers for each country

select 
	country,
	sum(score) as total_score,
	count(id) as total_customer
from customers
group by country

--- having function
--find the average score for each country considering follwing
--1.customers only score is not equal to 0
--2. return only those countries with AN average score greater than 500

select
	country,
	avg(score) as avg_score
from customers
where score != 0
group by country
having avg(score) > 550


--distinct
---return unique list of all countries

select distinct country from customers;

-- top
-- top customers
select top 3* from customers;

--top 3 customer based on highest scores
select top 3 * from customers order by score desc;
--lowest
select top 3 * from customers order by score asc;

--two most recent orders from order table

select top 2 * from orders order by order_date desc;


-- static values
select 
	id, 
	country , 
	first_name, 
	'new customer' as customer_type 
from customers ;

--create a new table called persons(DDL)

create table persons( 
	id int not null,
	person_name varchar(50) not null,
	birth_date date,
	phone varchar(15) not null
	constraint pk_persons primary key (id))

-- alter

alter table persons
add email varchar(50) not null

select * from persons

alter table persons
drop column phone 

--- drop table
drop table persons

--insert data
insert into customers (id, first_name, country, score) 
values(6, 'Anna', 'Sweden', 200),
	(7, 'Mousumi', 'Bangladesh', null),
	(8, 'Rani', null,600)

select * from customers;

-- insert data via query

insert into persons (id, person_name, birth_date, phone)
select id, first_name, null, 'Unknown' from customers

select * from persons;

--- update
-- set the score null to 0 then update

select * from customers

update customers 
set score = 0
where id = 7

-- change score of customers 10 to 0 and update the country to uk

update customers 
set 
	score = 100 , country = 'USA' 
where id = 7


--update all customers

update customers
set country = 'UK'
where country is null


---Delete all customers with an Id grater than 5

delete from customers
where id > 7

select * from customers;


--delete all data from table persons

truncate table persons;

-----------fitering data with comparison operators----------

-- retrieve all customers from germany

select * from customers where country = 'Germany'

select * from customers
where country != 'Germany' --  operation of not equal !=
--where country <> 'Germany' ( -- another operation of not equal <>)

--gerater than score > 500

select * from customers where score > 500

-- greater tan or equal to 500
select * from customers where score >= 500


--less than 500
select * from customers where score < 500

--less than or equal to 500
select * from customers where score <= 500


--- logical operator
-- AND
select * from customers
where country = 'USA' and score > 500

--- either country is usa or score is greater than 500
--OR
select * from customers
where country = 'USA' or score > 500

select * from customers

--NOT
---retrieve all customers with a score not less than 500
select * from customers
where not country = 'Sweden'  /*where not score > 500 | where score >= 500 (alternatives)*/

--between
-- retrieve all customer score range between 100 and 500 */

select * from customers
where score between 100 and 500

--alternatives

select * from customers
where score >= 100 and score <= 500 -- higher or equal to 100 and lower and equal to 500


--- In operators

--OR
select * from customers
where country = 'USA' or country='USA'

--alternatives In operator

select * from customers
where country in ('Germany', 'USA')


--- like operators
--find all customer which name start with a

select * from customers
where first_name like 'A%'

--end with n
select * from customers
where first_name like '%n'

--anywhere name has A
select * from customers
where first_name like '%A%'

--first name has 3rd position with r
select * from customers
where first_name like '__r%'
