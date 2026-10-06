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
```

Trips schema:

```sql
CREATE TABLE trips (
    trip_id TEXT PRIMARY KEY,
    start_time TEXT NOT NULL,
    end_time TEXT,
    start_station_id TEXT REFERENCES stations(station_id),
    end_station_id TEXT REFERENCES stations(station_id),
    rider_type TEXT,
    bike_type TEXT
);
```

### TODO 0b

```text
cid | name             | type    | notnull | dflt_value | pk
0   | station_id       | TEXT    | 0       | NULL       | 1
1   | station_name     | TEXT    | 1       | NULL       | 0
2   | neighborhood     | TEXT    | 0       | NULL       | 0
3   | latitude         | REAL    | 0       | NULL       | 0
4   | longitude        | REAL    | 0       | NULL       | 0
5   | docks            | INTEGER | 0       | NULL       | 0
6   | year_installed   | INTEGER | 0       | NULL       | 0
```

Primary key: `station_id`

### TODO 0c

I created `SQL-LOG.md` and the `queries/` folder and committed them early with the commit message:

```text
Set up Assignment 7 SQL log and queries
```

### Q0

`PRAGMA table_info(stations)` showed that `station_id` is defined as the primary key. Opening `stations.xlsx` in Excel would show the column values, but it would not show that database constraint.

---

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

---

## Part 2

### TODO 2a

First 5 rows:

```text
station_id | neighborhood       | latitude | longitude
S01        | Downtown           | 35.9649  | -83.9197
S02        | Downtown           | 35.9662  | -83.9184
S03        | Downtown           | 35.9636  | -83.9186
S04        | Old City           | 35.9721  | -83.9151
S05        | World's Fair Park  | 35.9622  | -83.9265
```

### TODO 2b

First 5 rows:

```text
station_id | station_name           | year_installed | age_years
S01        | Market Square          | 2022           | 4
S02        | Gay Street & Union Ave | 2022           | 4
S03        | Krutch Park            | 2022           | 4
S04        | Old City - Jackson Ave | 2022           | 4
S05        | World's Fair Park      | 2022           | 4
```

### TODO 2c

First 5 rows:

```text
trip_id  | start_time          | duration_hr
T0057984 | 2025-01-01 00:06:48 | 0.21
T0073896 | 2025-01-01 00:40:20 | 0.67
T0206129 | 2025-01-01 00:42:40 | 0.46
T0163585 | 2025-01-01 00:42:54 | 0.25
T0094124 | 2025-01-01 01:19:33 | 0.51
```

### Q2d

No. `age_years` does not become a permanent column in the `stations` table; it exists only in the output of that query. A result set is the temporary table of rows and columns returned by a SQL query.

### Q2e

Using `SELECT * FROM trips;` would return every column for all 250,000 trips even though the ops team only needs three columns. Selecting only the required columns makes the result smaller, easier to read, and focused on the question being answered.

---

## Part 3

### TODO 3a

```text
neighborhood
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
```

### TODO 3b

Row count: 25

Last 3 rows:

```text
start_station_id
S23
S24
S99
```

### Q3c

The station ID is `S99`. It appears in the `trips` table but does not have a matching row in the `stations` table. SQLite foreign-key enforcement was not active when the data were loaded, so that unmatched station reference was allowed.

### Q3d

A database can still contain inconsistent versions of what should be the same category unless rules are added to prevent them. `DISTINCT` shows the values that actually exist in the data, so categorical values should be inspected before they are used in filters.

---

## Part 4

### TODO 4a

```text
station_id | station_name              | neighborhood | latitude | longitude | docks | year_installed
S11        | Cumberland Ave & 17th St  | Fort Sanders | 35.9575  | -83.9330  | 16    | 2022
S12        | Fort Sanders - Laurel Ave | Fort Sanders | 35.9601  | -83.9331  | 12    | 2023
```

### TODO 4b

```text
station_id | station_name       | docks
S01        | Market Square      | 20
S05        | World's Fair Park  | 20
S06        | Hodges Library     | 24
S08        | Student Union - UT | 24
```

### TODO 4c

```text
station_id | station_name             | neighborhood | latitude | longitude | docks | year_installed
S06        | Hodges Library           | UT Campus    | 35.9553  | -83.9264  | 24    | 2022
S08        | Student Union - UT       | UT Campus    | 35.9560  | -83.9295  | 24    | 2022
S09        | Neyland Stadium          | UT Campus    | 35.9550  | -83.9250  | 16    | 2023
S11        | Cumberland Ave & 17th St | Fort Sanders | 35.9575  | -83.9330  | 16    | 2022
```

Row count: 4

### TODO 4d

```text
station_id | station_name             | neighborhood | latitude | longitude | docks | year_installed
S06        | Hodges Library           | UT Campus    | 35.9553  | -83.9264  | 24    | 2022
S07        | The Hill - Ayres Hall    | UT Campus    | 35.9546  | -83.9256  | 12    | 2022
S08        | Student Union - UT       | UT Campus    | 35.9560  | -83.9295  | 24    | 2022
S09        | Neyland Stadium          | UT Campus    | 35.9550  | -83.9250  | 16    | 2023
S11        | Cumberland Ave & 17th St | Fort Sanders | 35.9575  | -83.9330  | 16    | 2022
```

Row count: 5

### TODO 4e

```text
station_id | station_name         | neighborhood    | latitude | longitude | docks | year_installed
S14        | South Waterfront     | South Knoxville | 35.9575  | -83.9130  | 12    | 2023
S15        | Suttree Landing Park | South Knoxville | 35.9541  | -83.9060  | 10    | 2024
S16        | Ijams Nature Center  | South Knoxville | 35.9560  | -83.8680  | 10    | 2024
S20        | Zoo Knoxville        | East Knoxville  | 35.9863  | -83.8880  | 10    | 2024
S21        | Caswell Park         | East Knoxville  | 35.9760  | -83.8990  | 10    | 2024
```

### TODO 4f

```text
station_id | station_name              | docks
S02        | Gay Street & Union Ave    | 16
S03        | Krutch Park               | 12
S04        | Old City - Jackson Ave    | 16
S07        | The Hill - Ayres Hall     | 12
S09        | Neyland Stadium           | 16
S10        | Ag Campus - Morgan Hall   | 12
S11        | Cumberland Ave & 17th St  | 16
S12        | Fort Sanders - Laurel Ave | 12
S14        | South Waterfront          | 12
S17        | Happy Holler              | 12
S19        | Broadway & Central        | 12
S22        | Tyson Park                | 12
S23        | Bearden - Kingston Pike   | 12
```

### Q4g

TODO 4c returns 4 rows, while TODO 4d returns 5 rows. TODO 4c correctly answers the ops lead's question because the parentheses make the 16-dock requirement apply to both UT Campus and Fort Sanders stations.

Without parentheses, SQL evaluates `AND` before `OR`. Therefore, TODO 4d includes every UT Campus station regardless of dock count, which is why S07 with only 12 docks appears.

### Q4h

The equivalent condition is:

```sql
WHERE docks >= 12
  AND docks <= 16
