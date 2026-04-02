-- =====================================================
-- Tabellen löschen (Reset)
-- =====================================================
DROP TABLE IF EXISTS retail.order_reviews;
DROP TABLE IF EXISTS retail.order_reviews_raw;


-- =====================================================
-- Staging-Tabelle (Rohdaten)
-- =====================================================
CREATE TABLE retail.order_reviews_raw (
    review_id TEXT,
    order_id TEXT,
    review_score TEXT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TEXT,
    review_answer_timestamp TEXT
);

-- CSV hier per pgAdmin in retail.order_reviews_raw importieren


-- =====================================================
-- Ziel-Tabelle (bereinigte Daten)
-- =====================================================
CREATE TABLE retail.order_reviews (
    review_id TEXT,
    order_id TEXT,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);


-- =====================================================
-- Datenbereinigung & Laden
-- =====================================================
INSERT INTO retail.order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
SELECT
    review_id,
    order_id,
    review_score::INTEGER,
    NULLIF(review_comment_title, ''),
    NULLIF(review_comment_message, ''),
    review_creation_date::TIMESTAMP,
    NULLIF(review_answer_timestamp, '')::TIMESTAMP
FROM retail.order_reviews_raw;


-- =====================================================
-- Validierung: Zeilenanzahl
-- =====================================================
SELECT COUNT(*) AS raw_count 
FROM retail.order_reviews_raw;

SELECT COUNT(*) AS clean_count 
FROM retail.order_reviews;


-- =====================================================
-- Validierung: Stichprobe
-- =====================================================
SELECT *
FROM retail.order_reviews
LIMIT 10;


-- =====================================================
-- Validierung: Pflichtfelder
-- =====================================================
SELECT *
FROM retail.order_reviews
WHERE review_id IS NULL
   OR order_id IS NULL
   OR review_score IS NULL;


-- =====================================================
-- Validierung: Duplikate (review_id)
-- =====================================================
SELECT
    review_id,
    COUNT(*) AS cnt
FROM retail.order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;


-- =====================================================
-- Validierung: Wertebereich (review_score)
-- =====================================================
SELECT *
FROM retail.order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;