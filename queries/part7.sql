-- TODO 7b: Counts Q4 2025 trips ending at valid stations; excludes trips outside Q4, never-docked trips, and unmatched end-station IDs.-- TODO 7a: Rank Q4 2025 arrivals per dock while preserving every station
-- TODO 7b: Counts trips ending at valid stations during Q4 2025; excludes trips outside Q4, trips without a recorded end station, and unmatched end-station IDs.
SELECT s.station_name,
       s.neighborhood,
       s.docks,
       COUNT(t.trip_id) AS q4_arrivals,
       ROUND(
           1.0 * COUNT(t.trip_id) / s.docks,
           2
       ) AS arrivals_per_dock
FROM stations AS s
LEFT JOIN trips AS t
  ON s.station_id = t.end_station_id
 AND t.end_time >= '2025-10-01'
 AND t.end_time < '2026-01-01'
GROUP BY s.station_id,
         s.station_name,
         s.neighborhood,
         s.docks
ORDER BY arrivals_per_dock DESC,
         s.station_name ASC;