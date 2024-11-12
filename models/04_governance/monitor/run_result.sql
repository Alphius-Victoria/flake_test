{{
    config(
        materialized = 'incremental'
        , unique_key = 'result_id'
        , post_hook = "DELETE FROM {{ this }} WHERE created_at < {{ get_rolling_start_date(var('run_result')['rolling_back_period']) }}"
    )
}}

WITH

-- define the table structure with all columns set to NULL
create_table_struct AS (

    SELECT

        NULL                                AS result_id
        , NULL                              AS invocation_id
        , NULL                              AS unique_id
        , NULL                              AS database_name
        , NULL                              AS schema_name
        , NULL                              AS name
        , NULL                              AS resource_type
        , NULL                              AS status
        , CAST(NULL AS FLOAT)               AS execution_time
        , CAST(NULL AS INT)                 AS rows_affected
        , CAST(NULL AS TIMESTAMP_NTZ)      AS created_at
)

SELECT * FROM create_table_struct
WHERE 
    1 = 0    --- This is a filter so we will never actually insert these values

-- Handle incremental logic for new data
{% if is_incremental() %}
    AND created_at > (SELECT MAX(created_at) FROM {{ this }})
{% endif %}