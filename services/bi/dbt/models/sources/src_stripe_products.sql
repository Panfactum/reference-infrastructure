WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_products') }}
)

SELECT
    *
FROM source
