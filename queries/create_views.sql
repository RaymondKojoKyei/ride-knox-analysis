-- TODO 9a: Create the shared completed_trips view
CREATE VIEW completed_trips AS
SELECT trip_id,
       start_time,
       start_station_id,
       end_station_id,
       LOWER(rider_type) AS rider_type,
       bike_type,
       ROUND(
           (julianday(end_time) - julianday(start_time)) * 24 * 60,
           1
       ) AS duration_min,
       strftime('%Y-%m', start_time) AS month
FROM trips
WHERE start_station_id <> 'S99'
  AND end_station_id IS NOT NULL
  AND (julianday(end_time) - julianday(start_time)) * 24 * 60
      BETWEEN 2 AND 720;