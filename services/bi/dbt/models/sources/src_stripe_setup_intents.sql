WITH source AS (
    SELECT * FROM {{ source('stripe', 'setup_intents') }}
)

SELECT
    *
FROM source
