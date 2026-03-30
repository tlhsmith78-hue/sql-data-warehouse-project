/*
===============================================================
Stored Procedure : Loads Bronze Layer (Source -> Bronze)
===============================================================
Script Purpose:
  Loads data into the 'bronze' schema from existing CSV files.
  Running this script will 
    - truncate the 'bronze' tables,
    - COPY data from csv files to the 'bronze' tables.

Parameters:
  None. This procedure does not accept parameters and does not return any values.

Usage Example:
  CALL bronze.load_bronze();
===============================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
	t_start TIMESTAMP;
	t_step TIMESTAMP;
BEGIN
	t_start := clock_timestamp();
	
	RAISE NOTICE'===================================';
	RAISE NOTICE'Loading Bronze Tables';
	RAISE NOTICE'===================================';

	RAISE NOTICE'-----------------------------------';
	RAISE NOTICE'Loading CRM Tables';
	RAISE NOTICE'-----------------------------------';

	t_step := clock_timestamp();
	
	TRUNCATE TABLE bronze.crm_cust_info;
	COPY bronze.crm_cust_info
	FROM 'C:\SQL\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
	WITH (
		FORMAT csv,
		DELIMITER ',',
		HEADER true
	);
	
	RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
	TRUNCATE TABLE bronze.crm_prd_info;
	RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
	COPY bronze.crm_prd_info
	FROM 'C:\SQL\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
	WITH (
		HEADER true,
		FORMAT csv,
		DELIMITER ','
	);
	
	RAISE NOTICE '>> Truncating Table: bronze.crm_sales_detailss';
	TRUNCATE TABLE bronze.crm_sales_details;
	RAISE NOTICE'>> Inserting Data Into: bronze.crm_sales_details';
	COPY bronze.crm_sales_details
	FROM 'C:\SQL\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
	WITH (
		FORMAT csv,
		DELIMITER ',',
		HEADER true
	);

	RAISE NOTICE 'CRM Tables Loading Time: % ms',
	EXTRACT(milliseconds FROM (clock_timestamp() - t_step));

	RAISE NOTICE'-----------------------------------';
	RAISE NOTICE'Loading ERP Tables';
	RAISE NOTICE'-----------------------------------';

	t_step := clock_timestamp();

	RAISE NOTICE'>> Truncating Table: bronze.erp_CUST_AZ12';
	TRUNCATE TABLE bronze.erp_CUST_AZ12;
	RAISE NOTICE'>> Inserting Data Into: bronze.erp_CUST_AZ12';
	COPY bronze.erp_CUST_AZ12
	FROM 'C:\SQL\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
	WITH (
		FORMAT csv,
		DELIMITER ',',
		HEADER true
	);
	
	RAISE NOTICE'>> Truncating Table: bronze.erp_LOC_A101';
	TRUNCATE TABLE bronze.erp_LOC_A101;
	RAISE NOTICE'>> Inserting Data Into: bronze.erp_LOC_A101';
	COPY bronze.erp_LOC_A101
	FROM 'C:\SQL\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
	WITH (
		FORMAT csv,
		DELIMITER ',',
		HEADER true
	);
	
	RAISE NOTICE'>> Truncating Table: bronze.erp_PX_CAT_G1V2';
	TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;
	RAISE NOTICE'>> Inserting Data Into: bronze.erp_PX_CAT_G1V2';
	COPY bronze.erp_PX_CAT_G1V2
	FROM 'C:\SQL\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
	WITH (
		FORMAT csv,
		HEADER true,
		DELIMITER ','
	);

	RAISE NOTICE 'ERP Tables Loading Time : % ms',
	EXTRACT (milliseconds FROM (clock_timestamp() - t_step));

	RAISE NOTICE 'Total Table Loading Time : % ms',
	EXTRACT (milliseconds FROM (clock_timestamp() - t_start));
END;
$$
