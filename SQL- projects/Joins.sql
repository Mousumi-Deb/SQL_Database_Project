#inner jon
SELECT
	movies.movie_id, title, budget, revenue, currency, unit
from movies
Join financials 
On movies.movie_id= financials.movie_id;

#left join
SELECT
	movies.movie_id, title, budget, revenue, currency, unit
from movies
Left Join financials 
On movies.movie_id= financials.movie_id

Union

#right join
SELECT
	f.movie_id, title, budget, revenue, currency, unit
from movies m 
right Join financials f
On m.movie_id= f.movie_id;

#1) Show all the movies with their language names

   SELECT m.title, l.name FROM movies m 
   JOIN languages l USING (language_id);
   
#2) Show all Telugu movie names (assuming you don't know language id for Telugu)
  
   SELECT title	FROM movies m 
   LEFT JOIN languages l 
   ON m.language_id=l.language_id
   WHERE l.name="Telugu";

#3) Show language and number of movies released in that language
   	SELECT 
            l.name, 
            COUNT(m.movie_id) as no_movies
	FROM languages l
	LEFT JOIN movies m USING (language_id)        
	GROUP BY language_id
	ORDER BY no_movies DESC;

#get bollywood movies profit
select
	m.movie_id, title, budget, revenue, currency, unit
    (revenue- budget) as profit
from movies m
join financials f on m.movie_id=f.movie_id
where industry = "bollywood"
order by profit Desc;

#print all bollywood movies profit with unit normalization
select
	m.movie_id, title, budget, revenue, currency, unit,
    CASE
		when  unit ="thousands" then round((revenue-budget)/1000,1)
        when  unit ="billions" then round((revenue-budget)*1000,1)
        else round((revenue-budget),1)
    END as profit_mln
from movies m
join financials f on m.movie_id=f.movie_id
where industry = "bollywood"
order by profit_mln Desc;

#join more than two tables
select m.title,group_concat(a.name separator " | ") as actors
from movies m
join movie_actor ma on ma.movie_id =m.movie_id
join actors a on a.actor_id =ma.actor_id
group by m.movie_id ;

#print actors movie count 
select 
	a.name, group_concat(m.title separator " | ") as movies,
    count(m.title) as movie_count
from movies m
join movie_actor ma on ma.movie_id =m.movie_id
join actors a on a.actor_id =ma.actor_id
group by a.actor_id 
order by movie_count desc;

















