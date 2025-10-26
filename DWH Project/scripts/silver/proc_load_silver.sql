
/*===========================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

USE Datawarehouse
GO

---EXEC silver.load_silver
-- GO
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';
    -- Loading silver.crm_cust_info
    SET @start_time = GETDATE();
    PRINT '>>> Truncating Table : silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    PRINT '>>> Loading data into : silver.crm_cust_info';
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
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


    ---------------------loading data into silver.crm_prd_info table-------------------
    SET @start_time = GETDATE();
    PRINT '>>> Truncating Table : silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;
    PRINT '>>> Loading data into : silver.crm_prd_info';

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
    from bronze.crm_prd_info;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    PRINT '>> -------------';



    --=============================Lets work with silver.crm_sales_details table================================

    --- Insert data into silver.crm_sales_details table with necessary transformations
    SET @start_time = GETDATE();
    PRINT '>>> Truncating Table : silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;
    PRINT '>>> Loading data into : silver.crm_sales_details';

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
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    PRINT '>> -------------';


    --=======================================================================================================
    -------------------lets work with ERP data table
    set @start_time = GETDATE();
    PRINT '>>> Truncating Table : silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;
    PRINT '>>> Loading data into : silver.erp_cust_az12';

    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT 
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))       -- remove 'NAS' prefix if exists
        ELSE cid
    END AS cid,
    CASE 
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,       ---set future birth dates to null
    CASE 
        WHEN UPPER(TRIM(gen)) In ('M', 'MALE') Then 'Male'
        WHEN UPPER(TRIM(gen)) In ('F', 'FEMALE') Then 'Female'
        ELSE 'n/a'
    END AS gen          ---normalize the gender values and handle unknown cases 
    from bronze.erp_cust_az12;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    PRINT '>> -------------';

    --============================================================================
    -----ERp location table
    PRINT '------------------------------------------------';
    PRINT 'Loading ERP Tables';
    PRINT '------------------------------------------------';

-- Loading erp_loc_a101
    SET @start_time = GETDATE();
    PRINT '>>> Truncating Table : silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;
    PRINT '>>> Loading data into : silver.erp_loc_a101';

    Insert into silver.erp_loc_a101 (cid, cntry)
    SELECT 
    REPLACE(cid, '-', '') cid,
    Case 
        when TRIM(cntry) = 'DE' THEN 'Germany'
        when TRIM(cntry) IN ('US','USA') then 'United States'
        when TRIM(cntry) = '' OR cntry is NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry
    from bronze.erp_loc_a101;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    PRINT '>> -------------';


    ----insert data into silver erp product category table
    SET @start_time = GETDATE();
    PRINT '>>> Truncating Table : silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    PRINT '>>> Loading data into : silver.erp_px_cat_g1v2';

    INSERT into silver.erp_px_cat_g1v2 
    (id,cat,subcat, maintenance)
    SELECT
        id,
        cat,
        subcat,
        maintenance
    from bronze.erp_px_cat_g1v2;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    PRINT '>> -------------';

    SET @batch_end_time = GETDATE();
    PRINT '================================================';
    PRINT 'Silver Layer Load Completed Successfully';
    PRINT 'Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
    PRINT '================================================';

END TRY
BEGIN CATCH
        PRINT '=========================================='
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================='
    END CATCH
END

