WITH source AS (
    SELECT * FROM {{ source('stripe', 'payment_intents') }}
)

SELECT
    *
FROM source
