WITH source AS (
    SELECT * FROM {{ source('asana', 'workspaces') }}
)

SELECT
    *
FROM source
