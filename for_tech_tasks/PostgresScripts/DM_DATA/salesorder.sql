-- Drop tab if exists
DROP TABLE IF EXISTS "DM_DATA".salesorder;

-- Create table
CREATE TABLE "DM_DATA".salesorder (
  id bigint PRIMARY KEY NOT NULL,
  customer_id bigint NOT NULL,
  order_number varchar(50) NOT NULL,
  created_at timestamp(0) NOT NULL,
  modified_at timestamp(0) NOT NULL,
  order_total numeric(28, 10) NOT NULL,
  total_qty_ordered bigint NOT NULL,
  UNIQUE(order_number)
);

-- Comment table
COMMENT ON TABLE "DM_DATA".salesorder IS 'Cleaned data from stage layer. Table that stores order data';

-- Comment on columns
COMMENT ON COLUMN "DM_DATA".salesorder.id IS 'Unique identifier of the Order record';
COMMENT ON COLUMN "DM_DATA".salesorder.customer_id IS 'Customer ID of the customer who placed the order';
COMMENT ON COLUMN "DM_DATA".salesorder.order_number IS 'Unique Readable Order Number which is used by the business';
COMMENT ON COLUMN "DM_DATA".salesorder.created_at IS 'Created Time of the Order';
COMMENT ON COLUMN "DM_DATA".salesorder.modified_at IS 'Last Modified time of the order';
COMMENT ON COLUMN "DM_DATA".salesorder.order_total IS 'Total Value of the Order';
COMMENT ON COLUMN "DM_DATA".salesorder.total_qty_ordered IS 'Total No of Items in the Order';