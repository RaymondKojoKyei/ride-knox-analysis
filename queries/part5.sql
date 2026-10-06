-- TODO 5a: Trips that started in September 2025
SELECT trip_id,
       start_time,
       rider_type
FROM trips
WHERE start_time >= '2025-09-01'
  AND start_time < '2025-10-01';

-- TODO 5b: Naive September filter using BETWEEN
SELECT trip_id,
       start_time,
       rider_type
FROM trips
WHERE start_time BETWEEN '2025-09-01' AND '2025-09-30';

-- TODO 5c: Trips starting in the second half of March 2025
SELECT trip_id,
       start_time
FROM trips
WHERE start_time >= '2025-03-15'
  AND start_time < '2025-04-01';

-- TODO 5d: October member trips using exact lowercase match
SELECT trip_id,
       start_time,
       rider_type
FROM trips
WHERE rider_type = 'member'
  AND start_time >= '2025-10-01'
  AND start_time < '2025-11-01';

-- TODO 5d: October member trips using case-insensitive normalization
SELECT trip_id,
       start_time,
       rider_type
FROM trips
WHERE LOWER(rider_type) = 'member'
  AND start_time >= '2025-10-01'
  AND start_time < '2025-11-01';