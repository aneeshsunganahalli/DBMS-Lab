-- create customer table
CREATE TABLE Customer (
    cust INT PRIMARY KEY,
    cname VARCHAR(100),
    city VARCHAR(100)
);

-- create order table 
CREATE TABLE Order_ (
    order_ INT PRIMARY KEY,
    odate DATE,
    cust INT,
    order_amt INT,
    FOREIGN KEY (cust) REFERENCES Customer(cust) ON DELETE CASCADE
);

-- Create Item table 
CREATE TABLE Item (
    item INT PRIMARY KEY,
    unitprice INT
);

-- Create Order_item table
CREATE TABLE OrderItem (
    order_ INT,
    item INT,
    qty INT,
    FOREIGN KEY (order_) REFERENCES Order_(order_) ON DELETE CASCADE,
    FOREIGN KEY (item) REFERENCES Item(item) ON DELETE CASCADE
);

-- Create Warehouse table bcoz shipment requires warehouse as reference
CREATE TABLE Warehouse (
    warehouse INT PRIMARY KEY,
    city VARCHAR(100)
);

-- create shipment table
CREATE TABLE Shipment (
    order_ INT,
    warehouse INT,
    ship_date DATE,
    FOREIGN KEY (order_) REFERENCES Order_(order_) ON DELETE CASCADE,
    FOREIGN KEY (warehouse) REFERENCES Warehouse(warehouse) ON DELETE CASCADE
);

-- 1. List the Order# and Ship_date for all orders shipped from Warehouse "2".   
-- Relational Algebra: π order_,ship_date (σ warehouse=2 (Shipment))
SELECT s.order_, s.ship_date
FROM Shipment s
WHERE s.warehouse = 2;

-- 2. List the Warehouse information from which the Customer named "Kumar" was supplied his orders.
-- Relational Algebra: π order_,warehouse,city (σ cname='Kumar' (Customer ⋈ Order_ ⋈ Shipment ⋈ Warehouse))
SELECT o.order_, s.warehouse,w.city
FROM Order_ o
JOIN Shipment s ON o.order_ = s.order_
JOIN Customer c ON o.cust = c.cust
JOIN Warehouse w ON s.warehouse = w.warehouse
WHERE c.cname = 'Kumar';

-- 3. Produce a listing: Cname, #ofOrders, Avg_Order_Amt
-- Relational Algebra: γ cname,count(*)->no_of_orders,avg(order_amt)->avg_order_amt (Customer ⋈ Order_)
select cname, COUNT(*) as no_of_orders, AVG(order_amt) as avg_order_amt
from Customer c, Order_ o
where c.cust=o.cust 
group by cname;

-- 4. Delete all orders for customer named "Kumar".
-- Relational Algebra: Order_ ← Order_ - π order_ (σ cname='Kumar' (Customer ⋈ Order_))
DELETE FROM Order_
WHERE cust = (SELECT cust FROM Customer WHERE cname = 'Kumar');

-- 5. Find the item with the maximum unit price.
-- Relational Algebra: π item,unitprice (σ unitprice=max(unitprice) (Item))
SELECT item,unitprice
FROM Item
WHERE unitprice = (SELECT MAX(unitprice) FROM Item);

-- 7. Create a view to display orderID and shipment date of all orders shipped from warehouse 5
-- Relational Algebra: π order_,ship_date (σ warehouse=5 (Shipment))
CREATE OR REPLACE VIEW OrdersFromWarehouse5 AS
SELECT s.order_, s.ship_date
FROM Shipment s
WHERE s.warehouse = 5;
