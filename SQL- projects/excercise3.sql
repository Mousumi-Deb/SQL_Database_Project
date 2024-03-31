#How many movies were released between 2015 and 2022
select count(*) from movies where release_year Between 2015 and 2022;

#2. Print the max and min movie release year
select min(release_year),
	max(release_year)
from movies;

#Print year and how many movies were released in that year starting with the latest year
select release_year, count(*) as cnt_year from movies
group by release_year order by release_year desc;

# print all movies where more than 2 movies were released
Select release_year, count(*) as movies_count from movies
group by release_year
order by movies_count desc