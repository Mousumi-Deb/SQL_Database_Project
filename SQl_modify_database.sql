use Hospital_system_management;

-- distinct function
select distinct address from hospital;

-- use where function
select * from dbo.hospital
where address = 'sydney';

-- And, or, not function
select * from dbo.patient
where not address = 'Sollentuna'; 

select * from patient
where first_name = 'Max' or First_name = 'Eva';

Select * from patient
where not address = 'kista' and not address ='Akalla';


--  order by
select dr_id, d_name, specialization
from doctor 
order by specialization desc;

-- insert a new record on hospital table
insert into hospital(h_name,  country, address) values
('Karolinska medical hospital', 'sweden', 'solna centrum, stockholm');

select * from hospital;

-- drop the new record from hospital table
delete from hospital 
where h_name = 'Karolinska medical hospital';

-- nested queries
select *
from patient
where last_name=(select last_name from patient where first_name = 'ananya');

-- top function
select top 3 * from doctor
where gender = 'Male' ;


select * from doctor;

select d_name, h_name, specialization 
from doctor 
where specialization = 'Physiotherapist';

-- update recods
update doctor set specialization = 'Cardiologist' 
where d_name = 'Dr.Bill'
select * from doctor;

-- aggerate function
select 
	min(number_of_days) as mimimum_days,
	max(dr_charge) as highest_pay,
	avg(medicine_charge) as average_charge,
    sum(medicine_charge) as total_medicine_cost,
	count(*) as all_payments
from bill 
where medicine_charge < 4000;

-- like function
select * 
from patient 
where first_name Like 'a%';

-- in operator

select * from patient
where address in ('Kista', 'Alvik strand','Sollentuna');

-- between operator
select * from bill
where medicine_charge between 500 and 3500;

-- null operator
select * from appointment where phone is not null;

--inner joins
select appoint_id, a.dr_id, date_time, e_mail 
from appointment a     --use alies for make code simpler
join doctor d
	on a.dr_id= d.dr_id;


-- right join
select
    h.h_name, 
    h.country, 
    d.d_name, 
    d.specialization  
from hospital h
right join doctor d 
	on h.h_name = d.h_name ;


-- declare the variables function

declare @Appoint_id int
set @Appoint_id = 15
print @Appoint_id;

--using variables in query

select 
	dr_id,
	phone,
	appoint_id
from appointment
where appoint_id = @Appoint_id

select * 
from dbo.appointment;

-- group by function
select
	first_name,
	last_name, 
	p_gender,
	count(*)
from patient
group by first_name,last_name,p_gender
having count(*) = 1 
order by count(*) desc;
	

-- date functions
select dr_id, e_mail, date_time, day(date_time )as day_of_month
from appointment;

select 
	appoint_id, 
	e_mail, 
	date_time,
	datediff(day, date_time, getdate()) as day_differences
from appointment;

-- mathematical functioner

select SQUARE(145) ---returns 21025

select  floor(rand() * 100) 

-- i want to print 20 random number between 1 to 50 so i use loop in here
-- so that i create a loop

declare @total as int
set @total = 1
while (@total <= 5)
begin
	print floor(rand() * 50)
	set @total = @total + 1
end