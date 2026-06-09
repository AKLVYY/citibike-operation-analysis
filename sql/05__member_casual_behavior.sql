USE citibike;

# 会员和临时用户骑行规模
SELECT
    member_casual,
    COUNT(*) AS rides,
    COUNT(DISTINCT start_date) AS active_days,
    ROUND(COUNT(*) / COUNT(DISTINCT start_date), 2) AS avg_daily_rides,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (), 4) AS ride_share
FROM trip_base
GROUP BY member_casual
ORDER BY rides DESC;

# 会员和临时用户骑行时长
SELECT
    member_casual,
    COUNT(*) AS rides,
    ROUND(AVG(ride_duration_min), 2) AS avg_duration_min,
    ROUND(MIN(ride_duration_min), 2) AS min_duration_min,
    ROUND(MAX(ride_duration_min), 2) AS max_duration_min
FROM trip_base
GROUP BY member_casual
ORDER BY rides DESC;

# 骑行时长分组结构
SELECT
    member_casual,
    duration_group,
    COUNT(*) AS rides,
    ROUND(
        COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY member_casual),
        4
    ) AS ride_share_within_type
FROM trip_base
GROUP BY member_casual, duration_group
ORDER BY
    member_casual,
    CASE duration_group
        WHEN '0_5min' THEN 1
        WHEN '5_10min' THEN 2
        WHEN '10_20min' THEN 3
        WHEN '20_30min' THEN 4
        WHEN '30_60min' THEN 5
        WHEN '60min_plus' THEN 6
        ELSE 99
    END;
    
# 工作日和周末差异
SELECT
    member_casual,
    CASE
        WHEN is_weekend = 1 THEN 'weekend'
        ELSE 'weekday'
    END AS day_type,
    COUNT(*) AS total_rides,
    COUNT(DISTINCT start_date) AS active_days,
    ROUND(COUNT(*) / COUNT(DISTINCT start_date), 2) AS avg_daily_rides,
    ROUND(AVG(ride_duration_min), 2) AS avg_duration_min
FROM trip_base
GROUP BY member_casual, is_weekend
ORDER BY member_casual, is_weekend;

# 小时需求结构
SELECT
    member_casual,
    start_hour,
    COUNT(*) AS rides,
    ROUND(
        COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY member_casual),
        4
    ) AS ride_share_within_type
FROM trip_base
GROUP BY member_casual, start_hour
ORDER BY member_casual, start_hour;

# 时段结构
SELECT
    member_casual,
    time_period,
    COUNT(*) AS rides,
    ROUND(AVG(ride_duration_min), 2) AS avg_duration_min,
    ROUND(
        COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY member_casual),
        4
    ) AS ride_share_within_type
FROM trip_base
GROUP BY member_casual, time_period
ORDER BY
    member_casual,
    CASE time_period
        WHEN 'late_night' THEN 1
        WHEN 'morning_peak' THEN 2
        WHEN 'daytime' THEN 3
        WHEN 'evening_peak' THEN 4
        WHEN 'night' THEN 5
        ELSE 99
    END;
    
# 车型偏好
SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS rides,
    ROUND(AVG(ride_duration_min), 2) AS avg_duration_min,
    ROUND(
        COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY member_casual),
        4
    ) AS ride_share_within_type
FROM trip_base
GROUP BY member_casual, rideable_type
ORDER BY member_casual, rides DESC;

# Top起点站
WITH start_station_by_member AS (
    SELECT
        member_casual,
        start_station_name AS station_name,
        COUNT(*) AS rides,
        ROUND(AVG(ride_duration_min), 2) AS avg_duration_min
    FROM trip_base
    WHERE is_station_sample = 1
    GROUP BY member_casual, start_station_name
),

ranked_station AS (
    SELECT
        member_casual,
        station_name,
        rides,
        avg_duration_min,
        ROW_NUMBER() OVER (
            PARTITION BY member_casual
            ORDER BY rides DESC
        ) AS station_rank
    FROM start_station_by_member
)

SELECT
    member_casual,
    station_rank,
    station_name,
    rides,
    avg_duration_min
FROM ranked_station
WHERE station_rank <= 10
ORDER BY member_casual, station_rank;
