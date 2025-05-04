WITH source AS (
    SELECT * FROM {{ source('stripe', 'plans') }}
)

SELECT
    *
FROM source
