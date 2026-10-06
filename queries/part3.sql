-- TODO 3a: List every distinct neighborhood in stations
SELECT DISTINCT neighborhood
FROM stations
ORDER BY neighborhood;

-- TODO 3b: Distinct stations with electric-bike departures in December 2025
SELECT DISTINCT start_station_id
FROM trips
WHERE bike_type = 'electric'
  AND start_time >= '2025-12-01'
  AND start_time < '2026-01-01'
ORDER BY start_station_id;