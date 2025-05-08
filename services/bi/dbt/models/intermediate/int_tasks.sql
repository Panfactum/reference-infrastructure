-- models/intermediate/int_tasks.sql
-- Contains task information with task_type (derived from projects) and customer_id relationship

WITH projects AS (
    SELECT
        gid as project_gid,
        name AS project_name
    FROM
        {{ ref('projects') }}
),

-- Extract task type from project name and map to standardized types
 project_task_types AS (
     SELECT
         project_gid,
         -- Map the extracted task types to standardized categories
         CASE
             WHEN TRIM(SPLIT_PART(project_name, '-', 2)) = 'Stable Upgrade' THEN 'Client Upgrade'
             WHEN TRIM(SPLIT_PART(project_name, '-', 2)) = 'Onboarding' THEN 'Client Onboarding'
             WHEN TRIM(SPLIT_PART(project_name, '-', 2)) = 'Support' THEN 'Client Support'
             ELSE TRIM(SPLIT_PART(project_name, '-', 2)) -- Keep original if no mapping found
             END AS task_type
     FROM
         projects
     WHERE
         -- Ensure the project follows the expected format
         project_name LIKE '% - %'
 ),

-- Project to customer mapping
project_customers AS (
    SELECT
        project_gid,
        id as customer_id
    FROM
        projects p
    JOIN
        {{ ref('customers') }} c
    ON
        TRIM(SPLIT_PART(p.project_name, '-', 1)) = c.customer_name
    WHERE
        p.project_name LIKE '% - %'
),

-- Task base
task_base AS (
    SELECT
        t.task_gid,
        t.task_name,
        COALESCE(t.actual_time_minutes, 0) AS time_minutes,
        CAST(ROUND(COALESCE(t.actual_time_minutes, 0) / 60.0, 2) AS DECIMAL(12,2)) AS time_hours,
        CAST(ROUND((COALESCE(t.actual_time_minutes, 0) / 60.0) * 60, 2) AS DECIMAL(12,2)) AS cost,
        t.completed,
        t.completed_at,
        t.created_at,
        t.modified_at,
        t.workload,
        t.workload_type,
        t.environment,
        t.sla,
        proj.value.gid AS project_gid
    FROM
        {{ ref('tasks') }} t,
        UNNEST(t.projects) AS proj(value)
)

-- Final tasks with customer_id and task_type
SELECT
    tb.*,
    COALESCE(ptt.task_type, 'Unknown') AS task_type,
    pc.customer_id
FROM
    task_base tb
LEFT JOIN
    project_task_types ptt ON tb.project_gid = ptt.project_gid
LEFT JOIN
    project_customers pc ON tb.project_gid = pc.project_gid
WHERE
    task_type != 'Unknown'
and customer_id is not null