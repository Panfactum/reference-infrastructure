WITH source AS (
    SELECT * FROM {{ source('gsheet', 'customers') }}
)

SELECT
    *
FROM source
