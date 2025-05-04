#!/bin/bash

# Set the project root and data path
PROJECT_ROOT="/home/uptown/Projects/panfactum/reference-infrastructure/services/bi"
DATA_PATH="$PROJECT_ROOT/data"
OUTPUT_FILE="$PROJECT_ROOT/dbt/models/sources.yml"

# Create the beginning of the sources.yml file
cat > "$OUTPUT_FILE" << EOL
version: 2

sources:
EOL

# Find all source directories
SOURCE_DIRS=$(find "$DATA_PATH" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)

# Process each source directory
for SOURCE_DIR in $SOURCE_DIRS; do
  # Append source information to the file
  cat >> "$OUTPUT_FILE" << EOL
  - name: $SOURCE_DIR
    schema: "sources"
    meta:
      external_location: "/home/uptown/Projects/panfactum/reference-infrastructure/services/bi/data/$SOURCE_DIR/{name}/*.jsonl"
    tables:
EOL

  # Find all subdirectories (tables) in this source directory
  TABLE_DIRS=$(find "$DATA_PATH/$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)
  
  # Process each table directory
  for TABLE_DIR in $TABLE_DIRS; do
    # Append table information to the file
    echo "      - name: $TABLE_DIR" >> "$OUTPUT_FILE"
  done
  
  # Add a blank line after each source
  echo "" >> "$OUTPUT_FILE"
done

echo "Sources YAML file generated successfully at: $OUTPUT_FILE"
