select count(1)
from (
        select distinct (customer_id)
        from foodie_fi.subscriptions
    ) as fs;

select DATEPART (MONTH, sub.start_date) as month, count(1) as sub_count
from foodie_fi.subscriptions as sub
where
    sub.plan_id = 0
group by
    DATEPART (MONTH, sub.start_date)
order by DATEPART (MONTH, sub.start_date);

select pln.plan_name, count(*) as plan_count
from foodie_fi.subscriptions as sub
    join foodie_fi.plans as pln on sub.plan_id = pln.plan_id
where
    DATEPART (Year, sub.start_date) > '2020'
group by
    pln.plan_name;

DECLARE @totalCount int;

Select @totalCount = count(distinct (customer_id))
from foodie_fi.subscriptions;

DECLARE @churnCount int;

select @churnCount = count(distinct (customer_id))
from foodie_fi.subscriptions
where
    plan_id = 4;

select
    count(distinct (customer_id)) as customer_count,
    ROUND(
        (
            @churnCount * 100 / @totalCount
        ),
        10
    ) as percents,
    @churnCount as churnCount
from foodie_fi.subscriptions;

with
    prev_plan_cte as (
        select *, LAG(plan_id, 1) over (
                partition by
                    customer_id
                order by plan_id
            ) as prev_plan
        from foodie_fi.subscriptions
    )

select ROUND(
        (count(*) * 100) / (
            select count(distinct (customer_id))
            from foodie_fi.subscriptions
        ), 3
    ) as total_percent
from prev_plan_cte
where
    plan_id = 4
    and prev_plan = 0;

with
    after_plan as (
        select *, LEAD(plan_id, 1) over (
                partition by
                    customer_id
                order by plan_id
            ) as next_plan
        from foodie_fi.subscriptions
    )

select ROUND(
        count(1) * 100 / (
            select count(distinct (customer_id))
            from foodie_fi.subscriptions
        ), 2
    ) as percents, next_plan as plan_id
from after_plan
where
    plan_id = 0
group by
    next_plan;

select sub.start_date, sub.plan_id, pln.plan_name
from foodie_fi.subscriptions as sub
    join foodie_fi.plans as pln on pln.plan_id = sub.plan_id
where
    sub.plan_id = 3

DECLARE @cusCount int
select @cusCount = count(distinct (customer_id))
from (
        select *, lag(plan_id, 1) over (
                partition by
                    customer_id
                order by plan_id
            ) as prev_plan
        from foodie_fi.subscriptions
    ) as plan_cte
where
    plan_id = 3
    and prev_plan is not null
    and DATEPART (YEAR, start_date) = '2020';

print @cusCount;

select sub.customer_id, sub.start_date, pln.plan_name, pln.price, row_number() over (
        partition by
            customer_id
        order by start_date
    ) as plans_used
from foodie_fi.subscriptions as sub
    join foodie_fi.plans as pln on pln.plan_id = sub.plan_id
where
    pln.plan_id <> 0