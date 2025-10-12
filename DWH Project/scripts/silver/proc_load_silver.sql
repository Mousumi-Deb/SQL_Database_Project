
/*-----------------data quality check-(before inserting data into silver product table)------------------
---check for duplicate prd_id
Select 
    sls_prd_key 
from bronze.crm_sales_details
where sls_prd_key NOT IN 
    (SELECT prd_key from silver.crm_prd_info)

SELECT * from bronze.crm_prd_info

-- for split teh data from prd key need to check with bronze category table
SELECT distinct id from bronze.erp_px_cat_g1v2;

---query for testing data quality issues
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
group by prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;*/


---------------------loading data into silver.crm_prd_info table-------------------
USE Datawarehouse
GO

INSERT INTO silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT
    prd_id,
    ---split the prd_key by '-' and take the second part as cat_id
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, --- extract catogory id from prd_key
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -------Extract product key  
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost, --- replace null with 0
    --- standardize the product line values
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'N/A'
    END AS prd_line,  --- map product line ocdes to descriptive values
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(
        LEAD(prd_start_dt) 
        OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1  as Date) AS prd_end_dt --- set end date as one day before the next start date for the same product key
from bronze.crm_prd_info

----Recheck silver.crm_prd_info table for duplicate prd_id
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
group by prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


---check unwanted spaces in prd_nm
SELECT prd_nm 
from silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

---check for NULLs ornegative numbers in prd_cost
SELECT prd_cost
from silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0


---check for invalid date orders
SELECT prd_start_dt, prd_end_dt
from silver.crm_prd_info
WHERE prd_end_dt IS NOT NULL AND prd_end_dt < prd_start_dt


--- FINAL CHECK
SELECT * from silver.crm_prd_info


--=============================Lets work with silver.crm_sales_details table================================
/*-----------------data quality check-(before inserting data into silver sales details table)------------------

select 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
from bronze.crm_sales_details


---check the invalid date orders
SELECT 
    nullif(sls_order_dt,0) as sls_order_dt
from bronze.crm_sales_details
where sls_order_dt <= 0 
OR Len(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

---check the invalid ship date
select distinct
sls_sales,
sls_quantity,
sls_price
from bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL or sls_quantity IS NULL or sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
order by sls_sales, sls_quantity, sls_price;

---- transformation option of 3 columns (sls_sales, sls_quantity, sls_price)    

select distinct
sls_sales as old_sls_sales,
sls_quantity,
sls_price as old_sls_price,
CASE 
    When sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
CASE
    when sls_price is null or sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
from bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL or sls_quantity IS NULL or sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
order by sls_sales, sls_quantity, sls_price;

*/
--- INsert data into silver.crm_sales_details table with necessary transformations
INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price)

select 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE 
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,
  
    CASE 
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,

    CASE
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,

    CASE 
        When sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
					THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
        END AS sls_sales,
    sls_quantity,
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0 
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price  -- Derive price if original value is invalid
    END AS sls_price

from bronze.crm_sales_details



--============== Recheck silver.crm_sales_details table for data quality issues
---check the invalid date orders
SELECT * FROM
silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


---check the invalid ship date
select distinct
sls_sales,
sls_quantity,
sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL or sls_quantity IS NULL or sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
order by sls_sales, sls_quantity, sls_price;


--- FINAL CHECK
SELECT * from silver.crm_sales_details