-- =====================================================
-- Tabellen löschen (Reset)
-- =====================================================
DROP TABLE IF EXISTS retail.product_category_translation;
DROP TABLE IF EXISTS retail.product_category_translation_raw;


-- =====================================================
-- Staging-Tabelle (Rohdaten)
-- =====================================================
CREATE TABLE retail.product_category_translation_raw (
    product_category_name TEXT,
    product_category_name_english TEXT
);

-- CSV hier per pgAdmin in retail.product_category_translation_raw importieren


-- =====================================================
-- Ziel-Tabelle (bereinigte Daten)
-- =====================================================
CREATE TABLE retail.product_category_translation (
    product_category_name TEXT,
    product_category_name_english TEXT
);


-- =====================================================
-- Datenbereinigung & Laden
-- =====================================================
INSERT INTO retail.product_category_translation (
    product_category_name,
    product_category_name_english
)
SELECT
    NULLIF(product_category_name, ''),
    NULLIF(product_category_name_english, '')
FROM retail.product_category_translation_raw;


-- =====================================================
-- Validierung: Zeilenanzahl
-- =====================================================
SELECT COUNT(*) AS raw_count 
FROM retail.product_category_translation_raw;

SELECT COUNT(*) AS clean_count 
FROM retail.product_category_translation;


-- =====================================================
-- Validierung: Stichprobe
-- =====================================================
SELECT *
FROM retail.product_category_translation
LIMIT 10;


-- =====================================================
-- Validierung: Null-Werte
-- =====================================================
SELECT *
FROM retail.product_category_translation
WHERE product_category_name IS NULL
   OR product_category_name_english IS NULL;


-- =====================================================
-- Validierung: Duplikate (product_category_name)
-- =====================================================
SELECT
    product_category_name,
    COUNT(*) AS cnt
FROM retail.product_category_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;