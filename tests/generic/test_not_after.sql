{#- Fails rows where column_name is later than other_column (e.g. service after submission). -#}
{% test not_after(model, column_name, other_column) %}
select *
from {{ model }}
where {{ column_name }} > {{ other_column }}
{% endtest %}
