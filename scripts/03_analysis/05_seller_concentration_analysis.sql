-- Umsatzsicht pro Seller erstellen
DROP VIEW IF EXISTS retail.v_seller_revenue;

CREATE VIEW retail.v_seller_revenue AS
SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,

    -- Anzahl Bestellungen und verkaufte Positionen pro Seller
    COUNT(DISTINCT oi.order_id) AS orders_count,
    COUNT(*) AS items_sold,

    -- Umsatz aus Produkten, Versand und gesamt berechnen
    ROUND(SUM(oi.price), 2) AS item_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS gross_revenue
FROM retail.order_items oi
LEFT JOIN retail.sellers s
    ON oi.seller_id = s.seller_id
GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state;


-- Pareto-Sicht für Seller erstellen
DROP VIEW IF EXISTS retail.v_seller_revenue_pareto;

CREATE VIEW retail.v_seller_revenue_pareto AS
WITH ranked AS (
    SELECT
        seller_id,
        seller_city,
        seller_state,
        orders_count,
        items_sold,
        gross_revenue,

        -- Seller nach Umsatz sortieren
        ROW_NUMBER() OVER (ORDER BY gross_revenue DESC, seller_id) AS revenue_rank,

        -- Kumulierten Umsatz und Gesamtwerte berechnen
        SUM(gross_revenue) OVER (ORDER BY gross_revenue DESC, seller_id) AS cumulative_revenue,
        SUM(gross_revenue) OVER () AS total_dataset_revenue,
        COUNT(*) OVER () AS total_sellers
    FROM retail.v_seller_revenue
),
final AS (
    SELECT
        seller_id,
        seller_city,
        seller_state,
        orders_count,
        items_sold,
        gross_revenue,
        revenue_rank,
        total_sellers,

        -- Werte runden und Anteile berechnen
        ROUND(cumulative_revenue, 2) AS cumulative_revenue,
        ROUND(total_dataset_revenue, 2) AS total_dataset_revenue,
        ROUND(cumulative_revenue / NULLIF(total_dataset_revenue, 0), 4) AS cumulative_revenue_share,
        ROUND(revenue_rank::NUMERIC / NULLIF(total_sellers, 0), 4) AS cumulative_seller_share
    FROM ranked
)
SELECT *
FROM final;


-- Seller in 10 Umsatzgruppen einteilen
DROP VIEW IF EXISTS retail.v_seller_revenue_deciles;

CREATE VIEW retail.v_seller_revenue_deciles AS
WITH base AS (
    SELECT
        seller_id,
        gross_revenue,

        -- Seller nach Umsatz in 10 Gruppen aufteilen
        NTILE(10) OVER (ORDER BY gross_revenue DESC) AS seller_decile
    FROM retail.v_seller_revenue
)
SELECT
    seller_decile,

    -- Anzahl Seller und Umsatz pro Gruppe berechnen
    COUNT(*) AS sellers,
    ROUND(SUM(gross_revenue), 2) AS revenue,
    ROUND(AVG(gross_revenue), 2) AS avg_revenue_per_seller,

    -- Umsatzanteil der Gruppe am Gesamtumsatz
    ROUND(
        SUM(gross_revenue) / NULLIF(
            (SELECT SUM(gross_revenue) FROM retail.v_seller_revenue), 0
        ),
        4
    ) AS revenue_share
FROM base
GROUP BY seller_decile
ORDER BY seller_decile;