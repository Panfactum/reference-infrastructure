-- models/intermediate/int_customer_projects.sql
-- this is hack until airbyte's connector fixes portolio linkage to projects/portfolios

WITH projects AS (
    SELECT
        gid as project_gid,
        name AS project_name
    FROM
        {{ ref('projects') }}
),

-- Extract customer name from project name
     extracted_customers AS (
         SELECT
             project_gid,
             project_name,
             -- Extract everything before the first dash and trim
             TRIM(SPLIT_PART(project_name, '-', 1)) AS extracted_customer_name
         FROM
             projects
         WHERE
             -- Ensure the project follows the expected format
             project_name LIKE '% - %'
     ),

-- Customer reference table
     customers AS (
         SELECT
             id AS customer_id,
             customer_name,
             stripe_customer_id,
             root_asana_portfolio_gid
         FROM
             {{ ref('customers') }}
     )

-- Join the extracted customer names to the actual customer records
SELECT
    c.customer_id,
    c.customer_name,
    ec.project_gid,
    ec.project_name
FROM
    extracted_customers ec
        JOIN
    customers c ON ec.extracted_customer_name = c.customer_name