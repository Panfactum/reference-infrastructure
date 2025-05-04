WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'asana_users') }}
)

SELECT
    *
FROM source
