-- =====================================================
-- Tabellen löschen (Reset)
-- =====================================================
DROP TABLE IF EXISTS retail.geolocation;
DROP TABLE IF EXISTS retail.geolocation_raw;


-- =====================================================
-- Staging-Tabelle (Rohdaten)
-- =====================================================
CREATE TABLE retail.geolocation_raw (
    geolocation_zip_code_prefix TEXT,
    geolocation_lat TEXT,
    geolocation_lng TEXT,
    geolocation_city TEXT,
    geolocation_state TEXT
);

-- CSV hier per pgAdmin in retail.geolocation_raw importieren


-- =====================================================
-- Ziel-Tabelle (bereinigte Daten)
-- =====================================================
CREATE TABLE retail.geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat NUMERIC(12,8),
    geolocation_lng NUMERIC(12,8),
    geolocation_city TEXT,
    geolocation_state TEXT
);


-- =====================================================
-- Datenbereinigung & Laden
-- =====================================================
INSERT INTO retail.geolocation (
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
)
SELECT
    geolocation_zip_code_prefix::INTEGER,
    geolocation_lat::NUMERIC(12,8),
    geolocation_lng::NUMERIC(12,8),
    NULLIF(geolocation_city, ''),
    NULLIF(geolocation_state, '')
FROM retail.geolocation_raw;


-- =====================================================
-- Validierung: Zeilenanzahl
-- =====================================================
SELECT COUNT(*) AS raw_count 
FROM retail.geolocation_raw;

SELECT COUNT(*) AS clean_count 
FROM retail.geolocation;


-- =====================================================
-- Validierung: Stichprobe
-- =====================================================
SELECT *
FROM retail.geolocation
LIMIT 10;


-- =====================================================
-- Validierung: Null-Werte
-- =====================================================
SELECT *
FROM retail.geolocation
WHERE geolocation_zip_code_prefix IS NULL
   OR geolocation_lat IS NULL
   OR geolocation_lng IS NULL;


-- =====================================================
-- Validierung: Wertebereiche (Koordinaten)
-- =====================================================
SELECT
    MIN(geolocation_lat) AS min_lat,
    MAX(geolocation_lat) AS max_lat,
    MIN(geolocation_lng) AS min_lng,
    MAX(geolocation_lng) AS max_lng
FROM retail.geolocation;