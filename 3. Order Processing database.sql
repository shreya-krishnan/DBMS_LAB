
-- PROGRAM 3: ORDER PROCESSING DATABASE

DROP DATABASE IF EXISTS order_processing_187;
CREATE DATABASE order_processing_187;
USE order_processing_187;

-- TABLE CREATION

CREATE TABLE Customers (
    cust_id INT PRIMARY KEY,
    cname VARCHAR(35) NOT NULL,
    city VARCHAR(35) NOT NULL
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    odate DATE NOT NULL,
    cust_id INT,
    order_amt INT NOT NULL,
    FOREIGN KEY (cust_id) REFERENCES Customers(cust_id) ON DELETE CASCADE
);

CREATE TABLE Items (
    item_id INT PRIMARY KEY,
    unitprice INT NOT NULL
);

CREATE TABLE OrderItems (
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    qty INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Items(item_id) ON DELETE CASCADE
);

CREATE TABLE Warehouses (
    warehouse_id INT PRIMARY KEY,
    city VARCHAR(35) NOT NULL
);

CREATE TABLE Shipments (
    order_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    ship_date DATE NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id) ON DELETE CASCADE
);

-- INSERT DATA

INSERT INTO Customers VALUES
(0001, "Customer_1", "Mysuru"),
(0002, "Customer_2", "Bengaluru"),
(0003, "Kumar", "Mumbai"),
(0004, "Customer_4", "Dehli"),
(0005, "Customer_5", "Bengaluru");

INSERT INTO Orders VALUES
(001, "2020-01-14", 0001, 2000),
(002, "2021-04-13", 0002, 500),
(003, "2019-10-02", 0003, 2500),
(004, "2019-05-12", 0005, 1000),
(005, "2020-12-23", 0004, 1200);

INSERT INTO Items VALUES
(0001, 400),
(0002, 200),
(0003, 1000),
(0004, 100),
(0005, 500);

INSERT INTO Warehouses VALUES
(0001, "Mysuru"),
(0002, "Bengaluru"),
(0003, "Mumbai"),
(0004, "Dehli"),
(0005, "Chennai");

INSERT INTO OrderItems VALUES
(001, 0001, 5),
(002, 0005, 1),
(003, 0005, 5),
(004, 0003, 1),
(005, 0004, 12);

INSERT INTO Shipments VALUES
(001, 0002, "2020-01-16"),
(002, 0001, "2021-04-14"),
(003, 0004, "2019-10-07"),
(004, 0003, "2019-05-16"),
(005, 0005, "2020-12-23");

-- DISPLAY TABLES

SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM Items;
SELECT * FROM OrderItems;
SELECT * FROM Warehouses;
SELECT * FROM Shipments;


-- QUESTION 1:
-- List Order# and Ship_date for all orders shipped from warehouse 0001.

SELECT order_id, ship_date
FROM Shipments
WHERE warehouse_id = 0001;


-- QUESTION 2:
-- List warehouse information supplying orders to customer Kumar,
-- displaying Order# and Warehouse#.

SELECT s.order_id, s.warehouse_id
FROM Shipments s
JOIN Orders o ON s.order_id = o.order_id
JOIN Customers c ON o.cust_id = c.cust_id
WHERE c.cname LIKE "%Kumar%";


-- QUESTION 3:
-- List customer name, number of orders and average order amount
-- using aggregate functions.

SELECT c.cname,
       COUNT(*) AS no_of_orders,
       AVG(o.order_amt) AS avg_order_amt
FROM Customers c
JOIN Orders o ON c.cust_id = o.cust_id
GROUP BY c.cname;


-- QUESTION 4:
-- Delete all orders for customer named Kumar.

DELETE FROM Orders
WHERE cust_id = (
    SELECT cust_id
    FROM Customers
    WHERE cname LIKE "%Kumar%"
);

SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Shipments;


-- QUESTION 5:
-- Find the item with the maximum unit price.

SELECT MAX(unitprice)
FROM Items;


-- QUESTION 6:
-- Create a trigger to update order amount based on
-- quantity and unit price when a new OrderItem is inserted.

DROP TRIGGER IF EXISTS UpdateOrderAmt;

DELIMITER $$

CREATE TRIGGER UpdateOrderAmt
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET order_amt = NEW.qty * (
        SELECT unitprice
        FROM Items
        WHERE item_id = NEW.item_id
    )
    WHERE order_id = NEW.order_id;
END$$

DELIMITER ;

-- Insert a new order and its corresponding order item.

INSERT INTO Orders VALUES
(006, "2020-12-23", 0004, 1200);

INSERT INTO OrderItems VALUES
(006, 0001, 5);

SELECT * FROM Orders;
SELECT * FROM OrderItems;


-- QUESTION 7:
-- Create a view displaying OrderID and shipment date
-- for all orders shipped from warehouse 5.

CREATE VIEW ShipmentDatesFromWarehouse5 AS
SELECT order_id, ship_date
FROM Shipments
WHERE warehouse_id = 5;

SELECT * FROM ShipmentDatesFromWarehouse5;
