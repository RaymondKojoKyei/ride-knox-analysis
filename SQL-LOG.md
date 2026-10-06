# DATA 501 — Assignment 7 SQL Log

**Name:** Raymond Kojo Kyei  
**NetID:** rkyei  
**SQL tool used:** DB Browser for SQLite

## Part 0

### TODO 0a

Tables:

```text
stations
trips


trip_id           TEXT PRIMARY KEY
start_time        TEXT NOT NULL
end_time          TEXT
start_station_id  TEXT REFERENCES stations(station_id)
end_station_id    TEXT REFERENCES stations(station_id)
rider_type        TEXT
bike_type         TEXT

0 | station_id     | TEXT    | 0 | NULL | 1
1 | station_name   | TEXT    | 1 | NULL | 0
2 | neighborhood   | TEXT    | 0 | NULL | 0
3 | latitude       | REAL    | 0 | NULL | 0
4 | longitude      | REAL    | 0 | NULL | 0
5 | docks          | INTEGER | 0 | NULL | 0
6 | year_installed | INTEGER | 0 | NULL | 0


That Q0 answer directly addresses what the instructor is asking. :chatgpt-content-reference{index="7"}

---

## Step 5 — Create the `queries` folder

In PowerShell:

```powershell
mkdir queries


## Part 0

### TODO 0a

Tables:

```text
stations
trips

cid | name             | type | notnull | dflt_value | pk
0   | trip_id          | TEXT | 0       | NULL       | 1
1   | start_time       | TEXT | 1       | NULL       | 0
2   | end_time         | TEXT | 0       | NULL       | 0
3   | start_station_id | TEXT | 0       | NULL       | 0
4   | end_station_id   | TEXT | 0       | NULL       | 0
5   | rider_type       | TEXT | 0       | NULL       | 0
6   | bike_type        | TEXT | 0       | NULL       | 0


cid | name           | type    | notnull | dflt_value | pk
0   | station_id     | TEXT    | 0       | NULL       | 1
1   | station_name   | TEXT    | 1       | NULL       | 0
2   | neighborhood   | TEXT    | 0       | NULL       | 0
3   | latitude       | REAL    | 0       | NULL       | 0
4   | longitude      | REAL    | 0       | NULL       | 0
5   | docks          | INTEGER | 0       | NULL       | 0
6   | year_installed | INTEGER | 0       | NULL       | 0

Primary key: station_id

Q0
PRAGMA table_info(stations) showed that station_id is defined as the primary key. Opening stations.xlsx in Excel would show the columns and values, but it would not show the database constraint that defines station_id as the primary key.

CREATE TABLE trips (
    trip_id           TEXT PRIMARY KEY,
    start_time        TEXT NOT NULL,
    end_time          TEXT,
    start_station_id  TEXT REFERENCES stations(station_id),
    end_station_id    TEXT REFERENCES stations(station_id),
    rider_type        TEXT,
    bike_type         TEXT
)


## Part 1
### TODO 1a

Primary keys:

- `trips.trip_id` — primary key of the `trips` table
- `stations.station_id` — primary key of the `stations` table

Foreign keys:

- `trips.start_station_id` → `stations.station_id`
- `trips.end_station_id` → `stations.station_id`

### TODO 1b

The database stores station information once in the `stations` table instead of repeating `start_station_name` in every trip row. Trips keep only the station ID, which links back to the station record. This prevents the inconsistent station-name problem from Modules 2–3, where the same station could appear with different capitalization or extra spaces in the flat CSV.

### TODO 1c

Only one row needs to change: the row for `S15` in the `stations` table. Its latitude and longitude can be updated once there. In a flat CSV where station information is repeated across trip rows, the same station information could have to be changed in many rows, creating a risk of inconsistent values.

### Q1d

The `PRIMARY KEY` constraint on `trips.trip_id` rejected the 600 duplicate rows because a primary key must be unique. This is better than using `drop_duplicates()` after loading because the database prevents duplicate trip IDs from entering the table in the first place and continuously enforces that data-integrity rule.


## Part 2

### TODO 2a

```text
station_id | neighborhood      | latitude | longitude
S01        | Downtown          | 35.9649  | -83.9197
S02        | Downtown          | 35.9662  | -83.9184
S03        | Downtown          | 35.9636  | -83.9186
S04        | Old City          | 35.9721  | -83.9151
S05        | World's Fair Park | 35.9622  | -83.9265


station_id | station_name          | year_installed | age_years
S01        | Market Square         | 2022           | 4
S02        | Gay Street & Union Ave| 2022           | 4
S03        | Krutch Park           | 2022           | 4
S04        | Old City - Jackson Ave| 2022           | 4
S05        | World's Fair Park     | 2022           | 4

### Q2d

No. `age_years` does not become a permanent column in the `stations` table; it exists only in the output of that query. A result set is the temporary table of rows and columns returned by a SQL query.

### Q2e

Using `SELECT * FROM trips;` would return every column for all 250,000 trips even though the ops team only needs three columns. Selecting only the required columns makes the result smaller, easier to read, and focused on the question being answered.

## Part 3

Bearden
Downtown
East Knoxville
Fort Sanders
North Knoxville
Old City
Sequoyah Hills
South Knoxville
UT Ag Campus
UT Campus
West Knoxville
World's Fair Park

