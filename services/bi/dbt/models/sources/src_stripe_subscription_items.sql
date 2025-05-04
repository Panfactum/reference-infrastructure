WITH source AS (
    SELECT * FROM {{ source('stripe', 'subscription_items') }}
)

SELECT
    *
FROM source
