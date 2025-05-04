WITH source AS (
    SELECT * FROM {{ source('stripe', 'events') }}
)

SELECT
    *
FROM source
