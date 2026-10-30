.headers on
.mode csv

.output out/trips_month_product.csv
SELECT
    substr(start_time, 1, 7) AS month,
    rider_type,
    COUNT(*) AS trips
FROM trips
GROUP BY month, rider_type
ORDER BY month, rider_type;

.output out/cargo_month_station.csv
SELECT
    substr(start_time, 1, 7) AS month,
    start_station_id,
    COUNT(*) AS cargo_trips
FROM trips
WHERE bike_type = 'cargo'
GROUP BY month, start_station_id
ORDER BY month, start_station_id;

.output out/cargo_first_station.csv
SELECT
    start_station_id,
    MIN(start_time) AS first_cargo_trip
FROM trips
WHERE bike_type = 'cargo'
GROUP BY start_station_id
ORDER BY first_cargo_trip, start_station_id;

.output out/campus_cargo_launch.csv
SELECT
    MIN(start_time) AS first_campus_cargo_trip,
    COUNT(*) AS campus_cargo_trips
FROM trips
WHERE bike_type = 'cargo'
  AND start_station_id IN ('S06','S07','S08','S09','S10');

.output out/month_totals.csv
SELECT
    substr(start_time, 1, 7) AS month,
    COUNT(*) AS trips
FROM trips
GROUP BY month
ORDER BY month;

.output stdout
