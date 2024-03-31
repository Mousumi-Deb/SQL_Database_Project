
select * from food_db.items
cross join food_db.variants;

Select *, concat(name, " - ", variant_name) as full_name
from food_db.items
cross join food_db.variants;

Select *, concat(name, " - ", variant_name) as full_name,
	(price+variant_price) as full_price
from food_db.items
cross join food_db.variants;


