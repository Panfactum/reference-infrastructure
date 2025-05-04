WITH project_tasks as (
    SELECT
        proj.value.gid AS project_gid,
        t.*
    FROM
        {{ ref ('tasks') }} t,
        UNNEST(t.projects) AS proj(value),
)

select
    *
from project_tasks