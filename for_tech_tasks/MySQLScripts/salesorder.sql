DROP TABLE IF EXISTS db.salesorder;

-- db.salesorder definition

CREATE TABLE db.`salesorder` (
  `id` varchar(30) DEFAULT NULL,
  `customer_id` varchar(10) DEFAULT NULL,
  `order_number` varchar(50) DEFAULT NULL,
  `created_at` varchar(30) DEFAULT NULL,
  `modified_at` varchar(30) DEFAULT NULL,
  `order_total` varchar(20) DEFAULT NULL,
  `total_qty_ordered` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Than I comment it even it's a raw data
ALTER TABLE db.salesorder MODIFY id varchar(30) COMMENT "Unique identifier of the Order record"
						,MODIFY customer_id varchar(10) COMMENT "Customer ID of the customer who placed the order"
						,MODIFY order_number varchar(50) COMMENT "Unique Readable Order Number which is used by the business"
						,MODIFY created_at varchar(30) COMMENT "Created Time of the Order"
						,MODIFY modified_at varchar(30) COMMENT "Last Modified time of the order"
						,MODIFY order_total varchar(20) COMMENT "Total Value of the Order"
						,MODIFY total_qty_ordered varchar(5) COMMENT "Total No of Items in the Order";