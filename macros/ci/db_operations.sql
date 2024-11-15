-- Macro is used for cloning the prod databases into ci databases
{% macro ci_clone_db() %}

    {% for prod_database in var('ci')['prod_databases'] %}

        {% set upper_prod_database = prod_database | upper %}
        {% set upper_ci_database = (prod_database | upper).replace('PROD', 'CI') %}

        {% set sql = 'CREATE OR REPLACE DATABASE '+ upper_ci_database +' CLONE '+ upper_prod_database +';' %}

        {% do run_query(sql) %}
 
        {{ log("Created Cloned Database from "+ upper_prod_database, info=True) }}

    {% endfor %}

{% endmacro %}

-- Macro is used for droping the ci databases
{% macro ci_drop_db() %}

    {% for prod_database in var('ci')['prod_databases'] %}

        {% set upper_ci_database = (prod_database | upper).replace('PROD', 'CI') %}

        {% set sql = 'DROP DATABASE IF EXISTS '+ upper_ci_database +';' %}

        {% do run_query(sql) %}

        {{ log("Dropping Cloned Database from "+upper_ci_database, info=True) }}

    {% endfor %}

{% endmacro %}

-- Macro is used for providing view access to the role
{% macro grant_view_access() %}

    {% for prod_database in var('ci')['prod_databases'] %}

        {% set upper_ci_database = (prod_database | upper).replace('PROD', 'CI') %}

        {% for ci_read_access in var('ci')['read_access'] %}

            {% set sql = "GRANT USAGE ON DATABASE IDENTIFIER('"+ upper_ci_database +"') TO ROLE IDENTIFIER('"+ ci_read_access +"');" %}

            {% do run_query(sql) %}

            {% set sql = 'GRANT USAGE ON ALL SCHEMAS IN DATABASE '+ upper_ci_database +' TO ROLE '+ ci_read_access +';
                        GRANT SELECT, REFERENCES ON ALL TABLES IN DATABASE '+ upper_ci_database +' TO ROLE '+ ci_read_access +';
                        GRANT SELECT, REFERENCES ON ALL VIEWS IN DATABASE '+ upper_ci_database +' TO ROLE '+ ci_read_access +';
                        GRANT SELECT, REFERENCES ON ALL MATERIALIZED VIEWS IN DATABASE '+ upper_ci_database +' TO ROLE '+ ci_read_access +';
                        GRANT USAGE ON ALL FUNCTIONS IN DATABASE '+ upper_ci_database +' TO ROLE '+ ci_read_access +';
                        GRANT USAGE ON ALL PROCEDURES IN DATABASE '+ upper_ci_database +' TO ROLE '+ ci_read_access +';
                        GRANT USAGE ON ALL STAGES IN DATABASE '+ upper_ci_database +' TO ROLE '+ ci_read_access +';' %}

            {% do run_query(sql) %}

        {% endfor %}

    {% endfor %}

{% endmacro %}
