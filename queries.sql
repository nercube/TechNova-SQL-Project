SELECT e.name,d.department_name,e.salary
    FROM employees e JOIN departments d
    ON e.department_id=d.department_id;
    
SELECT c.name, o.order_id, o.order_date, o.total_amount
    FROM orders o JOIN customers c
    ON c.customer_id=o.customer_id
    WHERE o.order_status='completed';
    
SELECT d.department_name, SUM(e.salary)
   FROM departments d JOIN employees e 
   ON d.department_id= e.department_id
   GROUP BY d.department_name
   ORDER BY SUM(e.salary) DESC;
   
SELECT c.name, SUM(p.amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_status = 'Success'
GROUP BY c.name
ORDER BY total_spent DESC;

SELECT d.department_name, SUM(e.salary)
    FROM  departments d JOIN employees e ON e.department_id=d.department_id 
    GROUP BY d.department_name
    ORDER BY SUM(e.salary) DESC;

SELECT d.department_name, ROUND(SUM(e.salary)/(SELECT SUM(salary) FROM employees)*100, 2) AS P
    FROM departments d JOIN employees e 
    ON d.department_id=e.department_id
    GROUP BY d.department_name
    ORDER BY P DESC;

-- Who are Top 3 highest paying customers bases on total salary spent
SELECT c.name, SUM(p.amount) AS total
    FROM orders o JOIN customers c ON o.customer_id=c.customer_id
    JOIN payments p ON p.order_id=o.order_id WHERE p.payment_status='SUCCESS'
    GROUP BY c.name
    ORDER BY total DESC
    LIMIT 3;
 
-- Show customers who placed more than 1 order.
SELECT c.name
    FROM orders o JOIN customers c ON o.customer_id=c.customer_id
    GROUP BY c.name
    HAVING COUNT(o.order_id)>1;

-- Customers who never placed an order (LEFT JOIN + NULL)
SELECT (c.name)
    FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id
    WHERE  o.order_id IS NULL;

--  Products never sold
SELECT p.product_name
    FROM products p LEFT JOIN order_items o ON p.product_id=o.product_id
    WHERE o.product_id IS NULL;
    
-- Monthly revenue report
SELECT YEAR(p.payment_date) AS year, MONTH(p.payment_date) AS month, SUM(p.amount) AS total_amount
    FROM payments p
    WHERE p.payment_status='SUCCESS'
    GROUP BY YEAR(p.payment_date), MONTH(p.payment_date)
    ORDER BY year,month;
-- Revenue by category
SELECT pr.category, SUM(pa.amount) AS total_revenue
    FROM products pr JOIN order_items oi ON pr.product_id=oi.product_id 
    JOIN payments pa ON oi.order_id=pa.order_id
    WHERE pa.payment_status='SUCCESS'
    GROUP BY pr.category
    ORDER BY total_revenue DESC;
    
-- Average order value per customer
SELECT c.name, ROUND(SUM(p.amount)/COUNT(o.order_id), 2) AS avg_order_value
   FROM customers c JOIN orders o ON c.customer_id=o.customer_id
   JOIN payments p ON o.order_id=p.order_id
   WHERE p.payment_status='SUCCESS'
   GROUP BY c.name;
   
-- Customers with more than 2 orders
SELECT c.name, COUNT(o.order_id) AS order_count
    FROM orders o JOIN customers c ON c.customer_id=o.customer_id
    WHERE o.customer_id IS NOT NULL
    GROUP BY c.name
    HAVING order_count>2;

-- Orders with no successful payment
SELECT o.order_id
    FROM payments p LEFT join orders o ON p.order_id=o.order_id AND payment_status='SUCCESS'
    WHERE p.order_id IS NULL;

-- Rank employees by salary inside department
select d.department_name, e.name, RANK() OVER(PARTITION BY d.department_name ORDER BY e.salary DESC) r
    FROM employees e LEFT JOIN departments d ON e.department_id=d.department_id;
    
-- Top earning employee per department
SELECT * FROM(
    select d.department_name, e.name, RANK() OVER(PARTITION BY d.department_name ORDER BY e.salary DESC) r
    FROM employees e LEFT JOIN departments d ON e.department_id=d.department_id
) t
WHERE r=1;

-- Running total of monthly revenue
SELECT month, amount, SUM(amount) OVER(ORDER BY month) running_total
    FROM ( SELECT MONTH(payment_date) month, SUM(amount) amount  
    FROM payments 
    WHERE payment_status='SUCCESS' 
    GROUP BY MONTH(payment_date)
    ) t;

-- Compare employee salary with department average
SELECT  name, salary, ROUND(AVG(salary) OVER(PARTITION BY department_id), 2) avg_salary_by_department, 
    (salary - ROUND(AVG(salary) OVER(PARTITION BY department_id), 2)) AS difference,
    CASE 
        WHEN salary>AVG(salary) OVER(PARTITION BY department_id) THEN 'ABOVE_AVERAGE'
        WHEN salary<AVG(salary) OVER(PARTITION BY department_id) THEN 'BELOW_AVG'
        ELSE 'EQUAL'
	END AS comparison_status
    FROM employees ;
    
-- Compare employee salary with department average
WITH salary_data AS (
    SELECT 
        name, salary, department_id, AVG(salary) OVER(PARTITION BY department_id) AS dept_avg
    FROM employees
)

SELECT name, salary, ROUND(dept_avg, 2) AS avg_salary_by_department,
    salary - ROUND(dept_avg, 2) AS difference,
    CASE
        WHEN salary > dept_avg THEN 'ABOVE_AVERAGE'
        WHEN salary < dept_avg THEN 'BELOW_AVG'
        ELSE 'EQUAL'
    END AS comparison_status
FROM salary_data;


-- Identify repeat customers
SELECT * FROM(
SELECT DISTINCT name, COUNT(o.customer_id) OVER(PARTITION BY o.customer_id) AS n
    FROM customers c LEFT JOIN orders o ON c.customer_id=o.customer_id ) AS t
    WHERE n>1;

-- Cohort-style analysis (first order month vs repeat orders)
WITH first_order AS(
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM orders GROUP BY customer_id
)
SELECT o.customer_id, DATE_FORMAT(f.first_order_date, '%Y-%M') AS coherent_month,
    COUNT(order_id) total_orders,
    SUM(CASE
            WHEN o.order_date>f.first_order_date THEN 1
            ELSE 0
		END) AS repeat_orders
    FROM orders o JOIN first_order f ON o.customer_id=f.customer_id 
    GROUP BY o.customer_id, coherent_month;



-- Find 2nd highest salary per department
WITH SALARY_TABLE_RANK AS(
SELECT name, e.salary, d.department_name, DENSE_RANK() OVER(PARTITION BY e.department_id ORDER BY e.salary DESC) AS r
    FROM employees e LEFT JOIN departments d ON e.department_id=d.department_id
)
SELECT * FROM SALARY_TABLE_RANK WHERE r=2;

-- PHASE 5
-- 1.Sales Dashboard Queries (Total Revenue, Monthy Grwoth, Total Orders, Active Customers, Payment Success Rate)

-- 1.1 Total Revenue
SELECT SUM(amount) AS TOTAL_REVENUE FROM payments WHERE payment_status='SUCCESS';

-- 1.2 Monthly Growth
WITH SALES AS (SELECT date_format(payment_date, '%Y-%M') AS monthly, SUM(CASE
	WHEN payment_status='SUCCESS' THEN amount ELSE 0 END 
    ) AS month_revenue
    FROM payments WHERE payment_status='SUCCESS'
    GROUP BY date_format(payment_date, '%Y-%M')
)
SELECT monthly, month_revenue, LAG(month_revenue) OVER(ORDER BY monthly) AS previous_month,
    ROUND(
    (month_revenue - LAG(month_revenue) OVER (ORDER BY monthly))/(LAG(month_revenue) OVER(ORDER BY monthly)) *100, 2
    ) AS growth_present
    FROM SALES;
    
-- 1.3 Total Orders
SELECT COUNT(order_id) FROM orders;

-- 1.4 Active Customers
SELECT DISTINCT c.name
    FROM customers c LEFT JOIN orders o ON c.customer_id=o.customer_id
    WHERE DATE_FORMAT(order_date, '%Y-%m')='2024-02';
    
-- Payment Success Rate
SELECT ROUND(COUNT(CASE WHEN payment_status='SUCCESS' THEN 1 END)/COUNT(*)*100 , 2) AS success_rate
    FROM payments;

-- 2.Churn Prediction Logic (Churn = Customer who stopped buying)
SELECT c.customer_id, c.name, MAX(order_date) AS last_order
    FROM customers c LEFT JOIN orders o ON c.customer_id=o.customer_id
    GROUP BY c.customer_id,c.name
    HAVING last_order<SUBDATE(CURDATE(),INTERVAL 30 DAY) OR MAX(o.order_date) IS NULL;
    
-- 3.Revenue growth month over month
WITH MONTHLY_REVENUE AS(SELECT DATE_FORMAT(payment_date,'%Y-%M') AS over_month, SUM(amount) AS revenue
    FROM payments WHERE payment_status='SUCCESS' GROUP BY over_month ORDER BY over_month)
SELECT over_month, ROUND((revenue-LAG(revenue) OVER (ORDER BY over_month))/LAG(revenue) OVER (ORDER BY over_month)*100, 2) AS MONTHLY_GROWTH
    FROM MONTHLY_REVENUE;

-- 4.Product performance analysis
SELECT p.product_id, p.product_name, COUNT(oi.order_id) AS total_orders, SUM(oi.quantity*oi.price_at_purchase) AS PRODUCT_REVENUE
    FROM products p JOIN order_items oi ON p.product_id=oi.product_id 
        JOIN orders o ON oi.order_id=o.order_id 
		JOIN payments pa ON o.order_id=pa.order_id
        WHERE pa.payment_status='SUCCESS'
    GROUP BY p.product_id, p.product_name
    ORDER BY PRODUCT_REVENUE
    LIMIT 10;

-- 5.Employee productivity logic
WITH REVENUE AS(
    SELECT SUM(amount) AS total_revenue FROM payments WHERE payment_status='SUCCESS'
) ,
COUNT_EMPLOYEES AS(
    SELECT COUNT(employee_id) AS count_employees FROM employees
)
SELECT ROUND(r.total_revenue/e.count_employees) AS revenue_per_employee FROM REVENUE r, COUNT_EMPLOYEES e ;

WITH REVENUE AS(
    SELECT SUM(amount) AS total_revenue FROM payments WHERE payment_status='SUCCESS'
) ,
TOTAL_SALARY AS(
    SELECT SUM(salary) AS total_salary FROM employees
)
SELECT ROUND(r.total_revenue/s.total_salary, 2) AS profit_revenue_per_employee FROM REVENUE r, TOTAL_SALARY s ;

-- Payment failure rate
SELECT ROUND(COUNT(CASE WHEN payment_status!='SUCCESS' THEN 1 END)/COUNT(*)*100, 2) AS payment_failure_rate
    FROM payments ;
    
-- Customer Lifetime values
EXPLAIN
SELECT c.name, c.customer_id, COALESCE(SUM(p.amount),0) AS life_time_value
    FROM customers c LEFT JOIN orders o ON c.customer_id=o.customer_id
    LEFT JOIN payments p ON o.order_id=p.order_id
    AND p.payment_status='SUCCESS'
    GROUP BY c.name,c.customer_id
    ORDER BY life_time_value DESC;
    
-- PHASE 6

-- TASK 1- CREATING INDEXES
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_payments_order ON payments(order_id);   
CREATE INDEX idx_payments_order ON payments(payment_status);
CREATE INDEX idx_order_product ON order_items(product_id);
CREATE INDEX idx_payment_status_order ON payments(payment_status, order_id);
    
SHOW CREATE TABLE orders;

-- TASK 2 - Compare JOIN vs Subquery Performance
EXPLAIN 
SELECT c.customer_id, c.name, SUM(p.amount) AS total_revenue
    FROM customers c JOIN orders o ON c.customer_id=o.customer_id
    JOIN payments p ON o.order_id=p.order_id
    WHERE p.payment_status='SUCCESS'
    GROUP BY c.customer_id, c.name;
    
EXPLAIN 
SELECT c.customer_id, c.name, (
    SELECT SUM(p.amount) FROM orders o JOIN payments p ON o.order_id=p.order_id 
    WHERE o.customer_id=c.customer_id AND p.payment_status='SUCCESS') as total_revenue
    FROM customers c;
    
-- Task 3 - Optimize a Slow Query
EXPLAIN 
SELECT c.customer_id, c.name, SUM(p.amount) AS total_revenue
    FROM customers c JOIN orders o ON c.customer_id=o.customer_id JOIN payments p ON o.order_id=p.order_id
    WHERE p.payment_status='SUCCESS'
    GROUP BY  c.customer_id, c.name
    ORDER BY total_revenue DESC;
 
EXPLAIN
WITH PAYMENT AS (
    SELECT order_id,SUM(amount) AS total_amount
    FROM payments WHERE payment_status='SUCCESS'
    GROUP BY order_id),
 ORDERS AS (
    SELECT o.order_id, o.customer_id, p.total_amount
    FROM PAYMENT p JOIN orders o ON p.order_id=o.order_id
)
SELECT c.customer_id, c.name, SUM(o.total_amount) AS total_revenue FROM ORDERS o JOIN customers c ON o.customer_id=c.customer_id
GROUP BY c.customer_id ORDER BY total_revenue DESC;



-- PHASE 7

-- TASK 1 - CREATE ANALYTICS VIEW FOR REVENUE
CREATE VIEW vw_customer_revenue AS
    SELECT c.customer_id , c.name AS customer_name, 
    COUNT(DISTINCT o.order_id) AS total_order, COALESCE(SUM(p.amount),0) AS total_revenue
    FROM customers c LEFT JOIN orders o ON c.customer_id=o.customer_id
    LEFT JOIN payments p ON o.order_id=p.order_id AND p.payment_status='SUCCESS'
    GROUP BY c.customer_id, c.name
;

SELECT * FROM vw_customer_revenue;

-- TASK 2  - CREATE RESTRICTED ROLE FOR ANALYST
CREATE ROLE analyst_role;
GRANT SELECT ON technova_pvt_ltd.vw_customer_revenue TO analyst_role;

CREATE USER 'analyst1'@'localhost' IDENTIFIED BY 'admin';
GRANT analyst_role TO 'analyst1'@'localhost';
SET DEFAULT ROLE analyst_role TO 'analyst1'@'localhost';


SELECT CURRENT_USER();
