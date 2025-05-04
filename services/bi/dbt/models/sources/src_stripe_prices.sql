WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_prices') }}
)

SELECT
    *
FROM source
