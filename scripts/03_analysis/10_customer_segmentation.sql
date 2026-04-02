-- Bestehende Views löschen, damit die Segmentierung sauber neu aufgebaut wird
DROP VIEW IF EXISTS retail.v_customer_segmentation_base;
DROP VIEW IF EXISTS retail.v_customer_segments;
DROP VIEW IF EXISTS retail.v_customer_segment_summary;
DROP VIEW IF EXISTS retail.v_customer_segment_delivery_review;
DROP VIEW IF EXISTS retail.v_customer_segment_monthly;


-- Basis für Kundensegmentierung erstellen (zentrale KPIs pro Kunde)
CREATE VIEW retail.v_customer_segmentation_base AS
WITH customer_base AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS orders_count,
        ROUND(SUM(payment_revenue), 2) AS total_revenue,
        ROUND(AVG(payment_revenue), 2) AS avg_order_value,
        ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
        ROUND(AVG(delivery_delay_days), 2) AS avg_delivery_delay_days,
        ROUND(AVG(CASE WHEN is_late_delivery = 1 THEN 1.0 ELSE 0.0 END), 4) AS late_delivery_rate,
        ROUND(AVG(avg_review_score), 2) AS avg_review_score,
        MIN(order_purchase_timestamp) AS first_order_at,
        MAX(order_purchase_timestamp) AS last_order_at,

        -- Zeitspanne zwischen erster und letzter Bestellung
        DATE_PART(
            'day',
            MAX(order_purchase_timestamp) - MIN(order_purchase_timestamp)
        ) AS customer_lifespan_days
    FROM retail.v_order_fact
    WHERE customer_unique_id IS NOT NULL
      AND payment_revenue IS NOT NULL
    GROUP BY customer_unique_id
)
SELECT
    customer_unique_id,
    orders_count,
    total_revenue,
    avg_order_value,
    avg_delivery_days,
    avg_delivery_delay_days,
    late_delivery_rate,
    avg_review_score,
    first_order_at,
    last_order_at,
    customer_lifespan_days,

    -- Kunden grob nach Kaufhäufigkeit einteilen
    CASE
        WHEN orders_count = 1 THEN 'one_time'
        WHEN orders_count = 2 THEN 'repeat'
        ELSE 'loyal'
    END AS frequency_segment
FROM customer_base;


-- Hauptsegmente bauen (Kaufhäufigkeit + Umsatz kombinieren)
CREATE VIEW retail.v_customer_segments AS
WITH ranked AS (
    SELECT
        customer_unique_id,
        orders_count,
        total_revenue,
        avg_order_value,
        avg_delivery_days,
        avg_delivery_delay_days,
        late_delivery_rate,
        avg_review_score,
        first_order_at,
        last_order_at,
        customer_lifespan_days,
        frequency_segment,

        -- Kunden nach Umsatz in 4 Gruppen einteilen
        NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_quartile
    FROM retail.v_customer_segmentation_base
)
SELECT
    customer_unique_id,
    orders_count,
    total_revenue,
    avg_order_value,
    avg_delivery_days,
    avg_delivery_delay_days,
    late_delivery_rate,
    avg_review_score,
    first_order_at,
    last_order_at,
    customer_lifespan_days,
    frequency_segment,
    revenue_quartile,

    -- Geschäftsnahe Kundensegmente ableiten
    CASE
        WHEN frequency_segment = 'loyal' AND revenue_quartile = 1 THEN 'high_value_loyal'
        WHEN frequency_segment IN ('repeat', 'loyal') AND revenue_quartile IN (1, 2) THEN 'core_customers'
        WHEN frequency_segment = 'one_time' AND revenue_quartile = 1 THEN 'high_value_one_time'
        WHEN frequency_segment = 'one_time' AND revenue_quartile IN (2, 3) THEN 'mid_value_one_time'
        ELSE 'low_value_occasional'
    END AS customer_segment
FROM ranked;


-- Segmente zusammenfassen (Größe, Umsatzanteil, Durchschnittswerte)
CREATE VIEW retail.v_customer_segment_summary AS
WITH segment_base AS (
    SELECT
        customer_segment,
        customer_unique_id,
        orders_count,
        total_revenue,
        avg_order_value,
        avg_delivery_days,
        late_delivery_rate,
        avg_review_score
    FROM retail.v_customer_segments
)
SELECT
    customer_segment,
    COUNT(*) AS customers,
    SUM(orders_count) AS total_orders,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(AVG(avg_delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(late_delivery_rate), 4) AS avg_late_delivery_rate,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,

    -- Anteil am Gesamtumsatz und an allen Kunden
    ROUND(
        SUM(total_revenue)
        / NULLIF((SELECT SUM(total_revenue) FROM retail.v_customer_segments), 0),
        4
    ) AS revenue_share,
    ROUND(
        COUNT(*)::NUMERIC
        / NULLIF((SELECT COUNT(*) FROM retail.v_customer_segments), 0),
        4
    ) AS customer_share
FROM segment_base
GROUP BY customer_segment
ORDER BY total_revenue DESC;


-- Liefer- und Bewertungsverhalten je Segment vertieft analysieren
CREATE VIEW retail.v_customer_segment_delivery_review AS
WITH order_level AS (
    SELECT
        cs.customer_segment,
        of.order_id,
        of.payment_revenue,
        of.delivery_days,
        of.delivery_delay_days,
        of.is_late_delivery,
        of.avg_review_score
    FROM retail.v_order_fact of
    JOIN retail.v_customer_segments cs
        ON of.customer_unique_id = cs.customer_unique_id
    WHERE of.payment_revenue IS NOT NULL
)
SELECT
    customer_segment,
    COUNT(DISTINCT order_id) AS orders_count,
    ROUND(AVG(payment_revenue), 2) AS avg_order_value,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delivery_delay_days,
    ROUND(AVG(CASE WHEN is_late_delivery = 1 THEN 1.0 ELSE 0.0 END), 4) AS late_delivery_rate,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score
FROM order_level
GROUP BY customer_segment
ORDER BY orders_count DESC;


-- Monatliche Entwicklung der Kundensegmente für Zeitreihenanalysen
CREATE VIEW retail.v_customer_segment_monthly AS
WITH order_level AS (
    SELECT
        DATE_TRUNC('month', of.order_purchase_timestamp) AS order_month,
        cs.customer_segment,
        of.order_id,
        of.customer_unique_id,
        of.payment_revenue
    FROM retail.v_order_fact of
    JOIN retail.v_customer_segments cs
        ON of.customer_unique_id = cs.customer_unique_id
    WHERE of.order_purchase_timestamp IS NOT NULL
      AND of.payment_revenue IS NOT NULL
)
SELECT
    order_month,
    customer_segment,
    COUNT(DISTINCT order_id) AS orders_count,
    COUNT(DISTINCT customer_unique_id) AS active_customers,
    ROUND(SUM(payment_revenue), 2) AS total_revenue,
    ROUND(AVG(payment_revenue), 2) AS avg_order_value
FROM order_level
GROUP BY order_month, customer_segment
ORDER BY order_month, customer_segment;