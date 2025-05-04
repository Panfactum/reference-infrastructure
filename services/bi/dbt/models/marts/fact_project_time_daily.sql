-- models/marts/fact_project_time_daily.sql
WITH daily_tasks AS (
    SELECT
        task_gid,
        project_gid,
        DATE_TRUNC('day', completed_at) AS completion_date,
        COALESCE(actual_time_minutes, 0) AS time_minutes
    FROM
        {{ ref('project_tasks') }}
    WHERE
        completed = TRUE
      AND completed_at IS NOT NULL
)
SELECT
    dt.completion_date,
    dt.project_gid,
    pc.project_name,
    pc.project_type,
    pc.team,
    SUM(dt.time_minutes) AS total_minutes,
    ROUND(SUM(dt.time_minutes) / 60.0, 2) AS total_hours
FROM
    daily_tasks dt
        JOIN {{ ref('dim_projects_classified') }} pc ON dt.project_gid = pc.project_gid
GROUP BY
    dt.completion_date,
    dt.project_gid,
    pc.project_name,
    pc.project_type,
    pc.team