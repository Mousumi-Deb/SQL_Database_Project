# get top total quantity
select
	p.division,
	p.product,
    sum(sold_quantity) as total_qty
from 
	gdb0041.fact_sales_monthly s
join dim_product p on p.product_code = s.product_code
where 
	fiscal_year = 2021
group by 
	p.division, p.product;


#to get to 3 dense rank product
with cte1 as(
	select
		p.division,
		p.product,
		sum(sold_quantity) as total_qty
	from 
		gdb0041.fact_sales_monthly s
	join dim_product p on p.product_code = s.product_code
	where 
		fiscal_year = 2021
	group by p.division, p.product),

	cte2 as (
		select 
			*, 
			dense_rank() over(partition by division order by total_qty desc) as dens_rnk
		from cte1)
select * from cte2 where dens_rnk <= 3;


#retrieve the top 2 markets in every region by their gross sales amount in FY=2021.
with cte1 as (
		select
			c.market,
			c.region,
			round(sum(gross_price_total)/1000000,2) as gross_sales_mln
		from net_sales s
		join dim_customer c
			on c.customer_code=s.customer_code
		where fiscal_year=2021
		group by c.market,c.region
		order by gross_sales_mln desc),
cte2 as (select 
			*,
			dense_rank() over(partition by region order by gross_sales_mln desc) as drnk
		 from cte1)
select * from cte2 where drnk<=2;


#get the percentage of net sales 
with cte1 as (
	select customer,
		round(sum(net_sales)/1000000,2) as net_sales_mln
	from net_sales s
	join dim_customer c
		on s.customer_code = c.customer_code
	where s.fiscal_year = 2021
	group by customer)

select 
	*,
    net_sales_mln *  100 / sum(net_sales_mln) over() as pct
from cte1
order by net_sales_mln desc;


#get percentage share region of net sales
with cte1 as (
	select 
		c.customer,
        c.region,
		round(sum(net_sales)/1000000,2) as net_sales_mln
	from net_sales s
	join dim_customer c
		on s.customer_code = c.customer_code
	where s.fiscal_year = 2021
	group by c.customer, c.region)
    
select 
	*,
    net_sales_mln *  100 / sum(net_sales_mln) over(partition by region) as pct_share_region 
from cte1
order by region, net_sales_mln desc;


#from expenses table
#get all column of expenses table in order to category

select *,
row_number() over(partition by category order by amount desc) as row_num
from expenses
order by category;


#get top 2 expenses in each category
with cte1 as (
	select *,
	row_number() over(partition by category order by amount desc) as row_num,
    rank() over(partition by category order by amount desc) as rank_num,
    dense_rank() over(partition by category order by amount desc) as dens_rnk
from expenses
order by category)

select * from cte1 where dens_rnk <= 2;


#from student_ranks tagle get the rank and dense rank
select *,
	row_number() over(order by marks desc) as row_num,
    rank() over(order by marks desc) as rank_num,
    dense_rank() over(order by marks desc) as dens_rnk
from student_marks;











	



