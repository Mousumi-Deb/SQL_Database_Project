use DataWarehouse
GO

--- creating customer dim tables----
/*
CREATE VIEW gold.dim_customers as 
SELECT
    ROW_NUMBER() over(order by cst_id) as customer_key,
    ci.cst_id as customer_id,
    ci.cst_key as customer_number,
    ci.cst_firstname as first_name,
    ci.cst_lastname as lastname,
    la.cntry as country,
    ci.cst_marital_status as marital_status,
    case 
        when ci.cst_gndr != 'n/a' then ci.cst_gndr  --- crm is the  master for gender info  
        Else coalesce(ca.gen,'n/a')
    END as gender,
    ca.bdate as birthdate,
    ci.cst_create_date as create_date
FROM silver.crm_cust_info ci
left join silver.erp_cust_az12 ca  
    on ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la  
    on ci.cst_key = la.cid;


----------creating product dim table----------------
CREATE VIEW gold.dim_products as 
SELECT 
ROW_NUMBER() over(order by pn.prd_start_dt, pn.prd_key)as product_key,
    pn.prd_id as product_id,
    pn.prd_key as product_number,
    pn.prd_nm as product_name,
    pn.cat_id as category_id,
    pc.cat as category,
    pc.subcat as subcategory,
    pc.maintenance,
    pn.prd_cost as cost,
    pn.prd_line as product_line,
    pn.prd_start_dt as start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc  
    ON pn.cat_id = pc.id
WHERE prd_end_dt is NULL;*/

------- creating fact tables in gold layers

CREATE VIEW gold.fact_sales as
SELECT
    sd.sls_ord_num as order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt as order_date,
    sd.sls_ship_dt as shipping_date,
    sd.sls_due_dt as due_date,
    sd.sls_sales as sales_amount,
    sd.sls_quantity as quantity,
    sd.sls_price as price
FROM silver.crm_sales_details as sd
LEFT JOIN gold.dim_products pr  
 ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu  
 ON sd.sls_cust_id = cu.customer_id

