-- DATA 501 SQL Module Project
-- reports.sql

-- >>> JULY_BY_PRODUCT
SELECT
    CASE
        WHEN start_time >= '2025-07-01' AND start_time < '2025-08-01' THEN '2025-07'
        WHEN start_time >= '2026-07-01' AND start_time < '2026-08-01' THEN '2026-07'
    END AS july_period,
    rider_type,
    COUNT(*) AS trips
FROM reporting_trips
WHERE (start_time >= '2025-07-01' AND start_time < '2025-08-01')
   OR (start_time >= '2026-07-01' AND start_time < '2026-08-01')
GROUP BY july_period, rider_type
ORDER BY july_period, rider_type;
-- <<< JULY_BY_PRODUCT

-- >>> ANNIVERSARY_DEFINITIONS
WITH counts AS (
    SELECT
        SUM(CASE WHEN start_time >= '2025-07-01' AND start_time < '2025-08-01'
                  AND rider_type = 'casual' THEN 1 ELSE 0 END) AS jul_2025_casual,
        SUM(CASE WHEN start_time >= '2026-07-01' AND start_time < '2026-08-01'
                  AND rider_type = 'casual' THEN 1 ELSE 0 END) AS jul_2026_casual,
        SUM(CASE WHEN start_time >= '2026-07-01' AND start_time < '2026-08-01'
                  AND rider_type = 'day_pass' THEN 1 ELSE 0 END) AS jul_2026_day_pass
    FROM reporting_trips
)
SELECT
    jul_2025_casual,
    jul_2026_casual,
    jul_2026_day_pass,
    jul_2026_casual + jul_2026_day_pass AS jul_2026_casual_plus_day_pass,
    ROUND(100.0 * (jul_2026_casual - jul_2025_casual) / jul_2025_casual, 1)
        AS casual_only_pct_change,
    ROUND(100.0 * ((jul_2026_casual + jul_2026_day_pass) - jul_2025_casual)
          / jul_2025_casual, 1) AS combined_pct_change
FROM counts;
-- <<< ANNIVERSARY_DEFINITIONS

-- >>> MONTHLY_BASE_EFFECT
SELECT
    CAST(strftime('%m', start_time) AS INTEGER) AS month_num,
    SUM(CASE WHEN start_time >= '2025-01-01' AND start_time < '2025-08-01'
              AND rider_type = 'casual' THEN 1 ELSE 0 END) AS casual_2025,
    SUM(CASE WHEN start_time >= '2026-01-01' AND start_time < '2026-08-01'
              AND rider_type = 'casual' THEN 1 ELSE 0 END) AS casual_2026,
    SUM(CASE WHEN start_time >= '2026-01-01' AND start_time < '2026-08-01'
              AND rider_type IN ('casual', 'day_pass') THEN 1 ELSE 0 END)
        AS casual_plus_daypass_2026
FROM reporting_trips
WHERE (start_time >= '2025-01-01' AND start_time < '2025-08-01')
   OR (start_time >= '2026-01-01' AND start_time < '2026-08-01')
GROUP BY CAST(strftime('%m', start_time) AS INTEGER)
ORDER BY month_num;
-- <<< MONTHLY_BASE_EFFECT

-- >>> CAPACITY_VERDICT
WITH target_stations AS (
    SELECT 'S06' AS station_id
    UNION ALL SELECT 'S08'
    UNION ALL SELECT 'S25'
    UNION ALL SELECT 'S23'
    UNION ALL SELECT 'S24'
),
trip_counts AS (
    SELECT
        s.station_id,
        SUM(CASE WHEN r.start_time >= '2025-07-01' AND r.start_time < '2025-08-01'
                 THEN 1 ELSE 0 END) AS trips_2025,
        SUM(CASE WHEN r.start_time >= '2026-07-01' AND r.start_time < '2026-08-01'
                 THEN 1 ELSE 0 END) AS trips_2026
    FROM target_stations AS s
    LEFT JOIN reporting_trips AS r
      ON r.start_station_id = s.station_id
     AND ((r.start_time >= '2025-07-01' AND r.start_time < '2025-08-01')
       OR (r.start_time >= '2026-07-01' AND r.start_time < '2026-08-01'))
    GROUP BY s.station_id
),
capacity AS (
    SELECT
        s.station_id,
        (
            SELECT c.docks FROM station_capacity_history AS c
            WHERE c.station_id = s.station_id
              AND c.effective_date <= '2025-07-01'
            ORDER BY c.effective_date DESC LIMIT 1
        ) AS docks_2025,
        (
            SELECT c.docks FROM station_capacity_history AS c
            WHERE c.station_id = s.station_id
              AND c.effective_date <= '2026-07-01'
            ORDER BY c.effective_date DESC LIMIT 1
        ) AS docks_2026
    FROM target_stations AS s
)
SELECT
    tc.station_id,
    st.station_name,
    tc.trips_2025,
    c.docks_2025,
    CASE WHEN c.docks_2025 IS NULL THEN NULL
         ELSE ROUND(1.0 * tc.trips_2025 / c.docks_2025, 1) END AS trips_per_dock_2025,
    tc.trips_2026,
    c.docks_2026,
    CASE WHEN c.docks_2026 IS NULL THEN NULL
         ELSE ROUND(1.0 * tc.trips_2026 / c.docks_2026, 1) END AS trips_per_dock_2026,
    CASE WHEN c.docks_2025 IS NULL OR c.docks_2026 IS NULL OR tc.trips_2025 = 0 THEN NULL
         ELSE ROUND(100.0 * ((1.0 * tc.trips_2026 / c.docks_2026)
                   - (1.0 * tc.trips_2025 / c.docks_2025))
                   / (1.0 * tc.trips_2025 / c.docks_2025), 1) END AS pressure_pct_change
FROM trip_counts AS tc
JOIN capacity AS c ON c.station_id = tc.station_id
JOIN stations AS st ON st.station_id = tc.station_id
ORDER BY tc.station_id;
-- <<< CAPACITY_VERDICT

-- >>> PARAM_STATION_MONTH
SELECT rider_type, COUNT(*) AS trips
FROM reporting_trips
WHERE start_station_id = ?
  AND start_time >= ?
  AND start_time < ?
GROUP BY rider_type
ORDER BY trips DESC, rider_type;
-- <<< PARAM_STATION_MONTH

-- >>> PRODUCT_PERIOD_REPORT
SELECT COUNT(*) AS trips
FROM reporting_trips
WHERE rider_type = ?
  AND start_time >= ?
  AND start_time < ?;
-- <<< PRODUCT_PERIOD_REPORT
