# JSONL Data Integration with dbt and DuckDB

This project demonstrates how to directly load JSONL files into DuckDB using dbt, eliminating the need for a separate import script.

## How It Works

1. The `sources.yml` file defines external tables that point to JSONL files in your data directory
2. Each source table combines all JSONL files from a specific directory
3. Table names follow the pattern `source_parent` (e.g., `stripe_usage_records`)
4. dbt models can reference these sources using the standard `source()` function

## Key Features

- **No Separate Import Script**: Direct integration with JSONL files eliminates the need for the import_to_duckdb.ts script
- **Automatic File Combination**: Multiple JSONL files in the same directory are combined into a single logical table
- **Schema Flexibility**: The `union_by_name` option handles files with slightly different schemas
- **Semantic Table Names**: Tables are named after both the source and parent directories for clarity

## Usage

### 1. Creating dbt Models

Create staging models to reference the JSONL sources:

```sql
-- models/staging/stg_stripe_usage_records.sql
{{
  config(
    materialized = 'view'
  )
}}

SELECT * FROM {{ source('jsonl_files', 'stripe_usage_records') }}
```

### 2. Adding New Sources

When you add new JSONL files:

1. Place them in appropriate subdirectories under `/data` (e.g., `/data/stripe/usage_records/`)
2. They'll automatically be included in the corresponding source table
3. If you create new subdirectories, update the `sources.yml` file to include them

You can generate a complete `sources.yml` file for all JSONL files in your data directory:

```bash
dbt run-operation generate_sources_yml
```

Copy the output into `models/sources.yml`.

## Directory Structure

For optimal organization:

- Place JSONL files in directories following the pattern: `/data/source/type/`
- Example: `/data/stripe/subscriptions/file1.jsonl`
- This will create a source table named `stripe_subscriptions`

## Examples

### Example 1: Basic Usage

```sql
-- models/marts/subscription_metrics.sql
SELECT
  s.subscription_id,
  s.status,
  s.current_period_start,
  s.current_period_end,
  u.quantity
FROM {{ source('jsonl_files', 'stripe_subscriptions') }} s
LEFT JOIN {{ source('jsonl_files', 'stripe_usage_records') }} u
  ON s.id = u.subscription_id
```

### Example 2: Combining with Other Sources

```sql
-- models/marts/customer_analysis.sql
SELECT
  c.customer_id,
  c.email,
  c.created,
  COUNT(DISTINCT s.id) as subscription_count,
  SUM(p.amount) as total_payments
FROM {{ source('jsonl_files', 'stripe_customers') }} c
LEFT JOIN {{ source('jsonl_files', 'stripe_subscriptions') }} s
  ON c.id = s.customer_id
LEFT JOIN {{ source('jsonl_files', 'stripe_charges') }} p
  ON c.id = p.customer_id
GROUP BY 1, 2, 3
```

## Performance Considerations

- DuckDB reads the JSONL files each time a model is run
- For improved performance with large files, consider materializing frequently used models as tables

## Troubleshooting

If you encounter issues:

1. Run `dbt run-operation generate_sources_yml` to see what sources are detected
2. Verify that your JSONL files are properly formatted
3. Try reading the files directly using `read_json_auto()` to isolate any issues
4. Check the DuckDB documentation for specific JSON options
