# 创建全日站点失衡视图 v_station_imbalance
CREATE OR REPLACE VIEW v_station_imbalance AS
WITH station_list AS (
    SELECT start_station_name AS station_name
    FROM trip_base
    WHERE is_station_sample = 1

    UNION

    SELECT end_station_name AS station_name
    FROM trip_base
    WHERE is_station_sample = 1
),

start_summary AS (
    SELECT
        start_station_name AS station_name,
        COUNT(*) AS start_rides
    FROM trip_base
    WHERE is_station_sample = 1
    GROUP BY start_station_name
),

end_summary AS (
    SELECT
        end_station_name AS station_name,
        COUNT(*) AS end_rides
    FROM trip_base
    WHERE is_station_sample = 1
    GROUP BY end_station_name
)

SELECT
    sl.station_name,
    COALESCE(ss.start_rides, 0) AS start_rides,
    COALESCE(es.end_rides, 0) AS end_rides,
    COALESCE(ss.start_rides, 0) + COALESCE(es.end_rides, 0) AS total_activity,
    COALESCE(es.end_rides, 0) - COALESCE(ss.start_rides, 0) AS net_inflow,
    ABS(COALESCE(es.end_rides, 0) - COALESCE(ss.start_rides, 0)) AS abs_net_inflow,
    ROUND(
        (COALESCE(es.end_rides, 0) - COALESCE(ss.start_rides, 0))
        / NULLIF(COALESCE(ss.start_rides, 0) + COALESCE(es.end_rides, 0), 0),
        4
    ) AS imbalance_ratio,
    CASE
        WHEN COALESCE(es.end_rides, 0) - COALESCE(ss.start_rides, 0) > 0
            THEN 'net_inflow_accumulation'
        WHEN COALESCE(es.end_rides, 0) - COALESCE(ss.start_rides, 0) < 0
            THEN 'net_outflow_shortage'
        ELSE 'balanced'
    END AS imbalance_type
FROM station_list sl
LEFT JOIN start_summary ss
    ON sl.station_name = ss.station_name
LEFT JOIN end_summary es
    ON sl.station_name = es.station_name;

# 检查全日站点汇总口径
SELECT
    COUNT(*) AS station_count,
    SUM(start_rides) AS total_start_rides,
    SUM(end_rides) AS total_end_rides,
    SUM(total_activity) AS total_activity,
    SUM(net_inflow) AS net_inflow_sum
FROM v_station_imbalance;

# 查询全日Top10净流出站点
SELECT
    station_name,
    start_rides,
    end_rides,
    total_activity,
    net_inflow,
    abs_net_inflow,
    imbalance_ratio,
    imbalance_type
FROM v_station_imbalance
ORDER BY net_inflow ASC
LIMIT 10;

# 查询全日Top10净流入站点
SELECT
    station_name,
    start_rides,
    end_rides,
    total_activity,
    net_inflow,
    abs_net_inflow,
    imbalance_ratio,
    imbalance_type
FROM v_station_imbalance
ORDER BY net_inflow DESC
LIMIT 10;

# 筛选高活跃缺车风险站点
SELECT
    station_name,
    start_rides,
    end_rides,
    total_activity,
    net_inflow,
    abs_net_inflow,
    imbalance_ratio,
    imbalance_type
FROM v_station_imbalance
WHERE total_activity >= 1000
  AND imbalance_type = 'net_outflow_shortage'
ORDER BY abs_net_inflow DESC
LIMIT 10;

# 筛选高活跃积车风险站点
SELECT
    station_name,
    start_rides,
    end_rides,
    total_activity,
    net_inflow,
    abs_net_inflow,
    imbalance_ratio,
    imbalance_type
FROM v_station_imbalance
WHERE total_activity >= 1000
  AND imbalance_type = 'net_inflow_accumulation'
ORDER BY abs_net_inflow DESC
LIMIT 10;

# 创建晚高峰站点失衡视图
CREATE OR REPLACE VIEW v_evening_station_imbalance AS
WITH station_list AS (
    SELECT start_station_name AS station_name
    FROM trip_base
    WHERE is_station_sample = 1
      AND time_period = 'evening_peak'

    UNION

    SELECT end_station_name AS station_name
    FROM trip_base
    WHERE is_station_sample = 1
      AND time_period = 'evening_peak'
),

start_summary AS (
    SELECT
        start_station_name AS station_name,
        COUNT(*) AS start_rides
    FROM trip_base
    WHERE is_station_sample = 1
      AND time_period = 'evening_peak'
    GROUP BY start_station_name
),

end_summary AS (
    SELECT
        end_station_name AS station_name,
        COUNT(*) AS end_rides
    FROM trip_base
    WHERE is_station_sample = 1
      AND time_period = 'evening_peak'
    GROUP BY end_station_name
)

SELECT
    sl.station_name,
    COALESCE(ss.start_rides, 0) AS start_rides,
    COALESCE(es.end_rides, 0) AS end_rides,
    COALESCE(ss.start_rides, 0) + COALESCE(es.end_rides, 0) AS total_activity,
    COALESCE(es.end_rides, 0) - COALESCE(ss.start_rides, 0) AS net_inflow,
    ABS(COALESCE(es.end_rides, 0) - COALESCE(ss.start_rides, 0)) AS abs_net_inflow,
    ROUND(
        (COALESCE(es.end_rides, 0) - COALESCE(ss.start_rides, 0))
        / NULLIF(COALESCE(ss.start_rides, 0) + COALESCE(es.end_rides, 0), 0),
        4
    ) AS imbalance_ratio,
    CASE
        WHEN COALESCE(es.end_rides, 0) - COALESCE(ss.start_rides, 0) > 0
            THEN 'net_inflow_accumulation'
        WHEN COALESCE(es.end_rides, 0) - COALESCE(ss.start_rides, 0) < 0
            THEN 'net_outflow_shortage'
        ELSE 'balanced'
    END AS imbalance_type
FROM station_list sl
LEFT JOIN start_summary ss
    ON sl.station_name = ss.station_name
LEFT JOIN end_summary es
    ON sl.station_name = es.station_name;
    
# 检查晚高峰视图口径
SELECT
    COUNT(*) AS station_count,
    SUM(start_rides) AS total_start_rides,
    SUM(end_rides) AS total_end_rides,
    SUM(total_activity) AS total_activity,
    SUM(net_inflow) AS net_inflow_sum
FROM v_evening_station_imbalance;

# 查询晚高峰缺车风险站点
SELECT
    station_name,
    start_rides,
    end_rides,
    total_activity,
    net_inflow,
    abs_net_inflow,
    imbalance_ratio,
    imbalance_type
FROM v_evening_station_imbalance
WHERE total_activity >= 300
  AND imbalance_type = 'net_outflow_shortage'
ORDER BY abs_net_inflow DESC
LIMIT 10;

# 查询晚高峰积车风险站点
SELECT
    station_name,
    start_rides,
    end_rides,
    total_activity,
    net_inflow,
    abs_net_inflow,
    imbalance_ratio,
    imbalance_type
FROM v_evening_station_imbalance
WHERE total_activity >= 300
  AND imbalance_type = 'net_inflow_accumulation'
ORDER BY abs_net_inflow DESC
LIMIT 10;
