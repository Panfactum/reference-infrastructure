WITH source AS (
    SELECT * FROM {{ source('asana', 'portfolios') }}
)

SELECT
    *
FROM source
