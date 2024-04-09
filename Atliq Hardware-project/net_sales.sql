-- get total post invoice discount percentages
select
	*,
    (1 - pre_invoice_discount_pct) * gross_price_total as net_invoice_sales,
    (po.discounts_pct + po.other_deductions_pct) as post_invoice_discount_pct
from sales_preinvoice_discount s 
join fact_post_invoice_deductions po
on 
	s.date = po.date and
    s.product_code = po.product_code and
    s.customer_code = po.customer_code;
    
select
	market,
    sum(net_sales)
from net_sales
where fiscal_year = 2021
group by market;

#get top five market 

select
	market,
    round(sum(net_sales)/1000000,2) as net_sales_mln
from net_sales
where fiscal_year = 2021
group by market
order by net_sales_mln desc
limit 5;


#get top customers

select
	c.customer,
    round(sum(net_sales)/1000000,2) as net_sales_mln
from net_sales n
join dim_customer c 
	on n.customer_code = c.customer_code
where fiscal_year = 2021
group by c.customer
order by net_sales_mln desc
limit 5;




