
select * from movies;

## distict funtion
SELECT distinct studio FROM movies;

## count funtion
select count(*) from movies where industry="hollywood";


## where funtion
select * from movies where release_year="2022";

## Like funtion
select * from movies where title like "THOR%";
select * from movies where title like "%America%";