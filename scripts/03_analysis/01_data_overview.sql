-- Zeitraum Orders
SELECT
    MIN(order_purchase_timestamp) AS first_order_at,
    MAX(order_purchase_timestamp) AS last_order_at,
    COUNT(*) AS total_orders
FROM retail.orders;

-- Anzahl Kundeninstanzen
SELECT COUNT(*) AS total_customer_rows
FROM retail.customers;

-- Anzahl eindeutiger Kunden
SELECT COUNT(DISTINCT customer_unique_id) AS distinct_customers
FROM retail.customers;

-- Anzahl Order Items
SELECT COUNT(*) AS total_order_items
FROM retail.order_items;

-- Anzahl Produkte
SELECT COUNT(*) AS total_products
FROM retail.products;

-- Anzahl Seller
SELECT COUNT(*) AS total_sellers
FROM retail.sellers;

-- Anzahl Reviews
SELECT COUNT(*) AS total_reviews
FROM retail.order_reviews;

-- Anzahl Payments
SELECT COUNT(*) AS total_payments
FROM retail.order_payments;

-- Orders pro eindeutigem Kunden
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS distinct_order_customers,
    ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT c.customer_unique_id), 2) AS avg_orders_per_customer
FROM retail.orders o
JOIN retail.customers c
    ON o.customer_id = c.customer_id;

-- Durchschnittlicher Bestellwert auf Payment-Basis
SELECT
    ROUND(AVG(order_total), 2) AS avg_order_value
FROM (
    SELECT
        order_id,
        SUM(payment_value) AS order_total
    FROM retail.order_payments
    GROUP BY order_id
) x;