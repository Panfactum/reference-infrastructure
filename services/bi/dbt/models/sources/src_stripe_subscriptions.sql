WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_subscriptions') }}
)

SELECT
    *
FROM source
