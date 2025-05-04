WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_customer_balance_transactions') }}
)

SELECT
    *
FROM source
