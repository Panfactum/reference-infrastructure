---
title: Upgrading
---

<Details title='How to edit this page'>

  This page can be found in your project at `/pages/index.md`. Make a change to the markdown file and save it to see the change take effect in your browser. xx
</Details>

```sql customers
from customers
select 
    customer_id
    , customer_name
```

<Dropdown title="Interval" name=interval>
    <DropdownOption value=week />
    <DropdownOption value=month />
</Dropdown>

<Dropdown title="Dimension" name=dimension>
    <DropdownOption value=customer_name />
    <DropdownOption value=environment />
</Dropdown>

<Dropdown title="Customer filter" data={customers} name=customer value=customer_name label=customer_name>
    <DropdownOption value="%" valueLabel="All Customers"/>
</Dropdown>

show: ${inputs.customer.value == '%' ? 'true' : 'false'}

```sql customer_hours
from tasks 
left join customers
  on tasks.customer_id = customers.customer_id
select 
  date_trunc('${inputs.interval.value}', tasks.created_at) as month
  , ${inputs.dimension.value} as dimension
  , sum(time_hours) as hours
where task_type = 'Client Upgrade'
and customer_name like '${inputs.customer.value}'
group by 1, 2 
```



<BarChart
    data={customer_hours}
    title="Customer Hours by Month"
    x=month
    y=hours
    series=dimension
/>