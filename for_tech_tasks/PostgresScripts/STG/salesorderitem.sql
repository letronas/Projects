-- Drop tab if exists
DROP TABLE IF EXISTS "STG".salesorderitem;

-- Create table
CREATE TABLE "STG".salesorderitem (
  item_id varchar(15) NULL,
  order_id varchar(30) NULL,
  product_id varchar(20) NULL,
  product_sku varchar(200) NULL,
  product_name varchar(200) NULL,
  qty_ordered varchar(5) NULL,
  price varchar(20) NULL,
  line_total varchar(20) NULL,
  created_at varchar(30) NULL,
  modified_at varchar(30) NULL
);

-- Comment table
COMMENT ON TABLE "STG".salesorderitem IS 'Stage table from MySQL DB with the same name. Table that stores tem data at the order level';

-- Comment on columns
COMMENT ON COLUMN "STG".salesorderitem.item_id IS 'Unique identifier for the order item record';
COMMENT ON COLUMN "STG".salesorderitem.order_id IS 'Related Order Record id slaesorder.id';
COMMENT ON COLUMN "STG".salesorderitem.product_id IS 'Related Product’s ID';
COMMENT ON COLUMN "STG".salesorderitem.product_sku IS 'Product’s SKU, which use to identify the product uniquely by the business';
COMMENT ON COLUMN "STG".salesorderitem.product_name IS 'Name of the Product';
COMMENT ON COLUMN "STG".salesorderitem.qty_ordered IS 'Quantity Ordered';
COMMENT ON COLUMN "STG".salesorderitem.price IS 'Unit Price of the Product';
COMMENT ON COLUMN "STG".salesorderitem.line_total IS 'Qty_ordered * price';
COMMENT ON COLUMN "STG".salesorderitem.created_at IS 'Created Time of the Order Line Item Records';
COMMENT ON COLUMN "STG".salesorderitem.modified_at IS 'Last Modified time of the Line Item Record';
