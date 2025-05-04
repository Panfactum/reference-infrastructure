WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_setup_intents') }}
)

SELECT
    *
FROM source
