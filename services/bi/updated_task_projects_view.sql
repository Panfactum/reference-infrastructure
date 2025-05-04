CREATE OR REPLACE VIEW task_projects AS
SELECT 
    t.gid AS task_gid,
    t.name AS task_name,
    t.completed,
    t.created_at,
    t.modified_at,
    p.gid AS project_gid,
    p.name AS project_name,
    -- Flatten custom fields using JSON functions
    MAX(CASE WHEN cf.unnest.name = 'Status' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS status,
    MAX(CASE WHEN cf.unnest.name = 'Type' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS type,
    MAX(CASE WHEN cf.unnest.name = 'Sprint' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS sprint,
    MAX(CASE WHEN cf.unnest.name = 'Priority' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS priority,
    MAX(CASE WHEN cf.unnest.name = 'Service Status' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS service_status,
    MAX(CASE WHEN cf.unnest.name = 'Cluster' AND cf.unnest.enum_value IS NOT NULL THEN cf.unnest.enum_value.name END) AS cluster,
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
    t.gid,
    t.name,
    t.completed,
    t.created_at,
    t.modified_at,
    p.gid,
    p.name