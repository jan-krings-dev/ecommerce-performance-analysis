-- Bestehende Views löschen, damit sie sauber neu erstellt werden
DROP VIEW IF EXISTS retail.v_review_vs_delivery_score;
DROP VIEW IF EXISTS retail.v_review_vs_delivery_bucket;
DROP VIEW IF EXISTS retail.v_review_late_vs_ontime;
DROP VIEW IF EXISTS retail.v_review_delivery_by_revenue_segment;
DROP VIEW IF EXISTS retail.v_low_review_drivers;
DROP VIEW IF EXISTS retail.v_review_delivery_combined;


-- Zusammenhang zwischen Bewertung und Lieferkennzahlen analysieren
CREATE VIEW retail.v_review_vs_delivery_score AS
WITH review_base AS (
    SELECT
        avg_review_score,
        delivery_days,
        delivery_delay_days,
        is_late_delivery,
        payment_revenue
    FROM retail.v_order_fact
    WHERE avg_review_score IS NOT NULL
      AND delivery_days IS NOT NULL
)
SELECT
    ROUND(avg_review_score, 0)::INTEGER AS review_score,
    COUNT(*) AS orders_count,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delivery_delay_days,
    ROUND(AVG(CASE WHEN is_late_delivery = 1 THEN 1.0 ELSE 0.0 END), 4) AS late_delivery_rate,
    ROUND(AVG(payment_revenue), 2) AS avg_order_revenue
FROM review_base
GROUP BY ROUND(avg_review_score, 0)::INTEGER
ORDER BY review_score;


-- Bewertungen nach Lieferzeit-Gruppen vergleichen
CREATE VIEW retail.v_review_vs_delivery_bucket AS
WITH review_base AS (
    SELECT
        avg_review_score,
        delivery_days,
        is_late_delivery,
        payment_revenue,
        CASE
            WHEN delivery_days < 3 THEN '< 3 days'
            WHEN delivery_days < 7 THEN '3-6 days'
            WHEN delivery_days < 14 THEN '7-13 days'
            WHEN delivery_days < 21 THEN '14-20 days'
            ELSE '21+ days'
        END AS delivery_bucket
    FROM retail.v_order_fact
    WHERE avg_review_score IS NOT NULL
      AND delivery_days IS NOT NULL
)
SELECT
    delivery_bucket,
    COUNT(*) AS orders_count,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,
    ROUND(AVG(payment_revenue), 2) AS avg_order_revenue,
    ROUND(AVG(CASE WHEN is_late_delivery = 1 THEN 1.0 ELSE 0.0 END), 4) AS late_delivery_rate
FROM review_base
GROUP BY delivery_bucket
ORDER BY
    CASE
        WHEN delivery_bucket = '< 3 days' THEN 1
        WHEN delivery_bucket = '3-6 days' THEN 2
        WHEN delivery_bucket = '7-13 days' THEN 3
        WHEN delivery_bucket = '14-20 days' THEN 4
        ELSE 5
    END;


-- Verspätete und pünktliche Lieferungen direkt vergleichen
CREATE VIEW retail.v_review_late_vs_ontime AS
WITH review_base AS (
    SELECT
        avg_review_score,
        delivery_days,
        payment_revenue,
        CASE
            WHEN is_late_delivery = 1 THEN 'late'
            ELSE 'on_time_or_early'
        END AS delivery_type
    FROM retail.v_order_fact
    WHERE avg_review_score IS NOT NULL
      AND delivery_days IS NOT NULL
)
SELECT
    delivery_type,
    COUNT(*) AS orders_count,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(payment_revenue), 2) AS avg_order_revenue
FROM review_base
GROUP BY delivery_type
ORDER BY delivery_type;


-- Prüfen, ob sich der Liefereinfluss je Umsatzsegment unterscheidet
CREATE VIEW retail.v_review_delivery_by_revenue_segment AS
WITH review_base AS (
    SELECT
        avg_review_score,
        delivery_days,
        is_late_delivery,
        payment_revenue,
        CASE
            WHEN payment_revenue < 50 THEN 'low_value'
            WHEN payment_revenue < 150 THEN 'mid_value'
            ELSE 'high_value'
        END AS revenue_segment,
        CASE
            WHEN is_late_delivery = 1 THEN 'late'
            ELSE 'on_time_or_early'
        END AS delivery_type
    FROM retail.v_order_fact
    WHERE avg_review_score IS NOT NULL
      AND delivery_days IS NOT NULL
)
SELECT
    revenue_segment,
    delivery_type,
    COUNT(*) AS orders_count,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(CASE WHEN is_late_delivery = 1 THEN 1.0 ELSE 0.0 END), 4) AS late_delivery_rate,
    ROUND(AVG(payment_revenue), 2) AS avg_order_value
FROM review_base
GROUP BY revenue_segment, delivery_type
ORDER BY
    CASE
        WHEN revenue_segment = 'low_value' THEN 1
        WHEN revenue_segment = 'mid_value' THEN 2
        ELSE 3
    END,
    delivery_type;


-- Typische Merkmale von niedrigen Bewertungen zusammenfassen
CREATE VIEW retail.v_low_review_drivers AS
WITH review_base AS (
    SELECT
        avg_review_score,
        delivery_days,
        delivery_delay_days,
        is_late_delivery,
        payment_revenue,
        CASE
            WHEN avg_review_score <= 2 THEN 'low_reviews'
            ELSE 'normal_reviews'
        END AS review_group
    FROM retail.v_order_fact
    WHERE avg_review_score IS NOT NULL
      AND delivery_days IS NOT NULL
)
SELECT
    review_group,
    COUNT(*) AS orders_count,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay_days,
    ROUND(AVG(CASE WHEN is_late_delivery = 1 THEN 1.0 ELSE 0.0 END), 4) AS late_rate,
    ROUND(AVG(payment_revenue), 2) AS avg_order_value
FROM review_base
GROUP BY review_group
ORDER BY review_group;


-- Lieferzeit-Gruppe und Lieferstatus gemeinsam auswerten
CREATE VIEW retail.v_review_delivery_combined AS
WITH review_base AS (
    SELECT
        avg_review_score,
        delivery_days,
        CASE
            WHEN delivery_days < 3 THEN '< 3 days'
            WHEN delivery_days < 7 THEN '3-6 days'
            WHEN delivery_days < 14 THEN '7-13 days'
            WHEN delivery_days < 21 THEN '14-20 days'
            ELSE '21+ days'
        END AS delivery_bucket,
        CASE
            WHEN is_late_delivery = 1 THEN 'late'
            ELSE 'on_time'
        END AS delivery_type
    FROM retail.v_order_fact
    WHERE avg_review_score IS NOT NULL
      AND delivery_days IS NOT NULL
)
SELECT
    delivery_bucket,
    delivery_type,
    COUNT(*) AS orders_count,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score
FROM review_base
GROUP BY delivery_bucket, delivery_type
ORDER BY
    CASE
        WHEN delivery_bucket = '< 3 days' THEN 1
        WHEN delivery_bucket = '3-6 days' THEN 2
        WHEN delivery_bucket = '7-13 days' THEN 3
        WHEN delivery_bucket = '14-20 days' THEN 4
        ELSE 5
    END,
    delivery_type;