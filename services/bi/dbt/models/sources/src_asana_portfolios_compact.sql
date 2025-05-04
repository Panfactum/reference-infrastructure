WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'asana_portfolios_compact') }}
)

SELECT
    *
FROM source
