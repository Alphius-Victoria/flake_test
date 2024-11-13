{{
    config(
        materialized = 'incremental'
        , post_hook = "DELETE FROM {{ this }} WHERE freshness_checked_at < {{ get_rolling_start_date(var('source_freshness')['rolling_back_period']) }}"

    )
}}

{% set first_node = [] %}

    
WITH 

required_fields AS (

    -- loop through the graph
    {% for node in graph.sources.values() %}
 
        -- filter out the nodes without loaded_at_field
        {% if node['loaded_at_field'] != none %}

            -- filter out the nodes without freshness block
            {% if node['freshness'] != none %}

                -- append union all except for the first node
                {% if (first_node | length > 0) %} 
                    UNION ALL 
                {% endif %}   

                {%- do first_node.append(1) -%}

                {% set warn_count = node['freshness']['warn_after']['count'] if node['freshness']['warn_after']['count'] != None else 0 %}
                {% set error_count = node['freshness']['error_after']['count'] if node['freshness']['error_after']['count'] != None else 0 %}

                SELECT
     
                    '{{ node["unique_id"] }}'                                                                                                           AS source_freshness_id
                    , '{{ node["loader"] }}'                                                                                                            AS data_loader
                    , '{{ node["database"] }}'                                                                                                          AS database_name
                    , '{{ node["schema"] }}'                                                                                                            AS schema_name
                    , '{{ node["name"] }}'                                                                                                              AS table_name
                    , '{{ node["loaded_at_field"] }}'                                                                                                   AS column_name
          
                    -- select the recent timestamp when data loaded from source
                    , MAX({{ node["loaded_at_field"] }})                                                                                                AS max_data_loaded_at
          
                    , {{warn_count }}                                                                                                                   AS warn_after_count
                    , '{{ (node["freshness"]["warn_after"]["period"] | lower) if node["freshness"]["warn_after"]["period"] != None else 'NULL' }}'      AS warn_after_period
                    , {{error_count }}                                                                                                                  AS error_after_count
                    , '{{ (node["freshness"]["error_after"]["period"] | lower) if node["freshness"]["error_after"]["period"] != None else 'NULL'}}'     AS error_after_period
          
                    -- convert warn after count to minutes from days/hours
                    , CASE 
                        WHEN '{{ node["freshness"]["warn_after"]["period"] | lower }}' = 'day' 
                            THEN {{ warn_count }} * 1440
                        WHEN '{{ node["freshness"]["warn_after"]["period"] | lower }}' = 'hour' 
                            THEN {{ warn_count }} * 60
                        ELSE {{ warn_count }}
                    END                                                                                                                                 AS warn_after_minutes         
                    
                    -- convert error after count to minutes from days/hours
                    , CASE 
                        WHEN '{{ node["freshness"]["error_after"]["period"] | lower }}' = 'day'
                            THEN {{ error_count }} * 1440
                        WHEN '{{ node["freshness"]["error_after"]["period"] | lower }}' = 'hour' 
                            THEN {{ error_count }} * 60
                        ELSE {{ error_count }}
                    END                                                                                                                       AS error_after_minutes
                   
                    -- calculate the time difference (in minutes) of data since last loaded from source
                    , ABS(TIMESTAMPDIFF(MINUTE, CURRENT_TIMESTAMP,max_data_loaded_at ))                                                       AS minutes_difference

                FROM {{ node["relation_name"] }}

           {% endif %}
       {% endif %}
    {% endfor %}

),

final AS (

    SELECT 

        *

        -- set the freshness status by comparing time difference and acceptance level specified in freshness block
        , CASE 
            WHEN warn_after_minutes > 0 AND error_after_minutes > 0 
                THEN
                    CASE
                        WHEN minutes_difference < warn_after_minutes  
                            THEN 'Pass'
                        WHEN minutes_difference > error_after_minutes 
                            THEN 'Error'
                        ELSE 'Warn'
                    END   

            WHEN error_after_minutes = 0 
                THEN
                    CASE
                        WHEN minutes_difference > warn_after_minutes 
                            THEN 'Warn'
                        ELSE 'Pass'
                    END

            WHEN warn_after_minutes = 0 
                THEN
                    CASE
                        WHEN minutes_difference > error_after_minutes 
                            THEN 'Error'
                        ELSE 'Pass'
                    END
        END                                                                    AS status

        , CURRENT_TIMESTAMP()                                                  AS freshness_checked_at

    FROM required_fields
    WHERE 
        warn_after_count != 0 OR error_after_count != 0

)

SELECT * FROM final

-- Handle incremental logic for new source freshness data
{% if is_incremental() %}
    WHERE 
        freshness_checked_at > (SELECT MAX(freshness_checked_at) FROM {{ this }})
{% endif %}