```

I would hand a colleague the `BETWEEN 12 AND 16` version because it is shorter and clearly communicates that the dock count must fall within an inclusive range.

---

## Part 5

### TODO 5a

Row count: 23139

First 3 rows:

```text
trip_id  | start_time          | rider_type
T0089973 | 2025-09-01 00:07:55 | member
T0244496 | 2025-09-01 00:07:57 | member
T0004667 | 2025-09-01 00:14:49 | member
```

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
```

### TODO 5d

Exact lowercase match:

```text
Row count: 14164
```

Using `LOWER(rider_type) = 'member'`:

```text
Row count: 14686
```

### Q5e

TODO 5b lost 796 trips compared with TODO 5a. The reason is that `BETWEEN '2025-09-01' AND '2025-09-30'` uses `'2025-09-30'` as the upper-bound text. A timestamp such as `'2025-09-30 18:04:11'` is greater than the shorter text value `'2025-09-30'`, so it is excluded. The half-open range correctly includes every time on September 30.

### Q5f

The naive version missed 522 member trips. This is not a rounding issue because real records were excluded from the answer, so the query gives an incorrect count of member trips.

---

## Part 6

### TODO 6a

```text
station_id | station_name
S02        | Gay Street & Union Ave
S04        | Old City - Jackson Ave
S11        | Cumberland Ave & 17th St
S12        | Fort Sanders - Laurel Ave
```

