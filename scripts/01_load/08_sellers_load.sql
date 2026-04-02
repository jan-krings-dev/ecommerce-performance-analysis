-- =====================================================
-- Tabellen löschen (Reset)
-- =====================================================
DROP TABLE IF EXISTS retail.sellers;
DROP TABLE IF EXISTS retail.sellers_raw;


-- =====================================================
-- Staging-Tabelle (Rohdaten)
-- =====================================================
CREATE TABLE retail.sellers_raw (
    seller_id TEXT,
    seller_zip_code_prefix TEXT,
    seller_city TEXT,
    seller_state TEXT
);

-- CSV hier per pgAdmin in retail.sellers_raw importieren


-- =====================================================
-- Ziel-Tabelle (bereinigte Daten)
-- =====================================================
CREATE TABLE retail.sellers (
    seller_id TEXT,
    seller_zip_code_prefix INTEGER,
    seller_city TEXT,
    seller_state TEXT
);


-- =====================================================
-- Datenbereinigung & Laden
-- =====================================================
INSERT INTO retail.sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT
    seller_id,
    seller_zip_code_prefix::INTEGER,
    NULLIF(seller_city, ''),
    NULLIF(seller_state, '')
FROM retail.sellers_raw;


-- =====================================================
-- Validierung: Zeilenanzahl
-- =====================================================
SELECT COUNT(*) AS raw_count 
FROM retail.sellers_raw;

SELECT COUNT(*) AS clean_count 
FROM retail.sellers;


-- =====================================================
-- Validierung: Stichprobe
-- =====================================================
SELECT *
FROM retail.sellers
LIMIT 10;


-- =====================================================
-- Validierung: Pflichtfelder
-- =====================================================
SELECT *
FROM retail.sellers
WHERE seller_id IS NULL;


-- =====================================================
-- Validierung: Duplikate (seller_id)
-- =====================================================
SELECT
    seller_id,
    COUNT(*) AS cnt
FROM retail.sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;