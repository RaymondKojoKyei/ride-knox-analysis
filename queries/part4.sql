```sql
-- TODO 4a: Return all stations in Fort Sanders
SELECT *
FROM stations
WHERE neighborhood = 'Fort Sanders';

-- TODO 4b: Stations with 20 or more docks
SELECT station_id,
       station_name,
       docks
FROM stations
WHERE docks >= 20;

-- TODO 4c: UT Campus or Fort Sanders stations with 16 or more docks
SELECT *
FROM stations
WHERE (neighborhood = 'UT Campus'
       OR neighborhood = 'Fort Sanders')
  AND docks >= 16;

-- TODO 4d: Same condition as 4c without parentheses
SELECT *
FROM stations
WHERE neighborhood = 'UT Campus'
   OR neighborhood = 'Fort Sanders'
  AND docks >= 16;

-- TODO 4e: South Knoxville or East Knoxville stations using IN
SELECT *
FROM stations
WHERE neighborhood IN ('South Knoxville', 'East Knoxville');

-- TODO 4f: Stations with dock counts between 12 and 16 inclusive
SELECT station_id,
       station_name,
       docks
FROM stations
WHERE docks BETWEEN 12 AND 16;