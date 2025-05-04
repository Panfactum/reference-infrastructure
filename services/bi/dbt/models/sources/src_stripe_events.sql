WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_events') }}
)

SELECT
    *
FROM source
