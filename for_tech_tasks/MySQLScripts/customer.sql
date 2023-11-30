DROP TABLE IF EXISTS db.customer;

-- db.customer definition


CREATE TABLE db.`customer` (
  `id` varchar(10) DEFAULT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `gender` varchar(50) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `billing_address` varchar(150) DEFAULT NULL,
  `shipping_address` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Than I comment it even it's a raw data
ALTER TABLE db.customer MODIFY id varchar(10) COMMENT "Primary Key for the customer"
						,MODIFY first_name varchar(50) COMMENT "Customer\’s First Name"
						,MODIFY last_name varchar(50) COMMENT "Customer\’s Last Name"
						,MODIFY gender varchar(50) COMMENT "Customer\’s Gender"
						,MODIFY email varchar(150) COMMENT "Customer\’s email address"
						,MODIFY billing_address varchar(150) COMMENT "Default Billing Address of the Customer"
						,MODIFY shipping_address varchar(150) COMMENT "Default Shipping Address of the Customer";
