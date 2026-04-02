-- Anzahl aller Bestellungen in der View prüfen
SELECT COUNT(*) AS total_orders
FROM retail.v_order_fact;

-- Prüfen, bei wie vielen Bestellungen keine Zahlungsdaten vorhanden sind
SELECT COUNT(*) AS missing_payment_revenue
FROM retail.v_order_fact
WHERE payment_revenue IS NULL;

-- Prüfen, bei wie vielen Bestellungen keine Item-/Umsatzdaten vorhanden sind
SELECT COUNT(*) AS missing_item_value
FROM retail.v_order_fact
WHERE gross_item_value IS NULL;

-- Anzahl der bereits gelieferten Bestellungen prüfen
SELECT COUNT(*) AS delivered_orders
FROM retail.v_order_fact
WHERE order_delivered_customer_date IS NOT NULL;

-- Durchschnittswerte für Umsatz und Lieferzeit berechnen
SELECT
    ROUND(AVG(payment_revenue), 2) AS avg_payment_revenue,
    ROUND(AVG(gross_item_value), 2) AS avg_gross_item_value,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days
FROM retail.v_order_fact;