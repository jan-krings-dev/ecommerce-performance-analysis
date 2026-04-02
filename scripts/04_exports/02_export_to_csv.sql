-- Daten aus Export-Tabellen als CSV-Dateien speichern
\set export_path ' '


-- Base Path Variable (nur in psql nutzbar)
\set export_path 'C:/Users/Jan/Desktop/Brazilian E-Commerce_Olist/data/analysis_exports'


-- Customer und Seller Export
COPY (
    SELECT * FROM retail.export_customer_revenue_pareto ORDER BY revenue_rank
) TO :'export_path'/customer_revenue_pareto.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_customer_revenue_deciles ORDER BY revenue_decile
) TO :'export_path'/customer_revenue_deciles.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_seller_revenue_pareto ORDER BY revenue_rank
) TO :'export_path'/seller_revenue_pareto.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_seller_revenue_deciles ORDER BY seller_decile
) TO :'export_path'/seller_revenue_deciles.csv
WITH (FORMAT CSV, HEADER);


-- Delivery Export
COPY (
    SELECT * FROM retail.export_delivery_performance_monthly ORDER BY order_month
) TO :'export_path'/delivery_performance_monthly.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_delivery_performance_by_status ORDER BY orders_count DESC
) TO :'export_path'/delivery_performance_by_status.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_delivery_time_buckets ORDER BY orders_count DESC
) TO :'export_path'/delivery_time_buckets.csv
WITH (FORMAT CSV, HEADER);


-- Review und Ursachenanalyse Export
COPY (
    SELECT * FROM retail.export_review_vs_delivery_score ORDER BY review_score
) TO :'export_path'/review_vs_delivery_score.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_review_vs_delivery_bucket
) TO :'export_path'/review_vs_delivery_bucket.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_review_late_vs_ontime ORDER BY delivery_type
) TO :'export_path'/review_late_vs_ontime.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_review_delivery_by_revenue_segment ORDER BY revenue_segment, delivery_type
) TO :'export_path'/review_delivery_by_revenue_segment.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_low_review_drivers ORDER BY review_group
) TO :'export_path'/low_review_drivers.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_review_delivery_combined
) TO :'export_path'/review_delivery_combined.csv
WITH (FORMAT CSV, HEADER);


-- Produkt und Kategorie Export
COPY (
    SELECT * FROM retail.export_category_performance ORDER BY gross_revenue DESC
) TO :'export_path'/category_performance.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_product_performance ORDER BY gross_revenue DESC
) TO :'export_path'/product_performance.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_category_review_performance ORDER BY reviewed_orders DESC, avg_review_score DESC
) TO :'export_path'/category_review_performance.csv
WITH (FORMAT CSV, HEADER);


-- Payment Export
COPY (
    SELECT * FROM retail.export_payment_type_mix ORDER BY total_payment_value DESC
) TO :'export_path'/payment_type_mix.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_payment_installments ORDER BY payment_installments
) TO :'export_path'/payment_installments.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_payment_type_review ORDER BY reviewed_orders DESC
) TO :'export_path'/payment_type_review.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_payment_type_delivery ORDER BY orders_count DESC
) TO :'export_path'/payment_type_delivery.csv
WITH (FORMAT CSV, HEADER);


-- Customer Segmentation Export
COPY (
    SELECT * FROM retail.export_customer_segments
) TO :'export_path'/customer_segments.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_customer_segment_summary ORDER BY total_revenue DESC
) TO :'export_path'/customer_segment_summary.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_customer_segment_delivery_review ORDER BY orders_count DESC
) TO :'export_path'/customer_segment_delivery_review.csv
WITH (FORMAT CSV, HEADER);

COPY (
    SELECT * FROM retail.export_customer_segment_monthly ORDER BY order_month, customer_segment
) TO :'export_path'/customer_segment_monthly.csv
WITH (FORMAT CSV, HEADER);