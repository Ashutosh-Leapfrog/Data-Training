select SUM(men.price) as total_spent, mem.customer_id as customer
from dannys_diner.menu as men
    join dannys_diner.sales as mem on mem.product_id = men.product_id
group by
    mem.customer_id;

select count(*) as visited, sal.customer_id as customer
from dannys_diner.sales as sal
group by
    sal.customer_id;

select rt.customer_id, prod.product_name
from (
        select product_id, customer_id, row_number() over (
                partition by
                    customer_id
                order by order_date
            ) as rank
        from dannys_diner.sales
    ) as rt
    join dannys_diner.menu as prod on prod.product_id = rt.product_id
where
    rank = 1;

select top 1 *
from (
        select product_id, count(*) as prod_count
        from dannys_diner.sales
        group by
            product_id
    ) as pc order by prod_count desc;



with ranks as (select
    customer_id,
    product_id,
    count(*) as prod_count
from dannys_diner.sales
group by
    product_id,
    customer_id)
,
orderrank as (select customer_id, product_id, prod_count, rank() over(partition by customer_id order by prod_count desc) as rank
from
ranks)

select customer_id, product_id from orderrank where rank = 1



select rt.customer_id, prod.product_name
from (
        select
            product_id, sa.customer_id, cus.join_date, order_date, row_number() over (
                partition by
                    sa.customer_id
                order by order_date
            ) as rank
        from dannys_diner.sales as sa
            join dannys_diner.members as cus on cus.customer_id = sa.customer_id
    ) as rt
    join dannys_diner.menu as prod on prod.product_id = rt.product_id
where
    rank = 1;



select
    product_id,
    sa.customer_id,
    cus.join_date,
    order_date,
    row_number() over (
        partition by
            sa.customer_id
        order by order_date
    ) as rank
from dannys_diner.sales as sa
    left join dannys_diner.members as cus on cus.customer_id = sa.customer_id;

select customer_id, product_id
from (
        select
            product_id, sa.customer_id, cus.join_date, order_date, row_number() over (
                partition by
                    sa.customer_id
                order by order_date
            ) as rank
        from dannys_diner.sales as sa
            left join dannys_diner.members as cus on cus.customer_id = sa.customer_id
        where
            order_date > cus.join_date
    ) as tab
where
    rank = 1

union all
select customer_id, product_id
from (
        select
            product_id, sa.customer_id, cus.join_date, order_date, row_number() over (
                partition by
                    sa.customer_id
                order by order_date desc
            ) as rank
        from dannys_diner.sales as sa
            left join dannys_diner.members as cus on cus.customer_id = sa.customer_id
        where
            order_date < cus.join_date
    ) as tab
where
    rank = 1;


select SUM(men.price) as total_spent, sal.customer_id as customer, mem.join_date as join_date
from dannys_diner.menu as men
    join dannys_diner.sales as sal on sal.product_id = men.product_id
	join dannys_diner.members as mem on mem.customer_id = sal.customer_id
	where sal.order_date < mem.join_date
group by
    sal.customer_id,mem.join_date;

Select sum(points) as total_points, sal.customer_id from (select men.product_id, points = CASE men.product_name
	WHEN 'sushi' THEN men.price * 20
	ELSE men.price * 10
	END
from dannys_diner.menu as men) as points join dannys_diner.sales as sal on points.product_id = sal.product_id 
group by sal.customer_id;

DECLARE @points INT;
SET @points = 10;
Select sum(points) as total_points, customer_id as customer_id from (select men.product_id,sal.customer_id,order_date, points = CASE 
	WHEN DATEDIFF(DAY,sal.order_date,DateADD(DAY,7,mem.join_date)) = 7 THEN men.price * 2 * @points
	WHEN men.product_name = 'sushi' THEN men.price * 2 * @points
	ELSE men.price * @points
	END
from dannys_diner.menu as men
join dannys_diner.sales as sal on men.product_id = sal.product_id 
join dannys_diner.members as mem on mem.customer_id = sal.customer_id
) as points where order_date < '2021-01-31' group by customer_id;