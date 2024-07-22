--Calculate Total Revenue for Each Category:
select category, Sum(qty*price) as total_sales
from amz_sales
group by category
order by total_sales desc;

--Calculate Average Order Value per Month:
with avg_price as (
	select date_trunc('month', date) as order_month, sum(price * qty) as total_order_value 
	from amz_sales
	group by order_month
	order by order_month
)
select order_month, round(avg(total_order_value),2) as avg_order_value
from avg_price
group by order_month;
	
--Top 5 Best Selling Products by Quantity:
select category, sum(qty) as total_qty
from amz_sales
group by category
order by total_qty desc
limit 5;

--Identify Top 3 Shipping Cities by Total Revenue:
select ship_city, sum(price*qty) as total_revenue
from amz_sales
group by ship_city
order by total_revenue desc
limit 3;

--Each category's contribution to the total sales
select category, sum(price * qty) as category_sales,
    round(sum(price * qty) * 100.0 / (select sum(price * qty) from amz_sales),2) as contribution_percentage
from amz_sales
group by category
order by contribution_percentage desc;

--Percentage of orders made using each payment mode.
select payment_mode,
     round(count(order_id) * 100.0 / (select count(*) from amz_sales),2) as order_percentage
from amz_sales
group by payment_mode;

--Percentage of Orders by Month that are Over avg order value.
with monthly_order_avg as (
    select date_trunc('month', date) AS order_month, AVG(price) AS avg_order_value
    from amz_sales
    group by order_month
),
orders_with_avg_comparison as (
    select date_trunc('month', o.date) AS order_month, o.order_id, o.price, m.avg_order_value
    from amz_sales o
    join monthly_order_avg m on date_trunc('month', o.date) = m.order_month
)
select to_char(order_month, 'YYYY-MM') as month, count(*) as total_orders,
    round(100.0 * sum(case when price > avg_order_value then 1 else 0 end) / count(*), 2) as percentage_over_avg
from orders_with_avg_comparison
group by order_month
order by order_month;

--Busiest Days in Terms of Orders (Top 3):
select date_trunc('day', date) as order_day, count(*) as order_count
from amz_sales
group by order_day
order by order_count desc
limit 3;

--Monthly Revenue Growth Rate:
with monthly_revenue as (
    select date_trunc('month', date) as order_month, sum(price) as total_revenue   
    from amz_sales
    group by order_month
)
select to_char(order_month, 'YYYY-MM') as month, total_revenue, 
    ROUND(100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month)) / LAG(total_revenue) OVER (ORDER BY order_month),2) AS growth_rate_percentage
from monthly_revenue
order by order_month;

--Top 20 average Order Value by Customer Location (City):
with avg_price_citywise as (
    select ship_city, DATE_TRUNC('month', date) AS order_month,
		sum(price * qty) as total_order_value    
    from amz_sales
    group by ship_city, order_month
)
select ship_city, order_month, round(avg(total_order_value), 2) as avg_order_value
from avg_price_citywise
group by ship_city, order_month 
order by avg_order_value desc 
limit 20;







