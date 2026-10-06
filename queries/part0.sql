-- TODO 0a: List database tables
SELECT name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;

-- TODO 0a: Inspect trips table structure
PRAGMA table_info(trips);


-- TODO 0a: Display the complete trips table schema
SELECT sql
FROM sqlite_master
WHERE type = 'table'
    AND name = 'trips';

    -- TODO 0b: Inspect stations table structure
PRAGMA table_info(stations);


### TODO 2b — Compute station age

The assignment asks for:

- `station_id`
- `station_name`
- `year_installed`
- computed age as of 2026
- alias that computed column as `age_years` :chatgpt-content-reference{index="3"}

Run:

```sql
SELECT station_id,
       station_name,
       year_installed,
       2026 - year_installed AS age_years
FROM stations;

-- Compute station age as of 2026.
-- This creates a calculated result column named age_years.
-- It does not permanently alter the stations table.