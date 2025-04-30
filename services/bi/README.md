# BI Service for Panfactum

This directory contains scripts for importing Asana data into DuckDB for analysis.

## Overview

The system traverses all JSONL files in the data directory and imports them into corresponding tables in a DuckDB database. Table names are derived from the directory structure.

## Requirements

- Bun (JavaScript runtime)
- DuckDB (embedded analytics database)

## Directory Structure

- `data/` - Contains all the source JSONL files organized by entity type (tasks, users, etc.)
- `import_to_duckdb.ts` - Script to import all data into DuckDB tables
- `refresh_duckdb.sh` - Shell script to refresh the database (can be scheduled via cron)
- `explore_data.ts` - Script to explore and analyze the imported data
- `bi.duckdb` - The DuckDB database file (created by the import script)

## Usage

### Import Data

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

### Explore Data

To explore the imported data:

```bash
./explore_data.ts
```

This will:
1. List all tables in the database
2. Show record counts for each table
3. Display sample data from key tables
4. Run some example analysis queries

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