### TODO 6b

```text
station_id | station_name            | neighborhood
S20        | Zoo Knoxville           | East Knoxville
S21        | Caswell Park            | East Knoxville
S22        | Tyson Park              | West Knoxville
S23        | Bearden - Kingston Pike | Bearden
S24        | Sequoyah Hills Park     | Sequoyah Hills
```

### TODO 6c

```text
station_id | neighborhood
S14        | South Knoxville
S15        | South Knoxville
S16        | South Knoxville
S17        | North Knoxville
S18        | North Knoxville
S19        | North Knoxville
S20        | East Knoxville
S21        | East Knoxville
S22        | West Knoxville
```

### TODO 6d

```text
station_name       | neighborhood    | docks
South Waterfront   | South Knoxville | 12
Happy Holler       | North Knoxville | 12
Broadway & Central | North Knoxville | 12
```

### Q6e

In SQLite, `LIKE` is normally case-insensitive for ASCII text, so `%park%` can match the same rows as `%Park%`. PostgreSQL's `LIKE` is case-sensitive, so the identical query would not necessarily return the same rows.

If I mean case-insensitive matching in PostgreSQL, I would use:

```sql
WHERE station_name ILIKE '%park%'
```

---

## Part 7

### TODO 7a

Row count: 3767

First 3 rows:

```text
trip_id  | start_station_id | start_time
T0168031 | S06              | 2025-01-01 08:17:12
T0043727 | S12              | 2025-01-01 10:24:35
T0237204 | S03              | 2025-01-01 16:18:45
```

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
```

### Q7e

TODO 7c returns 3,767 more rows than TODO 7b. When `end_station_id` is `NULL`, SQL treats the comparison `end_station_id <> 'S01'` as **unknown** rather than true, so those rows do not pass the `WHERE` filter. Adding `OR end_station_id IS NULL` explicitly keeps those 3,767 rows.

### Q7f

I would use TODO 7c if “did not end at Market Square” means every trip that cannot be confirmed as ending at S01, including trips with no recorded end station. However, I would confirm whether the ops lead wants unknown destinations included, because TODO 7b is appropriate if she only wants trips with a known end station that is not S01.

---

## Part 8

### TODO 8a

```text
station_id | station_name              | docks | year_installed
S06        | Hodges Library            | 24    | 2022
S08        | Student Union - UT        | 24    | 2022
S01        | Market Square             | 20    | 2022
S05        | World's Fair Park         | 20    | 2022
S02        | Gay Street & Union Ave    | 16    | 2022
S04        | Old City - Jackson Ave    | 16    | 2022
S11        | Cumberland Ave & 17th St  | 16    | 2022
S03        | Krutch Park               | 12    | 2022
S07        | The Hill - Ayres Hall     | 12    | 2022
S09        | Neyland Stadium           | 16    | 2023
S10        | Ag Campus - Morgan Hall   | 12    | 2023
S12        | Fort Sanders - Laurel Ave | 12    | 2023
S14        | South Waterfront          | 12    | 2023
S17        | Happy Holler              | 12    | 2023
S22        | Tyson Park                | 12    | 2023
S13        | Second Creek Greenway     | 10    | 2023
S19        | Broadway & Central        | 12    | 2024
S15        | Suttree Landing Park      | 10    | 2024
S16        | Ijams Nature Center       | 10    | 2024
S18        | Fourth & Gill             | 10    | 2024
S20        | Zoo Knoxville             | 10    | 2024
S21        | Caswell Park              | 10    | 2024
S23        | Bearden - Kingston Pike   | 12    | 2025
S24        | Sequoyah Hills Park       | 10    | 2025
```

### TODO 8b

```text
station_id | station_name             | docks | year_installed
S04        | Old City - Jackson Ave   | 16    | 2022
S11        | Cumberland Ave & 17th St | 16    | 2022
S03        | Krutch Park              | 12    | 2022
S07        | The Hill - Ayres Hall    | 12    | 2022
S09        | Neyland Stadium          | 16    | 2023
```

### TODO 8c

```text
station_name            | neighborhood    | year_installed
Bearden - Kingston Pike | Bearden         | 2025
Sequoyah Hills Park     | Sequoyah Hills  | 2025
Suttree Landing Park    | South Knoxville | 2024
```

### Q8d

The query is wrong for two reasons. First, it does not select the `docks` column, so it does not show station size. Second, it has no `ORDER BY`, so SQL is not instructed to return the stations with the largest dock counts.

A correct query is:

```sql
SELECT station_name,
       docks
