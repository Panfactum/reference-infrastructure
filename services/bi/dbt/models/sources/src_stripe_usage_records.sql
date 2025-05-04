WITH source AS (
    SELECT * FROM {{ source('stripe', 'usage_records') }}
)

SELECT
    *
FROM source
