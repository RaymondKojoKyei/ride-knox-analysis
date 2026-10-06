-- TODO 9a: Shortest completed member trips on classic bikes
-- from UT Campus stations in the second half of March 2025

SELECT trip_id,
       start_station_id,
       start_time,
       ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) AS duration_hr
FROM trips
WHERE LOWER(rider_type) = 'member'
  AND bike_type = 'classic'
  AND start_station_id IN ('S06', 'S07', 'S08', 'S09')
  AND start_time >= '2025-03-15'
  AND start_time < '2025-04-01'
  AND end_station_id IS NOT NULL
ORDER BY duration_hr ASC
LIMIT 8;


-- TODO 9c: Remove impossible trips where end_time is before start_time

SELECT trip_id,
       start_station_id,
       start_time,
       ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) AS duration_hr
FROM trips
WHERE LOWER(rider_type) = 'member'
  AND bike_type = 'classic'
  AND start_station_id IN ('S06', 'S07', 'S08', 'S09')
  AND start_time >= '2025-03-15'
  AND start_time < '2025-04-01'
  AND end_station_id IS NOT NULL
  AND end_time > start_time
ORDER BY duration_hr ASC
LIMIT 8;