{{
    config(
        tags=['staging', 'hubspot']
    )
}}

-- Create project table from the 'hubspot' schema and 'projects' seed table
{{ generate_stg_table('hubspot', 'projects') }}