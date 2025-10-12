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
-- want to drop IF EXISTS



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

