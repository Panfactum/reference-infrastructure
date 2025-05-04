WITH project_tasks as (
    SELECT
        proj.value.gid AS project_gid,
        t.* EXCLUDE (actual_time_minutes),
        COALESCE(actual_time_minutes, 0) AS time_minutes,
        CAST(ROUND(COALESCE(actual_time_minutes, 0) / 60.0, 2) AS DECIMAL(12,2)) AS time_hours,
        CAST(ROUND((COALESCE(actual_time_minutes, 0) / 60.0) * 60, 2) AS DECIMAL(12,2)) AS cost
    FROM
        {{ ref ('tasks') }} t,
        UNNEST(t.projects) AS proj(value),
)

select
    *
from project_tasks