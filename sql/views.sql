-- views.sql -- the shared definition of a trip that belongs in reports.
-- One filter, one place, every downstream number -- instead of five analysts'
-- five opinions. Thresholds: the house window (1 minute to 24 hours), plus a
-- recorded start time (you cannot put an undated trip in a month). Rows the
-- view excludes are still IN the warehouse -- stored, countable, auditable.

DROP VIEW IF EXISTS trips_reportable;
CREATE VIEW trips_reportable AS
SELECT t.*,
       DATE(t.start_time)                                        AS ride_date,
       SUBSTR(t.start_time, 1, 7)                                AS ride_month,
       SUBSTR(t.start_time, 1, 4)                                AS ride_year,
       (julianday(t.end_time) - julianday(t.start_time)) * 1440  AS duration_min
FROM trips t
WHERE t.start_time IS NOT NULL
  AND (t.end_time IS NULL   -- a trip with no recorded end still HAPPENED;
                            -- it counts, it just carries no duration
       OR ((julianday(t.end_time) - julianday(t.start_time)) * 1440 >= 1
           AND (julianday(t.end_time) - julianday(t.start_time)) * 1440 <= 1440));

-- Year-correct dock counts: for a given year, the docks in force at that
-- year's mid-season (Jul 1). This is what dock_history exists for.
DROP VIEW IF EXISTS docks_by_year;
CREATE VIEW docks_by_year AS
SELECT y.yr, dh.station_id, dh.docks
FROM (SELECT '2025' AS yr UNION ALL SELECT '2026') y
JOIN dock_history dh
  ON dh.valid_from = (SELECT MAX(valid_from) FROM dock_history d2
                       WHERE d2.station_id = dh.station_id
                         AND d2.valid_from <= y.yr || '-07-01');
