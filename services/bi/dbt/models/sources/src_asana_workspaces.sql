WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'asana_workspaces') }}
)

SELECT
    *
FROM source
