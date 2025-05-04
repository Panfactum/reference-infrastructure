WITH source AS (
    SELECT * FROM {{ source('stripe', 'prices') }}
)

SELECT
    *
FROM source
