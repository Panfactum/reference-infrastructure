WITH source AS (
    SELECT * FROM {{ source('stripe', 'invoices') }}
)

SELECT
    *
FROM source
