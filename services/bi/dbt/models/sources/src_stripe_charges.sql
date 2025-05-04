WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_charges') }}
)

SELECT
    *
FROM source
