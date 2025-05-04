WITH source AS (
    SELECT * FROM {{ source('stripe', 'products') }}
)

SELECT
    *
FROM source
