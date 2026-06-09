# 检查基本粒度
USE citibike;

SELECT
    COUNT(*) AS rows_count,
    COUNT(DISTINCT ride_id) AS unique_ride_ids,
    COUNT(*) - COUNT(DISTINCT ride_id) AS duplicated_ride_ids,
    MIN(started_at) AS min_started_at,
    MAX(started_at) AS max_started_at,
    ROUND(AVG(ride_duration_min), 2) AS avg_duration_min,
    ROUND(MIN(ride_duration_min), 2) AS min_duration_min,
    ROUND(MAX(ride_duration_min), 2) AS max_duration_min
FROM trip_base;

# 检查用户类型
SELECT
    member_casual,
    COUNT(*) AS rides,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (), 4) AS ride_share
FROM trip_base
GROUP BY member_casual
ORDER BY rides DESC;

# 检查车型
SELECT
    rideable_type,
    COUNT(*) AS rides,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (), 4) AS ride_share
FROM trip_base
GROUP BY rideable_type
ORDER BY rides DESC;

# 检查样本标记
SELECT
    COUNT(*) AS total_rides,
    SUM(is_station_sample) AS station_sample_rides,
    ROUND(SUM(is_station_sample) / COUNT(*), 4) AS station_sample_rate,
    SUM(is_map_sample) AS map_sample_rides,
    ROUND(SUM(is_map_sample) / COUNT(*), 4) AS map_sample_rate
FROM trip_base;