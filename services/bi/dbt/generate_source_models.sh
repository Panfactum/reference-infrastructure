#!/bin/bash

# Set the project root and data path
PROJECT_ROOT="/home/uptown/Projects/panfactum/reference-infrastructure/services/bi"
DATA_PATH="$PROJECT_ROOT/data"
DBT_DIR="$PROJECT_ROOT/dbt"
SOURCES_DIR="$DBT_DIR/models/sources"

# Navigate to the dbt directory
cd $DBT_DIR

# Ensure the sources directory exists
mkdir -p "$SOURCES_DIR"

# Generate the source models using bash
echo "Generating source models..."

# Function to find JSONL files and create models
generate_models() {
  local data_dir="$1"
  local source_models_dir="$2"
  local count=0
  
  # Find all unique source/parent directory combinations
  find "$data_dir" -name "*.jsonl" | while read file; do
    # Extract the source and parent directories
    # Example: /path/to/data/asana/tasks/file.jsonl
    # source_dir = asana, parent_dir = tasks
    source_dir=$(basename $(dirname $(dirname "$file")))
    parent_dir=$(basename $(dirname "$file"))
    table_name="${source_dir}_${parent_dir}"
    model_name="src_${table_name}"
    model_file="$source_models_dir/${model_name}.sql"
    
    # Skip if we've already processed this combination
    if [ ! -f "$model_file" ]; then
      # Create the SQL file
      cat > "$model_file" << EOF
WITH source AS (
    SELECT * FROM {{ source('jsonl_files', '${table_name}') }}
)

SELECT
    *
FROM source
EOF
      
      echo "Created source model: $model_file"
      ((count++))
    fi
  done
  
  echo "Total models created: $count"
}

# Run the generator function
generate_models "$DATA_PATH" "$SOURCES_DIR"

echo "Source models have been generated in $SOURCES_DIR/"
