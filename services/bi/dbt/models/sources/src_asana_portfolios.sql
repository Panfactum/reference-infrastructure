WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'asana_portfolios') }}
)

SELECT
    *
FROM source
