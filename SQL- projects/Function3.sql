#count function
select count(*) from movies where industry="bollywood";

#max function
select (max(imdb_rating))as max_rating from movies where industry ="Hollywood";

#max function
select (min(imdb_rating)) as min_rating from movies where industry ="Hollywood";

# Average function
select round(avg(imdb_rating),2) as avg_rating from movies where studio ="Marvel Studios";

#all 3 func together
select max(imdb_rating) as max_rating,
	min(imdb_rating) as min_rating,
    round(avg(imdb_rating),2) as avg_rating 
    from movies where studio ="Marvel Studios";
    
#group By function
Select industry, count(industry) as total,
round(avg(imdb_rating),2) as avg_rating
from movies group by industry;
    
Select 
	studio, count(*) as total 
from movies where studio != ""
group by studio 
order by total DESC;
    
# Having function
#From -----> where ----> group by ---> Having ------> Order by

select release_year, count(*) as movies_count from movies
group by release_year
having movies_count > 2
order by movies_count desc;
    
    
    
    
    
    