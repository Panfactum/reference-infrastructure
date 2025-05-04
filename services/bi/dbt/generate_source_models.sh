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
  
  # Find all source directories
  find "$data_dir" -mindepth 1 -maxdepth 1 -type d | while read source_path; do
    # Get the source directory name
    source_dir=$(basename "$source_path")
    
    # Find all subdirectories in this source directory
    find "$source_path" -mindepth 1 -maxdepth 1 -type d | while read table_path; do
      # Get the table directory name
      table_dir=$(basename "$table_path")
      
      # Check if there are any JSONL files in this table directory
      if ls "$table_path"/*.jsonl 1> /dev/null 2>&1; then
        # Create the model name and file path
        model_name="${source_dir}_${table_dir}"
        model_file="$source_models_dir/${model_name}.sql"
        
        # Skip if we've already processed this combination
        if [ ! -f "$model_file" ]; then
          # Create the SQL file
          cat > "$model_file" << EOF
WITH source AS (
    SELECT * FROM {{ source('${source_dir}', '${table_dir}') }}
)

SELECT
    *
FROM source
EOF
          
          echo "Created source model: $model_file"
          ((count++))
        fi
      fi
    done
  done
  
  echo "Total models created: $count"
}

# Run the generator function
generate_models "$DATA_PATH" "$SOURCES_DIR"

echo "Source models have been generated in $SOURCES_DIR/"
