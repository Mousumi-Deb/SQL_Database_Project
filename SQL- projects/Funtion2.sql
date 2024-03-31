
# print movies where imdb_rating is greater than 9
select * from movies where imdb_rating > 9;

# print movies where imdb_rating is greater than equal to 6
select * from movies where imdb_rating <= 6;

# AND Funtion
select * from movies where imdb_rating >= 6 and imdb_rating <= 9;

# between Funtion
select * from movies where imdb_rating between 6 and 9;

# OR funtion
select * from movies where release_year= 2019 or release_year= 2022;

# In funtion
select * from movies where release_year IN (2018,2019,2022);

select * from movies where imdb_rating is not null;

# order by
select * from movies 
where industry="Hollywood" order by imdb_rating DESC;

#limit funtion
select * from movies 
where industry="Hollywood" order by imdb_rating DESC Limit 5;

## offset (is index num)
select * from movies 
where industry="Hollywood" 
order by imdb_rating DESC Limit 5 offset 1;



















