WITH project as (
    SELECT
        gid,
        archived,
        created_at,
        modified_at,
        name,
        notes,
        permalink_url,
        public,
        resource_type,
        due_on,
        due_date,
        start_on
FROM {{ ref ('asana_projects') }} t, )

select * from project