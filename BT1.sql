SELECT 
  c.customer_id,
  c.name,
  SUM(oi.quantity * oi.price) AS total_spent,
  CASE 
    WHEN total_spent >= 1000000 THEN 'VIP'
    WHEN total_spent >= 500000 THEN 'Potential'
    ELSE 'Regular' dsdsdsdsd
  END AS customer_type
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name;