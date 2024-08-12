SELECT Count(*) as total_orders from pizza_runner.customer_orders;

SELECT customer_id, count(*) as uniqueOrders
from pizza_runner.customer_orders as co
group by
    customer_id;

SELECT count(*) as count
from pizza_runner.runner_orders as ro
where
    cancellation not like '%cancellation';

Select runner_id, count(*) as not_cancelled
from (
        SELECT
            order_id, runner_id, pickup_time, distance, duration, ISNULL(cancellation, 'NO') as cancellation
        from pizza_runner.runner_orders as ro
    ) as sq
where
    cancellation not like '%cancellation'
group by
    runner_id;

Select count(*) as pizzz_count, pn.pizza_name, co.customer_id
from pizza_runner.customer_orders as co
    join pizza_runner.pizza_names as pn on co.pizza_id = pn.pizza_id
group by
    co.customer_id,
    pn.pizza_name;

select max(order_count) as max_delivered
from (
        select count(*) as order_count, order_time
        from pizza_runner.customer_orders
        group by
            order_time
    ) as oc;

select *
from pizza_runner.customer_orders as co
where
    exclusions in ('', NULL, 'null')
    and extras in ('', NULL, 'null');

select
    count(*) as orders_per_day,
    DATEPART (WEEK, order_time) as week,
    DATEPART (DAY, order_time) as day
from pizza_runner.customer_orders
group by
    DATEPART (WEEK, order_time),
    DATEPART (DAY, order_time);

select count(*) as joined, DATEPART (WEEK, registration_date) as week
from pizza_runner.runners
group by
    DATEPART (WEEK, registration_date);

select runner_id, AVG(
        CONVERT(
            INT, SUBSTRING(duration, 1, 2)
        )
    ) as avg_minutes
from pizza_runner.runner_orders
group by
    runner_id;

select * from pizza_runner.runner_orders;

select cus.customer_id, AVG(
        CONVERT(
            float,
            REPLACE (ro.distance, 'km', '')
        )
    ) as dist
from pizza_runner.runner_orders as ro
    join pizza_runner.customer_orders as cus on ro.order_id = cus.order_id
group by
    cus.customer_id;

select (max(duration) - min(duration)) as diff
from (
        select CONVERT(
                int, SUBSTRING(duration, 1, 2)
            ) as duration
        from pizza_runner.runner_orders
    ) as sr;

select (
        select CONVERT(
                float,
                replace (distance, 'km', '')
            ) as dist, convert(
                int, SUBSTRING(duration, 1, 2)
            ) as dur
        from pizza_runner.runner_orders
    );

with
    cte_pizza_topping as (
        select pizza_id, value as topping
        from pizza_runner.pizza_recipes cross apply string_split (toppings, ',')
    )

select topping, count(1)
from cte_pizza_topping
group by
    topping
having
    count(1) = (
        Select count(distinct (pizza_id))
        from pizza_runner.pizza_recipes
    )