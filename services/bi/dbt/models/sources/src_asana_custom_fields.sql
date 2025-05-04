WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'asana_custom_fields') }}
)

SELECT
    *
FROM source
