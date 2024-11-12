{%- macro clean_column_name(column) -%}

    {#- 
    to clean up column names of special characters 
    end goal is for a column name that can be used without the need for quotes "coding-friendly"
    -#}

    {#- annoying characters -#}
    {%- set column = column 
        | replace(' ', '_') 
        | replace('-', '_') 
        | replace('(', '_')
        | replace(')', '_')
        | replace(',', '_')
        | replace('?', '_')
        | replace('!', '_')
        | replace('.', '_')
    -%}

    {#- silly characters -#}
    {% set column = column 
        | replace('é', 'e')
        | replace('&', 'and')
        | replace('ø', 'o')
    %}

    {#- swap for words -#}
    {%- set column = column 
        | replace('$', 'usd')
        | replace('£', 'gbp')
        | replace('€', 'eur')
        | replace('%', 'percent')
    -%}

    {#- restricted sql words -#}
    {%- set column = column 
        | replace('Select', 'Select_')
        | replace('Values', 'Values_')
    -%}

    {# dbt trying to get their product name all over our datasets #}
    {% if column == 'DBT_VALID_FROM' %}
        {% set column = 'VALID_FROM' %}
    {% elif column == 'DBT_VALID_TO' %}
        {% set column = 'VALID_TO' %}
    {% endif %}

    {#- the thing we are trying to output! -#}
    {{ column }}

{%- endmacro -%}


{%- macro standardise(object) -%}
    
    {#- 
    iterate through the columns of a table and 
    return sql with the columns having nice names instead 
    -#}

    {# get all the columns on the existing table #}
    {%- set all_columns = dbt_utils.get_filtered_columns_in_relation(from=object)-%}
    
    {# simple select statement renaming #}
    select 

        {% for col in all_columns %}
            {%- if not loop.first -%} , {%- endif -%} 
            "{{col}}" as {{clean_column_name(col)}} 
        {% endfor %}

    from {{ object }}

{%- endmacro -%}