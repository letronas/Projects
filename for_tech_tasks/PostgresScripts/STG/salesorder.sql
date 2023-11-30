-- Drop tab if exists
DROP TABLE IF EXISTS "STG".salesorder;

-- Create table
CREATE TABLE "STG".salesorder (
  id varchar(30) NULL,
  customer_id varchar(10) NULL,
  order_number varchar(50) NULL,
  created_at varchar(30) NULL,
  modified_at varchar(30) NULL,
  order_total varchar(20) NULL,
  total_qty_ordered varchar(5) NULL
);

-- Comment table
COMMENT ON TABLE "STG".salesorder IS 'Stage table from MySQL DB with the same name. Table that stores order data';

-- Comment on columns
COMMENT ON COLUMN "STG".salesorder.id IS 'Unique identifier of the Order record';
COMMENT ON COLUMN "STG".salesorder.customer_id IS 'Customer ID of the customer who placed the order';
COMMENT ON COLUMN "STG".salesorder.order_number IS 'Unique Readable Order Number which is used by the business';
COMMENT ON COLUMN "STG".salesorder.created_at IS 'Created Time of the Order';
COMMENT ON COLUMN "STG".salesorder.modified_at IS 'Last Modified time of the order';
COMMENT ON COLUMN "STG".salesorder.order_total IS 'Total Value of the Order';
COMMENT ON COLUMN "STG".salesorder.total_qty_ordered IS 'Total No of Items in the Order';