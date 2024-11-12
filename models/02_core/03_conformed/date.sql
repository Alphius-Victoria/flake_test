{{ 
    config(
        tags=["date"],
        materialization="table"
    )
}}

-- Declaring the start date and end data
{% set start_date = '2019-02-12' %}           -- Start date(yyyy-mm-dd)
{% set end_date = '2024-08-15' %}             -- End date(yyyy-mm-dd)

WITH 
   
-- Logical CTE(s) for looping over the start and end date range
date_range AS (

    SELECT DATE '{{ start_date }}' AS date

    UNION ALL

    SELECT date + INTERVAL '1 DAY' FROM date_range

    WHERE 
        date < DATE '{{ end_date }}'
 
),

-- Logical CTE(s) for calculating date metrics
date_metrics AS (

    SELECT

        CAST(CONCAT(YEAR(date), 
            RIGHT('0' || MONTH(date), 2), 
            RIGHT('0' || DAY(date), 2)
            ) AS INT)                                                                                               AS date_key
        
        , date
        , DAYNAME(date)                                                                                             AS day_name
        , CASE WHEN DAYOFWEEK(date) = 0 THEN 7 ELSE DAYOFWEEK(date) END                                             AS day_of_week
        , DAYOFMONTH(date)                                                                                          AS day_of_month
        , DATEDIFF('day', DATE_TRUNC('quarter', date), date) + 1                                                    AS day_of_quarter
        , DAYOFYEAR(date)                                                                                           AS day_of_year
       
        , CEIL((DAY(date) + EXTRACT(DAYOFWEEK FROM DATE_TRUNC('MONTH', date)) - 1)/ 7.0)                            AS week_of_month
        , FLOOR(day_of_quarter / 7) + 1                                                                             AS week_of_quarter
        , WEEKOFYEAR(date)                                                                                          AS week_of_year

        , CAST(MONTH(date) AS INT)                                                                                  AS month_of_year
        , MONTHNAME(date)                                                                                           AS month_name        
        , QUARTER(date)                                                                                             AS quarter
        , YEAR(date)                                                                                                AS year

        , CASE WHEN DAYOFWEEK(date) IN (0, 6) THEN 'TRUE' ELSE 'FALSE' END                                          AS is_weekend
        , CASE WHEN DAYOFWEEK(date) NOT IN (0, 6) THEN 'TRUE' ELSE 'FALSE' END                                      AS is_weekday

        , CASE WHEN DAY(date) = 1 THEN 'TRUE' ELSE 'FALSE' END                                                      AS is_first_day_of_month
        , CASE WHEN date = LAST_DAY(date) THEN 'TRUE' ELSE 'FALSE' END                                              AS is_month_end

        , CASE 
            WHEN DAY(date) = 1 AND MONTH(date) IN (1, 4, 7, 10)
                THEN 'TRUE'
            ELSE 'FALSE'
          END                                                                                                       AS is_first_day_of_quarter

        , CASE
            WHEN date = DATEADD('DAY', -1, DATEADD('MONTH', 3, DATE_TRUNC('QUARTER', date)))
                THEN 'TRUE'
            ELSE 'FALSE'
          END                                                                                                       AS is_last_day_of_quarter

        , CASE WHEN DAYOFYEAR(date) = 1 THEN 'TRUE' ELSE 'FALSE' END                                                AS is_first_day_of_year
        , CASE 
            WHEN date = DATE_TRUNC('YEAR', date) + INTERVAL '1 YEAR' - INTERVAL '1 DAY'
                THEN 'TRUE'
            ELSE 'FALSE'
          END                                                                                                       AS is_year_end

        , CASE
            WHEN MOD(YEAR(date), 4) = 0 AND (
                  MOD(YEAR(date), 100) != 0 OR MOD(YEAR(date), 400) = 0)
                THEN 'TRUE'
            ELSE 'FALSE'
          END                                                                                                       AS is_leap_year



        , CASE WHEN date = CURRENT_DATE THEN 'TRUE' ELSE 'FALSE' END                                                AS current_day_flag
        , CASE WHEN date = CURRENT_DATE - INTERVAL '1 DAY' THEN 'TRUE' ELSE 'FALSE' END                             AS previous_day_flag
        , CASE WHEN date = CURRENT_DATE + INTERVAL '1 DAY' THEN 'TRUE' ELSE 'FALSE' END                             AS next_day_flag   

        , CASE
            WHEN WEEK(date) = WEEK(CURRENT_DATE) AND 
                YEAR(date) = YEAR(CURRENT_DATE) 
                THEN 'TRUE'
            ELSE 'FALSE'
          END                                                                                                       AS current_week_flag

        , CASE
            WHEN WEEK(date) = WEEK(DATEADD('WEEK', -1, CURRENT_DATE)) AND
                YEAR(date) = YEAR(DATEADD('WEEK', -1, CURRENT_DATE))
                THEN 'TRUE'
            ELSE 'FALSE'
          END                                                                                                       AS previous_week_flag                                                                                                  

        , CASE
            WHEN WEEK(date) = WEEK(DATEADD('WEEK', 1, CURRENT_DATE)) AND
                YEAR(date) = YEAR(DATEADD('WEEK', 1, CURRENT_DATE))
                THEN 'TRUE'
            ELSE 'FALSE'
          END                                                                                                       AS next_week_flag                                                                                                       

       , CASE
            WHEN MONTH(date) = MONTH(CURRENT_DATE) AND YEAR(date) = YEAR(CURRENT_DATE)
                THEN 'TRUE'
            ELSE 'FALSE'
          END                                                                                                       AS current_month_flag
        
        , CASE
            WHEN MONTH(date) = MONTH(DATEADD('MONTH', -1, CURRENT_DATE)) AND YEAR(date) = YEAR(CURRENT_DATE)
                THEN 'TRUE'
            ELSE 'FALSE'                                                                                         
          END                                                                                                       AS previous_month_flag

        , CASE
            WHEN MONTH(date) = MONTH(DATEADD('MONTH', 1, CURRENT_DATE)) AND YEAR(date) = YEAR(CURRENT_DATE)
                THEN 'TRUE'
            ELSE 'FALSE'                                                                                          
          END                                                                                                       AS next_month_flag

        , CASE
            WHEN EXTRACT(QUARTER FROM date) = EXTRACT(QUARTER FROM CURRENT_DATE) AND
                EXTRACT(YEAR FROM date) = EXTRACT(YEAR FROM CURRENT_DATE)
                THEN 'TRUE'
            ELSE 'FALSE'
          END                                                                                                       AS current_quarter_flag

        , CASE
            WHEN EXTRACT(QUARTER FROM date) = EXTRACT(QUARTER FROM DATEADD(QUARTER, -1, CURRENT_DATE)) AND
                EXTRACT(YEAR FROM date) = EXTRACT(YEAR FROM DATEADD(QUARTER, -1, CURRENT_DATE))
                THEN 'TRUE'
             ELSE 'FALSE'
          END                                                                                                       AS previous_quarter_flag

        , CASE
            WHEN EXTRACT(QUARTER FROM date) = EXTRACT(QUARTER FROM DATEADD(QUARTER, 1, CURRENT_DATE)) AND
                EXTRACT(YEAR FROM date) = EXTRACT(YEAR FROM DATEADD(QUARTER, 1, CURRENT_DATE))
                THEN 'TRUE'
            ELSE 'FALSE'
          END                                                                                                       AS next_quarter_flag 

        , CASE WHEN YEAR(date) = YEAR(CURRENT_DATE) THEN 'TRUE' ELSE 'FALSE' END                                    AS current_year_flag 
        , CASE WHEN YEAR(date) < YEAR(CURRENT_DATE) THEN 'TRUE' ELSE 'FALSE' END                                    AS previous_year_flag
        , CASE WHEN YEAR(date) > YEAR(CURRENT_DATE) THEN 'TRUE' ELSE 'FALSE' END                                    AS next_year_flag

        , CASE 
            WHEN date BETWEEN DATE_TRUNC(week, DATE(GETDATE())) AND DATE(GETDATE())
                THEN TRUE
            ELSE FALSE
            END                                                                                                     AS week_to_date_flag  

        , CASE 
            WHEN date BETWEEN DATE(CONCAT(YEAR(GETDATE()), '-', MONTH(GETDATE()), '-01')) AND DATE(GETDATE())
                THEN TRUE
            ELSE FALSE
            END                                                                                                     AS month_to_date_flag

        , CASE 
            WHEN date BETWEEN DATE(CONCAT(YEAR(GETDATE()), '-01-01')) AND DATE(GETDATE())
                THEN TRUE
            ELSE FALSE
            END                                                                                                     AS year_to_date_flag

        , CASE 
            WHEN holiday_date IS NOT NULL 
                THEN TRUE
            ELSE FALSE                                                                          
            END                                                                                                     AS is_uk_bank_holiday

        , CASE 
            WHEN is_uk_bank_holiday = FALSE AND is_weekday = TRUE
                THEN TRUE
            ELSE FALSE
            END                                                                                                     AS is_business_day
        , DAY(LAST_DAY(date, 'month'))                                                                              AS days_in_month
        , DATEDIFF('day', DATE_TRUNC('quarter', date), DATEADD('quarter', 1, DATE_TRUNC('quarter', date)))          AS days_in_quarter
        , DATEDIFF('day', DATE_TRUNC('year', date), DATEADD('year', 1, DATE_TRUNC('year', date)))                   AS days_in_year
        , DATEDIFF('day', date, LAST_DAY(date, 'month'))                                                            AS days_remaining_in_month
        , DATEDIFF('day', date, DATEADD('day', -1, DATEADD('quarter', 1, DATE_TRUNC('quarter', date))))             AS days_remaining_in_quarter
        , DATEDIFF('day', date, DATEADD('day', -1, DATEADD('year', 1, DATE_TRUNC('year', date))))                   AS days_remaining_in_year


        -------------------------------------------------------------------------------------------------------------
        -- you can add further logic below to calculate any other metrics
        --
        --
        --
        
        -------------------------------------------------------------------------------------------------------------
        

    FROM date_range dr

    LEFT JOIN {{ ref('uk_holidays') }} ukh
        ON dr.date = ukh.holiday_date

),

