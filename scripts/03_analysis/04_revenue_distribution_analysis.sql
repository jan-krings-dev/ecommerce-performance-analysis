-- Kundenumsatz aggregieren (Bestellungen + Umsatz pro Kunde)
DROP VIEW IF EXISTS retail.v_customer_revenue;

CREATE VIEW retail.v_customer_revenue AS
SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS orders_count,
    SUM(payment_revenue) AS total_revenue,
    AVG(payment_revenue) AS avg_order_revenue
FROM retail.v_order_fact
GROUP BY customer_unique_id;


-- Pareto-Analyse vorbereiten (Ranking + kumulierter Umsatz)
DROP VIEW IF EXISTS retail.v_customer_revenue_pareto;

CREATE VIEW retail.v_customer_revenue_pareto AS
WITH ranked AS (
    SELECT
        customer_unique_id,
        orders_count,
        total_revenue,
        avg_order_revenue,

        -- Kunden nach Umsatz sortieren (höchster zuerst)
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC, customer_unique_id) AS revenue_rank,

        -- Kumulierten Umsatz berechnen (für Pareto)
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC, customer_unique_id) AS cumulative_revenue,

        -- Gesamtumsatz und Gesamtanzahl Kunden
        SUM(total_revenue) OVER () AS total_dataset_revenue,
        COUNT(*) OVER () AS total_customers
    FROM retail.v_customer_revenue
),

final AS (
    SELECT
        customer_unique_id,
        orders_count,
        total_revenue,
        avg_order_revenue,
        revenue_rank,
        total_customers,

        -- Werte runden für bessere Lesbarkeit
        ROUND(cumulative_revenue, 2) AS cumulative_revenue,
        ROUND(total_dataset_revenue, 2) AS total_dataset_revenue,

        -- Anteil am Gesamtumsatz und Kundenanteil berechnen
        ROUND(cumulative_revenue / NULLIF(total_dataset_revenue, 0), 4) AS cumulative_revenue_share,
        ROUND(revenue_rank::NUMERIC / NULLIF(total_customers, 0), 4) AS cumulative_customer_share
    FROM ranked
)

SELECT *
FROM final;


-- Kunden in 10 Gruppen nach Umsatz einteilen (Deciles)
DROP VIEW IF EXISTS retail.v_customer_revenue_deciles;

CREATE VIEW retail.v_customer_revenue_deciles AS
WITH base AS (
    SELECT
        customer_unique_id,
        total_revenue,

        -- Kunden in 10 gleich große Gruppen nach Umsatz aufteilen
        NTILE(10) OVER (ORDER BY total_revenue DESC) AS revenue_decile
    FROM retail.v_customer_revenue
)

SELECT
    revenue_decile,

    -- Anzahl Kunden pro Gruppe
    COUNT(*) AS customers,

    -- Gesamtumsatz pro Gruppe
    ROUND(SUM(total_revenue), 2) AS revenue,

    -- Durchschnittlicher Umsatz pro Kunde in der Gruppe
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer,

    -- Anteil der Gruppe am Gesamtumsatz
    ROUND(
        SUM(total_revenue) / NULLIF(
            (SELECT SUM(total_revenue) FROM retail.v_customer_revenue), 0
        ),
        4
    ) AS revenue_share

FROM base
GROUP BY revenue_decile
ORDER BY revenue_decile;