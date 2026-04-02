-- =====================================================
-- Tabellen löschen (Reset)
-- =====================================================
DROP TABLE IF EXISTS retail.products;
DROP TABLE IF EXISTS retail.products_raw;


-- =====================================================
-- Staging-Tabelle (Rohdaten)
-- =====================================================
CREATE TABLE retail.products_raw (
    product_id TEXT,
    product_category_name TEXT,
    product_name_lenght TEXT,
    product_description_lenght TEXT,
    product_photos_qty TEXT,
    product_weight_g TEXT,
    product_length_cm TEXT,
    product_height_cm TEXT,
    product_width_cm TEXT
);

-- CSV hier per pgAdmin in retail.products_raw importieren


-- =====================================================
-- Ziel-Tabelle (bereinigte Daten)
-- =====================================================
CREATE TABLE retail.products (
    product_id TEXT,
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);


-- =====================================================
-- Datenbereinigung & Laden
-- =====================================================
INSERT INTO retail.products (
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    product_id,
    NULLIF(product_category_name, ''),
    NULLIF(product_name_lenght, '')::INTEGER,
    NULLIF(product_description_lenght, '')::INTEGER,
    NULLIF(product_photos_qty, '')::INTEGER,
    NULLIF(product_weight_g, '')::INTEGER,
    NULLIF(product_length_cm, '')::INTEGER,
    NULLIF(product_height_cm, '')::INTEGER,
    NULLIF(product_width_cm, '')::INTEGER
FROM retail.products_raw;


-- =====================================================
-- Validierung: Zeilenanzahl
-- =====================================================
SELECT COUNT(*) AS raw_count 
FROM retail.products_raw;

SELECT COUNT(*) AS clean_count 
FROM retail.products;


-- =====================================================
-- Validierung: Stichprobe
-- =====================================================
SELECT *
FROM retail.products
LIMIT 10;


-- =====================================================
-- Validierung: Pflichtfelder
-- =====================================================
SELECT *
FROM retail.products
WHERE product_id IS NULL;


-- =====================================================
-- Validierung: Duplikate (product_id)
-- =====================================================
SELECT
    product_id,
    COUNT(*) AS cnt
FROM retail.products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- =====================================================
-- Validierung: Negative Werte
-- =====================================================
SELECT *
FROM retail.products
WHERE product_weight_g < 0
   OR product_length_cm < 0
   OR product_height_cm < 0
   OR product_width_cm < 0;