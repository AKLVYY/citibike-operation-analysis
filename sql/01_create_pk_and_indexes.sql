USE citibike;

ALTER TABLE trip_base 
    ADD PRIMARY KEY (ride_id),
    ADD INDEX idx_start_date (start_date),
    ADD INDEX idx_start_hour (start_hour),
    ADD INDEX idx_member_casual (member_casual),
    ADD INDEX idx_time_period (time_period),
    ADD INDEX idx_station_sample (is_station_sample),
    ADD INDEX idx_start_station_name (start_station_name(100)),
    ADD INDEX idx_end_station_name (end_station_name(100));
