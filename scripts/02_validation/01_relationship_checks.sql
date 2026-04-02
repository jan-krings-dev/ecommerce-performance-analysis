-- Orders ohne passenden Customer
SELECT COUNT(*) AS missing_customers_for_orders
FROM retail.orders o
LEFT JOIN retail.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Order Items ohne passende Order
SELECT COUNT(*) AS missing_orders_for_items
FROM retail.order_items oi
LEFT JOIN retail.orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Order Items ohne passendes Product
SELECT COUNT(*) AS missing_products_for_items
FROM retail.order_items oi
LEFT JOIN retail.products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Order Items ohne passenden Seller
SELECT COUNT(*) AS missing_sellers_for_items
FROM retail.order_items oi
LEFT JOIN retail.sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Payments ohne passende Order
SELECT COUNT(*) AS missing_orders_for_payments
FROM retail.order_payments op
LEFT JOIN retail.orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Reviews ohne passende Order
SELECT COUNT(*) AS missing_orders_for_reviews
FROM retail.order_reviews r
LEFT JOIN retail.orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Produkte ohne Category Translation
SELECT
    COUNT(*) AS missing_category_translations,
    (SELECT COUNT(*) FROM retail.products) AS total_products,
    ROUND(
        COUNT(*)::NUMERIC / NULLIF((SELECT COUNT(*) FROM retail.products), 0),
        4
    ) AS missing_rate
FROM retail.products p
LEFT JOIN retail.product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;

-- Customers ohne Geolocation-Match über ZIP Prefix
SELECT
    COUNT(*) AS customers_without_geo_match,
    (SELECT COUNT(*) FROM retail.customers) AS total_customers,
    ROUND(
        COUNT(*)::NUMERIC / NULLIF((SELECT COUNT(*) FROM retail.customers), 0),
        4
    ) AS missing_rate
FROM retail.customers c
LEFT JOIN retail.geolocation g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

-- Sellers ohne Geolocation-Match über ZIP Prefix
SELECT
    COUNT(*) AS sellers_without_geo_match,
    (SELECT COUNT(*) FROM retail.sellers) AS total_sellers,
    ROUND(
        COUNT(*)::NUMERIC / NULLIF((SELECT COUNT(*) FROM retail.sellers), 0),
        4
    ) AS missing_rate
FROM retail.sellers s
LEFT JOIN retail.geolocation g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

-- Fazit: keine relevanten Auffälligkeiten gefunden, Daten können so weiterverarbeitet werden