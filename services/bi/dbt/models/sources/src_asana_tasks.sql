WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'asana_tasks') }}
)

SELECT
    *
FROM source
