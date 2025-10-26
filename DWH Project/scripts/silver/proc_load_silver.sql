
--=============================Lets work with silver.crm_cust_info table================================

USE Datawarehouse
GO

INSERT into silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
        when UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
        when UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
        Else 'N/A'
    END AS cst_marital_status,
    CASE 
        when UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
        when UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
        Else 'N/A'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    from bronze.crm_cust_info where cst_id IS NOT NULL) t 
    WHERE flag_last = 1;


---------------------loading data into silver.crm_prd_info table-------------------


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



--=============================Lets work with silver.crm_sales_details table================================

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

from bronze.crm_sales_details;


--=======================================================================================================
-------------------lets work with ERP data table


SELECT 
CASE 
    WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
    ELSE cid
END AS cid,
bdate,
CASE 
    WHEN bdate > GETDATE() THEN NULL
ELSE bdate
END AS bdate,
gen
from bronze.erp_cust_az12


