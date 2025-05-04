WITH source AS (
    SELECT * FROM {{ source('asana', 'portfolios_memberships') }}
)

SELECT
    *
FROM source
