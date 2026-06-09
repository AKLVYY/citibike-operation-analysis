# 每日需求
USE citibike;

SELECT
    start_date,
    COUNT(*) AS rides,
    ROUND(AVG(ride_duration_min), 2) AS avg_duration_min
FROM trip_base
GROUP BY start_date
ORDER BY start_date;

# 小时需求
SELECT
    start_hour,
    COUNT(*) AS rides,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (), 4) AS ride_share,
    ROUND(AVG(ride_duration_min), 2) AS avg_duration_min
FROM trip_base
GROUP BY start_hour
ORDER BY start_hour;

# 星期日均需求
SELECT
    day_of_week,
    day_of_week_num,
    COUNT(*) AS total_rides,
    COUNT(DISTINCT start_date) AS active_days,
    ROUND(COUNT(*) / COUNT(DISTINCT start_date), 2) AS avg_daily_rides,
    ROUND(AVG(ride_duration_min), 2) AS avg_duration_min
FROM trip_base
GROUP BY day_of_week, day_of_week_num
ORDER BY day_of_week_num;

# 工作日和周末对比
SELECT
    CASE WHEN is_weekend = 1 THEN 'weekend' ELSE 'weekday' END AS day_type,
    COUNT(*) AS total_rides,
    COUNT(DISTINCT start_date) AS active_days,
    ROUND(COUNT(*) / COUNT(DISTINCT start_date), 2) AS avg_daily_rides,
    ROUND(AVG(ride_duration_min), 2) AS avg_duration_min,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (), 4) AS ride_share
FROM trip_base
GROUP BY is_weekend
ORDER BY is_weekend;

# 时段需求强度
WITH time_period_summary AS (
    SELECT
        time_period,
        COUNT(*) AS rides,
        ROUND(AVG(ride_duration_min), 2) AS avg_duration_min,
        CASE
            WHEN time_period = 'late_night' THEN 6
            WHEN time_period = 'morning_peak' THEN 4
            WHEN time_period = 'daytime' THEN 6
            WHEN time_period = 'evening_peak' THEN 4
            WHEN time_period = 'night' THEN 4
        END AS period_hours
    FROM trip_base
    GROUP BY time_period
)
SELECT
    time_period,
    rides,
    period_hours,
    ROUND(rides / period_hours, 2) AS rides_per_hour,
    avg_duration_min,
    ROUND(rides / SUM(rides) OVER (), 4) AS ride_share
FROM time_period_summary
ORDER BY rides_per_hour DESC;

# 工作日/周末小时曲线
SELECT
    CASE WHEN is_weekend = 1 THEN 'weekend' ELSE 'weekday' END AS day_type,
    start_hour,
    COUNT(*) AS rides,
    ROUND(
        COUNT(*) / SUM(COUNT(*)) OVER (
            PARTITION BY CASE WHEN is_weekend = 1 THEN 'weekend' ELSE 'weekday' END
        ),
        4
    ) AS ride_share_within_day_type
FROM trip_base
GROUP BY is_weekend, start_hour
ORDER BY day_type, start_hour;