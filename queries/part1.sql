-- TODO 1a: Network dock-capacity summary
SELECT SUM(docks) AS total_docks,
       ROUND(AVG(docks), 1) AS avg_docks_per_station,
       MIN(docks) AS min_docks,
       MAX(docks) AS max_docks
FROM stations;

-- TODO 1b: Trip-duration summary in hours before filtering
SELECT COUNT(*) AS trip_count,
       ROUND(AVG((julianday(end_time) - julianday(start_time)) * 24), 2)
           AS avg_duration_hr,
       ROUND(MIN((julianday(end_time) - julianday(start_time)) * 24), 2)
           AS min_duration_hr,
       ROUND(MAX((julianday(end_time) - julianday(start_time)) * 24), 2)
           AS max_duration_hr
FROM trips;

-- TODO 1c: Trip-duration summary for trips from 1 minute to 6 hours
SELECT COUNT(*) AS trip_count,
       ROUND(AVG((julianday(end_time) - julianday(start_time)) * 24), 2)
           AS avg_duration_hr,
       ROUND(MIN((julianday(end_time) - julianday(start_time)) * 24), 2)
           AS min_duration_hr,
       ROUND(MAX((julianday(end_time) - julianday(start_time)) * 24), 2)
           AS max_duration_hr
FROM trips
WHERE (julianday(end_time) - julianday(start_time)) * 24 * 60
      BETWEEN 1 AND 360;

-- TODO 1d: Electric-bike share of all trips
SELECT COUNT(*) AS total_trips,
       SUM(
           CASE
               WHEN bike_type = 'electric' THEN 1
               ELSE 0
           END
       ) AS electric_trips,
       ROUND(
           100.0 *
           SUM(
               CASE
                   WHEN bike_type = 'electric' THEN 1
                   ELSE 0
               END
           ) / COUNT(*),
           1
       ) AS electric_pct
FROM trips;

-- Q1f: Repeat electric-bike percentage using integer 100
SELECT COUNT(*) AS total_trips,
       SUM(
           CASE
               WHEN bike_type = 'electric' THEN 1
               ELSE 0
           END
       ) AS electric_trips,
       ROUND(
           100 *
           SUM(
               CASE
                   WHEN bike_type = 'electric' THEN 1
                   ELSE 0
               END
           ) / COUNT(*),
           1
       ) AS electric_pct
FROM trips;