FROM stations
ORDER BY docks DESC
LIMIT 3;
```

---

## Part 9

### TODO 9a

Query:

```sql
SELECT trip_id,
       start_station_id,
       start_time,
       ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) AS duration_hr
FROM trips
WHERE LOWER(rider_type) = 'member'
  AND bike_type = 'classic'
  AND start_station_id IN ('S06', 'S07', 'S08', 'S09')
  AND start_time >= '2025-03-15'
  AND start_time < '2025-04-01'
  AND end_station_id IS NOT NULL
ORDER BY duration_hr ASC
LIMIT 8;
```

Result:

```text
trip_id  | start_station_id | start_time          | duration_hr
T0163787 | S09              | 2025-03-22 08:51:23 | -0.20
T0042244 | S08              | 2025-03-20 13:32:03 | 0.03
T0088672 | S06              | 2025-03-27 17:11:30 | 0.03
T0124681 | S08              | 2025-03-18 19:35:31 | 0.04
T0162779 | S09              | 2025-03-15 09:05:45 | 0.05
T0202713 | S06              | 2025-03-16 06:50:47 | 0.05
T0101111 | S06              | 2025-03-16 14:43:44 | 0.05
T0224454 | S08              | 2025-03-16 17:25:21 | 0.05
```

### TODO 9b

The top row has a negative duration of `-0.20` hours, which is impossible for a real trip. This is the negative-duration data-quality problem from Module 3, caused by an end time that occurs before the start time.

### TODO 9c

Corrected query:

```sql
SELECT trip_id,
       start_station_id,
       start_time,
       ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) AS duration_hr
FROM trips
WHERE LOWER(rider_type) = 'member'
  AND bike_type = 'classic'
  AND start_station_id IN ('S06', 'S07', 'S08', 'S09')
  AND start_time >= '2025-03-15'
  AND start_time < '2025-04-01'
  AND end_station_id IS NOT NULL
  AND end_time > start_time
