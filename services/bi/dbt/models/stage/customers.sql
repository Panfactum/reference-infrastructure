with customers AS (
     SELECT
         id,
         customer_name,
         stripe_customer_id,
         root_asana_portfolio_gid
     FROM
         {{ ref('gsheet_customers') }}
 )

select
    *
from customers