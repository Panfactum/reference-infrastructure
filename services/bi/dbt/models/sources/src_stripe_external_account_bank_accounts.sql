WITH source AS (
    SELECT * FROM {{ source('stripe', 'external_account_bank_accounts') }}
)

SELECT
    *
FROM source
