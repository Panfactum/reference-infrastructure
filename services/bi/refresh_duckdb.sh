#!/bin/bash

# Set up error handling
set -e
set -o pipefail

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LOG_FILE="${SCRIPT_DIR}/duckdb_import.log"
DB_PATH="${SCRIPT_DIR}/bi.duckdb"
IMPORT_SCRIPT="${SCRIPT_DIR}/import_to_duckdb.ts"

# Log function
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Start logging
log "Starting DuckDB refresh process"

# Check if database backup is needed
if [ -f "$DB_PATH" ]; then
  log "Creating backup of existing database"
  cp "$DB_PATH" "${DB_PATH}.bak"
fi

# Run the import script
log "Running import script"
bun run "$IMPORT_SCRIPT" 2>&1 | tee -a "$LOG_FILE"

# Verify that the database was created successfully
if [ -f "$DB_PATH" ]; then
  log "DuckDB refresh completed successfully"
else
  log "ERROR: DuckDB database was not created"
  exit 1
fi

# Create compact backup and remove older backups if needed
log "Cleaning up old backups"
find "$SCRIPT_DIR" -name "bi.duckdb.bak.*" -type f -mtime +7 -delete

# Timestamp current backup
cp "${DB_PATH}.bak" "${DB_PATH}.bak.$(date '+%Y%m%d%H%M%S')"

log "Process completed"
exit 0
