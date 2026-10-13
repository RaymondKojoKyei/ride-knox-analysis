-- TODO 8a: Neighborhoods above average neighborhood departure count
SELECT s.neighborhood,
       COUNT(*) AS trip_count
FROM trips AS t
JOIN stations AS s
  ON t.start_station_id = s.station_id
GROUP BY s.neighborhood
HAVING COUNT(*) > (
    SELECT AVG(neighborhood_count)
    FROM (
        SELECT s2.neighborhood,
               COUNT(*) AS neighborhood_count
        FROM trips AS t2
        JOIN stations AS s2
          ON t2.start_station_id = s2.station_id
        GROUP BY s2.neighborhood
    ) AS neighborhood_counts
)
ORDER BY trip_count DESC;

-- TODO 8b: Monthly summary using a subquery in FROM
SELECT ROUND(AVG(monthly_count), 1) AS avg_monthly_trips,
       MIN(monthly_count) AS min_monthly_trips,
       MAX(monthly_count) AS max_monthly_trips
FROM (
    SELECT strftime('%Y-%m', start_time) AS month,
           COUNT(*) AS monthly_count
    FROM trips
    WHERE start_time >= '2025-01-01'
      AND start_time < '2026-01-01'
    GROUP BY strftime('%Y-%m', start_time)
) AS monthly_counts;

-- TODO 8c: Monthly summary using a CTE
WITH monthly_counts AS (
    SELECT strftime('%Y-%m', start_time) AS month,
           COUNT(*) AS monthly_count
    FROM trips
    WHERE start_time >= '2025-01-01'
      AND start_time < '2026-01-01'
    GROUP BY strftime('%Y-%m', start_time)
)
SELECT ROUND(AVG(monthly_count), 1) AS avg_monthly_trips,
       MIN(monthly_count) AS min_monthly_trips,
       MAX(monthly_count) AS max_monthly_trips
FROM monthly_counts;

-- TODO 8d: Five stations with the fewest trips per dock
WITH trip_counts AS (
    SELECT start_station_id AS station_id,
           COUNT(*) AS trip_count
    FROM trips
    GROUP BY start_station_id
),
station_rates AS (
    SELECT s.station_name,
           s.docks,
           COALESCE(tc.trip_count, 0) AS trip_count,
           ROUND(
               1.0 * COALESCE(tc.trip_count, 0) / s.docks,
               1
           ) AS trips_per_dock
    FROM stations AS s
    LEFT JOIN trip_counts AS tc
      ON s.station_id = tc.station_id
)
SELECT station_name,
       docks,
       trip_count,
       trips_per_dock
FROM station_rates
ORDER BY trips_per_dock ASC,
         station_name ASC
LIMIT 5;