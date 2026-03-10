-- Script purpose:
	-- This script creates a new database called 'DataWarehouse' after checking if it alreadty exists.
	-- If the database exists, it is dropped and recreated. 
	-- Additionally, the script sets up three schemas within the database : 'bronze', 'silver', 'gold'.

-- Warning:
	-- Running this script will drop the entire 'DataWarehouse' database if it exists.
	-- All data in the database will be permanently deleted, proceed with caution.
	-- Ensure you have proper backups before running this script.

\c postgres

DROP DATABASE IF EXISTS DataWarehouse WITH(FORCE);

CREATE DATABASE "DataWarehouse";

\c DataWarehouse

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
