--SELECT * FROM batch_data WHERE batch_id = 'BATCH_02020';
--SELECT * FROM inventory_data WHERE SKU = 'SKU_0001';
--
WITH 
sorted_batch AS (
	SELECT bd.batch_id, bd.SKU, bd.batch_quantity, bd.batch_received_date,
		   ROW_NUMBER() OVER(PARTITION BY bd.SKU ORDER BY bd.batch_received_date asc, bd.batch_id) batch_order
	FROM batch_data bd
),
product_quantity_accumulated AS (
	SELECT sb.*,
	SUM(sb.batch_quantity) OVER(PARTITION BY sb.SKU ORDER BY sb.batch_order
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_sum --- Tính lũy kế số lượng hàng theo từng batch nhập
	FROM sorted_batch sb
),
--SELECT * FROM product_quantity_accumulatedA
inventory_with_batch AS (
	SELECT p.*,
		   i.Current_Stock,
		   CASE WHEN p.running_sum <= i.Current_Stock THEN p.batch_quantity
		        WHEN p.running_sum - p.batch_quantity < i.Current_Stock THEN i.Current_Stock - (p.running_sum - p.batch_quantity)
				ELSE 0
				END AS quantity_left_batch
	FROM product_quantity_accumulated p
	LEFT JOIN inventory_data i ON p.SKU = i.SKU
)
SELECT SKU, batch_id, Batch_Received_Date, quantity_left_batch
FROM inventory_with_batch
WHERE quantity_left_batch >0
