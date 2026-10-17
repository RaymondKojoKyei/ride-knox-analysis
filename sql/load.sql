-- DATA 501 SQL Module Project
-- load.sql
-- Dimension loading, SQL normalization, and constrained migration.

-- >>> SEED_PRODUCTS
INSERT INTO rider_products (product_code, product_name, launch_date)
VALUES
    ('member', 'Member', NULL),
    ('casual', 'Casual single ride', NULL),
    ('day_pass', 'Day Pass', '2026-03-01');
-- <<< SEED_PRODUCTS

-- >>> SEED_BIKE_TYPES
INSERT INTO bike_types (bike_type, description)
VALUES
    ('classic', 'Classic bicycle'),
    ('electric', 'Electric-assist bicycle');
-- <<< SEED_BIKE_TYPES

-- >>> LOAD_STATIONS
INSERT INTO stations (
    station_id, station_name, neighborhood, latitude, longitude, year_installed
)
SELECT
    TRIM(station_id), TRIM(station_name), TRIM(neighborhood),
    latitude, longitude, year_installed
FROM stg_stations_2026;
-- <<< LOAD_STATIONS

-- >>> CAPACITY_BASELINE_2025
INSERT INTO station_capacity_history (
    station_id, effective_date, docks, event_type, note
)
SELECT
    TRIM(station_id), '2025-01-01', docks, 'baseline',
    '2025 published station directory'
FROM stg_stations_2025;
-- <<< CAPACITY_BASELINE_2025

-- >>> CAPACITY_S06
INSERT INTO station_capacity_history (
    station_id, effective_date, docks, event_type, note
)
SELECT 'S06', '2026-02-15', docks, 'expansion', 'Hodges Library expansion'
FROM stg_stations_2026
WHERE TRIM(station_id) = 'S06';
-- <<< CAPACITY_S06

-- >>> CAPACITY_S08
INSERT INTO station_capacity_history (
    station_id, effective_date, docks, event_type, note
)
SELECT 'S08', '2026-02-15', docks, 'expansion', 'Student Union expansion'
FROM stg_stations_2026
WHERE TRIM(station_id) = 'S08';
-- <<< CAPACITY_S08

-- >>> CAPACITY_S25
INSERT INTO station_capacity_history (
    station_id, effective_date, docks, event_type, note
)
SELECT 'S25', '2026-03-01', docks, 'opening', 'Cumberland Ave & 22nd St opening'
FROM stg_stations_2026
WHERE TRIM(station_id) = 'S25';
-- <<< CAPACITY_S25

-- Normalization is intentionally done in SQL after raw staging.
-- >>> NORMALIZE_2025
CREATE TABLE stg_trips_2025_norm AS
SELECT
    source_row,
    NULLIF(TRIM(trip_id), '') AS trip_id,
    NULLIF(TRIM(start_time), '') AS start_time,
    NULLIF(TRIM(end_time), '') AS end_time,
    NULLIF(TRIM(start_station_id), '') AS start_station_id,
    NULLIF(TRIM(start_station_name), '') AS start_station_name,
    NULLIF(TRIM(end_station_id), '') AS end_station_id,
    CASE
        WHEN REPLACE(REPLACE(LOWER(TRIM(rider_type)), ' ', ''), '_', '') = 'daypass'
            THEN 'day_pass'
        ELSE LOWER(TRIM(rider_type))
    END AS rider_type,
    LOWER(TRIM(bike_type)) AS bike_type
FROM stg_trips_2025_raw;
-- <<< NORMALIZE_2025

-- >>> NORMALIZE_H1
CREATE TABLE stg_trips_2026_h1_norm AS
SELECT
    source_row,
    NULLIF(TRIM(trip_id), '') AS trip_id,
    NULLIF(TRIM(start_time), '') AS start_time,
    NULLIF(TRIM(end_time), '') AS end_time,
    NULLIF(TRIM(start_station_id), '') AS start_station_id,
    NULLIF(TRIM(start_station_name), '') AS start_station_name,
    NULLIF(TRIM(end_station_id), '') AS end_station_id,
    CASE
        WHEN REPLACE(REPLACE(LOWER(TRIM(rider_type)), ' ', ''), '_', '') = 'daypass'
            THEN 'day_pass'
        ELSE LOWER(TRIM(rider_type))
    END AS rider_type,
    LOWER(TRIM(bike_type)) AS bike_type
FROM stg_trips_2026_h1_raw;
-- <<< NORMALIZE_H1

