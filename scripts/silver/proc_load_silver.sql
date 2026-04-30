/*
===============================================================
DDL Script: Create Bronze Tables
===============================================================
Script Purpose:
  Creates tables in the 'bronze' schema, dropping existing tables if they already exist.
  Run this script to redefine the DDL structure of the 'bronze' tables.
===============================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
	t_start TIMESTAMP;
	t_step TIMESTAMP;
BEGIN
	t_start := clock_timestamp();

	RAISE NOTICE'===================================';
	RAISE NOTICE'Loading Silver Tables';
	RAISE NOTICE'===================================';

	RAISE NOTICE'-----------------------------------';
	RAISE NOTICE'Loading CRM Tables';
	RAISE NOTICE'-----------------------------------';

	t_step := clock_timestamp();
	RAISE NOTICE'Loading Table silver.crm_cust_info';
	
	TRUNCATE silver.crm_cust_info;
	INSERT INTO silver.crm_cust_info (
	cst_id ,
	cst_key ,
	cst_firstname ,
	cst_lastname ,
	cst_marital_status ,
	cst_gndr ,
	cst_create_date)
	SELECT 
	cst_id ,
	cst_key ,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname ,
	CASE
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'n/a' 
	END AS cst_marital_status,
	CASE 
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		ELSE 'n/a'
	END AS cst_gndr,
	cst_create_date FROM (
	SELECT *, row_number() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
	)
	WHERE flag_last = 1;


	RAISE NOTICE'Truncating Table silver.crm_prd_info';
	TRUNCATE silver.crm_prd_info;
	RAISE NOTICE'Loading Table silver.crm_prd_info';
	INSERT INTO silver.crm_prd_info (
	prd_id ,
	cat_id ,
	prd_key ,
	prd_nm ,
	prd_cost ,
	prd_line ,
	prd_start_dt ,
	prd_end_dt
	)
	SELECT
	prd_id,
	REPLACE (SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
	prd_nm,
	CASE WHEN prd_cost IS NULL THEN 0
	ELSE prd_cost END AS prd_cost,
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a' END AS prd_line,
	prd_start_dt,
	LEAD(prd_start_dt - 1) OVER (PARTITION BY SUBSTRING(prd_key, 7, LENGTH(prd_key)) ORDER BY prd_start_dt) AS prd_end_dt
	FROM bronze.crm_prd_info;


	RAISE NOTICE'Truncating Table silver.crm_sales_details';
	TRUNCATE silver.crm_sales_details;
	RAISE NOTICE'Loading Table silver.crm_sales_details';
	INSERT INTO silver.crm_sales_details (
	sls_ord_num ,
	sls_prd_key ,
	sls_cust_id ,
	sls_order_dt ,
	sls_ship_dt ,
	sls_due_dt ,
	sls_sales ,
	sls_quantity ,
	sls_price
	)
	SELECT
	sls_ord_num ,
	sls_prd_key ,
	sls_cust_id ,
	CASE
		WHEN sls_order_dt <= 0 OR LENGTH(sls_order_dt::text) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE
		WHEN sls_ship_dt <= 0 OR LENGTH(sls_ship_dt::text) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE
		WHEN sls_due_dt <= 0 OR LENGTH(sls_due_dt::text) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE
		WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price) 
		THEN  sls_quantity * ABS(sls_price)
		WHEN sls_sales IS NULL OR sls_sales <=0 AND sls_price <0 THEN sls_quantity * sls_price * (-1)
		ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE
		WHEN sls_price IS NULL OR sls_price = 0 THEN sls_sales / sls_quantity
		WHEN sls_price < 0 THEN sls_price * (-1)
		ELSE sls_price
	END AS sls_price
	FROM bronze.crm_sales_details;

	RAISE NOTICE'CRM Tables Loading Time: % ms',
	EXTRACT(milliseconds FROM (clock_timestamp() - t_step));

	t_step := clock_timestamp();
	RAISE NOTICE'-----------------------------------';
	RAISE NOTICE'Loading ERP Tables';
	RAISE NOTICE'-----------------------------------';

	RAISE NOTICE'Truncating Table silver.epr_cust_az12';
	TRUNCATE silver.erp_cust_az12;
	RAISE NOTICE'Loading Table silver.erp_cust_az12';
	INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
	SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
		ELSE cid
	END AS cid,
	CASE
		WHEN bdate > CURRENT_DATE THEN NULL
		ELSE bdate
	END AS bdate,
	CASE
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		ELSE 'n/a'
	END AS gen
	FROM bronze.erp_CUST_AZ12;


	RAISE NOTICE'Truncating Table silver.erp_loc_a101';
	TRUNCATE silver.erp_loc_a101;
	RAISE NOTICE'Loading Table silver.epr_loc_a101';
	INSERT INTO silver.erp_loc_a101 (cid, cntry)
	SELECT
	REPLACE(cid, '-', '') AS cid,
	CASE
		WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
		WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		ELSE TRIM(cntry)
	END AS cntry
	FROM bronze.erp_LOC_A101;


	RAISE NOTICE'Truncating Table silver.erp_px_cat_g1v2';
	TRUNCATE silver.erp_px_cat_g1v2;
	RAISE NOTICE'Loading Table silver.erp_px_cat_g1v2';
	INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
	SELECT
	id,
	cat,
	subcat,
	maintenance
	FROM bronze.erp_px_cat_g1v2;

	RAISE NOTICE'ERP Tables Loading Time: % ms',
	EXTRACT(milliseconds FROM (clock_timestamp() - t_step));

	RAISE NOTICE'Silver Layer Tables Loading Time : % ms',
	EXTRACT(milliseconds FROM (clock_timestamp() - t_start));
END;
$$

CALL silver.load_silver();