ORDER BY duration_hr ASC
LIMIT 8;
```

Corrected result:

```text
trip_id  | start_station_id | start_time          | duration_hr
T0042244 | S08              | 2025-03-20 13:32:03 | 0.03
T0088672 | S06              | 2025-03-27 17:11:30 | 0.03
T0124681 | S08              | 2025-03-18 19:35:31 | 0.04
T0162779 | S09              | 2025-03-15 09:05:45 | 0.05
T0202713 | S06              | 2025-03-16 06:50:47 | 0.05
T0101111 | S06              | 2025-03-16 14:43:44 | 0.05
T0224454 | S08              | 2025-03-16 17:25:21 | 0.05
T0051651 | S06              | 2025-03-23 08:44:56 | 0.05
```

### TODO 9d

Pull request URL:

https://github.com/RaymondKojoKyei/ride-knox-analysis/pull/38

The Assignment 7 work was completed on a feature branch, pushed to GitHub, and merged into `main` through a pull request.

### Q9e

The logical evaluation order of the query is:

1. `FROM`
2. `WHERE`
3. `SELECT`
4. `ORDER BY`
5. `LIMIT`

`ORDER BY` can use `duration_hr` because the alias is created by the `SELECT` stage before the rows are sorted.

When I tested a condition using:

```sql
AND duration_hr > 0
```

SQLite accepted the alias and ran the query successfully. However, using a `SELECT` alias in `WHERE` is not portable SQL because `WHERE` is logically evaluated before `SELECT`.

A portable version repeats the expression:

```sql
AND ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) > 0
```

For this particular data-quality check, the clearer version is:

```sql
AND end_time > start_time
```

### Q9f

I would defend `end_station_id IS NOT NULL` most strongly because the ops lead specifically asked for completed trips. Removing that condition would mix never-docked or incomplete trips into the result and would change the meaning of the question rather than simply returning more valid rows.

---

## Part 10 — Challenge

### TODO 10a

Stations whose names contain `Park`:

```text
station_id | station_name
S03        | Krutch Park
S05        | World's Fair Park
S15        | Suttree Landing Park
S21        | Caswell Park
S22        | Tyson Park
S24        | Sequoyah Hills Park
```

Late-night trip row count: **111**

First 6 rows:

```text
trip_id  | start_time          | start_station_id | bike_type
T0165811 | 2025-01-07 03:06:27 | S22              | classic
T0123077 | 2025-01-08 03:49:29 | S03              | classic
T0136097 | 2025-01-21 02:15:03 | S03              | electric
T0081707 | 2025-01-23 03:06:35 | S03              | classic
T0038452 | 2025-02-05 03:26:40 | S05              | electric
T0121246 | 2025-02-14 02:30:31 | S15              | classic
```

### TODO 10b

I first queried the `stations` table to identify station IDs whose station names contained `Park`. I then manually copied those station IDs into an `IN` list in the query against the `trips` table. This manually connected information from the two tables through the station ID.

### Q10c

A SQL `JOIN` would remove the need to copy the station IDs manually. A join can directly connect `trips.start_station_id` to `stations.station_id`. The upcoming module introduces joins for combining related tables.

---

## Reflection + AI Disclosure

### R1

Several queries in this assignment showed that SQL can run successfully and still return the wrong answer. Unlike a Python traceback, which normally signals that execution failed, an incorrect SQL filter can return valid-looking rows without producing an error. I therefore need to check row counts, inspect returned values, and verify the query logic rather than assuming that a query is correct simply because it runs.

### R2 — AI Disclosure

I used ChatGPT as a learning and troubleshooting assistant during this assignment. I used it to help explain SQL concepts and syntax, including `DISTINCT`, date filtering, operator precedence, `LIKE`, `NULL`, aliases, sorting, and query structure.

I ran the SQL queries myself in DB Browser for SQLite, checked the outputs against the database, recorded the results, and reviewed the final queries and conclusions before including them in my submission.

---

## Final Query Verification

I reviewed the submitted `.sql` files to confirm that each query:

- is preceded by a `-- TODO` comment identifying the task;
- uses uppercase SQL keywords;
- places clauses on separate lines for readability;
- uses single quotes for text values;
- ends with a semicolon; and
- runs successfully in DB Browser for SQLite.

No `INSERT`, `UPDATE`, `DELETE`, or `CREATE` statements are included in the submitted `.sql` files.