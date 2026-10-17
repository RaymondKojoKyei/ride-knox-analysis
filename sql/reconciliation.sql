-- DATA 501 SQL Module Project
-- reconciliation.sql
-- Every raw row receives exactly one named outcome.

-- Station-file closure tables.
-- >>> RECON_STATIONS_2025
CREATE TABLE recon_stations_2025 AS
SELECT TRIM(station_id) AS station_id, 'capacity_baseline' AS outcome
FROM stg_stations_2025;
-- <<< RECON_STATIONS_2025

-- >>> RECON_STATIONS_2026
CREATE TABLE recon_stations_2026 AS
SELECT TRIM(station_id) AS station_id, 'loaded_station' AS outcome
FROM stg_stations_2026;
-- <<< RECON_STATIONS_2026

-- 2025 anchors are measured after collapsing exact duplicate trip IDs, matching the
-- 250,000-row clean source used by the class database.
-- >>> ANCHORS_2025
WITH first_rows AS (
    SELECT trip_id, MIN(source_row) AS first_row
    FROM stg_trips_2025_raw
    GROUP BY trip_id
), deduped AS (
    SELECT r.*
    FROM stg_trips_2025_raw AS r
    JOIN first_rows AS f
      ON f.trip_id = r.trip_id
     AND f.first_row = r.source_row
)
SELECT
    (SELECT COUNT(*) FROM stg_trips_2025_raw) AS raw_rows,
    (SELECT COUNT(*) FROM stg_trips_2025_raw) - COUNT(*) AS duplicate_rows,
    SUM(CASE WHEN start_station_id = 'S99' THEN 1 ELSE 0 END) AS test_station_rows,
    SUM(CASE WHEN end_station_id IS NULL OR TRIM(end_station_id) = '' THEN 1 ELSE 0 END)
        AS missing_end_station_rows
FROM deduped;
-- <<< ANCHORS_2025

-- >>> RECON_2025
CREATE TABLE recon_2025 AS
WITH first_rows AS (
    SELECT trip_id, MIN(source_row) AS first_row
    FROM stg_trips_2025_norm
    WHERE trip_id IS NOT NULL
    GROUP BY trip_id
)
SELECT
    n.source_row,
    n.trip_id,
    CASE
        WHEN n.trip_id IS NULL THEN 'missing_trip_id'
        WHEN n.source_row <> f.first_row THEN 'duplicate_in_file'
        WHEN n.start_time IS NULL THEN 'missing_start_time'
        WHEN julianday(n.start_time) IS NULL THEN 'bad_start_time_format'
        WHEN n.end_time IS NOT NULL AND julianday(n.end_time) IS NULL THEN 'bad_end_time_format'
        WHEN date(n.start_time) < '2025-01-01' OR date(n.start_time) >= '2026-01-01'
            THEN 'outside_file_window'
        WHEN n.end_time IS NOT NULL AND n.end_time <= n.start_time THEN 'impossible_timestamp'
        WHEN NOT EXISTS (SELECT 1 FROM stations AS s WHERE s.station_id = n.start_station_id)
            THEN 'orphan_start_station'
        WHEN n.end_station_id IS NOT NULL
         AND NOT EXISTS (SELECT 1 FROM stations AS s WHERE s.station_id = n.end_station_id)
            THEN 'orphan_end_station'
        WHEN NOT EXISTS (SELECT 1 FROM rider_products AS p WHERE p.product_code = n.rider_type)
            THEN 'unknown_product'
        WHEN EXISTS (
            SELECT 1 FROM rider_products AS p
            WHERE p.product_code = n.rider_type
              AND p.launch_date IS NOT NULL
              AND date(n.start_time) < p.launch_date
        ) THEN 'product_before_launch'
        WHEN NOT EXISTS (SELECT 1 FROM bike_types AS b WHERE b.bike_type = n.bike_type)
            THEN 'unknown_bike_type'
        ELSE 'loaded'
    END AS outcome
FROM stg_trips_2025_norm AS n
LEFT JOIN first_rows AS f ON f.trip_id = n.trip_id;
-- <<< RECON_2025

-- >>> SUMMARY_2025
SELECT outcome, COUNT(*) AS rows
FROM recon_2025
GROUP BY outcome
ORDER BY rows DESC, outcome;
-- <<< SUMMARY_2025

