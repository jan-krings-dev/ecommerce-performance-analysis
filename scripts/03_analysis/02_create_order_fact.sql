-- View wird neu erstellt (alte Version löschen, um Konflikte zu vermeiden)
DROP VIEW IF EXISTS retail.v_order_fact;


-- Zentrale Faktentabelle auf Order-Ebene bauen (alle wichtigen Infos zusammenführen)
CREATE VIEW retail.v_order_fact AS

-- Zahlungen pro Bestellung aggregieren (Umsatz, Anzahl Zahlungen, Raten)
WITH payment_agg AS (
    SELECT
        order_id,
        SUM(payment_value) AS payment_revenue,
        COUNT(*) AS payment_rows,
        MAX(payment_installments) AS max_installments
    FROM retail.order_payments
    GROUP BY order_id
),

-- Bestellpositionen aggregieren (Mengen, Produkte, Seller, Umsatz + Versand)
item_agg AS (
    SELECT
        oi.order_id,
        COUNT(*) AS items_count,
        COUNT(DISTINCT oi.product_id) AS distinct_products,
        COUNT(DISTINCT oi.seller_id) AS distinct_sellers,
        SUM(oi.price) AS items_revenue,
        SUM(oi.freight_value) AS freight_revenue,
        SUM(oi.price + oi.freight_value) AS gross_item_value
    FROM retail.order_items oi
    GROUP BY oi.order_id
),

-- Reviews aggregieren (Durchschnittsbewertung + Anzahl)
review_agg AS (
    SELECT
        order_id,
        AVG(review_score)::NUMERIC(10,2) AS avg_review_score,
        COUNT(*) AS review_count
    FROM retail.order_reviews
    GROUP BY order_id
)

-- Alles zusammenführen: Orders + Kunden + aggregierte Kennzahlen
SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_status,
    o.order_purchase_timestamp,

    -- Monatsebene für Zeitanalysen
    DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,

    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    -- Zahlungs-KPIs
    pa.payment_revenue,
    pa.payment_rows,
    pa.max_installments,

    -- Item-/Umsatz-KPIs
    ia.items_count,
    ia.distinct_products,
    ia.distinct_sellers,
    ia.items_revenue,
    ia.freight_revenue,
    ia.gross_item_value,

    -- Review-KPIs
    ra.avg_review_score,
    ra.review_count,

    -- Lieferdauer (Bestellung → Lieferung in Tagen)
    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
         AND o.order_purchase_timestamp IS NOT NULL
        THEN EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400.0
        ELSE NULL
    END AS delivery_days,

    -- Abweichung zur geplanten Lieferung (Delay in Tagen)
    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
        THEN EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)) / 86400.0
        ELSE NULL
    END AS delivery_delay_days,

    -- Flag: verspätete Lieferung ja/nein
    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
         AND o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1
        ELSE 0
    END AS is_late_delivery

FROM retail.orders o

-- Kundeninfos hinzufügen (für Segmentierung)
JOIN retail.customers c
    ON o.customer_id = c.customer_id

-- Aggregierte Kennzahlen anhängen (optional vorhanden → LEFT JOIN)
LEFT JOIN payment_agg pa
    ON o.order_id = pa.order_id
LEFT JOIN item_agg ia
    ON o.order_id = ia.order_id
LEFT JOIN review_agg ra
    ON o.order_id = ra.order_id;