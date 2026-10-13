-- TODO 7a/7b: Rank Q4 2025 arrivals per dock while preserving all stations; count valid Q4 arrivals and exclude trips outside Q4, missing end stations, and unmatched end-station IDs.
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