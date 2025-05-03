#!/usr/bin/env bun

import { promises as fs } from "fs";
import { join, basename, dirname } from "path";
import * as duckdb from "duckdb";

// Configuration
const DATA_ROOT = "/home/uptown/Projects/panfactum/reference-infrastructure/services/bi/data";
const DB_PATH = "/home/uptown/Projects/panfactum/reference-infrastructure/services/bi/bi.duckdb";

// Initialize DuckDB
const db = new duckdb.Database(DB_PATH);
const conn = db.connect();

/**
 * Drop a table if it exists
 */
async function dropTableIfExists(tableName: string): Promise<void> {
  try {
    console.log(`Dropping table if it exists: ${tableName}`);
    conn.exec(`DROP TABLE IF EXISTS ${tableName}`);
  } catch (error) {
    console.error(`Error dropping table ${tableName}: ${error}`);
  }
}

/**
 * Process a JSONL file and import it into DuckDB
 */
async function processFile(filePath: string, tableName: string): Promise<void> {
  console.log(`Processing file: ${filePath} into table: ${tableName}`);

  try {
    // Drop the table if it exists
    await dropTableIfExists(tableName);

    // Create the table and import data
    console.log(`Creating table: ${tableName}`);
    conn.exec(`CREATE TABLE ${tableName} AS SELECT * FROM read_json_auto('${filePath}', format='newline_delimited') LIMIT 0`);
    conn.exec(`INSERT INTO ${tableName} SELECT * FROM read_json_auto('${filePath}', format='newline_delimited')`);
    console.log(`Successfully imported data from ${filePath} into ${tableName}`);
  } catch (error) {
    console.error(`Error processing file ${filePath}: ${error}`);
  }
}

/**
 * Traverse directory and process all JSONL files
 */
async function traverseDirectory(dir: string): Promise<void> {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  
  for (const entry of entries) {
    const path = join(dir, entry.name);
    
    if (entry.isDirectory()) {
      await traverseDirectory(path);
    } else if (entry.isFile() && entry.name.endsWith('.jsonl')) {
      // Get relative path from DATA_ROOT and create table name
      const relativePath = path.substring(DATA_ROOT.length + 1);
      const directory = dirname(relativePath);
      const tableName = directory.replace(/\//g, '_');
      
      await processFile(path, tableName);
    }
  }
}

/**
 * Create views for easier querying
 */
async function createViews(): Promise<void> {
  console.log("Creating views for common queries...");

  try {
    const derivedTableName = "task_projects_materialized"; // Use a distinct name

    // **Crucial:** Drop the table first if running the script repeatedly
    await dropTableIfExists(derivedTableName);

    console.log(`Creating table: ${derivedTableName}...`);
    // Use CREATE TABLE AS SELECT...
    conn.exec(`
      CREATE TABLE ${derivedTableName} AS
      SELECT
          p.gid AS project_gid,
          p.name AS project_name,
          t.gid AS task_gid,
          t.name AS task_name,
          t.actual_time_minutes,
          t.completed,
          t.created_at,
          t.modified_at,
          MAX(CASE WHEN cf.unnest.name = 'Workload' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS workload,
          MAX(CASE WHEN cf.unnest.name = 'Workload Type' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS workload_type,
          MAX(CASE WHEN cf.unnest.name = 'Environment' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS environment,
          MAX(CASE WHEN cf.unnest.name = 'SLA' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS sla
      FROM
          asana_tasks t,
          UNNEST(t.projects) AS proj(value),
          UNNEST(t.custom_fields) AS cf,
          asana_projects p
      WHERE
          p.gid = proj.value.gid
      GROUP BY
          1, 2, 3, 4, 5, 6, 7, 8
    `);
    console.log(`${derivedTableName} table created successfully`);

    // You could add other CREATE TABLE AS statements here if needed

  } catch (error) {
    // Note: If the underlying SELECT fails for other reasons (syntax, missing table),
    // the error will still be caught here.
    console.error(`Error creating derived tables: ${error}`);
  }
}

/**
 * Main function to run the import process
 */
async function main() {
  console.log(`Starting import process at ${new Date().toISOString()}`);
  console.log(`Database will be stored at: ${DB_PATH}`);
  
  // Create database instance
  conn.exec(`PRAGMA journal_mode=WAL`);
  
  try {
    // Traverse data directory
    await traverseDirectory(DATA_ROOT);
    
    // Create views for easier querying
    await createViews();
    
    // Run ANALYZE on all tables to update statistics
    conn.exec(`PRAGMA analyze_sample = 100`);
    conn.exec(`ANALYZE`);
    
    console.log(`Import process completed at ${new Date().toISOString()}`);
  } catch (error) {
    console.error(`Error during import: ${error}`);
  } finally {
    // Close database connection
    db.close();
  }
}

// Run the main function
main().catch(console.error);
