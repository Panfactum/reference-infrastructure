WITH tasks AS (
    SELECT
        t.gid AS task_gid,
        t.projects,
        t.name AS task_name,
        t.actual_time_minutes,
        t.completed,
        CAST(t.completed_at AS TIMESTAMP) AS completed_at,
        CAST(t.created_at AS TIMESTAMP) AS created_at,
        CAST(t.modified_at AS TIMESTAMP) AS modified_at,
        MAX(CASE WHEN cf.unnest.name = 'Workload' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS workload,
        MAX(CASE WHEN cf.unnest.name = 'Workload Type' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS workload_type,
        MAX(CASE WHEN cf.unnest.name = 'Environment' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS environment,
        MAX(CASE WHEN cf.unnest.name = 'SLA' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS sla
    FROM
        {{ ref('asana_tasks') }} t,
    UNNEST(t.custom_fields) AS cf
GROUP BY
    1, 2, 3, 4, 5, 6, 7, 8
    )

SELECT *
FROM tasks