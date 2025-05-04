WITH source AS (
    SELECT * FROM {{ source('stripe', 'customer_balance_transactions') }}
)

SELECT
    *
FROM source
