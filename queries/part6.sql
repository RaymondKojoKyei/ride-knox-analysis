```sql
-- TODO 6a: Stations whose name contains Ave
SELECT station_id,
       station_name
FROM stations
WHERE station_name LIKE '%Ave%';

-- TODO 6b: Station IDs matching S2_ exactly
SELECT station_id,
       station_name,
       neighborhood
FROM stations
WHERE station_id LIKE 'S2_';

-- TODO 6c: Neighborhoods ending with Knoxville
SELECT station_id,
       neighborhood
FROM stations
WHERE neighborhood LIKE '%Knoxville';

-- TODO 6d: Top 3 stations ending in Knoxville by dock count
SELECT station_name,
       neighborhood,
       docks
FROM stations
WHERE neighborhood LIKE '%Knoxville'
ORDER BY docks DESC
LIMIT 3;