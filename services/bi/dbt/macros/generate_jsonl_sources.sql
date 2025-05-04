-- This macro will generate the sources.yml file automatically
-- Run with: dbt run-operation generate_jsonl_sources

{% macro generate_jsonl_sources() %}

  {% set source_template %}
version: 2

sources:
  - name: jsonl_files
    tables:
  {% endset %}

  {{ log(source_template, info=true) }}
  
  {% set get_base_dirs_query %}
    SELECT name FROM duckdb_directories() 
    WHERE name LIKE '{{ var("data_path") }}/%' 
    AND name NOT LIKE '{{ var("data_path") }}/%/%'
  {% endset %}
  
  {% set base_dirs = run_query(get_base_dirs_query) %}
  
  {% for base_dir in base_dirs %}
    {% set base_dir_name = base_dir[0].split('/')[-1] %}
    {{ log('Found base directory: ' ~ base_dir_name, info=true) }}
    
    {% set get_sub_dirs_query %}
      SELECT name FROM duckdb_directories() 
      WHERE name LIKE '{{ base_dir[0] }}/%' 
      AND name NOT LIKE '{{ base_dir[0] }}/%/%'
    {% endset %}
    
    {% set sub_dirs = run_query(get_sub_dirs_query) %}
    
    {% for sub_dir in sub_dirs %}
      {% set sub_dir_name = sub_dir[0].split('/')[-1] %}
      {% set table_name = base_dir_name ~ '_' ~ sub_dir_name %}
      
      {% set check_files_query %}
        SELECT count(*) FROM glob('{{ sub_dir[0] }}/*.jsonl')
      {% endset %}
      
      {% set file_count = run_query(check_files_query)[0][0] %}
      
      {% if file_count > 0 %}
        {{ log('  - ' ~ table_name ~ ' (' ~ file_count ~ ' files)', info=true) }}
        {{ log('      - name: "' ~ table_name ~ '"', info=true) }}
        {{ log('        description: "JSONL files from ' ~ base_dir_name ~ '/' ~ sub_dir_name ~ ' directory"', info=true) }}
        {{ log('        external:', info=true) }}
        {{ log('          location: "' ~ sub_dir[0] ~ '/*.jsonl"', info=true) }}
        {{ log('          options:', info=true) }}
        {{ log('            format: ''json''', info=true) }}
        {{ log('            auto_detect: true', info=true) }}
        {{ log('            union_by_name: true', info=true) }}
        {{ log('', info=true) }}
      {% endif %}
    {% endfor %}
  {% endfor %}

{% endmacro %}
