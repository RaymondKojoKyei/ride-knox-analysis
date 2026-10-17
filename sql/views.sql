-- DATA 501 SQL Module Project
-- views.sql

-- A reportable trip is complete enough for board reporting and has a duration
-- from 1 minute through 6 hours. Positive durations outside this range remain
-- stored and auditable but are flagged out of this shared view.
-- >>> REPORTING_TRIPS
CREATE VIEW reporting_trips AS
SELECT
    t.trip_id,
    t.start_time,
    t.end_time,
    t.start_station_id,
    t.end_station_id,
    t.rider_type,
    t.bike_type,
    ROUND((julianday(t.end_time) - julianday(t.start_time)) * 1440.0, 1) AS duration_min,
    (
        SELECT c.docks
        FROM station_capacity_history AS c
        WHERE c.station_id = t.start_station_id
          AND c.effective_date <= date(t.start_time)
        ORDER BY c.effective_date DESC
        LIMIT 1
    ) AS start_docks
FROM trips AS t
WHERE t.end_time IS NOT NULL
  AND t.end_station_id IS NOT NULL
  AND t.duration_flag = 0
  AND (julianday(t.end_time) - julianday(t.start_time)) * 1440.0 BETWEEN 1 AND 360;
-- <<< REPORTING_TRIPS
