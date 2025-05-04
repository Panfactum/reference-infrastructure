-- Test model for stripe_usage_records source

{{
  config(
    materialized = 'view'
  )
}}

-- This will select from the manually defined stripe_usage_records source
SELECT * FROM {{ source('jsonl_files', 'stripe_usage_records') }}
LIMIT 10
