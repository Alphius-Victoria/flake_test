-- Create schema if not exists
{%- macro create_new_schema(db_name, schema_name) -%}

    CREATE SCHEMA IF NOT EXISTS {{ db_name }}.{{ schema_name }}

{%- endmacro -%}

{% macro get_required_columns(source_file, source_name, table_name) -%}

    {% set sql_statement %}
    
        SELECT 

            table_name
            , column_name
            , column_name_with_data_type

        FROM {{ ref(source_file) }}
        WHERE 
            UPPER(source_name) = '{{ source_name.upper() }}'
            AND UPPER(table_name) = '{{ table_name.upper() }}'
            
    {% endset %}

    {% set results = run_query(sql_statement) %}

    {% if execute %}
        {% do return(results) %}
    {% endif %}
    
{% endmacro %}