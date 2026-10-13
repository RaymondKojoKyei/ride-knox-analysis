-- TODO 5a: Electric trips from Old City or Fort Sanders with station details
SELECT t.trip_id,
       t.start_time,
       s.station_name,
       s.docks
FROM trips AS t
JOIN stations AS s
  ON t.start_station_id = s.station_id
WHERE s.neighborhood IN ('Old City', 'Fort Sanders')
  AND t.bike_type = 'electric'
ORDER BY t.start_time ASC;


-- TODO 5b: Count rows in an inner join using end_station_id
SELECT COUNT(*) AS joined_rows
FROM trips AS t
JOIN stations AS s
  ON t.end_station_id = s.station_id;


-- TODO 5c: Summarize departures and average duration by neighborhood
SELECT s.neighborhood,
       COUNT(*) AS trip_count,
       ROUND(
           AVG(
               (julianday(t.end_time) - julianday(t.start_time))
               * 24 * 60
           ),
           1
       ) AS avg_duration_min
FROM trips AS t
JOIN stations AS s
  ON t.start_station_id = s.station_id
GROUP BY s.neighborhood
ORDER BY trip_count DESC;