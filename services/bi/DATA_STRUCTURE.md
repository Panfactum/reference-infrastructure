# Data Structure Documentation

This document describes the folder and data structure within the `/data` directory of the BI service.

## Overview

The data directory contains Asana data organized in a hierarchical structure. Each entity type from Asana is stored in its own subdirectory, and data files are in JSONL (JSON Lines) format with timestamps in the filename.

## Directory Structure

```
/data
└── asana
    ├── custom_fields
    ├── portfolios
    ├── portfolios_compact
    ├── portfolios_memberships
    ├── projects
    ├── tasks
    ├── users
    └── workspaces
```

## File Naming Convention

Files within each directory follow a consistent naming pattern:
```
YYYY_MM_DD_TIMESTAMP_INDEX.jsonl
```

For example: `2025_04_29_1745945228535_0.jsonl`

- `2025_04_29` - Date of data export (April 29, 2025)
- `1745945228535` - Unix timestamp in milliseconds
- `0` - Index (for multiple files in a single export)
- `.jsonl` - JSON Lines format

## Entity Types and Data Formats

### Asana Data Structure

The data directory contains the following Asana entity types:

1. **custom_fields** - Custom field definitions from Asana
   - Contains metadata about custom fields including type, options, and settings

2. **portfolios** - Portfolio data
   - Contains portfolio metadata including name, owner, color, and workspace
   - Does not contain the actual items (projects) within the portfolio

3. **portfolios_compact** - Compact representation of portfolios
   - Contains minimal metadata about portfolios (likely for reference purposes)

4. **portfolios_memberships** - User memberships to portfolios
   - Maps users to portfolios they have access to
   - Contains portfolio_gid and user_gid

5. **projects** - Project data
   - Contains project metadata including name, description, status, custom fields, and workspace

6. **tasks** - Task data
   - Contains comprehensive task information including status, assignees, due dates, custom fields
   - The largest and most detailed dataset

7. **users** - User data
   - Contains user information including name, email, and photo

8. **workspaces** - Workspace data
   - Contains workspace metadata including name and settings

## Data Format Details

All data is stored in JSONL (JSON Lines) format, where each line represents a single JSON object. This format is well-suited for streaming and batch processing.

### Common Data Structure

Each JSON object typically contains:

1. **Metadata fields**:
   - `_airbyte_raw_id`: Unique identifier for the record
   - `_airbyte_extracted_at`: Timestamp when the data was extracted
   - `_airbyte_meta`: Additional metadata about the extraction
   - `_airbyte_generation_id`: Export batch identifier

2. **Entity-specific fields**:
   - `gid`: Global identifier unique to the entity
   - `resource_type`: Type of resource (e.g., "task", "project", "portfolio")
   - Entity-specific properties (e.g., name, description, status)

## Entity Relationships

The data follows Asana's data model with these key relationships:

1. **Workspaces** contain **Projects**, **Users**, and **Portfolios**
2. **Portfolios** contain **Projects** (though this relationship is not explicitly stored)
3. **Projects** contain **Tasks**
4. **Users** are members of **Workspaces**, **Projects**, and **Portfolios**
5. **Custom Fields** are associated with **Tasks** and **Projects**

## Important Notes

1. The relationship between portfolios and projects is not explicitly stored in the data structure. In Asana, portfolios can contain projects, but this relationship is not represented in a dedicated table in this data export.

2. All timestamps in the data are in ISO 8601 format (UTC).

3. The JSONL files may be large, especially for tasks, and should be processed with streaming parsers.

4. Custom fields data is complex, with nested structures representing different field types and options.

## Recommended Data Processing Approach

When importing this data into DuckDB:

1. Create separate tables for each entity type
2. Parse each JSONL file into its corresponding table
3. Create views or queries to join related entities
4. Handle nested JSON structures appropriately for complex fields

For efficient querying, consider creating the following relationships in your data model:

- Join `tasks` with `projects` using the project's GID
- Join `projects` with `workspaces` using the workspace's GID
- Join `users` with their respective entities using membership tables
