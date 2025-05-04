WITH source AS (
    SELECT * FROM {{ source('stripe', 'customers') }}
)

SELECT
    *
FROM source
