-- Q1.Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS totalOrderPlaced
FROM
    orders;

-- Q2.Calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(quantity * price), 2) AS total_revenue
FROM
    order_details
        INNER JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

-- Q3.Identify the highest-priced pizza
SELECT 
    pizza_types.name, size, price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Q4.Identify the most common pizza size ordered.
SELECT 
    size, COUNT(order_details.pizza_id) AS mostlySoldPizza
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY mostlySoldPizza DESC
LIMIT 1;

-- Q5.List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, sum(order_details.quantity) AS totalQuantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY totalQuantity DESC
LIMIT 5;


-- Q1.Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS totalQuantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY totalQuantity DESC;


-- Q2.Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time) AS hour, COUNT(order_id) AS count_orders
FROM
    orders
GROUP BY HOUR(time);


-- Q3.Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Q4.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(total_quantity), 0) as avg_Quantity
FROM
    (SELECT 
        DATE(date) AS sales_date,
            ROUND(SUM(order_details.quantity), 2) AS total_quantity
    FROM
        orders
    JOIN order_details ON order_details.order_id = orders.order_id
    GROUP BY DATE(date)
) AS order_quantity;
    

-- Q5.Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    pizza_types.pizza_type_id,
    ROUND(SUM(order_details.quantity * price), 2) AS revenue
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_type_id , pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Q1.Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
	pizza_types.category,
    ROUND(
        (SUM(order_details.quantity * pizzas.price) / 
        (SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) 
        FROM order_details
        JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100,
    2) AS revenue_percentage
FROM pizza_types
JOIN
pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN
order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY 
    revenue_percentage DESC;


-- Q2.Analyze the cumulative revenue generated over time.

 SELECT order_date,daily_revenue, 
 ROUND(SUM(daily_revenue) OVER(ORDER BY order_date),2) AS cumulative_revenue
 FROM 
 (SELECT 
    o.date AS order_date,
    ROUND(SUM(od.quantity * p.price),2) AS daily_revenue
FROM
    orders AS o
	JOIN
    order_details AS od ON od.order_id = o.order_id
    JOIN
    pizzas AS p ON p.pizza_id = od.pizza_id
    GROUP BY o.date
) AS daily_revenue_by_date
ORDER BY order_date;


-- Q3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category,name,revenue,revenue_each_category 
FROM
  (SELECT 
	category,
	name,
    revenue,
    RANK() OVER(PARTITION BY category ORDER BY revenue) AS revenue_each_category
FROM 
  (SELECT 
    pt.name,
    pt.category,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM
    pizzas AS p
    JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
	JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name, pt.category
) AS tb1
) AS tb2
where revenue_each_category < 4;



