-- =====================================================
-- Tabellen löschen (Reset)
-- =====================================================
DROP TABLE IF EXISTS retail.orders;
DROP TABLE IF EXISTS retail.orders_raw;


-- =====================================================
-- Staging-Tabelle (Rohdaten)
-- =====================================================
CREATE TABLE retail.orders_raw (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TEXT,
    order_approved_at TEXT,
    order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT
);

-- CSV hier per pgAdmin in retail.orders_raw importieren


-- =====================================================
-- Ziel-Tabelle (bereinigte Daten)
-- =====================================================
CREATE TABLE retail.orders (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);


-- =====================================================
-- Datenbereinigung & Laden
-- =====================================================
INSERT INTO retail.orders (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
)
SELECT
    order_id,
    customer_id,
    NULLIF(order_status, ''),
    order_purchase_timestamp::TIMESTAMP,
    NULLIF(order_approved_at, '')::TIMESTAMP,
    NULLIF(order_delivered_carrier_date, '')::TIMESTAMP,
    NULLIF(order_delivered_customer_date, '')::TIMESTAMP,
    NULLIF(order_estimated_delivery_date, '')::TIMESTAMP
FROM retail.orders_raw;


-- =====================================================
-- Validierung: Zeilenanzahl
-- =====================================================
SELECT COUNT(*) AS raw_count 
FROM retail.orders_raw;

SELECT COUNT(*) AS clean_count 
FROM retail.orders;


-- =====================================================
-- Validierung: Stichprobe
-- =====================================================
SELECT *
FROM retail.orders
LIMIT 10;


-- =====================================================
-- Validierung: Pflichtfelder
-- =====================================================
SELECT *
FROM retail.orders
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR order_purchase_timestamp IS NULL;


-- =====================================================
-- Validierung: Duplikate (order_id)
-- =====================================================
SELECT
    order_id,
    COUNT(*) AS cnt
FROM retail.orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- =====================================================
-- Validierung: Zeitbereich
-- =====================================================
SELECT
    MIN(order_purchase_timestamp) AS first_order_at,
    MAX(order_purchase_timestamp) AS last_order_at
FROM retail.orders;


-- =====================================================
-- Validierung: Statuswerte
-- =====================================================
SELECT DISTINCT order_status
FROM retail.orders
ORDER BY order_status;