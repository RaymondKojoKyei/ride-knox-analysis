PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS trips (
    trip_id TEXT PRIMARY KEY,
    start_time TEXT NOT NULL,
    end_time TEXT,
    start_station_id TEXT,
    start_station_name TEXT,
    end_station_id TEXT,
    rider_type TEXT,
    bike_type TEXT
);
