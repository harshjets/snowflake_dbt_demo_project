{{
    config(
        materialized='incremental',
        unique_key='_the_date',
        incremental_strategy='delete+insert'
    )
}}

{% set dates = get_watermark_across_upstream_data(
    [
        ref('table_c'), 
        ref('table_b')
    ]
  )
%}

{% set watermark = (dates|sort)[:-1][0] %}


with from_c as (
   select * from {{ ref('table_c') }} where _the_date <= '{{watermark}}'
),

from_b as (
   select * from {{ ref('table_b') }} where _the_date <= '{{watermark}}'
)

-- this is just to illustrate the date selection on table_c, which contains data up through 2023-01-04
-- but here we only want to select through 2023-01-03, because table_b ends at that time.
select * from from_c

-- build out the rest of your incremental logic from here
