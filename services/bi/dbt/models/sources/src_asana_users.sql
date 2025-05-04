WITH source AS (
    SELECT * FROM {{ source('asana', 'users') }}
)

SELECT
    *
FROM source
