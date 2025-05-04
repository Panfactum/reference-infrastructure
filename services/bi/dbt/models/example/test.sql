-- Test model for stripe_usage_records source

{{
  config(
    materialized = 'table'
  )
}}

-- Using the source 
-- If this fails, try the direct_test.sql model instead
SELECT * FROM {{ source('jsonl_files', 'stripe_usage_records') }}
LIMIT 10
