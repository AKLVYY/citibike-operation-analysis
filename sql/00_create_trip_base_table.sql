CREATE DATABASE IF NOT EXISTS citibike
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE citibike;

DROP TABLE IF EXISTS trip_base;

CREATE TABLE trip_base (
    ride_id VARCHAR(50) NOT NULL,
    rideable_type VARCHAR(50),
    started_at DATETIME,
    ended_at DATETIME,

    start_station_name VARCHAR(255),
    start_station_id VARCHAR(100),
    end_station_name VARCHAR(255),
    end_station_id VARCHAR(100),

    start_lat DECIMAL(12, 8),
    start_lng DECIMAL(12, 8),
    end_lat DECIMAL(12, 8),
    end_lng DECIMAL(12, 8),

    member_casual VARCHAR(20),
    ride_duration_min DECIMAL(10, 2),

    start_date DATE,
    start_month VARCHAR(10),
    start_hour INT,
    day_of_week VARCHAR(20),
    day_of_week_num INT,
    is_weekend TINYINT,

    time_period VARCHAR(50),
    duration_group VARCHAR(50),

    has_start_station TINYINT,
    has_end_station TINYINT,
    has_station_pair TINYINT,
    has_start_location TINYINT,
    has_end_location TINYINT,
    has_location_pair TINYINT,
    is_station_sample TINYINT,
    is_map_sample TINYINT
);

LOAD DATA LOCAL INFILE 'D:/citibike-operation-analysis/data_clean/trip_base_202407.csv'
INTO TABLE trip_base
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    @start_station_name,
    @start_station_id,
    @end_station_name,
    @end_station_id,
    @start_lat,
    @start_lng,
    @end_lat,
    @end_lng,
    member_casual,
    @ride_duration_min,
    start_date,
    start_month,
    start_hour,
    day_of_week,
    day_of_week_num,
    @is_weekend,
    time_period,
    duration_group,
    @has_start_station,
    @has_end_station,
    @has_station_pair,
    @has_start_location,
    @has_end_location,
    @has_location_pair,
    @is_station_sample,
    @is_map_sample
)
SET
    start_station_name = NULLIF(@start_station_name, ''),
    start_station_id = NULLIF(@start_station_id, ''),
    end_station_name = NULLIF(@end_station_name, ''),
    end_station_id = NULLIF(@end_station_id, ''),

    start_lat = NULLIF(@start_lat, ''),
    start_lng = NULLIF(@start_lng, ''),
    end_lat = NULLIF(@end_lat, ''),
    end_lng = NULLIF(@end_lng, ''),
    ride_duration_min = NULLIF(@ride_duration_min, ''),

    is_weekend = CASE WHEN TRIM(@is_weekend) = 'True' THEN 1 ELSE 0 END,
    has_start_station = CASE WHEN TRIM(@has_start_station) = 'True' THEN 1 ELSE 0 END,
    has_end_station = CASE WHEN TRIM(@has_end_station) = 'True' THEN 1 ELSE 0 END,
    has_station_pair = CASE WHEN TRIM(@has_station_pair) = 'True' THEN 1 ELSE 0 END,
    has_start_location = CASE WHEN TRIM(@has_start_location) = 'True' THEN 1 ELSE 0 END,
    has_end_location = CASE WHEN TRIM(@has_end_location) = 'True' THEN 1 ELSE 0 END,
    has_location_pair = CASE WHEN TRIM(@has_location_pair) = 'True' THEN 1 ELSE 0 END,
    is_station_sample = CASE WHEN TRIM(@is_station_sample) = 'True' THEN 1 ELSE 0 END,
    is_map_sample = CASE WHEN TRIM(@is_map_sample) = 'True' THEN 1 ELSE 0 END;
