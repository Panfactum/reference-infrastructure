WITH source AS (
    SELECT * FROM {{ source('stripe', 'subscription_schedule') }}
)

SELECT
    *
FROM source
