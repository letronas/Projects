-- Drop tab if exists
DROP TABLE IF EXISTS "DM_DATA".salesorderitem;

-- Create table
CREATE TABLE "DM_DATA".salesorderitem (
  item_id bigint PRIMARY KEY NOT NULL,
  order_id bigint NOT NULL,
  product_id bigint NOT NULL,
  product_sku varchar(200) NOT NULL,
  product_name varchar(200) NOT NULL,
  qty_ordered bigint NOT NULL,
  price numeric(28, 10) NOT NULL,
  line_total numeric(28, 10) NOT NULL,
  created_at timestamp(0) NOT NULL,
  modified_at timestamp(0) NOT NULL
);

-- Comment table
COMMENT ON TABLE "DM_DATA".salesorderitem IS 'Cleaned data from stage layer. Table that stores tem data at the order level';

-- Comment on columns
COMMENT ON COLUMN "DM_DATA".salesorderitem.item_id IS 'Unique identifier for the order item record';
COMMENT ON COLUMN "DM_DATA".salesorderitem.order_id IS 'Related Order Record id slaesorder.id';
COMMENT ON COLUMN "DM_DATA".salesorderitem.product_id IS 'Related Product’s ID';
COMMENT ON COLUMN "DM_DATA".salesorderitem.product_sku IS 'Product’s SKU, which use to identify the product uniquely by the business';
COMMENT ON COLUMN "DM_DATA".salesorderitem.product_name IS 'Name of the Product';
COMMENT ON COLUMN "DM_DATA".salesorderitem.qty_ordered IS 'Quantity Ordered';
COMMENT ON COLUMN "DM_DATA".salesorderitem.price IS 'Unit Price of the Product';
COMMENT ON COLUMN "DM_DATA".salesorderitem.line_total IS 'Qty_ordered * price';
COMMENT ON COLUMN "DM_DATA".salesorderitem.created_at IS 'Created Time of the Order Line Item Records';
COMMENT ON COLUMN "DM_DATA".salesorderitem.modified_at IS 'Last Modified time of the Line Item Record';
