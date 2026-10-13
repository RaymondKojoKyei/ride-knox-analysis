-- TODO 2a: Count trips by start station, busiest first
SELECT start_station_id,
       COUNT(*) AS trip_count
FROM trips
GROUP BY start_station_id
ORDER BY trip_count DESC;


-- TODO 2b: Show the six busiest hours of the day
SELECT strftime('%H', start_time) AS hour_of_day,
       COUNT(*) AS trip_count
FROM trips
GROUP BY strftime('%H', start_time)
ORDER BY trip_count DESC
LIMIT 6;


-- TODO 2c: Count trips and average duration by bike type and normalized rider type
SELECT bike_type,
       LOWER(rider_type) AS rider_type,
       COUNT(*) AS trip_count,
       ROUND(
           AVG((julianday(end_time) - julianday(start_time)) * 24 * 60),
           1
       ) AS avg_duration_min
FROM trips
GROUP BY bike_type,
         LOWER(rider_type)
ORDER BY rider_type,
         bike_type;


-- TODO 2d: Repeat TODO 2c without normalizing rider type
SELECT bike_type,
       rider_type,
       COUNT(*) AS trip_count,
       ROUND(
           AVG((julianday(end_time) - julianday(start_time)) * 24 * 60),
           1
       ) AS avg_duration_min
FROM trips
GROUP BY bike_type,
         rider_type
ORDER BY rider_type,
         bike_type;