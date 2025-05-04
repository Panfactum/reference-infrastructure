WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_balance_transactions') }}
)

SELECT
    *
FROM source
