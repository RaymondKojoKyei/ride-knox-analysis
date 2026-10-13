-- TODO 0a: Four-count database diagnostic
SELECT COUNT(*) AS total_trips,
       COUNT(end_station_id) AS recorded_end_station_count,
       COUNT(DISTINCT start_station_id) AS distinct_start_stations,
       COUNT(DISTINCT rider_type) AS distinct_rider_types
FROM trips;