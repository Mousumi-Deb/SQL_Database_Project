#subqueries return a table select all the actors whose age > 70 and <85.
select * from 
	(select 
		name, year(curdate())-birth_year as age
from actors) as actors_age
where age > 70 and age < 85;

#subqueries return a list of values
select * from movies
where imdb_rating in (
	(select min(imdb_rating) from movies),
    (select max(imdb_rating) from movies));
    
    
#select a movie with highest imdb_rating and return a single value
select * from movies
where imdb_rating = (select max(imdb_rating)
from movies);

#In operators
# select actors who acted in any movies
select * from actors 
where actor_id In(
		select actor_id 
		from movie_actor
		where movie_id in(101,110,121));
        
#ANY operator
select * from actors 
where actor_id = any(
		select actor_id 
		from movie_actor
		where movie_id in(101,110,121));
        
# select all movies whose rating is greater than *any* of the marvel movies rating
select * 
from movies
where imdb_rating = Any(
		select imdb_rating from movies 
        where studio ="Marvel studios");

#order by queries
select a.actor_id, a.name, count(*) as movies_count
from movie_actor ma
join actors a
on a.actor_id = ma.actor_id
group by actor_id
order by movies_count desc;


# subqueries
select
	actor_id,
    name,
    (select count(*) from movie_actor
    where actor_id=actors.actor_id) as movies_count
from actors
order by movies_count desc;

#1) select all the movies with minimum and maximum release_year. Note that there 
#can be more than one movies in min and max year hence output rows can be more than 2

select * from movies where release_year in (
(select min(release_year) from movies),
(select max(release_year) from movies));

#2) select all the rows from movies table whose imdb_rating is higher than the average rating

select * from movies 
where imdb_rating >  
(select avg(imdb_rating) from movies);


#get all actors whose age is between 70 and 85

with actors_age as (
	select
		name as actor_name,
        year(curdate())-birth_year as age
	from actors
)
select actor_name, age
from actors_age
where age > 70 and age < 85;

#movies that produced 500% profit
select x.movie_id, x.pct_profit,
		y.title, y.imdb_rating
from (select 
		*,
		(revenue-budget)*100/budget as pct_profit
	from financials) x
join (
	select * from movies
    where imdb_rating <(select avg(imdb_rating) from movies)) y
on x.movie_id = y.movie_id
where pct_profit >=500;
    
    
#with cte #Common Table Expression
with 
	x as (select 
		*,
		(revenue-budget)*100/budget as pct_profit
	from financials),
    y as (
	select * from movies
    where imdb_rating <(select avg(imdb_rating) from movies))
    
select x.movie_id, x.pct_profit,
		y.title, y.imdb_rating
from x
join y
on x.movie_id = y.movie_id
where pct_profit >=500;






