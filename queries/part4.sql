-- TODO 4a: Start stations with more than 15,000 trips
SELECT start_station_id,
       COUNT(*) AS trip_count
FROM trips
GROUP BY start_station_id
HAVING COUNT(*) > 15000
ORDER BY trip_count DESC;

-- TODO 4b: October electric departures with at least 300 per station
SELECT start_station_id,
       COUNT(*) AS trip_count
FROM trips
WHERE bike_type = 'electric'
  AND start_time >= '2025-10-01'
  AND start_time < '2025-11-01'
GROUP BY start_station_id
HAVING COUNT(*) >= 300
ORDER BY trip_count DESC;

-- TODO 4c: Months with more than 25,000 trips
SELECT strftime('%Y-%m', start_time) AS month,
       COUNT(*) AS trip_count
FROM trips
GROUP BY strftime('%Y-%m', start_time)
HAVING COUNT(*) > 25000
ORDER BY month;

-- TODO 4d: Deliberately place the aggregate condition in WHERE
-- This query is intentionally wrong for this exercise.
SELECT strftime('%Y-%m', start_time) AS month,
       COUNT(*) AS trip_count
FROM trips
WHERE COUNT(*) > 25000
GROUP BY strftime('%Y-%m', start_time)
ORDER BY month;