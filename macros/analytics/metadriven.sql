{% macro generate_stg_table(source_name, table_name) -%}
    
    WITH

    --CTE for data type converstion and take required columns
    final AS (

        {% set source_columns = get_required_columns('object_definition', source_name, table_name) %}

        SELECT

            {% for source_column in source_columns %}
                {{ source_column[2] }}      AS {{ source_column[1] }}
                {%- if not loop.last -%} , {%- endif -%}
            {% endfor %}

        FROM {{ source(source_name.upper(), table_name.upper()) }} 
         
    )

    SELECT * FROM final

{%- endmacro -%}