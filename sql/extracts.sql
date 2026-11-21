-- extracts.sql -- the SQL -> R handoff, made literal.
-- Run as:  sqlite3 "$DB" < sql/extracts.sql
-- Every number the annual report uses starts life in one of these files.
-- The report reads out/*.csv and NOTHING else; delete out/ and the report
-- cannot render -- which is exactly the dependency a real handoff creates.

.mode csv
.headers on

-- 1. Two-year monthly picture, by product.
.once out/monthly_by_product.csv
SELECT ride_year AS year, ride_month AS month, product_code, COUNT(*) AS trips
FROM trips_reportable
GROUP BY ride_year, ride_month, product_code
ORDER BY ride_month, product_code;

-- 2. Daily counts by product group -- the Integration Question's left table.
.once out/daily_products.csv
SELECT ride_date AS date,
       SUM(CASE WHEN product_code = 'member'   THEN 1 ELSE 0 END) AS member,
       SUM(CASE WHEN product_code = 'casual'   THEN 1 ELSE 0 END) AS casual,
       SUM(CASE WHEN product_code = 'day_pass' THEN 1 ELSE 0 END) AS day_pass,
       COUNT(*) AS total
FROM trips_reportable
GROUP BY ride_date
ORDER BY ride_date;

-- 3. Audited weather -- the Integration Question's right table.
--    (Already one row per date; sentinel precipitation is NULL, so a blank
--    lands in the CSV and read_csv() sees NA, not -99.9.)
.once out/weather_daily.csv
SELECT date, tmax_f, tmin_f, precip_in
FROM weather
ORDER BY date;

-- 4. Capacity scorecard with YEAR-CORRECT dock denominators from dock_history.
.once out/capacity_by_year.csv
SELECT t.ride_year AS year, t.start_station_id AS station_id,
       s.station_name, COUNT(*) AS departures, d.docks,
       ROUND(COUNT(*) * 1.0 / d.docks, 1) AS per_dock
FROM trips_reportable t
JOIN stations s      ON s.station_id = t.start_station_id
JOIN docks_by_year d ON d.station_id = t.start_station_id AND d.yr = t.ride_year
GROUP BY t.ride_year, t.start_station_id
ORDER BY t.ride_year, per_dock DESC;

-- 5. Warehouse coverage summary (for the report's audit section).
.once out/coverage.csv
SELECT ride_year AS year, MIN(ride_date) AS first_day, MAX(ride_date) AS last_day,
       COUNT(*) AS reportable_trips
FROM trips_reportable
GROUP BY ride_year;
