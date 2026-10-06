-- TODO 10a: Find station IDs for stations whose names contain Park
SELECT station_id,
       station_name
FROM stations
WHERE station_name LIKE '%Park%';

-- TODO 10a: Late-night trips starting at Park stations
SELECT trip_id,
       start_time,
       start_station_id,
       bike_type
FROM trips
WHERE strftime('%H', start_time) IN ('02', '03')
  AND start_station_id IN ('S03', 'S05', 'S15', 'S21', 'S22', 'S24')
ORDER BY start_time ASC;