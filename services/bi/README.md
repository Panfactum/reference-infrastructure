# BI Service for Panfactum

This directory contains scripts for importing Asana data into DuckDB for analysis.

## Overview

The system traverses all JSONL files in the data directory and imports them into corresponding tables in a DuckDB database. Table names are derived from the directory structure.

## Requirements

- Bun (JavaScript runtime)
- DuckDB (embedded analytics database) - Setup with the local installer script, not through Nix

## Directory Structure

- `data/` - Contains all the source JSONL files organized by entity type (tasks, users, etc.)
- `import_to_duckdb.ts` - Script to import all data into DuckDB tables
- `refresh_duckdb.sh` - Shell script to refresh the database (can be scheduled via cron)
- `explore_data.ts` - Script to explore and analyze the imported data
- `bi.duckdb` - The DuckDB database file (created by the import script)
- `setup_duckdb.sh` - Script to install DuckDB locally (outside of Nix)
- `duckdb_web_viewer.ts` - Bun script that provides a web UI for DuckDB
- `duckdb_ui.ts` - Helper script for working with DuckDB UI

## Usage

### Setup DuckDB Locally

Since DuckDB has been removed from the Nix flake, you need to set it up locally. This is done to avoid issues with Nix's immutable filesystem that prevents DuckDB from installing extensions properly.

```bash
# Make the setup script executable
chmod +x setup_duckdb.sh

# Run the setup script
./setup_duckdb.sh
```

This will:
1. Download and install DuckDB 1.2.2 in a local directory (.local/bin)
2. Create a DuckDB configuration file with extension settings
3. Create a duckdb-ui wrapper script for easily starting DuckDB with UI

### Using DuckDB UI

After running the setup script, you can use DuckDB with UI in several ways:

1. Using the duckdb-ui wrapper:
```bash
duckdb-ui bi.duckdb
```

2. Using the web viewer (recommended for better compatibility):
```bash
./duckdb_web_viewer.ts
```
Then open http://localhost:3000 in your browser.

3. Using the helper script with multiple fallback options:
```bash
./duckdb_ui.ts
```

### Import Data

Sync data from s3

```bash
aws s3 sync s3://airbyte-dest-589950d8851030f4 ./data/
```

Then, run the import script to create the DuckDB database and import all data:
```


To import all data into DuckDB:

```bash
./import_to_duckdb.ts
```

This will:
1. Traverse all directories under `data/`
2. Find all JSONL files
3. Create appropriate tables in DuckDB
4. Import data into these tables

### Refresh Database

To refresh the database (includes backup and logging):

```bash
./refresh_duckdb.sh
```

This can be scheduled via cron to run periodically, e.g.:

```bash
# Run daily at 2 AM
0 2 * * * /home/uptown/Projects/panfactum/reference-infrastructure/services/bi/refresh_duckdb.sh
```

## Data Schema

The data is organized by entity type. The main entities include:

- `asana_tasks` - Task data from Asana
- `asana_users` - User data from Asana
- `asana_workspaces` - Workspace data from Asana
- ... and other Asana entities

## Adding New Data Sources

To add new data sources:

1. Create a new directory under `data/` for the new source
2. Place JSONL files in appropriate subdirectories
3. Run the import script to update the database

## Customizing Analysis

Edit the `explore_data.ts` script to add custom analysis queries for your specific needs.
