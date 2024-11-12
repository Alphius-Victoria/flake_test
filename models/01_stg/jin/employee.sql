{{
    config(
        tags=['staging', 'jin']
    )
}}

-- Create employee table from the 'jin' schema and 'employees' seed table
{{ generate_stg_table('jin', 'employees') }}