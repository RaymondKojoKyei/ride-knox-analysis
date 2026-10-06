```sql
-- TODO 8a: Oldest stations first, breaking ties by largest dock count
SELECT station_id,
       station_name,
       docks,
       year_installed
FROM stations
ORDER BY year_installed ASC,
         docks DESC;

-- TODO 8b: Return rows 6 through 10 using the same ordering
SELECT station_id,
       station_name,
       docks,
       year_installed
FROM stations
ORDER BY year_installed ASC,
         docks DESC
LIMIT 5 OFFSET 5;

-- TODO 8c: Return the 3 newest stations
SELECT station_name,
       neighborhood,
       year_installed
FROM stations
ORDER BY year_installed DESC
LIMIT 3;