-- Performance nach Produktkategorie analysieren (Umsatz, Menge, Vielfalt)
DROP VIEW IF EXISTS retail.v_category_performance;

CREATE VIEW retail.v_category_performance AS
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category_name,

    -- Verkaufsmenge und Bestellungen je Kategorie
    COUNT(*) AS items_sold,
    COUNT(DISTINCT oi.order_id) AS orders_count,
    COUNT(DISTINCT oi.product_id) AS distinct_products,

    -- Umsatzkennzahlen je Kategorie
    ROUND(SUM(oi.price), 2) AS item_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_revenue,
    ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_item_value

FROM retail.order_items oi
LEFT JOIN retail.products p
    ON oi.product_id = p.product_id
LEFT JOIN retail.product_category_translation t
    ON p.product_category_name = t.product_category_name

GROUP BY COALESCE(t.product_category_name_english, p.product_category_name, 'unknown')
ORDER BY gross_revenue DESC;


-- Performance auf Produktebene analysieren (Details je Produkt)
DROP VIEW IF EXISTS retail.v_product_performance;

CREATE VIEW retail.v_product_performance AS
SELECT
    oi.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category_name,

    -- Verkaufsmenge und Bestellungen je Produkt
    COUNT(*) AS items_sold,
    COUNT(DISTINCT oi.order_id) AS orders_count,

    -- Umsatzkennzahlen je Produkt
    ROUND(SUM(oi.price), 2) AS item_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_revenue,
    ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_item_value

FROM retail.order_items oi
LEFT JOIN retail.products p
    ON oi.product_id = p.product_id
LEFT JOIN retail.product_category_translation t
    ON p.product_category_name = t.product_category_name

GROUP BY
    oi.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown');


-- Kategorien nach Bewertungen analysieren (Qualität + Wert)
DROP VIEW IF EXISTS retail.v_category_review_performance;

CREATE VIEW retail.v_category_review_performance AS
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category_name,

    -- Anzahl bewerteter Bestellungen
    COUNT(DISTINCT oi.order_id) AS reviewed_orders,

    -- Durchschnittliche Bewertung und Warenwert
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_item_value

FROM retail.order_items oi
LEFT JOIN retail.products p
    ON oi.product_id = p.product_id
LEFT JOIN retail.product_category_translation t
    ON p.product_category_name = t.product_category_name
JOIN retail.order_reviews r
    ON oi.order_id = r.order_id

GROUP BY COALESCE(t.product_category_name_english, p.product_category_name, 'unknown')
ORDER BY avg_review_score DESC, reviewed_orders DESC;