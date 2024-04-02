-- Month

Select * from fact_forecast_monthly
where 
	customer_code = 90002002 and
    year(date_add(date, interval 4 month)) =2021
order by date desc

