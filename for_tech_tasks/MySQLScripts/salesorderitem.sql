DROP TABLE IF EXISTS db.salesorderitem;

-- db.salesorderitem definition

CREATE TABLE db.`salesorderitem` (
  `item_id` varchar(15) DEFAULT NULL,
  `order_id` varchar(30) DEFAULT NULL,
  `product_id` varchar(20) DEFAULT NULL,
  `product_sku` varchar(200) DEFAULT NULL,
  `product_name` varchar(200) DEFAULT NULL,
  `qty_ordered` varchar(5) DEFAULT NULL,
  `price` varchar(20) DEFAULT NULL,
  `line_total` varchar(20) DEFAULT NULL,
  `created_at` varchar(30) DEFAULT NULL,
  `modified_at` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Than I comment it even it's a raw data
ALTER TABLE db.salesorderitem MODIFY item_id varchar(15) COMMENT "Unique identifier for the order item record"
							,MODIFY order_id varchar(30) COMMENT "Related Order Record id slaesorder.id"
							,MODIFY product_id varchar(20) COMMENT "Related Product’s ID"
							,MODIFY product_sku varchar(200) COMMENT "Product’s SKU, which use to identify the product uniquely by the business"
							,MODIFY product_name varchar(200) COMMENT "Name of the Product"
							,MODIFY qty_ordered varchar(5) COMMENT "Quantity Ordered"
							,MODIFY price varchar(20) COMMENT "Unit Price of the Product"
							,MODIFY line_total varchar(20) COMMENT "Qty_ordered * price"
							,MODIFY created_at varchar(30) COMMENT "Created Time of the Order Line Item Records"
							,MODIFY modified_at varchar(30) COMMENT "Last Modified time of the Line Item Record";