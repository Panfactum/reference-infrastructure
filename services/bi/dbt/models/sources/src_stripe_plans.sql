WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_plans') }}
)

SELECT
    *
FROM source
