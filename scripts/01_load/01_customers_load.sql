-- =====================================================
-- Tabellen löschen (Reset)
-- =====================================================
DROP TABLE IF EXISTS retail.customers;
DROP TABLE IF EXISTS retail.customers_raw;


-- =====================================================
-- Staging-Tabelle (Rohdaten)
-- =====================================================
CREATE TABLE retail.customers_raw (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT
);

-- CSV hier per pgAdmin in retail.customers_raw importieren


-- =====================================================
-- Ziel-Tabelle (bereinigte Daten)
-- =====================================================
CREATE TABLE retail.customers (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);


-- =====================================================
-- Datenbereinigung & Laden
-- =====================================================
INSERT INTO retail.customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix::INTEGER,
    NULLIF(customer_city, ''),
    NULLIF(customer_state, '')
FROM retail.customers_raw;


-- =====================================================
-- Validierung: Zeilenanzahl
-- =====================================================
SELECT COUNT(*) AS raw_count 
FROM retail.customers_raw;

SELECT COUNT(*) AS clean_count 
FROM retail.customers;


-- =====================================================
-- Validierung: Stichprobe
-- =====================================================
SELECT *
FROM retail.customers
LIMIT 10;


-- =====================================================
-- Validierung: Null-Werte
-- =====================================================
SELECT *
FROM retail.customers
WHERE customer_id IS NULL
   OR customer_unique_id IS NULL;


-- =====================================================
-- Validierung: Duplikate (customer_id)
-- =====================================================
SELECT
    customer_id,
    COUNT(*) AS cnt
FROM retail.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- =====================================================
-- Validierung: Duplikate (customer_unique_id)
-- =====================================================
SELECT
    customer_unique_id,
    COUNT(*) AS cnt
FROM retail.customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1;