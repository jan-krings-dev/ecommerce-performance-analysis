-- =====================================================
-- Tabellen löschen (Reset)
-- =====================================================
DROP TABLE IF EXISTS retail.order_payments;
DROP TABLE IF EXISTS retail.order_payments_raw;


-- =====================================================
-- Staging-Tabelle (Rohdaten)
-- =====================================================
CREATE TABLE retail.order_payments_raw (
    order_id TEXT,
    payment_sequential TEXT,
    payment_type TEXT,
    payment_installments TEXT,
    payment_value TEXT
);

-- CSV hier per pgAdmin in retail.order_payments_raw importieren


-- =====================================================
-- Ziel-Tabelle (bereinigte Daten)
-- =====================================================
CREATE TABLE retail.order_payments (
    order_id TEXT,
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value NUMERIC(10,2)
);


-- =====================================================
-- Datenbereinigung & Laden
-- =====================================================
INSERT INTO retail.order_payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    order_id,
    payment_sequential::INTEGER,
    NULLIF(payment_type, ''),
    payment_installments::INTEGER,
    payment_value::NUMERIC(10,2)
FROM retail.order_payments_raw;


-- =====================================================
-- Validierung: Zeilenanzahl
-- =====================================================
SELECT COUNT(*) AS raw_count 
FROM retail.order_payments_raw;

SELECT COUNT(*) AS clean_count 
FROM retail.order_payments;


-- =====================================================
-- Validierung: Stichprobe
-- =====================================================
SELECT *
FROM retail.order_payments
LIMIT 10;


-- =====================================================
-- Validierung: Pflichtfelder
-- =====================================================
SELECT *
FROM retail.order_payments
WHERE order_id IS NULL
   OR payment_sequential IS NULL
   OR payment_value IS NULL;


-- =====================================================
-- Validierung: Duplikate (order_id, payment_sequential)
-- =====================================================
SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS cnt
FROM retail.order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;


-- =====================================================
-- Validierung: Kategorien (payment_type)
-- =====================================================
SELECT DISTINCT payment_type
FROM retail.order_payments
ORDER BY payment_type;


-- =====================================================
-- Validierung: Negative Werte
-- =====================================================
SELECT *
FROM retail.order_payments
WHERE payment_value < 0
   OR payment_installments < 0;