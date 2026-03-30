/*
===============================================================
DDL Script: Create Bronze Tables
===============================================================
Script Purpose:
  Creates tables in the 'bronze' schema, dropping existing tables if they already exist.
  Run this script to redefine the DDL structure of the 'bronze' tables.
===============================================================
*/

DROP TABLE IF EXISTS bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key VARCHAR(32),
	cst_firstname VARCHAR(32),
	cst_lastname VARCHAR(32),
	cst_marital_status VARCHAR(4),
	cst_gndr VARCHAR(4),
	cst_create_date DATE
);

DROP TABLE IF EXISTS bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
	prd_id INT,
	prd_key VARCHAR(32),
	prd_nm VARCHAR(64),
	prd_cost INT,
	prd_line VARCHAR(8),
	prd_start_dt DATE,
	prd_end_dt DATE
);

DROP TABLE IF EXISTS bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
	sls_ord_num VARCHAR(32),
	sls_prd_key VARCHAR(32),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

DROP TABLE IF EXISTS bronze.erp_CUST_AZ12;

CREATE TABLE bronze.erp_CUST_AZ12 (
	CID VARCHAR(32),
	BDATE DATE,
	GEN VARCHAR(16)
);

DROP TABLE IF EXISTS bronze.erp_LOC_A101;

CREATE TABLE bronze.erp_LOC_A101 (
	CID VARCHAR(32),
	CNTRY VARCHAR(64)
);

DROP TABLE IF EXISTS bronze.erp_PX_CAT_G1V2;

CREATE TABLE bronze.erp_PX_CAT_G1V2 (
	ID VARCHAR(16),
	CAT VARCHAR(32),
	SUBCAT VARCHAR(32),
	MAINTENANCE VARCHAR(8)
);
