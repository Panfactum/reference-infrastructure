-- Example staging model that uses the combined source_parent directory name
-- You can create similar staging models for other directories

{{
  config(
    materialized = 'view'
  )
}}

-- This will reference all combined JSONL files from a directory
-- Replace 'stripe_usage_records' with the actual source_parent name 
-- For example, if your files are in /data/stripe/usage_records/,
-- use 'stripe_usage_records'
SELECT * FROM {{ source('jsonl_files', 'stripe_usage_records') }}
