
-- get fiscal quarter

Select * from fact_sales_monthly
where 
	customer_code = 90002002 and
    get_fiscal_year(date) =2021 and 
    get_fiscal_quarter(date) ="Q4"
order by date asc
limit 100000;


-- get variant, total gross price
select 
	s.date, s.product_code,
    p.product, p.variant, s.sold_quantity,
    g.gross_price,
    round(g.gross_price*s.sold_quantity,2) as total_gross_price
from fact_sales_monthly s
join dim_product p
on p.product_code = s.product_code
join fact_gross_price g 
on
	g.product_code = s.product_code and
    g.fiscal_year = get_fiscal_year(s.date)
where
	customer_code = 90002002 and 
    get_fiscal_year(date) = 2021
order by date asc
limit 1000000;

-- cromas transaction and monthly total gross sales

select 
	s.date,
    sum(round(g.gross_price * s.sold_quantity,2)) as total_gross_price
from fact_sales_monthly s 
join fact_gross_price g
on
	g.product_code = s.product_code and
    g.fiscal_year = get_fiscal_year(s.date)
where customer_code = 90002002
group by s.date
order by s.date asc;
    
-- Fiscal Year
-- Total Gross Sales amount In that year from Croma

select
		get_fiscal_year(date) as fiscal_year,
		sum(round(sold_quantity*g.gross_price,2)) as yearly_sales
from fact_sales_monthly s
join fact_gross_price g
on 
	g.fiscal_year=get_fiscal_year(s.date) and
	g.product_code=s.product_code
where
	customer_code=90002002
group by get_fiscal_year(date)
order by fiscal_year;

