-- =====================================================
-- Tabellen löschen (Reset)
-- =====================================================
DROP TABLE IF EXISTS retail.order_items;
DROP TABLE IF EXISTS retail.order_items_raw;


-- =====================================================
-- Staging-Tabelle (Rohdaten)
-- =====================================================
CREATE TABLE retail.order_items_raw (
    order_id TEXT,
    order_item_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,
    price TEXT,
    freight_value TEXT
);

-- CSV hier per pgAdmin in retail.order_items_raw importieren


-- =====================================================
-- Ziel-Tabelle (bereinigte Daten)
-- =====================================================
CREATE TABLE retail.order_items (
    order_id TEXT,
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);


-- =====================================================
-- Datenbereinigung & Laden
-- =====================================================
INSERT INTO retail.order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
)
SELECT
    order_id,
    order_item_id::INTEGER,
    product_id,
    seller_id,
    shipping_limit_date::TIMESTAMP,
    price::NUMERIC(10,2),
    freight_value::NUMERIC(10,2)
FROM retail.order_items_raw;


-- =====================================================
-- Validierung: Zeilenanzahl
-- =====================================================
SELECT COUNT(*) AS raw_count 
FROM retail.order_items_raw;

SELECT COUNT(*) AS clean_count 
FROM retail.order_items;


-- =====================================================
-- Validierung: Stichprobe
-- =====================================================
SELECT *
FROM retail.order_items
LIMIT 10;


-- =====================================================
-- Validierung: Pflichtfelder
-- =====================================================
SELECT *
FROM retail.order_items
WHERE order_id IS NULL
   OR order_item_id IS NULL
   OR product_id IS NULL
   OR seller_id IS NULL;


-- =====================================================
-- Validierung: Duplikate (order_id, order_item_id)
-- =====================================================
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS cnt
FROM retail.order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


-- =====================================================
-- Validierung: Zeitbereich
-- =====================================================
SELECT
    MIN(shipping_limit_date) AS first_shipping_limit,
    MAX(shipping_limit_date) AS last_shipping_limit
FROM retail.order_items;


-- =====================================================
-- Validierung: Negative Werte
-- =====================================================
SELECT *
FROM retail.order_items
WHERE price < 0
   OR freight_value < 0;