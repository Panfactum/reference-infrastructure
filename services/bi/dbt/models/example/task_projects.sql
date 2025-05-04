SELECT
    p.gid AS project_gid,
    p.name AS project_name,
    t.gid AS task_gid,
    t.name AS task_name,
    t.actual_time_minutes,
    t.completed,
    t.created_at,
    t.modified_at,
    MAX(CASE WHEN cf.unnest.name = 'Workload' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS workload,
    MAX(CASE WHEN cf.unnest.name = 'Workload Type' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS workload_type,
    MAX(CASE WHEN cf.unnest.name = 'Environment' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS environment,
    MAX(CASE WHEN cf.unnest.name = 'SLA' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS sla
FROM
    asana_tasks t,
    UNNEST(t.projects) AS proj(value),
    UNNEST(t.custom_fields) AS cf,
    asana_projects p
WHERE
    p.gid = proj.value.gid
GROUP BY
    1, 2, 3, 4, 5, 6, 7, 8