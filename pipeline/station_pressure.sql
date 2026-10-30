.headers on
.mode csv
.output out/station_pressure.csv

SELECT
    s.station_id,
    s.station_name,
    s.docks,
    COUNT(t.trip_id) AS departures,
    ROUND(1.0 * COUNT(t.trip_id) / s.docks, 1) AS trips_per_dock
FROM stations AS s
LEFT JOIN trips AS t
  ON t.start_station_id = s.station_id
GROUP BY
    s.station_id,
    s.station_name,
    s.docks
ORDER BY
    trips_per_dock DESC,
    s.station_id ASC;

.output stdout
