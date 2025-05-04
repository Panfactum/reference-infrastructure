WITH source AS (
    SELECT * FROM {{ source('asana', 'tasks') }}
)

SELECT
    *
FROM source
