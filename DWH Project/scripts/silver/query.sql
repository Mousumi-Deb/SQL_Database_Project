--- check for null or duplicate records in primary key columns
---expectation =No null or duplicate records

USE Datawarehouse;
GO

SELECT
    cst_id,
    COUNT(*)
from bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


--- check for specific customer id
SELECT * from bronze.crm_cust_info
WHERE cst_id = 29466

--- check for rownumber functon or remove any duplicates 
SELECT
*
FROM (
SELECT 
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
from bronze.crm_cust_info) t 
WHERE flag_last = 1


---check for unwanted spaces
---expectation = no unwanted spaces

SELECT cst_firstname 
from bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

---ccheck for lastname
SELECT cst_lastname 
from bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

---no result

SELECT cst_gndr 
from bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)
---data standardization and consistency check
SELECT DISTINCT cst_gndr from bronze.crm_cust_info;



---transformation and then insert data into silver table
use Datawarehouse;
GO
    

---check the data in silver table
SELECT * from silver.crm_cust_info;

--customer id
SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
group by cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

---checks first name
SELECT cst_firstname 
from silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

---checks first name
SELECT cst_lastname 
from silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

--SELECT cst_key from silver.crm_cust_info


--============================================== Recheck silver.crm_sales_details table for data quality issues===============================
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



----------------data quality check-(before inserting data into silver product table)------------------
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
HAVING COUNT(*) > 1 OR prd_id IS NULL;


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




-----------------data quality check-(before inserting data into silver sales details table)------------------

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



----
use DataWarehouse
GO

SELECT 
cid,
CASE 
    WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
    ELSE cid
END AS cid,
bdate,
gen
from bronze.erp_cust_az12
where CASE 
    when cid like 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
    ELSE cid
END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)



--- IDENTIFY OUT OD RANGE DATES

SELECT 
bdate
from bronze.erp_cust_az12
where bdate > '1924-01-01' AND bdate < GETDATE()


--- data standardization & consistency
SELECT Distinct gen,
CASE 
    WHEN UPPER(TRIM(gen)) In ('M', 'MALE') Then 'Male'
    WHEN UPPER(TRIM(gen)) In ('F', 'FEMALE') Then 'Female'
    ELSE 'n/a'
END AS gen 
from bronze.erp_cust_az12;


---data quality check after loading data into silver.erp_cust_az12 table
SELECT distinct gen from silver.erp_cust_az12



--- lets query erp location table for data quality issues
SELECT 
REPLACE(cid, '-', '') cid,
Case 
    when TRIM(cntry) = 'DE' THEN 'Germany'
    when TRIM(cntry) IN ('US','USA') then 'United States'
    when TRIM(cntry) = '' OR cntry is NULL THEN 'n/a'
    ELSE TRIM(cntry)
END AS cntry

from bronze.erp_loc_a101


---data standardization & consistency check
SELECT distinct cntry
from silver.erp_loc_a101 ORDER BY cntry;


SELECT * from silver .erp_loc_a101;


------- erp px category table data quality check
SELECT 
    id,
    cat, 
    subcat,
    maintenance
from bronze.erp_px_cat_g1v2



---check unwanted spaces in cat
SELECT*
from bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) or subcat != TRIM(subcat) or maintenance != TRIM(maintenance)


--standardization & consistency check
SELECT distinct maintenance
from bronze.erp_px_cat_g1v2

-- silver loading procedure execution
USE Datawarehouse
--exec silver.load_silver
go
--- EXEC bronze.load_bronze
exec bronze.load_bronze
GO


----- GOldLayer-----

-- checking data interation

SELECT Distinct
    ci.cst_gndr,
    ca.gen,
    case 
        when ci.cst_gndr != 'n/a' then ci.cst_gndr  --- crm is the  master for gender info  
        Else coalesce(ca.gen,'n/a')
    END as new_gen

FROM silver.crm_cust_info ci
left join silver.erp_cust_az12 ca  
    on ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la  
    on ci.cst_key = la.cid
ORDER BY 1, 2