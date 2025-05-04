WITH source AS (
    SELECT * FROM {{ source('stripe', 'charges') }}
)

SELECT
    *
FROM source
