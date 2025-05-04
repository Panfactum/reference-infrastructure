-- models/marts/fact_workload_time_daily.sql

WITH daily_tasks AS (
    SELECT
    DATE(completed_at) AS date_day,
    workload,
    SUM(time_minutes) AS total_minutes,
    SUM(time_hours) AS total_hours,
    SUM(cost) AS total_cost,
    COUNT(DISTINCT task_gid) AS task_count
FROM
    {{ ref('project_tasks') }}
WHERE
    completed = true
  AND completed_at IS NOT NULL
  AND workload IS NOT NULL
GROUP BY
    1, 2
    )

SELECT
    date_day,
    workload,
    total_minutes,
    total_hours,
    total_cost,
    task_count
FROM
    daily_tasks
ORDER BY
    date_day DESC,
    workload