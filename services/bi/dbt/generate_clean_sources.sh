#!/bin/bash

# Set the project root and data path
PROJECT_ROOT="/home/uptown/Projects/panfactum/reference-infrastructure/services/bi"
DATA_PATH="$PROJECT_ROOT/data"
DBT_DIR="$PROJECT_ROOT/dbt"

# Navigate to the dbt directory
cd $DBT_DIR

# Run dbt operation and capture only the output lines
dbt run-operation write_sources_yml --vars "{\"data_path\": \"$DATA_PATH\"}" > temp_output.log

# Extract only the YAML content (remove timestamp lines)
sed -E 's/^[0-9]{2}:[0-9]{2}:[0-9]{2}\s+//' temp_output.log | grep -v "Running with" | grep -v "Registered adapter" | grep -v "Found" > "$DBT_DIR/models/sources.yml"

# Clean up
rm temp_output.log

echo "YAML sources extracted to $DBT_DIR/models/sources.yml"