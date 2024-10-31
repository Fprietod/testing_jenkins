-- Selección explícita de columnas
SELECT
    customer_id,
    customer_name,
    customer_email
FROM
    customers
WHERE
    customer_status = 'ACTIVE'
ORDER BY
    customer_id;