-- >>> RECON_H1
CREATE TABLE recon_2026_h1 AS
WITH first_rows AS (
    SELECT trip_id, MIN(source_row) AS first_row
    FROM stg_trips_2026_h1_norm
    WHERE trip_id IS NOT NULL
    GROUP BY trip_id
)
SELECT
    n.source_row,
    n.trip_id,
    CASE
        WHEN n.trip_id IS NULL THEN 'missing_trip_id'
        WHEN n.source_row <> f.first_row THEN 'duplicate_in_file'
        WHEN EXISTS (SELECT 1 FROM trips AS t WHERE t.trip_id = n.trip_id)
            THEN 'duplicate_existing'
        WHEN n.start_time IS NULL THEN 'missing_start_time'
        WHEN julianday(n.start_time) IS NULL THEN 'bad_start_time_format'
        WHEN n.end_time IS NOT NULL AND julianday(n.end_time) IS NULL THEN 'bad_end_time_format'
        WHEN date(n.start_time) < '2026-01-01' OR date(n.start_time) >= '2026-07-01'
            THEN 'outside_file_window'
        WHEN n.end_time IS NOT NULL AND n.end_time <= n.start_time THEN 'impossible_timestamp'
        WHEN NOT EXISTS (SELECT 1 FROM stations AS s WHERE s.station_id = n.start_station_id)
            THEN 'orphan_start_station'
        WHEN n.end_station_id IS NOT NULL
         AND NOT EXISTS (SELECT 1 FROM stations AS s WHERE s.station_id = n.end_station_id)
            THEN 'orphan_end_station'
        WHEN NOT EXISTS (SELECT 1 FROM rider_products AS p WHERE p.product_code = n.rider_type)
            THEN 'unknown_product'
        WHEN EXISTS (
            SELECT 1 FROM rider_products AS p
            WHERE p.product_code = n.rider_type
              AND p.launch_date IS NOT NULL
              AND date(n.start_time) < p.launch_date
        ) THEN 'product_before_launch'
        WHEN NOT EXISTS (SELECT 1 FROM bike_types AS b WHERE b.bike_type = n.bike_type)
            THEN 'unknown_bike_type'
        ELSE 'loaded'
    END AS outcome
FROM stg_trips_2026_h1_norm AS n
LEFT JOIN first_rows AS f ON f.trip_id = n.trip_id;
-- <<< RECON_H1

-- >>> SUMMARY_H1
SELECT outcome, COUNT(*) AS rows
FROM recon_2026_h1
GROUP BY outcome
ORDER BY rows DESC, outcome;
-- <<< SUMMARY_H1

-- July inspection runs against raw staging before July normalization/migration.
-- >>> JULY_ROWCOUNT
SELECT COUNT(*) AS raw_rows
FROM stg_trips_2026_07_raw;
-- <<< JULY_ROWCOUNT

-- >>> JULY_DATE_RANGE
SELECT
    MIN(start_time) AS earliest_start,
    MAX(start_time) AS latest_start,
    SUM(CASE WHEN start_time IS NOT NULL AND start_time < '2026-07-01' THEN 1 ELSE 0 END)
        AS pre_july_rows,
    SUM(CASE WHEN start_time >= '2026-07-01' AND start_time < '2026-08-01' THEN 1 ELSE 0 END)
        AS july_rows,
    SUM(CASE WHEN start_time IS NULL OR TRIM(start_time) = '' THEN 1 ELSE 0 END)
        AS missing_start_rows
FROM stg_trips_2026_07_raw;
-- <<< JULY_DATE_RANGE

-- >>> JULY_DUPLICATES
SELECT COUNT(*) - COUNT(DISTINCT trip_id) AS duplicate_rows
FROM stg_trips_2026_07_raw;
-- <<< JULY_DUPLICATES

-- >>> JULY_RIDER_VALUES
SELECT rider_type, COUNT(*) AS rows
FROM stg_trips_2026_07_raw
GROUP BY rider_type
ORDER BY rows DESC, rider_type;
-- <<< JULY_RIDER_VALUES

-- >>> JULY_BIKE_VALUES
SELECT bike_type, COUNT(*) AS rows
FROM stg_trips_2026_07_raw
GROUP BY bike_type
ORDER BY rows DESC, bike_type;
-- <<< JULY_BIKE_VALUES

