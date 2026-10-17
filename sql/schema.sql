-- DATA 501 SQL Module Project
-- schema.sql
-- Normalized production schema and deliberate rejection tests.

-- >>> CREATE_RIDER_PRODUCTS
CREATE TABLE rider_products (
    product_code TEXT NOT NULL PRIMARY KEY,
    product_name TEXT NOT NULL,
    launch_date TEXT
);
-- <<< CREATE_RIDER_PRODUCTS

-- >>> CREATE_BIKE_TYPES
CREATE TABLE bike_types (
    bike_type TEXT NOT NULL PRIMARY KEY,
    description TEXT NOT NULL
);
-- <<< CREATE_BIKE_TYPES

-- >>> CREATE_STATIONS
CREATE TABLE stations (
    station_id TEXT NOT NULL PRIMARY KEY,
    station_name TEXT NOT NULL,
    neighborhood TEXT,
    latitude REAL CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    longitude REAL CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
    year_installed INTEGER NOT NULL CHECK (year_installed BETWEEN 2000 AND 2100),
    CHECK (station_id LIKE 'S%')
);
-- <<< CREATE_STATIONS

-- >>> CREATE_CAPACITY_HISTORY
CREATE TABLE station_capacity_history (
    station_id TEXT NOT NULL,
    effective_date TEXT NOT NULL,
    docks INTEGER NOT NULL CHECK (docks > 0),
    event_type TEXT NOT NULL CHECK (event_type IN ('baseline', 'expansion', 'opening')),
    note TEXT,
    PRIMARY KEY (station_id, effective_date),
    FOREIGN KEY (station_id) REFERENCES stations(station_id)
);
-- <<< CREATE_CAPACITY_HISTORY

-- >>> CREATE_TRIPS
CREATE TABLE trips (
    trip_id TEXT NOT NULL PRIMARY KEY,
    start_time TEXT NOT NULL,
    end_time TEXT,
    start_station_id TEXT NOT NULL,
    end_station_id TEXT,
    rider_type TEXT NOT NULL,
    bike_type TEXT NOT NULL,
    duration_flag INTEGER NOT NULL DEFAULT 0 CHECK (duration_flag IN (0, 1)),
    source_file TEXT NOT NULL,
    CHECK (trip_id LIKE 'T%'),
    CHECK (end_time IS NULL OR end_time > start_time),
    FOREIGN KEY (start_station_id) REFERENCES stations(station_id),
    FOREIGN KEY (end_station_id) REFERENCES stations(station_id),
    FOREIGN KEY (rider_type) REFERENCES rider_products(product_code),
    FOREIGN KEY (bike_type) REFERENCES bike_types(bike_type)
);
-- <<< CREATE_TRIPS

-- >>> CREATE_EXCLUSIONS
CREATE TABLE trip_exclusions (
    exclusion_id INTEGER PRIMARY KEY,
    source_file TEXT NOT NULL,
    source_row INTEGER NOT NULL,
    trip_id TEXT,
    reason TEXT NOT NULL
);
-- <<< CREATE_EXCLUSIONS

-- Deliberate rejection 1: CHECK constraint.
-- >>> TEST_BAD_DOCKS
INSERT INTO station_capacity_history (
    station_id, effective_date, docks, event_type, note
)
VALUES ('S06', '2099-01-01', 0, 'expansion', 'deliberate CHECK test');
-- <<< TEST_BAD_DOCKS

-- Deliberate rejection 2: FOREIGN KEY constraint.
-- >>> TEST_BAD_FOREIGN_KEY
INSERT INTO trips (
    trip_id, start_time, end_time, start_station_id, end_station_id,
    rider_type, bike_type, duration_flag, source_file
)
VALUES (
    'T_BAD_FK', '2026-07-10 10:00:00', '2026-07-10 10:20:00',
    'S999', 'S01', 'member', 'classic', 0, 'constraint_test'
);
-- <<< TEST_BAD_FOREIGN_KEY

-- Deliberate rejection 3: NOT NULL constraint.
-- >>> TEST_BAD_NOT_NULL
INSERT INTO trips (
    trip_id, start_time, end_time, start_station_id, end_station_id,
    rider_type, bike_type, duration_flag, source_file
)
VALUES (
    'T_BAD_NULL', NULL, NULL, 'S01', NULL,
    'member', 'classic', 0, 'constraint_test'
);
-- <<< TEST_BAD_NOT_NULL
