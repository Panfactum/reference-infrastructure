WITH source AS (
    SELECT * FROM {{ source('asana', 'portfolios_compact') }}
)

SELECT
    *
FROM source
