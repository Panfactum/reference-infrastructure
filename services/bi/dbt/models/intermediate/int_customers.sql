-- models/intermediate/int_customers.sql
-- Extracts customer information from projects where customer is not explicitly defined in the source
-- This model consolidates customer information from various sources

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

-- Base customer records from the customer source
base_customers AS (
    SELECT
        id AS customer_id,
        customer_name,
        stripe_customer_id,
        root_asana_portfolio_gid
    FROM
        {{ ref('customers') }}
)

-- Combine all customer information 
SELECT DISTINCT
    c.customer_id,
    c.customer_name,
    c.stripe_customer_id,
    c.root_asana_portfolio_gid
FROM
    base_customers c
