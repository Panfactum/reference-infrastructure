-- This macro generates a complete sources.yml file for all JSONL files
-- Run with: dbt run-operation generate_sources_yml

{% macro generate_sources_yml() %}
  {# First output the header #}
  {% do log('version: 2', info=true) %}
  {% do log('', info=true) %}
  {% do log('sources:', info=true) %}
  {% do log('  - name: jsonl_files', info=true) %}
  {% do log('    schema: main', info=true) %}
  {% do log('    tables:', info=true) %}
  
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
      
      {% do log('      - name: ' ~ table_name, info=true) %}
      {% do log('        description: "Combined data from ' ~ file_count ~ ' JSONL files in ' ~ source_dir ~ '/' ~ parent_dir ~ ' directory"', info=true) %}
      {% do log('        external:', info=true) %}
      {% do log('          location: "' ~ dir_path ~ '/*.jsonl"', info=true) %}
      {% do log('          options:', info=true) %}
      {% do log('            format: ''json''', info=true) %}
      {% do log('            auto_detect: true', info=true) %}
      {% do log('            union_by_name: true', info=true) %}
      {% do log('', info=true) %}
    {% endfor %}
  {% endif %}

  {{ return('') }}
{% endmacro %}