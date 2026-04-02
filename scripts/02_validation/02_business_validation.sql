-- Ungültige negative Werte bei Order Items
SELECT COUNT(*) AS invalid_negative_item_values
FROM retail.order_items
WHERE price < 0
   OR freight_value < 0;

-- Ungültige negative Werte bei Payments
SELECT COUNT(*) AS invalid_negative_payment_values
FROM retail.order_payments
WHERE payment_value < 0
   OR payment_installments < 0;

-- Review Score außerhalb 1-5
SELECT COUNT(*) AS invalid_review_scores
FROM retail.order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;

-- Orders mit Approval vor Purchase
SELECT COUNT(*) AS approval_before_purchase
FROM retail.orders
WHERE order_approved_at IS NOT NULL
  AND order_approved_at < order_purchase_timestamp;

-- Delivery Carrier Date vor Purchase
SELECT COUNT(*) AS carrier_before_purchase
FROM retail.orders
WHERE order_delivered_carrier_date IS NOT NULL
  AND order_delivered_carrier_date < order_purchase_timestamp;

-- Customer Delivery vor Purchase
SELECT COUNT(*) AS customer_delivery_before_purchase
FROM retail.orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date < order_purchase_timestamp;

-- Estimated Delivery vor Purchase
SELECT COUNT(*) AS estimated_delivery_before_purchase
FROM retail.orders
WHERE order_estimated_delivery_date IS NOT NULL
  AND order_estimated_delivery_date < order_purchase_timestamp;

-- Delivered Orders ohne Delivered Customer Date
SELECT COUNT(*) AS delivered_without_customer_date
FROM retail.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

-- Orders mit Gesamtzahlung = 0 oder negativ
SELECT COUNT(*) AS orders_with_nonpositive_payment_total
FROM (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment
    FROM retail.order_payments
    GROUP BY order_id
) x
WHERE total_payment <= 0;

-- Orders, deren Payment Total stark von Item Total abweicht
SELECT COUNT(*) AS payment_item_total_mismatch
FROM (
    SELECT
        oi.order_id,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS item_total,
        ROUND(COALESCE(p.total_payment, 0), 2) AS payment_total
    FROM retail.order_items oi
    LEFT JOIN (
        SELECT
            order_id,
            SUM(payment_value) AS total_payment
        FROM retail.order_payments
        GROUP BY order_id
    ) p
        ON oi.order_id = p.order_id
    GROUP BY oi.order_id, p.total_payment
) x
WHERE ABS(item_total - payment_total) > 0.05;

-- Produkte mit unplausiblen Dimensionen
SELECT COUNT(*) AS implausible_product_dimensions
FROM retail.products
WHERE product_weight_g < 0
   OR product_length_cm < 0
   OR product_height_cm < 0
   OR product_width_cm < 0;

-- Null-Checks auf Kernfeldern Orders
SELECT COUNT(*) AS orders_missing_core_fields
FROM retail.orders
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR order_purchase_timestamp IS NULL;

-- Null-Checks auf Kernfeldern Order Items
SELECT COUNT(*) AS items_missing_core_fields
FROM retail.order_items
WHERE order_id IS NULL
   OR order_item_id IS NULL
   OR product_id IS NULL
   OR seller_id IS NULL;

-- Mehrfache Reviews je Order prüfen
SELECT
    order_id,
    COUNT(*) AS review_count
FROM retail.order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY review_count DESC, order_id;

-- Mehrfache Payments je Order prüfen
SELECT
    order_id,
    COUNT(*) AS payment_rows
FROM retail.order_payments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_rows DESC, order_id;

-- Fazit: keine relevanten Auffälligkeiten gefunden, Daten können so weiterverarbeitet werden