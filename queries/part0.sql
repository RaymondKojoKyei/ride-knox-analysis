-- TODO 0a: List database tables
SELECT name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;

-- TODO 0a: Inspect trips table structure
PRAGMA table_info(trips);

-- TODO 0b: Inspect stations table structure
PRAGMA table_info(stations);