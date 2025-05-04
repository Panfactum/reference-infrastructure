WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_payment_intents') }}
)

SELECT
    *
FROM source
