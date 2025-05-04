# Automated JSONL File Loading with dbt and DuckDB

This project uses dbt with DuckDB to automatically load JSONL files as tables. Instead of using the `import_to_duckdb.ts` script, we're leveraging dbt's ability to work directly with DuckDB's JSONL file reading capabilities.

## How It Works

1. The `sources.yml` file dynamically scans your data directory for all JSONL files
2. Files are grouped by both their source directory and parent directory
3. Each directory group becomes a source table named `source_parent`, combining all JSONL files within that directory
4. You can reference these sources in your dbt models using the standard `source()` function

## Usage

1. Make sure your JSONL files are in the data directory: `/home/uptown/Projects/panfactum/reference-infrastructure/services/bi/data`

2. Run the test operation to see what tables will be available:
   ```bash
   cd /home/uptown/Projects/panfactum/reference-infrastructure/services/bi/models
   dbt run-operation test_jsonl_loading
   ```

3. Run a standard dbt process:
   ```bash
   dbt compile  # Check that the sources are correctly created
   dbt run      # Build all models
   ```

4. Create staging models for each directory of JSONL files you want to work with:
   ```sql
   -- models/staging/stg_your_data.sql
   {{
     config(
       materialized = 'view'
     )
   }}
   
   SELECT * FROM {{ source('jsonl_files', 'source_parent') }}
   ```
   
   Replace `source_parent` with the combined name of your directories.
   For example, if your files are in `/data/stripe/usage_records/`, use `'stripe_usage_records'`.

5. Build transformation models on top of your staging models as needed

## Table Naming Convention

Tables are named using the pattern `source_parent` where:
- `source` is the name of the source system directory (e.g., `stripe`)
- `parent` is the name of the parent directory containing the JSONL files (e.g., `usage_records`)

For example, files in the path `/data/stripe/usage_records/*.jsonl` will be available as:
```sql
{{ source('jsonl_files', 'stripe_usage_records') }}
```

## Key Features

- **Semantic Table Names**: Tables are named after both the source and parent directories of your JSONL files
  
- **Automatic File Combination**: Multiple JSONL files in the same directory are automatically combined into a single table

- **Schema Flexibility**: The `union_by_name` option allows combining files with potentially different schemas

## Benefits

- No need for a separate import script
- Automatic detection and grouping of JSONL files 
- Native integration with dbt's incremental models and other features
- Cleaner data pipeline with everything defined within dbt

## Troubleshooting

If you encounter issues:

1. Verify that your JSONL files are properly formatted
2. Check that the file paths in `dbt_project.yml` match your actual directory structure
3. Run `dbt debug` to check for configuration issues
4. Try to compile and run a single model first to isolate any problems