-- >>> NORMALIZE_JULY
CREATE TABLE stg_trips_2026_07_norm AS
SELECT
    source_row,
    NULLIF(TRIM(trip_id), '') AS trip_id,
    NULLIF(TRIM(start_time), '') AS start_time,
    NULLIF(TRIM(end_time), '') AS end_time,
    NULLIF(TRIM(start_station_id), '') AS start_station_id,
    NULLIF(TRIM(start_station_name), '') AS start_station_name,
    NULLIF(TRIM(end_station_id), '') AS end_station_id,
    CASE
        WHEN REPLACE(REPLACE(LOWER(TRIM(rider_type)), ' ', ''), '_', '') = 'daypass'
            THEN 'day_pass'
        ELSE LOWER(TRIM(rider_type))
    END AS rider_type,
    LOWER(TRIM(bike_type)) AS bike_type
FROM stg_trips_2026_07_raw;
-- <<< NORMALIZE_JULY

-- Cargo is registered only after Part C inspection identifies the July downtown pilot.
-- >>> REGISTER_CARGO
INSERT INTO bike_types (bike_type, description)
VALUES ('cargo', 'Cargo-bike type observed in the July 2026 downtown pilot');
-- <<< REGISTER_CARGO

-- >>> MIGRATE_2025
INSERT INTO trips (
    trip_id, start_time, end_time, start_station_id, end_station_id,
    rider_type, bike_type, duration_flag, source_file
)
SELECT
    n.trip_id, n.start_time, n.end_time, n.start_station_id, n.end_station_id,
    n.rider_type, n.bike_type,
    CASE
        WHEN n.end_time IS NOT NULL
         AND ((julianday(n.end_time) - julianday(n.start_time)) * 1440.0 < 1
           OR (julianday(n.end_time) - julianday(n.start_time)) * 1440.0 > 360)
        THEN 1 ELSE 0
    END,
    'trips_2025.csv'
FROM stg_trips_2025_norm AS n
JOIN recon_2025 AS r ON r.source_row = n.source_row
WHERE r.outcome = 'loaded';
-- <<< MIGRATE_2025

-- >>> EXCLUSIONS_2025
INSERT INTO trip_exclusions (source_file, source_row, trip_id, reason)
SELECT 'trips_2025.csv', source_row, trip_id, outcome
FROM recon_2025
WHERE outcome <> 'loaded';
-- <<< EXCLUSIONS_2025

-- >>> MIGRATE_H1
INSERT INTO trips (
    trip_id, start_time, end_time, start_station_id, end_station_id,
    rider_type, bike_type, duration_flag, source_file
)
SELECT
    n.trip_id, n.start_time, n.end_time, n.start_station_id, n.end_station_id,
    n.rider_type, n.bike_type,
    CASE
        WHEN n.end_time IS NOT NULL
         AND ((julianday(n.end_time) - julianday(n.start_time)) * 1440.0 < 1
           OR (julianday(n.end_time) - julianday(n.start_time)) * 1440.0 > 360)
        THEN 1 ELSE 0
    END,
    'trips_2026_h1.csv'
FROM stg_trips_2026_h1_norm AS n
JOIN recon_2026_h1 AS r ON r.source_row = n.source_row
WHERE r.outcome = 'loaded';
-- <<< MIGRATE_H1

-- >>> EXCLUSIONS_H1
INSERT INTO trip_exclusions (source_file, source_row, trip_id, reason)
SELECT 'trips_2026_h1.csv', source_row, trip_id, outcome
FROM recon_2026_h1
WHERE outcome <> 'loaded';
-- <<< EXCLUSIONS_H1

-- >>> MIGRATE_JULY
INSERT INTO trips (
    trip_id, start_time, end_time, start_station_id, end_station_id,
    rider_type, bike_type, duration_flag, source_file
)
SELECT
    n.trip_id, n.start_time, n.end_time, n.start_station_id, n.end_station_id,
    n.rider_type, n.bike_type,
    CASE
        WHEN n.end_time IS NOT NULL
         AND ((julianday(n.end_time) - julianday(n.start_time)) * 1440.0 < 1
           OR (julianday(n.end_time) - julianday(n.start_time)) * 1440.0 > 360)
        THEN 1 ELSE 0
    END,
    'trips_2026_07.csv'
FROM stg_trips_2026_07_norm AS n
JOIN recon_2026_07 AS r ON r.source_row = n.source_row
WHERE r.outcome IN ('loaded_july', 'loaded_backlog');
-- <<< MIGRATE_JULY

-- >>> EXCLUSIONS_JULY
INSERT INTO trip_exclusions (source_file, source_row, trip_id, reason)
SELECT 'trips_2026_07.csv', source_row, trip_id, outcome
FROM recon_2026_07
WHERE outcome NOT IN ('loaded_july', 'loaded_backlog');
-- <<< EXCLUSIONS_JULY
