#!/usr/bin/env bun

import { existsSync, readFileSync, writeFileSync, mkdirSync, readdirSync, statSync } from 'fs';
import { join, dirname } from 'path';
import * as yaml from 'yaml';

// Set the project root and data path
const PROJECT_ROOT = "/home/uptown/Projects/panfactum/reference-infrastructure/services/bi";
const DATA_PATH = `${PROJECT_ROOT}/data`;
const OUTPUT_FILE = `${PROJECT_ROOT}/dbt/models/sources.yml`;
const BACKUP_FILE = `${OUTPUT_FILE}.bak`;

interface TableDef {
  name: string;
  meta?: Record<string, any>;
  [key: string]: any;
}

interface SourceDef {
  name: string;
  schema: string;
  meta?: Record<string, any>;
  tables: TableDef[];
}

interface SourcesConfig {
  version: number;
  sources: SourceDef[];
}

async function main() {
  // Backup the original file if it exists
  if (existsSync(OUTPUT_FILE)) {
    const originalContent = readFileSync(OUTPUT_FILE, 'utf8');
    writeFileSync(BACKUP_FILE, originalContent);
    console.log(`Created backup at ${BACKUP_FILE}`);
  }

  // Read existing sources file to extract custom sources
  let customSources: SourceDef[] = [];

  // Get list of auto-generated source names (data directories)
  const autoSourceNames = readdirSync(DATA_PATH)
    .filter(dir => statSync(join(DATA_PATH, dir)).isDirectory());

  if (existsSync(OUTPUT_FILE)) {
    try {
      const fileContent = readFileSync(OUTPUT_FILE, 'utf8');
      const existingSources = yaml.parse(fileContent) as SourcesConfig;

      if (existingSources && existingSources.sources) {
        // Find custom sources that are not in data directories
        customSources = existingSources.sources.filter(
          source => !autoSourceNames.includes(source.name)
        );
      }
    } catch (e) {
      console.warn(`Warning: Could not parse existing sources file: ${e}`);
    }
  }

  // Generate sources.yml content
  let yamlContent = "version: 2\n\nsources:\n";

  // Add auto-generated sources first
  for (const sourceDir of autoSourceNames.sort()) {
    const sourcePath = join(DATA_PATH, sourceDir);

    // Get table directories
    const tableDirs = readdirSync(sourcePath)
      .filter(dir => statSync(join(sourcePath, dir)).isDirectory())
      .sort();

    // Add source entry
    yamlContent += `  - name: ${sourceDir}\n`;
    yamlContent += `    schema: "sources"\n`;
    yamlContent += "    meta:\n";
    yamlContent += `      external_location: "/home/uptown/Projects/panfactum/reference-infrastructure/services/bi/data/${sourceDir}/{name}/*.jsonl"\n`;
    yamlContent += "    tables:\n";

    // Add table entries
    for (const tableDir of tableDirs) {
      yamlContent += `      - name: ${tableDir}\n`;
    }

    yamlContent += "\n";  // Blank line after each source
  }

  // Add custom sources
  for (const source of customSources) {
    const { name, schema = 'sources' } = source;

    yamlContent += `  - name: ${name}\n`;
    yamlContent += `    schema: "${schema}"\n`;

    // Add meta section if present
    if (source.meta) {
      yamlContent += "    meta:\n";
      for (const [key, value] of Object.entries(source.meta)) {
        if (typeof value === 'string') {
          yamlContent += `      ${key}: "${value}"\n`;
        } else {
          yamlContent += `      ${key}: ${value}\n`;
        }
      }
    }

    // Add tables section
    yamlContent += "    tables:\n";

    // Add table entries
    for (const table of source.tables || []) {
      yamlContent += `      - name: ${table.name}\n`;

      // Handle additional table properties
      for (const [key, value] of Object.entries(table)) {
        if (key !== 'name') {
          if (key === 'meta') {
            yamlContent += "        meta:\n";
            for (const [metaKey, metaValue] of Object.entries(value as Record<string, any>)) {
              // Handle string values with comments
              const stringValue = String(metaValue);
              if (typeof metaValue === 'string' && !stringValue.startsWith('#')) {
                yamlContent += `          ${metaKey}: "${metaValue}"\n`;
              } else {
                yamlContent += `          ${metaKey}: ${metaValue}\n`;
              }
            }
          } else {
            yamlContent += `        ${key}: ${value}\n`;
          }
        }
      }
    }

    yamlContent += "\n";  // Blank line after each source
  }

  // Write the updated YAML file
  writeFileSync(OUTPUT_FILE, yamlContent);

  console.log(`Sources YAML file updated successfully at: ${OUTPUT_FILE}`);
  console.log(`Auto-generated sources: ${autoSourceNames.sort().join(', ')}`);
  if (customSources.length > 0) {
    console.log(`Custom sources preserved: ${customSources.map(s => s.name).join(', ')}`);
  }
}

main().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});