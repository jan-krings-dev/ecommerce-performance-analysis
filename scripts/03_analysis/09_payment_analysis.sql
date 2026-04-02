-- Verteilung der Zahlungsarten analysieren (Nutzung und Umsatzanteile)
DROP VIEW IF EXISTS retail.v_payment_type_mix;

CREATE VIEW retail.v_payment_type_mix AS
SELECT
    payment_type,

    -- Anzahl Zahlungen und betroffene Bestellungen
    COUNT(*) AS payment_rows,
    COUNT(DISTINCT order_id) AS orders_count,

    -- Umsatz und Durchschnittswerte je Zahlungsart
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS avg_payment_value,

    -- Anteil an allen Zahlungen und am Gesamtumsatz
    ROUND(
        COUNT(*)::NUMERIC
        / NULLIF((SELECT COUNT(*) FROM retail.order_payments), 0),
        4
    ) AS payment_row_share,
    ROUND(
        SUM(payment_value)
        / NULLIF((SELECT SUM(payment_value) FROM retail.order_payments), 0),
        4
    ) AS payment_value_share

FROM retail.order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- Analyse der Ratenzahlungen (Installments)
DROP VIEW IF EXISTS retail.v_payment_installments;

CREATE VIEW retail.v_payment_installments AS
SELECT
    payment_installments,

    -- Anzahl Zahlungen und Bestellungen je Ratenanzahl
    COUNT(*) AS payment_rows,
    COUNT(DISTINCT order_id) AS orders_count,

    -- Umsatz und Durchschnittswerte
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS avg_payment_value,

    -- Anteil an allen Zahlungen
    ROUND(
        COUNT(*)::NUMERIC
        / NULLIF((SELECT COUNT(*) FROM retail.order_payments), 0),
        4
    ) AS payment_row_share

FROM retail.order_payments
GROUP BY payment_installments
ORDER BY payment_installments;


-- Zusammenhang zwischen Zahlungsart und Bewertung analysieren
DROP VIEW IF EXISTS retail.v_payment_type_review;

CREATE VIEW retail.v_payment_type_review AS
SELECT
    p.payment_type,

    -- Anzahl bewerteter Bestellungen je Zahlungsart
    COUNT(DISTINCT p.order_id) AS reviewed_orders,

    -- Durchschnittliche Bewertung und Zahlungswert
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(AVG(p.payment_value), 2) AS avg_payment_value

FROM retail.order_payments p
JOIN retail.order_reviews r
    ON p.order_id = r.order_id

GROUP BY p.payment_type
ORDER BY reviewed_orders DESC;


-- Zusammenhang zwischen Zahlungsart und Lieferperformance analysieren
DROP VIEW IF EXISTS retail.v_payment_type_delivery;

CREATE VIEW retail.v_payment_type_delivery AS
SELECT
    p.payment_type,

    -- Anzahl Bestellungen je Zahlungsart
    COUNT(DISTINCT o.order_id) AS orders_count,

    -- Durchschnittliche Lieferzeit
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400.0
        ),
        2
    ) AS avg_delivery_days,

    -- Anteil verspäteter Lieferungen
    ROUND(
        AVG(
            CASE
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1.0
                ELSE 0.0
            END
        ),
        4
    ) AS late_delivery_rate

FROM retail.order_payments p
JOIN retail.orders o
    ON p.order_id = o.order_id

WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY p.payment_type
ORDER BY orders_count DESC;