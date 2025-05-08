# Automated JSONL File Loading with dbt and DuckDB

This project uses dbt with DuckDB to automatically load JSONL files as tables. Instead of using the `import_to_duckdb.ts` script, we're leveraging dbt's ability to work directly with DuckDB's JSONL file reading capabilities.

## Requirements

1. install [duckdb](https://duckdb.org/docs/installation/?version=stable&environment=cli&platform=macos&download_method=direct)
2. enable [gsheet](https://duckdb.org/community_extensions/extensions/gsheets.html) plugin
3. setup `~/.config/gspread/credentials.json` exists. Setup from https://console.cloud.google.com/apis/credentials?project=arboreal-moment-458810-a5

## Generate Source Models
1. run `aws s3 sync s3://airbyte-dest-589950d8851030f4 ./data`
2. run `./generate_sources.sh`
2. run `./generate_source_models.ts`

## Development

1. run `nix develop`
2. run `dev` - starts duckdb repl with dbt runtime
3. run `run` - triggers a dbt run to recreate models