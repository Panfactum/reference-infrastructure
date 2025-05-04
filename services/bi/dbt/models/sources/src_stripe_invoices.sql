WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_invoices') }}
)

SELECT
    *
FROM source
