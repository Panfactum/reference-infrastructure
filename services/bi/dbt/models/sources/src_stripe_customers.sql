WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_customers') }}
)

SELECT
    *
FROM source
