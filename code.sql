-- Creating the tables

CREATE TABLE orders (order_id INT, order_date DATE, user_id INT, product_id INT);
CREATE TABLE users (user_id INT, user_name VARCHAR(40), city VARCHAR(20), signup_date DATE);
CREATE TABLE products (product_id INT, product_name TEXT, price INT);
CREATE TABLE gold (user_id INT, gold_signup_date DATE);

-- Q1 Total amount spent by each customer?

SELECT o.user_id, SUM(p.price) AS total_spend
FROM orders AS o
INNER JOIN products AS p
ON o.product_id = p.product_id
GROUP BY o.user_id
ORDER BY 2 DESC;

-- Q2 How many days has each customer placed an order on the app?

SELECT user_id, COUNT(DISTINCT order_date) AS days_order_placed 
FROM orders
GROUP BY user_id
ORDER BY 2 DESC;

-- Q3 What was the first product purchased by each customer?

SELECT b.user_id, p.product_name AS first_product_purchased
FROM
(SELECT user_id, product_id 
FROM
(SELECT *, RANK() OVER(PARTITION BY user_id ORDER BY order_date) AS rnk
FROM orders) AS a
WHERE rnk = 1) AS b
INNER JOIN products AS p
ON b.product_id = p.product_id
;

-- Q4 What is the most purchased product and how many times was it purchased?

SELECT   p.product_name AS most_purchased_product, COUNT(o.order_id) AS times_purchased 
FROM orders AS o
INNER JOIN products AS p
ON o.product_id = p.product_id
GROUP BY o.product_id, p.product_name
ORDER BY COUNT(o.order_id) DESC 
LIMIT 1;

-- Q5 Which product was most popular for each customer?

SELECT c.user_id, p.product_name AS most_popular_product, c.quantity AS times_purchased FROM
(SELECT user_id, product_id, quantity
FROM
(SELECT *, RANK() OVER(PARTITION BY user_id ORDER BY quantity DESC) AS rnk
FROM
(SELECT user_id, product_id, COUNT(product_id) AS quantity 
FROM orders
GROUP BY user_id, product_id
ORDER BY user_id) AS a) AS b
WHERE rnk = 1) AS c
INNER JOIN products AS p
ON c.product_id = p.product_id
;

-- Q6 Which was the first product purchased by customers after they became a gold member?

SELECT c.user_id, p.product_name AS first_product_purchased_after_gold FROM 
(SELECT user_id, product_id FROM
(SELECT *, RANK() OVER(PARTITION BY user_id ORDER BY order_date) AS rnk
FROM
(SELECT o.user_id, o.product_id, o.order_date, g.gold_signup_date 
FROM orders AS o
INNER JOIN gold AS g ON o.user_id = g.user_id AND o.order_date >= g.gold_signup_date) AS a) AS b
WHERE rnk = 1) AS c
INNER JOIN products AS p
ON c.product_id = p.product_id
;

-- Q7 How many points earned by each customer, if 1 point = 10rs spent by customer?

SELECT user_id, SUM(price)/10 AS total_points
FROM
(SELECT o.order_id, o.user_id, p.price 
FROM orders AS o
INNER JOIN products AS p ON o.product_id = p.product_id) AS a
GROUP BY user_id
ORDER BY user_id
;

-- Q8 How much revenue does each city bring in?

SELECT  a.city, SUM(p.price) AS revenue 
FROM
(SELECT o.order_id, u.city, o.product_id 
FROM orders AS o
INNER JOIN users AS u
ON o.user_id = u.user_id) AS a
INNER JOIN products AS p
ON a.product_id = p.product_id
GROUP BY a.city
ORDER BY 2 DESC
;



