CREATE DATABASE customer_behavior;
USE customer_behavior;
SELECT*FROM customer LIMIT 20;

-- total purchase by gender(comment)
SELECT gender,SUM(`purchase_amount($)`) AS revenue
FROM customer
GROUP BY gender;

-- customer whose purchase amount is greater then avg purchase amount after discount
SELECT customer_id,`purchase_amount($)`
FROM customer
WHERE discount_applied='Yes' AND `purchase_amount($)`> (SELECT AVG(`purchase_amount($)`) FROM customer);

-- top5 products with highest average review rating
USE customer_behavior;
SELECT item_purchased, ROUND(AVG(review_rating),2) AS 'average_product_rating'
FROM customer
GROUP BY item_purchased
ORDER BY AVG(review_rating)DESC
LIMIT 5;

SELECT * FROM customer;

-- compare the avg purchase amount between the standard and express shipping
USE customer_behavior;
SELECT shipping_type,ROUND(AVG(`purchase_amount($)`),2)
FROM customer
WHERE  shipping_type IN('Standard','Express')
GROUP BY shipping_type;

-- do subscribed customer pay more ,compare avg spend and total revenue btw subscribed and non subscribed
SELECT subscription_status,
COUNT(customer_id),
AVG(`purchase_amount($)`) AS avg_spend,
SUM(`purchase_amount($)`) AS total_revenue
FROM customer 
GROUP BY subscription_status
ORDER BY total_revenue DESC;

-- which 5 products have the highest percentage of purchase with disount applied 
SELECT item_purchased,
COUNT(*) AS total_purchases,
SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) AS discounted_purchases,
ROUND(SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS discount_percentage
FROM customer
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;

-- ** segment customer into new,returning and loyal on the basis of the total number of previous purchases and show the count of each segment
-- using CTEs
WITH customer_type as(
SELECT customer_id,previous_purchases,
CASE 
WHEN previous_purchases=1 THEN 'New'
WHEN previous_purchases BETWEEN 2 AND 10  THEN 'Returning'
ELSE 'Loyal'
END AS customer_segment
FROM customer
)
SELECT customer_segment,COUNT(*) AS 'no.of customers'
FROM customer_type
GROUP BY customer_segment;

-- what are the top 3 products with in each category
-- using window function and cte both
WITH item_count AS (
    SELECT category,item_purchased,COUNT(customer_id) AS total_orders,
	ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)

SELECT total_orders,item_rank,category,item_purchased
FROM item_count
WHERE item_rank <=3;

-- Are customer who are repeat buyers(more than 5 previous purchase) also likely to subscribe
SELECT subscription_status,
COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases>5
GROUp BY subscription_status;

-- what is the revenue contribution of each age group
select*from customer limit 10;
select age_group,
SUM(`purchase_amount($)`) as revenue
from customer
GROUP BY age_group
ORDER BY revenue DESC;






