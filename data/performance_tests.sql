-- Olist Database Performance Tests
-- These queries test the performance of operations on scalar fields

-- 1. Basic Aggregation Tests

-- Test 1.1: Count total orders
SELECT COUNT(*) FROM orders;

-- Test 1.2: Sum of all payment values
SELECT SUM(payment_value) FROM order_payments;

-- Test 1.3: Average payment value
SELECT AVG(payment_value) FROM order_payments;

-- Test 1.4: Count of orders by status
SELECT order_status, COUNT(*) 
FROM orders 
GROUP BY order_status;

-- 2. Complex Aggregation Tests

-- Test 2.1: Total revenue by payment type
SELECT payment_type, SUM(payment_value) as total_revenue
FROM order_payments
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- Test 2.2: Average order value by customer state
SELECT c.customer_state, AVG(op.payment_value) as avg_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY c.customer_state
ORDER BY avg_order_value DESC;

-- Test 2.3: Total items sold by product category
SELECT p.product_category_name, COUNT(oi.order_item_id) as items_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY items_sold DESC
LIMIT 10;

-- 3. Time-based Analysis Tests

-- Test 3.1: Orders per month
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') as month,
    COUNT(*) as order_count
FROM orders
GROUP BY month
ORDER BY month;

-- Test 3.2: Average delivery time in days
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) as avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Test 3.3: Revenue by month
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') as month,
    SUM(op.payment_value) as total_revenue
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY month
ORDER BY month;

-- 4. Filtering and Comparison Tests

-- Test 4.1: High-value orders (top 10%)
SELECT o.order_id, op.payment_value
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id
WHERE op.payment_value > (
    SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY payment_value)
    FROM order_payments
)
ORDER BY op.payment_value DESC
LIMIT 100;

-- Test 4.2: Products with high profit margin
SELECT 
    p.product_id,
    p.product_category_name,
    AVG(oi.price) as avg_price,
    AVG(oi.freight_value) as avg_freight,
    AVG(oi.price - oi.freight_value) as avg_profit
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_category_name
HAVING avg_profit > 100
ORDER BY avg_profit DESC
LIMIT 20;

-- 5. Correlation Tests

-- Test 5.1: Correlation between review score and payment value
SELECT 
    AVG(CASE WHEN r.review_score >= 4 THEN op.payment_value ELSE NULL END) as high_rating_avg_value,
    AVG(CASE WHEN r.review_score < 4 THEN op.payment_value ELSE NULL END) as low_rating_avg_value
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id
JOIN order_reviews r ON o.order_id = r.order_id;

-- Test 5.2: Correlation between delivery time and review score
SELECT 
    AVG(CASE WHEN DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) <= 7 
        THEN r.review_score ELSE NULL END) as fast_delivery_avg_score,
    AVG(CASE WHEN DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) > 7 
        THEN r.review_score ELSE NULL END) as slow_delivery_avg_score
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL;

-- 6. Performance Tests with Indexes

-- Test 6.1: Create index on payment_value
CREATE INDEX idx_payment_value ON order_payments(payment_value);

-- Test 6.2: Query using the index
SELECT * FROM order_payments WHERE payment_value > 1000 LIMIT 100;

-- Test 6.3: Create composite index on order_id and payment_sequential
CREATE INDEX idx_order_payment ON order_payments(order_id, payment_sequential);

-- Test 6.4: Query using the composite index
SELECT * FROM order_payments WHERE order_id = 'e481f51cbdc54678c7cc91f6eeb20c99';

-- 7. Complex Joins and Calculations

-- Test 7.1: Customer lifetime value
SELECT 
    c.customer_id,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(op.payment_value) as total_spent,
    AVG(op.payment_value) as avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 20;

-- Test 7.2: Seller performance metrics
SELECT 
    s.seller_id,
    COUNT(DISTINCT oi.order_id) as order_count,
    COUNT(oi.order_item_id) as item_count,
    SUM(oi.price) as total_revenue,
    AVG(oi.price) as avg_item_price
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id
ORDER BY total_revenue DESC
LIMIT 20;

-- 8. Window Function Tests

-- Test 8.1: Running total of payments by date
SELECT 
    o.order_id,
    o.order_purchase_timestamp,
    op.payment_value,
    SUM(op.payment_value) OVER (ORDER BY o.order_purchase_timestamp) as running_total
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id
ORDER BY o.order_purchase_timestamp
LIMIT 100;

-- Test 8.2: Rank sellers by revenue
SELECT 
    s.seller_id,
    SUM(oi.price) as total_revenue,
    RANK() OVER (ORDER BY SUM(oi.price) DESC) as revenue_rank
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id
ORDER BY revenue_rank
LIMIT 20; 