--Uncomment the comma near the end of the date_metrics CTE and the below piece of code to view only needed metrics
final AS(

    SELECT 

        -- Comment out the metrics that are not relevant to your use case
        date_key
        , date
        , day_name
        , day_of_week
        , day_of_month
        , day_of_quarter
        , day_of_year
        , week_of_month
        , week_of_quarter
        , week_of_year
        , month_of_year
        , month_name
        , quarter
        , year
        , is_weekend
        , is_weekday
        , is_first_day_of_month
        , is_month_end
        , is_first_day_of_quarter
        , is_last_day_of_quarter
        , is_first_day_of_year
        , is_year_end
        , is_leap_year
        , current_day_flag
        , previous_day_flag
        , next_day_flag
        , current_week_flag
        , previous_week_flag
        , next_week_flag
        , current_month_flag
        , previous_month_flag
        , next_month_flag
        , current_quarter_flag
        , previous_quarter_flag
        , next_quarter_flag
        , current_year_flag 
        , previous_year_flag
        , next_year_flag
        , week_to_date_flag
        , month_to_date_flag
        , year_to_date_flag
        , is_uk_bank_holiday
        , is_business_day
        , days_in_month
        , days_in_quarter
        , days_in_year
        , days_remaining_in_month
        , days_remaining_in_quarter
        , days_remaining_in_year
    
    FROM date_metrics

)

SELECT * FROM final