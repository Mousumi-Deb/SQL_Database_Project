-- Month

Select * from fact_sales_monthly
where 
	customer_code = 90002002 and
    year(date_add(date, interval 4 month)) =2021
order by date desc;

-- get fiscal year
Select * from fact_sales_monthly
where 
	customer_code = 90002002 and
    get_fiscal_year(date) =2021
order by date asc;


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


-- 





















