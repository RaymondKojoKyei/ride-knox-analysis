-- TODO 3a: Wide rider-type by bike-type trip-count table
SELECT LOWER(rider_type) AS rider_type,
       SUM(
           CASE
               WHEN bike_type = 'classic' THEN 1
               ELSE 0
           END
       ) AS classic,
       SUM(
           CASE
               WHEN bike_type = 'electric' THEN 1
               ELSE 0
           END
       ) AS electric
FROM trips
GROUP BY LOWER(rider_type)
ORDER BY rider_type;

-- TODO 3b: Deliberately violate the grouping rule
-- This query is intentionally wrong for this exercise.
SELECT bike_type,
       rider_type,
       COUNT(*) AS trip_count
FROM trips
GROUP BY bike_type;