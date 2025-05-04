WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'asana_portfolios_memberships') }}
)

SELECT
    *
FROM source
