/*
===============================================================
DDL Script: Create Silver Tables
===============================================================
Script Purpose:
  Creates tables in the 'silver' schema, dropping existing tables if they already exist.
  Run this script to redefine the DDL structure of the 'silver' tables.
===============================================================
*/


DROP TABLE IF EXISTS silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info (
	cst_id INT,
	cst_key VARCHAR(32),
	cst_firstname VARCHAR(32),
	cst_lastname VARCHAR(32),
	cst_marital_status VARCHAR(16),
	cst_gndr VARCHAR(16),
	cst_create_date DATE,
	dwh_create_date timestamp DEFAULT clock_timestamp()
);

DROP TABLE IF EXISTS silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
	prd_id INT,
	cat_id VARCHAR(32),
	prd_key VARCHAR(32),
	prd_nm VARCHAR(64),
	prd_cost INT,
	prd_line VARCHAR(16),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date timestamp DEFAULT clock_timestamp()
);

DROP TABLE IF EXISTS silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
	sls_ord_num VARCHAR(32),
	sls_prd_key VARCHAR(32),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date timestamp DEFAULT clock_timestamp()
);

DROP TABLE IF EXISTS silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
	cid VARCHAR(32),
	bdate DATE,
	gen VARCHAR(16),
	dwh_create_date timestamp DEFAULT clock_timestamp()
);

DROP TABLE IF EXISTS silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101 (
	CID VARCHAR(32),
	CNTRY VARCHAR(64),
	dwh_create_date timestamp DEFAULT clock_timestamp()
);

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2 (
	ID VARCHAR(16),
	CAT VARCHAR(32),
	SUBCAT VARCHAR(32),
	MAINTENANCE VARCHAR(8),
	dwh_create_date timestamp DEFAULT clock_timestamp()
);
