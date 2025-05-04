with base as (
from bi.main.task_projects_materialized
select DATE_TRUNC('week', CAST(task_projects_materialized.created_at AS TIMESTAMP)) AS week_start
     , project_gid
     , project_name
     , task_name
     , actual_time_minutes where project_gid not in (1209563514922760, 1209563514922756, 1209588396899755, 1209601562053403, 1209497039028219, 1209573360448005, 1210104167998178, 1209573360447995, 1209570498743322, 1209914796715093, 1209972595616303, 1209631802806368, 1209601562053386, 1209601562053371)
)

-- select
--   *
-- from base

from base
select
    -- project_name
    sum(actual_time_minutes) / 60 as minutes
-- group by 1
-- order by minutes desc