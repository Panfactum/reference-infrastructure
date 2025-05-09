---
title: Customer Service
---

<Details title='How to edit this page'>

  This page can be found in your project at `/pages/index.md`. Make a change to the markdown file and save it to see the change take effect in your browser. xx
</Details>

<Dropdown title="Interval" name=interval>
    <DropdownOption value=week/>
    <DropdownOption value=month/>
</Dropdown>

<Dropdown title="Dimension" name=dimension>
    <DropdownOption value=customers.customer_name />
    <DropdownOption value=task_type />
    <DropdownOption value=workload_type />
    <DropdownOption value=workload />
</Dropdown>

```sql customer_hours
from tasks 
left join customers
  on tasks.customer_id = customers.customer_id
select 
  date_trunc('${inputs.interval.value}', tasks.created_at) as month
  , ${inputs.dimension.value} as dimension
  , sum(time_hours) as hours
group by 1, 2 
```

<BarChart
    data={customer_hours}
    title="Customer Hours by Month"
    x=month
    y=hours
    series=dimension
/>
