WITH source AS (
    SELECT * FROM {{ source('asana', 'custom_fields') }}
)

SELECT
    *
FROM source