-- >>> JULY_CARGO_STATIONS
SELECT start_station_id, COUNT(*) AS cargo_rows
FROM stg_trips_2026_07_raw
WHERE LOWER(TRIM(bike_type)) = 'cargo'
GROUP BY start_station_id
ORDER BY cargo_rows DESC, start_station_id;
-- <<< JULY_CARGO_STATIONS

-- >>> JULY_BAD_ROWS
SELECT
    SUM(CASE WHEN start_time IS NULL OR TRIM(start_time) = '' THEN 1 ELSE 0 END)
        AS missing_start_time,
    SUM(CASE WHEN end_station_id IS NULL OR TRIM(end_station_id) = '' THEN 1 ELSE 0 END)
        AS missing_end_station,
    SUM(CASE WHEN start_time IS NOT NULL AND end_time IS NOT NULL AND end_time <= start_time
             THEN 1 ELSE 0 END) AS impossible_timestamp,
    SUM(CASE WHEN start_station_name <> TRIM(start_station_name) THEN 1 ELSE 0 END)
        AS station_name_whitespace_rows
FROM stg_trips_2026_07_raw;
-- <<< JULY_BAD_ROWS

-- >>> JULY_OUTAGE_CHECK
SELECT
    MIN(end_time) AS earliest_end_for_missing_start,
    MAX(end_time) AS latest_end_for_missing_start,
    COUNT(*) AS rows
FROM stg_trips_2026_07_raw
WHERE start_time IS NULL OR TRIM(start_time) = '';
-- <<< JULY_OUTAGE_CHECK

-- >>> RECON_JULY
CREATE TABLE recon_2026_07 AS
WITH first_rows AS (
    SELECT trip_id, MIN(source_row) AS first_row
    FROM stg_trips_2026_07_norm
    WHERE trip_id IS NOT NULL
    GROUP BY trip_id
)
SELECT
    n.source_row,
    n.trip_id,
    CASE
        WHEN n.trip_id IS NULL THEN 'missing_trip_id'
        WHEN n.source_row <> f.first_row THEN 'duplicate_in_file'
        WHEN EXISTS (SELECT 1 FROM trips AS t WHERE t.trip_id = n.trip_id)
            THEN 'duplicate_existing'
        WHEN n.start_time IS NULL THEN 'missing_start_time'
        WHEN julianday(n.start_time) IS NULL THEN 'bad_start_time_format'
        WHEN n.end_time IS NOT NULL AND julianday(n.end_time) IS NULL THEN 'bad_end_time_format'
        WHEN date(n.start_time) >= '2026-08-01' THEN 'outside_future_window'
        WHEN n.end_time IS NOT NULL AND n.end_time <= n.start_time THEN 'impossible_timestamp'
        WHEN NOT EXISTS (SELECT 1 FROM stations AS s WHERE s.station_id = n.start_station_id)
            THEN 'orphan_start_station'
        WHEN n.end_station_id IS NOT NULL
         AND NOT EXISTS (SELECT 1 FROM stations AS s WHERE s.station_id = n.end_station_id)
            THEN 'orphan_end_station'
        WHEN NOT EXISTS (SELECT 1 FROM rider_products AS p WHERE p.product_code = n.rider_type)
            THEN 'unknown_product'
        WHEN EXISTS (
            SELECT 1 FROM rider_products AS p
            WHERE p.product_code = n.rider_type
              AND p.launch_date IS NOT NULL
              AND date(n.start_time) < p.launch_date
        ) THEN 'product_before_launch'
        WHEN NOT EXISTS (SELECT 1 FROM bike_types AS b WHERE b.bike_type = n.bike_type)
            THEN 'unknown_bike_type'
        WHEN date(n.start_time) < '2026-07-01' THEN 'loaded_backlog'
        ELSE 'loaded_july'
    END AS outcome
FROM stg_trips_2026_07_norm AS n
LEFT JOIN first_rows AS f ON f.trip_id = n.trip_id;
-- <<< RECON_JULY

-- >>> SUMMARY_JULY
SELECT outcome, COUNT(*) AS rows
FROM recon_2026_07
GROUP BY outcome
ORDER BY rows DESC, outcome;
-- <<< SUMMARY_JULY
