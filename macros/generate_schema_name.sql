{#- Use the custom schema name as-is (raw, staging, core, finance) instead of
    dbt's default "<target>_<custom>" prefixing. -#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {{ custom_schema_name | trim if custom_schema_name else target.schema }}
{%- endmacro %}
