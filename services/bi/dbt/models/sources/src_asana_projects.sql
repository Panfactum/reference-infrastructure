WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'asana_projects') }}
)

SELECT
    *
FROM source
