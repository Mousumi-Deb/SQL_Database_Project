-- get total quantity for all country
SELECT
	c.market,
	sum(sold_quantity) as total_qty
FROM fact_sales_monthly fs
join dim_customer c
on fs.customer_code = c.customer_code
where get_fiscal_year(fs.date) = 2021
group by c.market;


### Module: Problem Statement and Pre-Invoice Discount Report

-- Include pre-invoice deductions in Croma detailed report
SELECT 
		s.date, 
		s.product_code, 
		p.product, 
	p.variant, 
		s.sold_quantity, 
		g.gross_price as gross_price_per_item,
		ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
		pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
JOIN dim_product p
		ON s.product_code=p.product_code
JOIN fact_gross_price g
		ON g.fiscal_year=get_fiscal_year(s.date)
		AND g.product_code=s.product_code
JOIN fact_pre_invoice_deductions as pre
		ON pre.customer_code = s.customer_code AND
		pre.fiscal_year=get_fiscal_year(s.date)
WHERE 
	s.customer_code=90002002 AND 
	get_fiscal_year(s.date)=2021     
LIMIT 1000000;

-- creating pre invoice deductions in croma detailed report for all the customers
SELECT 
		s.date, 
		s.customer_code,
		s.product_code, 
		p.product, p.variant, 
		s.sold_quantity, 
		g.gross_price as gross_price_per_item,
		ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
		pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
JOIN dim_product p
		ON s.product_code=p.product_code
JOIN fact_gross_price g
		ON g.fiscal_year= get_fiscal_year(s.date)
		AND g.product_code=s.product_code
JOIN fact_pre_invoice_deductions as pre
		ON pre.customer_code = s.customer_code AND
		pre.fiscal_year= get_fiscal_year(s.date)
WHERE
    get_fiscal_year(s.date)= 2021
LIMIT 1000000;


-- 



