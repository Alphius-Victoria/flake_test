{{
    config(
        tags=['staging', 'jin']
    )
}}

-- Create contact table from the 'jin' schema and 'contacts' seed table
{{ generate_stg_table('jin', 'contacts') }}