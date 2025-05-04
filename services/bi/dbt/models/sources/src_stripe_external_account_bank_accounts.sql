WITH source AS (
    SELECT * FROM {{ source('jsonl_files', 'stripe_external_account_bank_accounts') }}
)

SELECT
    *
FROM source
