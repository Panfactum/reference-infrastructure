WITH source AS (
    SELECT * FROM {{ source('stripe', 'balance_transactions') }}
)

SELECT
    *
FROM source
