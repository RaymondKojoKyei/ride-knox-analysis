-- TODO 10a: Neighborhood seasonal swing
WITH monthly_counts AS (
    SELECT s.neighborhood,
           c.month,
           COUNT(*) AS trip_count
    FROM completed_trips AS c
    JOIN stations AS s
      ON c.start_station_id = s.station_id
    GROUP BY s.neighborhood,
             c.month
)
SELECT neighborhood,
       MIN(trip_count) AS quietest_month_trips,
       MAX(trip_count) AS busiest_month_trips,
       ROUND(
           1.0 * MAX(trip_count) / MIN(trip_count),
           2
       ) AS busiest_to_quietest_ratio
FROM monthly_counts
GROUP BY neighborhood
ORDER BY busiest_to_quietest_ratio DESC;

-- TODO 10b: Full-year departures versus arrivals by neighborhood
WITH departures AS (
    SELECT s.neighborhood,
           COUNT(*) AS total_departures
    FROM completed_trips AS c
    JOIN stations AS s
      ON c.start_station_id = s.station_id
    GROUP BY s.neighborhood
),
arrivals AS (
    SELECT s.neighborhood,
           COUNT(*) AS total_arrivals
    FROM completed_trips AS c
    JOIN stations AS s
      ON c.end_station_id = s.station_id
    GROUP BY s.neighborhood
)
SELECT d.neighborhood,
       d.total_departures,
       a.total_arrivals,
       d.total_departures - a.total_arrivals AS departure_minus_arrival
FROM departures AS d
JOIN arrivals AS a
  ON d.neighborhood = a.neighborhood
ORDER BY departure_minus_arrival DESC;