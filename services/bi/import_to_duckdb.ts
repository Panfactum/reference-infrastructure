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
 * Process a JSONL file and import it into DuckDB
 */
async function processFile(filePath: string, tableName: string): Promise<void> {
  console.log(`Processing file: ${filePath} into table: ${tableName}`);
  
  try {
    // Check if table exists and create it if not
    const tableExists = await new Promise<boolean>((resolve) => {
      conn.all(`SELECT name FROM sqlite_master WHERE type='table' AND name='${tableName}'`, (err, rows) => {
        if (err) {
          console.error(`Error checking if table exists: ${err.message}`);
          resolve(false);
        } else {
          resolve(rows.length > 0);
        }
      });
    });

    if (!tableExists) {
      console.log(`Creating table: ${tableName}`);
      conn.exec(`CREATE TABLE ${tableName} AS SELECT * FROM read_json_auto('${filePath}', format='newline_delimited') LIMIT 0`);
    }
    
    // Import data from the file
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
  
  // View for tasks with project info
  conn.exec(`
    CREATE OR REPLACE VIEW task_projects AS
    SELECT 
      t.gid as task_gid,
      t.name as task_name,
      t.completed,
      t.created_at,
      t.modified_at,
      p.gid as project_gid,
      p.name as project_name
    FROM asana_tasks t
    CROSS JOIN json_each(t.projects) as proj_json
    JOIN asana_projects p ON json_extract(proj_json.value, '$.gid') = p.gid
  `);
  
  // View for users with their workspaces
  conn.exec(`
    CREATE OR REPLACE VIEW user_workspaces AS
    SELECT 
      u.gid as user_gid,
      u.name as user_name,
      u.email,
      w.gid as workspace_gid,
      w.name as workspace_name
    FROM asana_users u
    CROSS JOIN json_each(u.workspaces) as ws_json
    JOIN asana_workspaces w ON json_extract(ws_json.value, '$.gid') = w.gid
  `);
  
  // View for portfolio memberships with user and portfolio info
  conn.exec(`
    CREATE OR REPLACE VIEW portfolio_users AS
    SELECT 
      pm.gid as membership_gid,
      json_extract(pm.portfolio, '$.gid') as portfolio_gid,
      p.name as portfolio_name,
      json_extract(pm.user, '$.gid') as user_gid,
      u.name as user_name,
      u.email as user_email
    FROM asana_portfolios_memberships pm
    JOIN asana_portfolios p ON json_extract(pm.portfolio, '$.gid') = p.gid
    JOIN asana_users u ON json_extract(pm.user, '$.gid') = u.gid
  `);
  
  // View for portfolio items (inferred relationship between portfolios and projects)
  // Note: This is a best-effort approach as the direct relationship is not in the data
  conn.exec(`
    CREATE OR REPLACE VIEW portfolio_projects AS
    SELECT DISTINCT
      p.gid as portfolio_gid,
      p.name as portfolio_name,
      pr.gid as project_gid,
      pr.name as project_name,
      pr.created_at as project_created_at,
      json_extract(pr.workspace, '$.gid') as workspace_gid
    FROM asana_portfolios p
    JOIN asana_projects pr ON json_extract(p.workspace, '$.gid') = json_extract(pr.workspace, '$.gid')
    -- This join assumes projects in the same workspace might be in the portfolio
    -- This is not accurate but provides a starting point
  `);
  
  console.log("Views created successfully");
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
