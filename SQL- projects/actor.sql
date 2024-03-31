
# get current date 
select curdate();

select *, Year(curdate())-birth_year as age from actors;