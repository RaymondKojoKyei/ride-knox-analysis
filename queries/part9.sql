-- TODO 9a: Verify the completed_trips view row count
SELECT COUNT(*) AS completed_trip_count
FROM completed_trips;

-- TODO 9b: Compare first-half and second-half casual trips by neighborhood
WITH h1 AS (
    SELECT s.neighborhood,
           COUNT(*) AS h1_casual_trips
    FROM completed_trips AS c
    JOIN stations AS s
      ON c.start_station_id = s.station_id
    WHERE c.rider_type = 'casual'
      AND c.start_time >= '2025-01-01'
      AND c.start_time < '2025-07-01'
    GROUP BY s.neighborhood
),
h2 AS (
    SELECT s.neighborhood,
           COUNT(*) AS h2_casual_trips
    FROM completed_trips AS c
    JOIN stations AS s
      ON c.start_station_id = s.station_id
    WHERE c.rider_type = 'casual'
      AND c.start_time >= '2025-07-01'
      AND c.start_time < '2026-01-01'
    GROUP BY s.neighborhood
),
capacity AS (
    SELECT neighborhood,
           SUM(docks) AS total_docks
    FROM stations
    GROUP BY neighborhood
)
SELECT capacity.neighborhood,
       COALESCE(h1.h1_casual_trips, 0) AS h1_casual_trips,
       COALESCE(h2.h2_casual_trips, 0) AS h2_casual_trips,
       COALESCE(h2.h2_casual_trips, 0)
           - COALESCE(h1.h1_casual_trips, 0) AS change_trips,
       capacity.total_docks,
       ROUND(
           1.0 *
           (
               COALESCE(h2.h2_casual_trips, 0)
               - COALESCE(h1.h1_casual_trips, 0)
           ) / capacity.total_docks,
           1
       ) AS change_per_dock
FROM capacity
LEFT JOIN h1
  ON capacity.neighborhood = h1.neighborhood
LEFT JOIN h2
  ON capacity.neighborhood = h2.neighborhood
ORDER BY change_per_dock ASC;