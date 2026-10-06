-- TODO 2a: Return station location information
SELECT station_id,
       neighborhood,
       latitude,
       longitude
FROM stations;

-- TODO 2b: Compute each station's age as of 2026
SELECT station_id,
       station_name,
       year_installed,
       2026 - year_installed AS age_years
FROM stations;

-- TODO 2c: Convert trip duration to hours rounded to two decimals
SELECT trip_id,
       start_time,
       ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) AS duration_hr
FROM trips;