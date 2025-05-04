WITH source AS (
    SELECT * FROM {{ source('stripe', 'subscriptions') }}
)

SELECT
    *
FROM source
