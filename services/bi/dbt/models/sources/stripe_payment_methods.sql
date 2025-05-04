WITH source AS (
    SELECT * FROM {{ source('stripe', 'payment_methods') }}
)

SELECT
    *
FROM source
