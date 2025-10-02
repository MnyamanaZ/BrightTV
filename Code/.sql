SELECT 
    U.UserID,
    U.Gender,
    U.Race,
    U.Age,
    U.Province,
    V.UserID,
    V.Channel2,
    V.RecordDate2,
    V.`Duration 2`
FROM workspace.default.user_profile AS U
LEFT JOIN workspace.default.viewership AS V
    ON U.UserID = V.UserID;

   SELECT 
    COUNT(*) AS users,
    Gender,
    Race,
    Province,
    Channel2 AS channel,

    -- DATE/TIME
    CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm')) AS recorddatesa,
    date_format(CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm')), 'MMMM') AS month_name,
    month(CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm'))) AS month_id,
    year(CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm'))) AS year_val,  
    date_format(CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm')), 'EE') AS day_name,
    dayofweek(CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm'))) AS day_id,
    hour(CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm'))) AS hour_of_day,
    date_format(Duration2, 'HH:mm:ss') AS total_duration,

    --- CASE Statements
    CASE
        WHEN Age BETWEEN 0 AND 12 THEN '0-12 Kids'
        WHEN Age BETWEEN 13 AND 19 THEN '13-19 Teens'
        WHEN Age BETWEEN 20 AND 34 THEN '20-34 Young Adults'
        WHEN Age BETWEEN 35 AND 64 THEN '35-64 Adults'
        ELSE '65+ Senior'
    END AS age_group,

    -- Use FLOOR to ensure integer minute bucketing
    CASE 
        WHEN FLOOR(hour(Duration2) * 60 + minute(Duration2) + second(Duration2)/60) BETWEEN 0 AND 5 THEN '0-5 Browsing'
        WHEN FLOOR(hour(Duration2) * 60 + minute(Duration2) + second(Duration2)/60) BETWEEN 6 AND 10 THEN '6-10 Skimming'
        WHEN FLOOR(hour(Duration2) * 60 + minute(Duration2) + second(Duration2)/60) BETWEEN 11 AND 30 THEN '11-30 Casual'
        WHEN FLOOR(hour(Duration2) * 60 + minute(Duration2) + second(Duration2)/60) BETWEEN 31 AND 60 THEN '31-60 Engaged'
        WHEN FLOOR(hour(Duration2) * 60 + minute(Duration2) + second(Duration2)/60) BETWEEN 61 AND 120 THEN '61-120 Committed'
        ELSE '121-240 Binge'
    END AS duration_bucket

FROM workspace.default.final_joined_table

GROUP BY
    Gender,
    Race,
    Province,
    Channel2,
    year(CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm'))), 
    CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm')),
    date_format(CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm')), 'MMMM'),
    month(CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm'))),
    date_format(CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm')), 'EE'),
    dayofweek(CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm'))),
    hour(CONVERT_TIMEZONE('UTC','Africa/Johannesburg', to_timestamp(RecordDate2, 'M/d/yyyy H:mm'))),
    date_format(Duration2, 'HH:mm:ss'),

    CASE
        WHEN Age BETWEEN 0 AND 12 THEN '0-12 Kids'
        WHEN Age BETWEEN 13 AND 19 THEN '13-19 Teens'
        WHEN Age BETWEEN 20 AND 34 THEN '20-34 Young Adults'
        WHEN Age BETWEEN 35 AND 64 THEN '35-64 Adults'
        ELSE '65+ Senior'
    END,

    CASE 
        WHEN FLOOR(hour(Duration2) * 60 + minute(Duration2) + second(Duration2)/60) BETWEEN 0 AND 5 THEN '0-5 Browsing'
        WHEN FLOOR(hour(Duration2) * 60 + minute(Duration2) + second(Duration2)/60) BETWEEN 6 AND 10 THEN '6-10 Skimming'
        WHEN FLOOR(hour(Duration2) * 60 + minute(Duration2) + second(Duration2)/60) BETWEEN 11 AND 30 THEN '11-30 Casual'
        WHEN FLOOR(hour(Duration2) * 60 + minute(Duration2) + second(Duration2)/60) BETWEEN 31 AND 60 THEN '31-60 Engaged'
        WHEN FLOOR(hour(Duration2) * 60 + minute(Duration2) + second(Duration2)/60) BETWEEN 61 AND 120 THEN '61-120 Committed'
        ELSE '121-240 Binge'
    END

