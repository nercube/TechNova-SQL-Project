CREATE DATABASE TechNova_Pvt_Ltd;
use TechNova_Pvt_Ltd;
CREATE TABLE departments(
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);
CREATE TABLE employees(
    employee_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2),
    joining_date DATE,
    department_id INT,
    FOREIGN KEY (department_id) references departments(department_id)
);
CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50),
    created_at DATE
);
CREATE TABLE products(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    is_active TINYINT(1)
);
CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_status VARCHAR(20),
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items(
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price_at_purchase DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE payments(
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    payment_method VARCHAR(20),
    payment_status VARCHAR(20),
    amount DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

INSERT INTO departments VALUES
(1, 'HR', 'Delhi'),
(2, 'Tech', 'Bangalore'),
(3, 'Sales', 'Mumbai'),
(4, 'Finance', 'Pune');

INSERT INTO employees VALUES
(101, 'Amit', 60000, '2023-01-10', 2),
(102, 'Riya', 50000, '2023-03-15', 1),
(103, 'Karan', 45000, '2023-06-20', 3),
(104, 'Neha', 70000, '2022-11-05', 2),
(105, 'Priya', 52000, '2023-08-12', 4);

INSERT INTO customers VALUES
(201, 'Rahul', 'rahul@gmail.com', 'Delhi', '2024-01-01'),
(202, 'Sneha', 'sneha@gmail.com', 'Mumbai', '2024-01-05'),
(203, 'Vikas', 'vikas@gmail.com', 'Bangalore', '2024-01-10'),
(204, 'Anjali', 'anjali@gmail.com', 'Delhi', '2024-02-01');

INSERT INTO products VALUES
(301, 'Laptop', 'Electronics', 60000, 1),
(302, 'Mouse', 'Accessories', 500, 1),
(303, 'Keyboard', 'Accessories', 1500, 1),
(304, 'Monitor', 'Electronics', 12000, 1);

INSERT INTO orders VALUES
(401, 201, '2024-02-01', 'Completed', 61500),
(402, 202, '2024-02-03', 'Completed', 1500),
(403, 203, '2024-02-05', 'Pending', 60000),
(404, 201, '2024-02-10', 'Completed', 12000);

INSERT INTO order_items VALUES
(1, 401, 301, 1, 60000),
(2, 401, 302, 3, 500),
(3, 402, 303, 1, 1500),
(4, 403, 301, 1, 60000),
(5, 404, 304, 1, 12000);

INSERT INTO payments VALUES
(501, 401, '2024-02-01', 'Card', 'Success', 61500),
(502, 402, '2024-02-03', 'UPI', 'Success', 1500),
(503, 404, '2024-02-10', 'Card', 'Success', 12000);
