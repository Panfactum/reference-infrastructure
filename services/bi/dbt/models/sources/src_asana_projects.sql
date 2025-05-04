WITH source AS (
    SELECT * FROM {{ source('asana', 'projects') }}
)

SELECT
    *
FROM source
