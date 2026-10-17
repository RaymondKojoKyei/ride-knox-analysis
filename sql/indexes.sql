-- DATA 501 SQL Module Project
-- indexes.sql

-- Equality on station first, then the time range.
-- >>> INDEX_STATION_START
CREATE INDEX idx_trips_station_start
ON trips (start_station_id, start_time);
-- <<< INDEX_STATION_START

-- Equality on normalized product first, then the time range.
-- >>> INDEX_PRODUCT_START
CREATE INDEX idx_trips_product_start
ON trips (rider_type, start_time);
-- <<< INDEX_PRODUCT_START
