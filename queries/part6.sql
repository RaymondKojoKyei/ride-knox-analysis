-- TODO 6a: End-station values with no matching station
SELECT t.end_station_id,
       COUNT(*) AS trip_count
FROM trips AS t
LEFT JOIN stations AS s
  ON t.end_station_id = s.station_id
WHERE s.station_id IS NULL
GROUP BY t.end_station_id
ORDER BY trip_count DESC;

-- TODO 6b: Check for duplicate station names
SELECT station_name,
       COUNT(*) AS station_count
FROM stations
GROUP BY station_name
HAVING COUNT(*) > 1;

-- TODO 6c Version 1: Conditions in WHERE
SELECT s.station_id,
       s.station_name,
       COUNT(t.trip_id) AS late_night_trips
FROM stations AS s
LEFT JOIN trips AS t
  ON s.station_id = t.start_station_id
WHERE t.start_time >= '2025-01-01'
  AND t.start_time < '2025-02-01'
  AND strftime('%H', t.start_time) IN ('02', '03', '04')
GROUP BY s.station_id,
         s.station_name
ORDER BY s.station_id;

-- TODO 6c Version 2: Conditions in ON
SELECT s.station_id,
       s.station_name,
       COUNT(t.trip_id) AS late_night_trips
FROM stations AS s
LEFT JOIN trips AS t
  ON s.station_id = t.start_station_id
 AND t.start_time >= '2025-01-01'
 AND t.start_time < '2025-02-01'
 AND strftime('%H', t.start_time) IN ('02', '03', '04')
GROUP BY s.station_id,
         s.station_name
ORDER BY s.station_id;

-- TODO 6d: Stations with fewer than two late-night January trips
SELECT s.station_name,
       s.neighborhood,
       COUNT(t.trip_id) AS late_night_trips
FROM stations AS s
LEFT JOIN trips AS t
  ON s.station_id = t.start_station_id
 AND t.start_time >= '2025-01-01'
 AND t.start_time < '2025-02-01'
 AND strftime('%H', t.start_time) IN ('02', '03', '04')
GROUP BY s.station_id,
         s.station_name,
         s.neighborhood
HAVING COUNT(t.trip_id) < 2
ORDER BY late_night_trips ASC,
         s.station_name ASC;