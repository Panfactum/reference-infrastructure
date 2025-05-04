-- models/marts/core/dim_projects_classified.sql
WITH
-- Get distinct projects from the project_tasks intermediate model with task metadata
projects_with_tasks AS (
    SELECT
        pt.project_gid,
        COUNT(CASE WHEN pt.completed = TRUE THEN 1 END) AS completed_tasks,
        COUNT(*) AS total_tasks,
        SUM(COALESCE(pt.actual_time_minutes, 0)) AS total_minutes
    FROM
        {{ ref('project_tasks') }} pt
GROUP BY
    pt.project_gid
    )
-- Final dimension table with classification
SELECT
    p.gid AS project_gid,
    p.name AS project_name,
    p.created_at AS project_created_at,
    p.modified_at AS project_modified_at,
    p.archived AS is_archived,
    p.notes AS project_notes,
    p.permalink_url,
    p.due_on,
    p.due_date,
    p.start_on,
    pt.total_tasks,
    pt.completed_tasks,

    -- Add total hours calculation
    ROUND(pt.total_minutes / 60.0, 2) AS total_hours,

    -- Project completion rate
    CASE
        WHEN pt.total_tasks > 0 THEN
            ROUND((pt.completed_tasks::FLOAT / pt.total_tasks) * 100, 2)
        ELSE 0
        END AS completion_percentage,

    -- Project type classification
    CASE
        WHEN p.name ILIKE '%onboarding%' THEN 'Onboarding'
        WHEN p.name ILIKE '%upgrade%' THEN 'Upgrade'
        WHEN p.name ILIKE '%support%' THEN 'Support'
        ELSE 'Other'
END AS project_type,

    CASE
        WHEN p.name ILIKE '%onboarding%' THEN 'Service'
        WHEN p.name ILIKE '%upgrade%' THEN 'Service'
        WHEN p.name ILIKE '%support%' THEN 'Service'
        ELSE 'Other'
    END AS team,

    -- Additional classification - project status
    CASE
        WHEN p.archived = TRUE THEN 'Archived'
        WHEN pt.completed_tasks > 0 AND pt.total_tasks > 0 AND pt.completed_tasks = pt.total_tasks THEN 'Completed'
        WHEN pt.completed_tasks > 0 AND pt.total_tasks > 0 THEN 'In Progress'
        WHEN pt.completed_tasks = 0 AND pt.total_tasks > 0 THEN 'Not Started'
        ELSE 'No Tasks'
END AS project_status,

FROM
    {{ ref('projects') }} p
    LEFT JOIN projects_with_tasks pt ON p.gid = pt.project_gid