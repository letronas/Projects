-- Drop tab if exists
DROP TABLE IF EXISTS "STG".customer;

-- Create table
CREATE TABLE "STG".customer (
  id varchar(10) NULL,
  first_name varchar(50) NULL,
  last_name varchar(50) NULL,
  gender varchar(50) NULL,
  email varchar(150) NULL,
  billing_address varchar(150) NULL,
  shipping_address varchar(150) NULL
);

-- Comment table
COMMENT ON TABLE "STG".customer IS 'Stage table from MySQL DB with the same name. Table that stores customer data';

-- Comment on columns
COMMENT ON COLUMN "STG".customer.id IS 'Primary Key for the customer';
COMMENT ON COLUMN "STG".customer.first_name IS 'Customer’s First Name';
COMMENT ON COLUMN "STG".customer.last_name IS 'Customer’s Last Name';
COMMENT ON COLUMN "STG".customer.gender IS 'Customer’s Gender';
COMMENT ON COLUMN "STG".customer.email IS 'Customer’s email address';
COMMENT ON COLUMN "STG".customer.billing_address IS 'Default Billing Address of the Customer';
COMMENT ON COLUMN "STG".customer.shipping_address IS 'Default Shipping Address of the Customer';

