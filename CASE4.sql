select count(distinct (node_id)) from data_bank.customer_nodes;

SELECT
    count(1) as node_per_region,
    node_id,
    region_id
from data_bank.customer_nodes
GROUP BY
    node_id,
    region_id
ORDER BY node_id, region_id;

SELECT
    count(customer_id) as customer_per_region,
    region_id
from data_bank.customer_nodes
GROUP BY
    region_id
ORDER BY region_id;

SELECT AVG(reallocation) as avg, customer_id
from (
        SELECT *, DATEDIFF(DAY, start_date, end_date) as reallocation
        from data_bank.customer_nodes
        WHERE
            end_date <> '9999-12-31'
    ) as realloc_tab
GROUP by
    customer_id
ORDER by customer_id

select txn_type, count(1) as uniq_count, sum(txn_amount) as amt
from data_bank.customer_transactions
GROUP BY
    txn_type;

with
    customer_trx as (
        SELECT
            customer_id,
            DATEPART (MONTH, txn_date) as month_id,
            DATENAME (MONTH, txn_date) as month_name,
            COUNT(
                CASE
                    WHEN txn_type = 'deposit' then 1
                end
            ) as deposit_count,
            COUNT(
                CASE
                    WHEN txn_type = 'withdrawl' then 1
                end
            ) as withdrawl_count,
            COUNT(
                CASE
                    WHEN txn_type = 'purchase' then 1
                end
            ) as purchase_count
        from data_bank.customer_transactions
        GROUP by
            customer_id,
            DATEPART (MONTH, txn_date),
            DATENAME (MONTH, txn_date)
    )

select *
from customer_trx
where
    deposit_count > 1
    and (
        withdrawl_count > 1
        OR purchase_count > 1
    )
ORDER by month_id, customer_id

select
    customer_id,
    DATEPART (MONTH, txn_date) as month_id,
    DATENAME (MONTH, txn_date) as month_name,
    SUM(txn_amount)
from data_bank.customer_transactions
GROUP by
    DATENAME (MONTH, txn_date),
    DATEPART (MONTH, txn_date),
    customer_id
ORDER BY DATEPART (MONTH, txn_date), customer_id