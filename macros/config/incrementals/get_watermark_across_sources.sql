{% macro get_watermark_across_upstream_data(upstream_refs=[]) %}
   
   {% if execute %}
   {% set dates = [] %}
   {% for ur in upstream_refs %}
      
      {% set sql %}
         select max(_the_date) from {{ ur }};
      {% endset %}

      {% set results = run_query(sql) %}
      {% set max_date = results.columns[0].values()[0] %}

      {{ log(max_date, info=true) }}
      {% do dates.append(max_date) %}

   {% endfor %}
   
   {% set watermark = (dates|sort)[0] %}

   {{ return(watermark) }}

   {% endif %}

{% endmacro %}