-- TODO 7a: Trips with no recorded end station
SELECT trip_id,
       start_station_id,
       start_time
FROM trips
WHERE end_station_id IS NULL;

-- TODO 7b: Naive filter for trips that did not end at Market Square
SELECT trip_id,
       start_station_id,
       end_station_id
FROM trips
WHERE end_station_id <> 'S01';

-- TODO 7c: Trips that did not end at S01, including trips with no recorded end station
SELECT trip_id,
       start_station_id,
       end_station_id
FROM trips
WHERE end_station_id <> 'S01'
   OR end_station_id IS NULL;

-- TODO 7d: South Knoxville trips with no recorded end station
SELECT trip_id,
       start_station_id
FROM trips
WHERE start_station_id IN ('S14', 'S15', 'S16')
  AND end_station_id IS NULL;