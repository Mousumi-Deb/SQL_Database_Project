select *, (revenue-budget) as profit from financials;

#get revenue into INR
# If function
Select *, 
	if(currency="USD", revenue*77, revenue) as revenue_inr
    from financials;

#print all unit distinct col
Select distinct unit from financials;

#get revenue into millions
Select *,
	case
		when unit ="thousands" then revenue/1000
        when unit ="billions" then revenue*1000
        when unit ="millions" then revenue
	end as revenue_Mln
from financials;

#print all profit % for all the movies
Select *, 
	(revenue-budget) as profit,
    (revenue-budget)* 100/budget as profit_pct
from financials;









