{#- Whole days from start_date to end_date. Kept as a macro so the
    warehouse can move from DuckDB to Snowflake/Postgres by changing one place. -#}
{% macro days_between(start_date, end_date) -%}
    {{ return(adapter.dispatch('days_between')(start_date, end_date)) }}
{%- endmacro %}

{% macro default__days_between(start_date, end_date) -%}
    datediff('day', {{ start_date }}, {{ end_date }})
{%- endmacro %}

{% macro postgres__days_between(start_date, end_date) -%}
    ({{ end_date }}::date - {{ start_date }}::date)
{%- endmacro %}
