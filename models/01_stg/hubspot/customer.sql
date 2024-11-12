{{
    config(
        tags=['staging', 'hubspot']
    )
}}

-- Create customer table from the 'hubspot' schema and 'customers' seed table
{{ generate_stg_table('hubspot', 'customers') }}