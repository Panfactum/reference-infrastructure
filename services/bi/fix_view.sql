-- Fix for task_projects view

-- First let's drop the existing view
DROP VIEW IF EXISTS task_projects;

-- Create new view with proper JSON string extraction
CREATE VIEW task_projects AS
SELECT 
    t.gid AS task_gid,
    t.name AS task_name,
    t.completed,
    t.created_at,
    t.modified_at,
    p.gid AS project_gid,
    p.name AS project_name
FROM 
    asana_tasks t,
    UNNEST(t.projects) AS proj(value)
JOIN 
    asana_projects p 
ON 
    p.gid = REPLACE(json_extract(proj.value, '$.gid')::VARCHAR, '"', '');
