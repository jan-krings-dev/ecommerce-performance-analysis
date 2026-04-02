-- Monatliche Lieferperformance analysieren (Zeittrend)
DROP VIEW IF EXISTS retail.v_delivery_performance_monthly;

CREATE VIEW retail.v_delivery_performance_monthly AS
SELECT
    order_month,

    -- Anzahl Bestellungen und gelieferte Bestellungen
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NOT NULL) AS delivered_orders,

    -- Durchschnittliche Lieferzeit und Verzögerung
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delivery_delay_days,

    -- Anzahl und Anteil verspäteter Lieferungen
    COUNT(*) FILTER (WHERE is_late_delivery = 1) AS late_deliveries,
    ROUND(
        COUNT(*) FILTER (WHERE is_late_delivery = 1)::NUMERIC
        / NULLIF(COUNT(*) FILTER (WHERE order_delivered_customer_date IS NOT NULL), 0),
        4
    ) AS late_delivery_rate

FROM retail.v_order_fact
GROUP BY order_month
ORDER BY order_month;


-- Lieferperformance nach Bestellstatus vergleichen
DROP VIEW IF EXISTS retail.v_delivery_performance_by_status;

CREATE VIEW retail.v_delivery_performance_by_status AS
SELECT
    order_status,

    -- Anzahl Bestellungen pro Status
    COUNT(*) AS orders_count,

    -- Durchschnittliche Lieferzeit und Verzögerung
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delivery_delay_days,

    -- Verspätungen je Status
    COUNT(*) FILTER (WHERE is_late_delivery = 1) AS late_deliveries,
    ROUND(
        COUNT(*) FILTER (WHERE is_late_delivery = 1)::NUMERIC
        / NULLIF(COUNT(*) FILTER (WHERE order_delivered_customer_date IS NOT NULL), 0),
        4
    ) AS late_delivery_rate

FROM retail.v_order_fact
GROUP BY order_status
ORDER BY orders_count DESC;


-- Lieferzeiten in Kategorien einteilen (Verteilung verstehen)
DROP VIEW IF EXISTS retail.v_delivery_time_buckets;

CREATE VIEW retail.v_delivery_time_buckets AS
SELECT
    CASE
        WHEN delivery_days IS NULL THEN 'not_delivered'
        WHEN delivery_days < 3 THEN '< 3 days'
        WHEN delivery_days < 7 THEN '3-6 days'
        WHEN delivery_days < 14 THEN '7-13 days'
        WHEN delivery_days < 21 THEN '14-20 days'
        ELSE '21+ days'
    END AS delivery_bucket,

    -- Anzahl und Anteil der Bestellungen je Kategorie
    COUNT(*) AS orders_count,
    ROUND(
        COUNT(*)::NUMERIC
        / NULLIF((SELECT COUNT(*) FROM retail.v_order_fact), 0),
        4
    ) AS orders_share

FROM retail.v_order_fact
GROUP BY
    CASE
        WHEN delivery_days IS NULL THEN 'not_delivered'
        WHEN delivery_days < 3 THEN '< 3 days'
        WHEN delivery_days < 7 THEN '3-6 days'
        WHEN delivery_days < 14 THEN '7-13 days'
        WHEN delivery_days < 21 THEN '14-20 days'
        ELSE '21+ days'
    END
ORDER BY orders_count DESC;