-- Drop tab if exists
DROP TABLE IF EXISTS "DATA".sales_order_item_flat;

-- Create table
CREATE TABLE "DATA".sales_order_item_flat (
	item_id bigint NULL,
	order_id bigint NULL,
	order_number varchar(50) NULL,
	order_created_at timestamp(0) NULL,
	order_total numeric(28, 10) NULL,
	total_qty_ordered bigint NULL,
	customer_id bigint NULL,
	customer_name varchar(50) NULL,
	customer_gender varchar(6) NULL,
	customer_email varchar(150) NULL,
	product_id bigint NULL,
	product_sku varchar(200) NULL,
	product_name varchar(200) NULL,
	item_price numeric(28, 10) NULL,
	item_qty_order bigint NULL
);

-- Comment table
COMMENT ON TABLE "DATA".sales_order_item_flat IS 'Report veiew of DM_DATA/ customer + selesorder + salesorderitem';

-- Comment on columns
COMMENT ON COLUMN "DATA".sales_order_item_flat.item_id IS 'Unique identifier for the order item record';
COMMENT ON COLUMN "DATA".sales_order_item_flat.order_id IS 'Unique identifier of the Order record';
COMMENT ON COLUMN "DATA".sales_order_item_flat.order_number IS 'Unique Readable Order Number which is used by the business';
COMMENT ON COLUMN "DATA".sales_order_item_flat.order_created_at IS 'Created Time of the Order';
COMMENT ON COLUMN "DATA".sales_order_item_flat.order_total IS 'Total Value of the Order';
COMMENT ON COLUMN "DATA".sales_order_item_flat.total_qty_ordered IS 'Total No of Items in the Order';
COMMENT ON COLUMN "DATA".sales_order_item_flat.customer_id IS 'Customer ID of the customer who placed the order';
COMMENT ON COLUMN "DATA".sales_order_item_flat.customer_name IS 'Customer’s First Name';
COMMENT ON COLUMN "DATA".sales_order_item_flat.customer_gender IS 'Customer’s Gender';
COMMENT ON COLUMN "DATA".sales_order_item_flat.customer_email IS 'Customer’s email address';
COMMENT ON COLUMN "DATA".sales_order_item_flat.product_id IS 'Related Product’s ID';
COMMENT ON COLUMN "DATA".sales_order_item_flat.product_sku IS 'Product’s SKU, which use to identify the product uniquely by the business';
COMMENT ON COLUMN "DATA".sales_order_item_flat.product_name IS 'Name of the Product';
COMMENT ON COLUMN "DATA".sales_order_item_flat.item_price IS 'Unit Price of the Product';
COMMENT ON COLUMN "DATA".sales_order_item_flat.item_qty_order IS 'Quantity Ordered';

