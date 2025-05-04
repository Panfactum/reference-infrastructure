WITH source AS (
    SELECT * FROM {{ source('gsheet', 'gross_margin') }}
)

SELECT
    *
FROM source
