WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_usage_records') }}
)

SELECT
    *
FROM source