### TODO 3b

Row count: 25

Last 3 rows:

```text
start_station_id
S23
S24
S99

### Q3c

The station ID is `S99`. It is an unknown or external station ID that appears in the trip data but does not have a matching row in the `stations` table. The database allowed it because SQLite foreign-key enforcement was not active when those trip records were loaded, so the reference was not rejected.

### Q3d

A database can store inconsistent versions of what should be the same category unless rules are added to prevent it. `DISTINCT` shows the values that actually exist in the data, so it is important to inspect categorical columns before filtering them.


## Part 4
### Q4g

TODO 4c returns 4 rows, while TODO 4d returns 5 rows. TODO 4c correctly answers the ops lead's question because the parentheses make the 16-dock requirement apply to both UT Campus and Fort Sanders stations.

Without parentheses, SQL evaluates `AND` before `OR`. As a result, 4d is interpreted as all UT Campus stations OR Fort Sanders stations with at least 16 docks, which incorrectly includes S07 with only 12 docks.

### Q4h

The equivalent condition is:

```sql
WHERE docks >= 12
  AND docks <= 16


  ### TODO 5a

Row count: 23139

First 3 rows:

```text
trip_id  | start_time          | rider_type
T0089973 | 2025-09-01 00:07:55 | member
T0244496 | 2025-09-01 00:07:57 | member
T0004667 | 2025-09-01 00:14:49 | member

### TODO 5b

Row count: 22343


### TODO 5c

Row count: 10912

First 3 rows:

```text
trip_id  | start_time
T0241055 | 2025-03-15 00:25:55
T0179889 | 2025-03-15 00:31:29
T0134722 | 2025-03-15 00:51:01

### TODO 5d

Exact lowercase match:

Row count: 14164

Using `LOWER(rider_type)`:

Row count: 14686

### Q5e

TODO 5b lost 796 trips compared with TODO 5a. The reason is that `BETWEEN '2025-09-01' AND '2025-09-30'` treats the upper bound as the text value `'2025-09-30'`, so a timestamp such as `'2025-09-30 18:04:11'` is greater than that upper-bound text and is excluded. The half-open range correctly includes all times on September 30.

### Q5f

The naive version missed 522 member trips. This is not just a rounding issue because those are real records being excluded from the answer, so the query gives an incorrect count of member trips.

## Part 6

### Q6e

In SQLite, `LIKE` is usually case-insensitive for ASCII text, so `%park%` can match the same rows as `%Park%`. In PostgreSQL, `LIKE` is case-sensitive, so the identical query would not necessarily return the same rows.

If I mean case-insensitive matching in PostgreSQL, I would use `ILIKE`, for example:

```sql
WHERE station_name ILIKE '%park%'

## Part 7

### TODO 7a

Row count: 3767

First 3 rows:

```text
trip_id  | start_station_id | start_time
T0168031 | S06              | 2025-01-01 08:17:12
T0043727 | S12              | 2025-01-01 10:24:35
T0237204 | S03              | 2025-01-01 16:18:45


### TODO 7b

Row count: 223917

### TODO 7c

Row count: 227684

### TODO 7d

Row count: 238

First 3 rows:

```text
trip_id  | start_station_id
T0084969 | S16
T0197506 | S14
T0238948 | S15

### Q7f

I would use TODO 7c if “did not end at Market Square” means every trip that cannot be confirmed as ending at S01, including trips with no recorded end station. However, I would confirm whether the ops lead wants unknown destinations included, because TODO 7b is appropriate if she only wants trips with a known end station that is not S01.


## Part 8

### TODO 8c

```text
station_name             | neighborhood     | year_installed
Bearden - Kingston Pike  | Bearden          | 2025
Sequoyah Hills Park      | Sequoyah Hills   | 2025
Suttree Landing Park     | South Knoxville  | 2024

### Q8d

The query is wrong for two reasons. First, it does not select the `docks` column, so it does not even show station size. Second, it has no `ORDER BY`, so SQL is not instructed to return the stations with the largest dock counts.

A correct query would be:

```sql
SELECT station_name,
       docks
FROM stations
ORDER BY docks DESC
LIMIT 3;


## Part 9

### TODO 9b

The top row has a negative duration of `-0.20` hours, which is impossible for a real trip. This is the negative-duration data-quality problem from Module 3, caused by an end time that occurs before the start time.

### Q9e

The logical evaluation order is:

1. `FROM`
2. `WHERE`
3. `SELECT`
4. `ORDER BY`
5. `LIMIT`

`ORDER BY` can use `duration_hr` because the alias is created in the `SELECT` stage before the rows are sorted.

When I tried `WHERE duration_hr > 0` in SQLite, the query ran successfully. However, using a `SELECT` alias in `WHERE` is not portable across database systems because `WHERE` is logically evaluated before `SELECT`.

A portable version would repeat the full expression:

```sql
AND ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) > 0

### Q9f

I would defend `end_station_id IS NOT NULL` most strongly because the ops lead specifically asked for completed trips. Removing that condition would mix never-docked or incomplete trips into the result and would change the meaning of the question rather than simply returning more valid rows.