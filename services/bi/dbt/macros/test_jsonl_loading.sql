-- This is a helper script to test the automatic JSONL loading
-- Run this with: dbt run-operation test_jsonl_loading

{% macro test_jsonl_loading() %}

  {% set get_dirs_query %}
    -- Get unique source and parent directories containing JSONL files
    WITH jsonl_files AS (
      SELECT file FROM glob('{{ var("data_path") }}/**/*.jsonl')
    ),
    with_two_levels AS (
      SELECT 
        file,
        regexp_extract(file, '.*/([^/]+)/([^/]+)/[^/]+$', 1) as source_dir,
        regexp_extract(file, '.*/([^/]+)/([^/]+)/[^/]+$', 2) as parent_dir
      FROM jsonl_files
      WHERE regexp_extract(file, '.*/([^/]+)/([^/]+)/[^/]+$', 1) IS NOT NULL
        AND regexp_extract(file, '.*/([^/]+)/([^/]+)/[^/]+$', 2) IS NOT NULL
    ),
    with_one_level AS (
      SELECT 
        file,
        'default' as source_dir,
        regexp_extract(file, '.*/([^/]+)/[^/]+$', 1) as parent_dir
      FROM jsonl_files
      WHERE regexp_extract(file, '.*/([^/]+)/[^/]+$', 1) IS NOT NULL
    ),
    combined AS (
      SELECT file, source_dir, parent_dir FROM with_two_levels
      UNION ALL
      SELECT file, source_dir, parent_dir FROM with_one_level
      WHERE NOT EXISTS (
        SELECT 1 FROM with_two_levels 
        WHERE with_two_levels.file = with_one_level.file
      )
    )
    SELECT 
      DISTINCT 
        source_dir,
        parent_dir,
        regexp_replace(file, '/[^/]+$', '') as full_dir_path
    FROM combined
  {% endset %}
  
  {% set dir_results = run_query(get_dirs_query) %}
  
  -- Print a list of all JSONL files found
  {% set files_query %}
    SELECT file FROM glob('{{ var("data_path") }}/**/*.jsonl')
  {% endset %}
  
  {% set files_result = run_query(files_query) %}
  
  {% if execute %}
    {{ log("Found the following JSONL files:", info=True) }}
    {% for row in files_result %}
      {{ log("  - " ~ row[0], info=True) }}
    {% endfor %}
    {{ log("", info=True) }}
  {% endif %}
  
  {% if execute %}
    {{ log("These will be grouped into the following tables:", info=True) }}
    {% for row in dir_results %}
      {{ log("  - Table name: '" ~ row[0] ~ "_" ~ row[1] ~ "'", info=True) }}
      {{ log("    Source: '" ~ row[0] ~ "', Directory: '" ~ row[1] ~ "'", info=True) }}
      {{ log("    Location: " ~ row[2], info=True) }}
    {% endfor %}
  {% endif %}

  -- Now get a count of files in each directory
  {% for row in dir_results %}
    {% set files_query %}
      SELECT count(*) as file_count FROM glob('{{ row[2] }}/*.jsonl')
    {% endset %}
    
    {% set files_result = run_query(files_query) %}
    {% set file_count = files_result[0][0] %}
    
    {{ log("    Table '" ~ row[0] ~ "_" ~ row[1] ~ "' will contain " ~ file_count ~ " JSONL files", info=True) }}
    {{ log("", info=True) }}
  {% endfor %}

{% endmacro %}
