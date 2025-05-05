-- models/marts/fact_workload_time_daily.sql

WITH daily_workload_tasks AS (
    SELECT
    DATE_TRUNC('day', completed_at) AS date_day,
    cp.customer_id,
    cp.customer_name,
    pt.workload,
    SUM(pt.time_minutes) AS total_minutes,
    SUM(pt.time_hours) AS total_hours,
    SUM(pt.cost) AS total_cost,
    COUNT(DISTINCT pt.task_gid) AS task_count
FROM
    {{ ref('project_tasks') }} pt
    LEFT JOIN
    {{ ref('customer_projects') }} cp ON pt.project_gid = cp.project_gid
WHERE
    pt.completed = true
  AND pt.completed_at IS NOT NULL
  AND pt.workload IS NOT NULL
GROUP BY
    1, 2, 3, 4
    )

SELECT
    date_day,
    customer_id,
    customer_name,
    workload,
    total_minutes,
    total_hours,
    total_cost,
    task_count
FROM
    daily_workload_tasks
ORDER BY
    date_day DESC,
    customer_name,
    workload