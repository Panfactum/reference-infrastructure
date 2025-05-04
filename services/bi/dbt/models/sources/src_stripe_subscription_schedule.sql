WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_subscription_schedule') }}
)

SELECT
    *
FROM source
