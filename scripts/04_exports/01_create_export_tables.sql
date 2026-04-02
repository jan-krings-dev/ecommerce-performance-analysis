-- Export-Tabellen für spätere Nutzung neu aufbauen


-- Customer- und Seller-Analysen exportieren
DROP TABLE IF EXISTS retail.export_customer_revenue_pareto;
CREATE TABLE retail.export_customer_revenue_pareto AS
SELECT *
FROM retail.v_customer_revenue_pareto
ORDER BY revenue_rank;

DROP TABLE IF EXISTS retail.export_customer_revenue_deciles;
CREATE TABLE retail.export_customer_revenue_deciles AS
SELECT *
FROM retail.v_customer_revenue_deciles
ORDER BY revenue_decile;

DROP TABLE IF EXISTS retail.export_seller_revenue_pareto;
CREATE TABLE retail.export_seller_revenue_pareto AS
SELECT *
FROM retail.v_seller_revenue_pareto
ORDER BY revenue_rank;

DROP TABLE IF EXISTS retail.export_seller_revenue_deciles;
CREATE TABLE retail.export_seller_revenue_deciles AS
SELECT *
FROM retail.v_seller_revenue_deciles
ORDER BY seller_decile;


-- Delivery-Analysen exportieren
DROP TABLE IF EXISTS retail.export_delivery_performance_monthly;
CREATE TABLE retail.export_delivery_performance_monthly AS
SELECT *
FROM retail.v_delivery_performance_monthly
ORDER BY order_month;

DROP TABLE IF EXISTS retail.export_delivery_performance_by_status;
CREATE TABLE retail.export_delivery_performance_by_status AS
SELECT *
FROM retail.v_delivery_performance_by_status
ORDER BY orders_count DESC;

DROP TABLE IF EXISTS retail.export_delivery_time_buckets;
CREATE TABLE retail.export_delivery_time_buckets AS
SELECT *
FROM retail.v_delivery_time_buckets
ORDER BY orders_count DESC;


-- Review- und Ursachenanalysen exportieren
DROP TABLE IF EXISTS retail.export_review_vs_delivery_score;
CREATE TABLE retail.export_review_vs_delivery_score AS
SELECT *
FROM retail.v_review_vs_delivery_score
ORDER BY review_score;

DROP TABLE IF EXISTS retail.export_review_vs_delivery_bucket;
CREATE TABLE retail.export_review_vs_delivery_bucket AS
SELECT *
FROM retail.v_review_vs_delivery_bucket;

DROP TABLE IF EXISTS retail.export_review_late_vs_ontime;
CREATE TABLE retail.export_review_late_vs_ontime AS
SELECT *
FROM retail.v_review_late_vs_ontime
ORDER BY delivery_type;

DROP TABLE IF EXISTS retail.export_review_delivery_by_revenue_segment;
CREATE TABLE retail.export_review_delivery_by_revenue_segment AS
SELECT *
FROM retail.v_review_delivery_by_revenue_segment
ORDER BY revenue_segment, delivery_type;

DROP TABLE IF EXISTS retail.export_low_review_drivers;
CREATE TABLE retail.export_low_review_drivers AS
SELECT *
FROM retail.v_low_review_drivers
ORDER BY review_group;

DROP TABLE IF EXISTS retail.export_review_delivery_combined;
CREATE TABLE retail.export_review_delivery_combined AS
SELECT *
FROM retail.v_review_delivery_combined;


-- Produkt- und Kategorieanalysen exportieren
DROP TABLE IF EXISTS retail.export_category_performance;
CREATE TABLE retail.export_category_performance AS
SELECT *
FROM retail.v_category_performance
ORDER BY gross_revenue DESC;

DROP TABLE IF EXISTS retail.export_product_performance;
CREATE TABLE retail.export_product_performance AS
SELECT *
FROM retail.v_product_performance
ORDER BY gross_revenue DESC;

DROP TABLE IF EXISTS retail.export_category_review_performance;
CREATE TABLE retail.export_category_review_performance AS
SELECT *
FROM retail.v_category_review_performance
ORDER BY reviewed_orders DESC, avg_review_score DESC;


-- Zahlungsanalysen exportieren
DROP TABLE IF EXISTS retail.export_payment_type_mix;
CREATE TABLE retail.export_payment_type_mix AS
SELECT *
FROM retail.v_payment_type_mix
ORDER BY total_payment_value DESC;

DROP TABLE IF EXISTS retail.export_payment_installments;
CREATE TABLE retail.export_payment_installments AS
SELECT *
FROM retail.v_payment_installments
ORDER BY payment_installments;

DROP TABLE IF EXISTS retail.export_payment_type_review;
CREATE TABLE retail.export_payment_type_review AS
SELECT *
FROM retail.v_payment_type_review
ORDER BY reviewed_orders DESC;

DROP TABLE IF EXISTS retail.export_payment_type_delivery;
CREATE TABLE retail.export_payment_type_delivery AS
SELECT *
FROM retail.v_payment_type_delivery
ORDER BY orders_count DESC;


-- Kundensegmentierung exportieren
DROP TABLE IF EXISTS retail.export_customer_segments;
CREATE TABLE retail.export_customer_segments AS
SELECT *
FROM retail.v_customer_segments;

DROP TABLE IF EXISTS retail.export_customer_segment_summary;
CREATE TABLE retail.export_customer_segment_summary AS
SELECT *
FROM retail.v_customer_segment_summary
ORDER BY total_revenue DESC;

DROP TABLE IF EXISTS retail.export_customer_segment_delivery_review;
CREATE TABLE retail.export_customer_segment_delivery_review AS
SELECT *
FROM retail.v_customer_segment_delivery_review
ORDER BY orders_count DESC;

DROP TABLE IF EXISTS retail.export_customer_segment_monthly;
CREATE TABLE retail.export_customer_segment_monthly AS
SELECT *
FROM retail.v_customer_segment_monthly
ORDER BY order_month, customer_segment;