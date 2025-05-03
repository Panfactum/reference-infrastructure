-- Debug the project gids

SELECT 
    t.gid AS task_gid,
    json_extract(proj.value, '$.gid') AS task_project_gid,
    typeof(json_extract(proj.value, '$.gid')) AS task_project_gid_type
FROM 
    asana_tasks t,
    UNNEST(t.projects) AS proj(value)
LIMIT 10;

SELECT 
    p.gid AS project_gid,
    typeof(p.gid) AS project_gid_type
FROM 
    asana_projects p
LIMIT 10;
