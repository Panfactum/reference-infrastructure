-- This macro generates a complete sources.yml file for all JSONL files and writes it to stdout cleanly
-- Run with: dbt run-operation write_sources_yml

{% macro write_sources_yml() %}
  {{ print('version: 2') }}
  {{ print('') }}
  {{ print('sources:') }}
  {{ print('  - name: jsonl_files') }}
  {{ print('    schema: main') }}
  {{ print('    tables:') }}
  
  {% set find_files_query %}
    WITH
    data_paths AS (
      SELECT 
        DISTINCT regexp_extract(file, '.*/([^/]+)/([^/]+)/[^/]+$', 1) as source_dir,
        regexp_extract(file, '.*/([^/]+)/([^/]+)/[^/]+$', 2) as parent_dir,
        regexp_replace(file, '/[^/]+$', '') as dir_path
      FROM glob('{{ var("data_path") }}/**/*.jsonl')
      WHERE 
        regexp_extract(file, '.*/([^/]+)/([^/]+)/[^/]+$', 1) IS NOT NULL
        AND regexp_extract(file, '.*/([^/]+)/([^/]+)/[^/]+$', 2) IS NOT NULL
    )
    SELECT * FROM data_paths
    ORDER BY source_dir, parent_dir
  {% endset %}
  
  {% set results = run_query(find_files_query) %}
  
  {% if execute %}
    {% for row in results %}
      {% set source_dir = row[0] %}
      {% set parent_dir = row[1] %}
      {% set dir_path = row[2] %}
      {% set table_name = source_dir ~ '_' ~ parent_dir %}
      
      {% set count_query %}
        SELECT count(*) FROM glob('{{ dir_path }}/*.jsonl')
      {% endset %}
      
      {% set count_result = run_query(count_query) %}
      {% set file_count = count_result[0][0] %}
      
      {{ print('      - name: ' ~ table_name) }}
      {{ print('        description: "Combined data from ' ~ file_count ~ ' JSONL files in ' ~ source_dir ~ '/' ~ parent_dir ~ ' directory"') }}
      {{ print('        external:') }}
      {{ print('          location: "' ~ dir_path ~ '/*.jsonl"') }}
      {{ print('          options:') }}
      {{ print('            format: ''json''') }}
      {{ print('            auto_detect: true') }}
      {{ print('            union_by_name: true') }}
      {{ print('') }}
    {% endfor %}
  {% endif %}

  {{ return('') }}
{% endmacro %}