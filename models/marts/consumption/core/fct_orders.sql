{{
    config(
        materialized = 'table',
        tags=['finance'],
    )
}}

with orders as (
    
    select * from {{ ref('stg_tpch_orders') }} 

),
order_item as (
    
    select * from {{ ref('order_items') }}

),
order_item_summary as (

    select 
        order_key,
        sum(gross_item_sales_amount) as gross_item_sales_amount,
        sum(item_discount_amount) as item_discount_amount,
        sum(item_tax_amount) as item_tax_amount,
        sum(net_item_sales_amount) as net_item_sales_amount,
        count_if( return_flag = 'returned' ) as return_count
    from order_item
    group by
        1
),
final as (

    select 

        orders.order_key, 
        orders.order_date,
        orders.customer_key,
        -- uncomment here and the join below to demonstrate pulling the region into the fct_orders model
        --dim_customers.region,
        orders.status_code,
        orders.priority_code,
        orders.clerk_name,
        orders.ship_priority,     
        1 as order_count,
        order_item_summary.return_count,             
        order_item_summary.gross_item_sales_amount,
        order_item_summary.item_discount_amount,
        order_item_summary.item_tax_amount,
        order_item_summary.net_item_sales_amount
    from
        orders
        inner join order_item_summary
            on orders.order_key = order_item_summary.order_key
        -- add ref() statement and uncomment the line below
        --inner join dim_customers as dim_customers
        --     on orders.customer_key = dim_customers.customer_key
)
select 
    *
from
    final

order by
    order_date