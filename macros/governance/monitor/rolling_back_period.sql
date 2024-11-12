-- Macro to return a date that is a specified number of days before the current timestamp
{% macro get_rolling_start_date(rolling_back_period) %}

    {{ dateadd('day', - rolling_back_period,  current_timestamp()) }}

{% endmacro %}