
--Viewership data cleaning
CREATE OR REPLACE TEMP VIEW viewership_clean AS
SELECT
  
  COALESCE(userID, userid) AS userid,
   Channel2 AS Channel,

   --DATE/TIME
  try_to_timestamp(recorddate2, 'M/d/yyyy H:mm') AS recorddate2_ts,
  TRY_TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss') AS duration2_ts,
  DATE_FORMAT(recorddate2_ts, 'HH:mm:ss') AS watch_time_start,
  date_format(duration2_ts, 'HH:mm:ss') AS total_duration,
  TO_DATE(recorddate2_ts)AS watch_date,
  DAYNAME(recorddate2_ts) AS day_name,
  dayofweek(recorddate2_ts) AS day_id,
  MONTHNAME(recorddate2_ts) AS month_name,
  MONTH(recorddate2_ts) AS month_id,
  HOUR(recorddate2_ts) AS hour_of_day,

    -- Convert duration to decimal hours
  HOUR(TRY_TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) 
    + MINUTE(TRY_TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) / 60.0 
    + SECOND(TRY_TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) / 3600.0 AS duration_decimal_hours
  
FROM default.Viewership;
--user profile data cleaning
CREATE OR REPLACE TEMP VIEW user_profile_clean AS
SELECT
  UserID AS userid,
  CASE 
    WHEN race IS NULL OR race IN ('None', 'other') THEN 'Other'
    ELSE race
  END AS race,
  CASE 
    WHEN gender IS NULL OR gender = 'None' THEN 'Other'
    ELSE gender
  END AS gender,
  CASE 
    WHEN province IS NULL OR province IN ('None') THEN 'Unknown'
    ELSE province
  END AS province,
  CASE
      WHEN age BETWEEN 0 AND 12 THEN '0-12 Kids'
      WHEN age BETWEEN 13 AND 19 THEN '13-19 Teens'
      WHEN age BETWEEN 20 AND 34 THEN '20-34 Young Adults'
      WHEN age BETWEEN 35 AND 64 THEN '35-64 Adults'
      WHEN age BETWEEN 65 AND 100 THEN '65+ Senior'
      ELSE '65+ Senior'
  END AS age_group
FROM default.user_profile;

--Left Join
CREATE OR REPLACE  TEMP VIEW combined_data AS
SELECT 
  v.userid, 
  v.channel, 
  v.recorddate2_ts,
  v.duration2_ts,
  v.total_duration,
  v.duration_decimal_hours,
  v.watch_time_start,
  v.watch_date, 
  v.day_name, 
  v.day_id,
  v.month_name,
  v.month_id,
  v.hour_of_day, 
  u.race,
  u.gender,
  u.province,
  u.age_group
FROM viewership_clean v
LEFT JOIN user_profile_clean u 
  ON v.userid = u.userid;

-- Aggregation (Demographics + Time & Duration Bucket
SELECT 
  COUNT(userid) AS users, 

  --Time of day
  CASE 
    WHEN hour_of_day BETWEEN 0 AND 5 THEN '0-5 Early Morning'
    WHEN hour_of_day BETWEEN 6 AND 11 THEN '6-11 Morning'
    WHEN hour_of_day BETWEEN 12 AND 17 THEN '12-17 Afternoon'
    WHEN hour_of_day BETWEEN 18 AND 21 THEN '18-21 Evening'
    ELSE 'Night'
  END AS time_of_day,

  --Duration buckets (in minutes)
  CASE 
    WHEN FLOOR(HOUR(duration2_ts)*60 + MINUTE(duration2_ts)) BETWEEN 0 AND 5 THEN '0-5 Browsing'
    WHEN FLOOR(HOUR(duration2_ts)*60 + MINUTE(duration2_ts)) BETWEEN 6 AND 10 THEN '6-10 Skimming'
    WHEN FLOOR(HOUR(duration2_ts)*60 + MINUTE(duration2_ts)) BETWEEN 11 AND 30 THEN '11-30 Casual'
    WHEN FLOOR(HOUR(duration2_ts)*60 + MINUTE(duration2_ts)) BETWEEN 31 AND 60 THEN '31-60 Engaged'
    WHEN FLOOR(HOUR(duration2_ts)*60 + MINUTE(duration2_ts)) BETWEEN 61 AND 120 THEN '61-120 Deep'
    ELSE '121-240 Binge'
  END AS duration_bucket,
  
--Groups
  channel,
  recorddate2_ts,
  watch_time_start,
  watch_date,
  total_duration,
  duration_decimal_hours,
  day_name,
  day_id,
  month_name,
  month_id,
  hour_of_day,
  race,
  gender,
  province,
  age_group

FROM combined_data
GROUP BY
  channel,
  recorddate2_ts,
  watch_time_start,
  watch_date,
  total_duration,
  duration_decimal_hours,
  day_name,
  day_id,
  month_name,
  month_id,
  hour_of_day,
  race,
  gender,
  province,
  duration_bucket,
  time_of_day,
  age_group;
