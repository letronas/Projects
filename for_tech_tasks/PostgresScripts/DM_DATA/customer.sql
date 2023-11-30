-- Drop tab if exists
DROP TABLE IF EXISTS "DM_DATA".customer;

-- Create table
CREATE TABLE "DM_DATA".customer (
  id bigint PRIMARY KEY NOT NULL,
  first_name varchar(50) NOT NULL,
  last_name varchar(50) NOT NULL,
  gender varchar(6) NOT NULL,
  email varchar(150) NOT NULL,
  billing_address varchar(150) NOT NULL,
  shipping_address varchar(150) NOT NULL
);

-- Comment table
COMMENT ON TABLE "DM_DATA".customer IS 'Cleaned data from stage layer. Table that stores customer data';

-- Comment on columns
COMMENT ON COLUMN "DM_DATA".customer.id IS 'Primary Key for the customer';
COMMENT ON COLUMN "DM_DATA".customer.first_name IS 'Customer’s First Name';
COMMENT ON COLUMN "DM_DATA".customer.last_name IS 'Customer’s Last Name';
COMMENT ON COLUMN "DM_DATA".customer.gender IS 'Customer’s Gender';
COMMENT ON COLUMN "DM_DATA".customer.email IS 'Customer’s email address';
COMMENT ON COLUMN "DM_DATA".customer.billing_address IS 'Default Billing Address of the Customer';
COMMENT ON COLUMN "DM_DATA".customer.shipping_address IS 'Default Shipping Address of the Customer';

