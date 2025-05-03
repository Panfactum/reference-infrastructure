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
    // View for tasks with project info - using DuckDB's JSON functions
    console.log("Creating task_projects view...");
    conn.exec(`
      CREATE OR REPLACE VIEW task_projects AS
      SELECT 
        t.gid AS task_gid,
        t.name AS task_name,
        t.completed,
        t.created_at,
        t.modified_at,
        p.gid AS project_gid,
        p.name AS project_name
      FROM 
        asana_tasks t,
        UNNEST(t.projects) AS proj(value)
      JOIN 
        asana_projects p 
      ON 
        p.gid = REPLACE(json_extract(proj.value, '$.gid')::VARCHAR, '"', '')
    `);
    console.log("task_projects view created successfully");
    
    // View for users with their workspaces
    console.log("Creating user_workspaces view...");
    conn.exec(`
      CREATE OR REPLACE VIEW user_workspaces AS
      SELECT 
        u.gid as user_gid,
        u.name as user_name,
        u.email,
        w.gid as workspace_gid,
        w.name as workspace_name
      FROM 
        asana_users u,
        UNNEST(u.workspaces) AS ws(value)
      JOIN 
        asana_workspaces w 
      ON 
        w.gid = REPLACE(json_extract(ws.value, '$.gid')::VARCHAR, '"', '')
    `);
    console.log("user_workspaces view created successfully");
    
    // View for portfolio memberships with user and portfolio info
    console.log("Creating portfolio_users view...");
    conn.exec(`
      CREATE OR REPLACE VIEW portfolio_users AS
      SELECT 
        pm.gid as membership_gid,
        REPLACE(json_extract(pm.portfolio, '$.gid')::VARCHAR, '"', '') as portfolio_gid,
        p.name as portfolio_name,
        REPLACE(json_extract(pm.user, '$.gid')::VARCHAR, '"', '') as user_gid,
        u.name as user_name,
        u.email as user_email
      FROM asana_portfolios_memberships pm
      JOIN asana_portfolios p ON REPLACE(json_extract(pm.portfolio, '$.gid')::VARCHAR, '"', '') = p.gid
      JOIN asana_users u ON REPLACE(json_extract(pm.user, '$.gid')::VARCHAR, '"', '') = u.gid
    `);
    console.log("portfolio_users view created successfully");
    
    // We've removed the portfolio_projects view as requested
    
    console.log("Views created successfully");
  } catch (error) {
    console.error(`Error creating views: ${error}`);
    console.log("Some views may not have been created due to errors.");
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
