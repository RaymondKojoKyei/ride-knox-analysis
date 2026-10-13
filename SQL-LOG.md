# DATA 501 — Assignment 8 SQL Log

**Name:** Raymond Kojo Kyei  
**NetID:** rkyei  
**SQL tool used:** DB Browser for SQLite

---

## Part 0

### TODO 0a

```text
total_trips | recorded_end_station_count | distinct_start_stations | distinct_rider_types
250000      | 246233                     | 25                      | 6
```

### TODO 0b

I added the Part 0 through Part 10 headings to `SQL-LOG.md` and maintained the Assignment 8 SQL files in the `queries/` folder.

### Q0c

The two diagnostic counts are `COUNT(DISTINCT start_station_id)` and `COUNT(DISTINCT rider_type)`.

There are 25 distinct start-station IDs even though the `stations` table contains only 24 valid stations. This shows that one start-station ID in the trip data does not match the station directory. In this database, the extra ID is `S99`.

There are 6 distinct stored rider-type values even though the real rider categories are only `casual` and `member`. The additional values are capitalization variants, showing that the field needs normalization before grouping.

---

## Part 1

### TODO 1a

```text
total_docks | avg_docks_per_station | min_docks | max_docks
330         | 13.8                  | 10        | 24
```

### TODO 1b

```text
trip_count | avg_duration_hr | min_duration_hr | max_duration_hr
250000     | 0.47            | -1.75           | 71.81
```

### TODO 1c

```text
trip_count | avg_duration_hr | min_duration_hr | max_duration_hr
248230     | 0.28            | 0.02            | 3.00
```

### TODO 1d

```text
total_trips | electric_trips | electric_pct
250000      | 95083          | 38.0
```

### Q1e

I would report the cleaned average from TODO 1c, which is **0.28 hours**, because TODO 1b includes impossible or implausible trip durations.

I would add this sentence below the number:

> Average trip duration is calculated only from trips lasting between 1 minute and 6 hours.

### Q1f

Using `100` instead of `100.0` returned:

```text
total_trips | electric_trips | electric_pct
250000      | 95083          | 38.0
```

SQLite performed integer arithmetic because the values involved were integers. This can truncate the fractional part before `ROUND()` is applied. Using `100.0` forces floating-point arithmetic and is safer for percentage calculations.

---

## Part 2

### TODO 2a

First 5 rows:

```text
start_station_id | trip_count
S06              | 26058
S08              | 24959
S01              | 22606
S11              | 18934
S02              | 16542
```

Row count:

```text
25
```

There are 25 groups rather than 24 because `S99` appears in the trip data but is not one of the 24 valid stations.

### TODO 2b

```text
hour_of_day | trip_count
17          | 25178
08          | 21766
18          | 21404
16          | 19220
12          | 16690
07          | 14910
```

### TODO 2c

```text
bike_type | rider_type | trip_count | avg_duration_min
classic   | casual     | 56538      | 34.6
electric  | casual     | 34920      | 34.8
classic   | member     | 98379      | 23.9
electric  | member     | 60163      | 25.9
```

### TODO 2d

```text
bike_type | rider_type | trip_count | avg_duration_min
classic   | CASUAL     | 852        | 27.7
electric  | CASUAL     | 518        | 36.8
classic   | Casual     | 1188       | 33.0
electric  | Casual     | 710        | 52.8
classic   | MEMBER     | 1481       | 24.6
electric  | MEMBER     | 882        | 22.3
classic   | Member     | 1970       | 20.0
electric  | Member     | 1192       | 27.6
classic   | casual     | 54498      | 34.7
electric  | casual     | 33692      | 34.4
classic   | member     | 94928      | 24.0
electric  | member     | 58089      | 26.0
```

Row count:

```text
12
```

### Q2e

TODO 2d returned 12 rows. Only 4 rows represent the four meaningful bike-type/rider-type combinations, so 8 rows are caused by capitalization variants rather than genuinely different rider categories.

`GROUP BY` groups according to the actual stored **value**, so values with different capitalization are treated as different groups.

### Q2f

The wide version would have one row for each normalized rider type and separate columns for classic-bike and electric-bike trip counts.

In pandas, this type of wide output can be produced using `pivot_table()`.

---

## Part 3

### TODO 3a

```text
rider_type | classic | electric
casual     | 56538   | 34920
member     | 98379   | 60163
```

### TODO 3b

This query intentionally violates the strict grouping rule.

```text
bike_type | rider_type | trip_count
classic   | casual     | 154917
electric  | casual     | 95083
```

### Q3c

TODO 3b produced a clean-looking result rather than an error or warning.

Because `rider_type` was neither grouped nor aggregated, SQLite selected a rider-type value from a row within each bike-type group. That value does not summarize all rows in the group.

A reader would have no visible warning that the grouping rule was violated, so the result could easily be mistaken for a correct grouped answer.

### Q3d

My grouping rule is that every selected column in an aggregate query should either appear in the `GROUP BY` clause or be inside an aggregate function.

PostgreSQL would reject TODO 3b because `rider_type` is neither grouped nor aggregated. I would prefer PostgreSQL's behavior because an explicit error is safer than a plausible-looking but logically invalid result.

---

## Part 4

### TODO 4a

```text
start_station_id | trip_count
S06              | 26058
S08              | 24959
S01              | 22606
S11              | 18934
S02              | 16542
S05              | 15398
```

### TODO 4b

```text
start_station_id | trip_count
S08              | 812
S06              | 808
S01              | 691
S11              | 573
S02              | 552
S05              | 454
S07              | 419
S09              | 405
S04              | 390
S03              | 323
```

### TODO 4c

```text
month   | trip_count
2025-04 | 25597
2025-05 | 29843
2025-06 | 31528
2025-07 | 27134
```

### TODO 4d

DB Browser returned:

```text
Execution finished with errors.
Result: misuse of aggregate: COUNT()
```

### Q4e

`WHERE` runs **before `GROUP BY`** in SQL's logical evaluation order.

When the `WHERE` clause is evaluated, the grouped `COUNT(*)` values do not yet exist. Therefore, SQLite reports a misuse-of-aggregate error. Aggregate conditions belong in `HAVING`, which is evaluated after grouping.

### Q4f

In TODO 4b, the conditions `bike_type = 'electric'` and the October date range filter individual trip rows, so they belong in `WHERE`.

`HAVING COUNT(*) >= 300` filters the station groups after the qualifying trips have been counted.

Moving the `bike_type` condition into `HAVING` would be a bad idea because it is a row-level condition rather than a group-level aggregate condition. Even if SQLite returned the same result in one case, the query would be less clear and less portable.

---

## Part 5

### TODO 5a

Row count:

```text
16312
```

First 5 rows:

```text
trip_id  | start_time          | station_name                  | docks
T0094124 | 2025-01-01 01:19:33 | Old City - Jackson Ave        | 16
T0158367 | 2025-01-01 06:14:57 | Cumberland Ave & 17th St      | 16
T0115606 | 2025-01-01 07:49:31 | Fort Sanders - Laurel Ave     | 12
T0051723 | 2025-01-01 08:28:33 | Fort Sanders - Laurel Ave     | 12
T0139613 | 2025-01-01 08:46:28 | Old City - Jackson Ave        | 16
```

### TODO 5b

```text
joined_rows
246233
```

### TODO 5c

```text
neighborhood       | trip_count | avg_duration_min
UT Campus          | 78141      | 28.7
Downtown           | 49760      | 27.6
Fort Sanders       | 28408      | 28.9
World's Fair Park  | 21455      | 25.1
North Knoxville    | 17065      | 28.8
South Knoxville    | 16331      | 26.9
Old City           | 14269      | 30.2
UT Ag Campus       | 7255       | 30.1
West Knoxville     | 6651       | 32.8
East Knoxville     | 6372       | 26.6
Bearden            | 2095       | 32.7
Sequoyah Hills     | 1935       | 35.4
```

### Q5d

TODO 5b lost **3,767 rows** compared with the 250,000 rows in `trips`.

An inner join can lose rows when the join key is `NULL` or when a non-NULL key has no matching row in the other table. In this result, the 3,767 lost rows are the trips whose `end_station_id` is `NULL`. The recorded end-station IDs match the station table.

This differs from the class example using `start_station_id`, where 263 trips were lost because `S99` was a non-NULL station ID that did not exist in `stations`.

### Q5e

With this Ride Knox schema, none of the columns used in TODO 5a or TODO 5c is actually ambiguous by name because the two tables do not share an identically named selected column.

I still use `t.` and `s.` prefixes because they clearly identify the source table. If two joined tables contained a column with the same name and I referenced it without a prefix, the database would report an ambiguous-column error.

### Q5f

No. Running TODO 5a does not store `station_name` in the `trips` table.

The join temporarily matches each trip's station ID to the corresponding station row and produces a result containing columns from both tables. Keeping station information in a separate table avoids repeating the same station details in every trip record.

---

## Part 6

### TODO 6a

```text
end_station_id | trip_count
NULL           | 3767
```

### TODO 6b

```text
No rows returned.
```

This means that no `station_name` appears more than once in the `stations` table.

### TODO 6c — Version 1

```text
station_id | station_name                  | late_night_trips
S01        | Market Square                 | 5
S02        | Gay Street & Union Ave        | 7
S03        | Krutch Park                   | 4
S04        | Old City - Jackson Ave        | 5
S05        | World's Fair Park             | 3
S06        | Hodges Library                | 13
S07        | The Hill - Ayres Hall         | 3
S08        | Student Union - UT            | 8
S09        | Neyland Stadium               | 6
S10        | Ag Campus - Morgan Hall       | 1
S11        | Cumberland Ave & 17th St      | 3
S12        | Fort Sanders - Laurel Ave     | 1
S13        | Second Creek Greenway         | 1
S14        | South Waterfront              | 1
S16        | Ijams Nature Center           | 2
S17        | Happy Holler                  | 1
S18        | Fourth & Gill                 | 1
S19        | Broadway & Central            | 1
S20        | Zoo Knoxville                 | 2
S21        | Caswell Park                  | 2
S22        | Tyson Park                    | 2
S23        | Bearden - Kingston Pike       | 1
```

Row count:

```text
22
```

### TODO 6c — Version 2

```text
station_id | station_name                  | late_night_trips
S01        | Market Square                 | 5
S02        | Gay Street & Union Ave        | 7
S03        | Krutch Park                   | 4
S04        | Old City - Jackson Ave        | 5
S05        | World's Fair Park             | 3
S06        | Hodges Library                | 13
S07        | The Hill - Ayres Hall         | 3
S08        | Student Union - UT            | 8
S09        | Neyland Stadium               | 6
S10        | Ag Campus - Morgan Hall       | 1
S11        | Cumberland Ave & 17th St      | 3
S12        | Fort Sanders - Laurel Ave     | 1
S13        | Second Creek Greenway         | 1
S14        | South Waterfront              | 1
S15        | Suttree Landing Park          | 0
S16        | Ijams Nature Center           | 2
S17        | Happy Holler                  | 1
S18        | Fourth & Gill                 | 1
S19        | Broadway & Central            | 1
S20        | Zoo Knoxville                 | 2
S21        | Caswell Park                  | 2
S22        | Tyson Park                    | 2
S23        | Bearden - Kingston Pike       | 1
S24        | Sequoyah Hills Park           | 0
```

Row count:

```text
24
```

### TODO 6d

```text
station_name                  | neighborhood       | late_night_trips
Sequoyah Hills Park           | Sequoyah Hills     | 0
Suttree Landing Park          | South Knoxville    | 0
Ag Campus - Morgan Hall       | UT Ag Campus       | 1
Bearden - Kingston Pike       | Bearden            | 1
Broadway & Central            | North Knoxville    | 1
Fort Sanders - Laurel Ave     | Fort Sanders       | 1
Fourth & Gill                 | North Knoxville    | 1
Happy Holler                  | North Knoxville    | 1
Second Creek Greenway         | World's Fair Park  | 1
South Waterfront              | South Knoxville    | 1
```

### Q6e

Version 2's **24 rows** are correct because the ops lead asked for all 24 stations, including stations with zero qualifying trips.

In Version 1, stations without matching qualifying trips have `NULL` values on the trips side of the `LEFT JOIN`. The January and hour conditions in the `WHERE` clause evaluate to **unknown** for those rows, so `WHERE` removes them.

Moving those conditions into the `ON` clause preserves all stations and allows stations without matches to appear with a count of zero.

### Q6f

For a station with no matching trips, `COUNT(*)` would report **1** because the `LEFT JOIN` preserves one result row for that station.

`COUNT(t.trip_id)` ignores the `NULL` trip ID on the unmatched row, so it correctly reports **0**.

---

## Part 7

### TODO 7a

Top 5:

```text
station_name                  | neighborhood | docks | q4_arrivals | arrivals_per_dock
Cumberland Ave & 17th St      | Fort Sanders | 16    | 3381        | 211.31
The Hill - Ayres Hall         | UT Campus    | 12    | 2454        | 204.50
Market Square                 | Downtown     | 20    | 3919        | 195.95
Hodges Library                | UT Campus    | 24    | 4527        | 188.63
Student Union - UT            | UT Campus    | 24    | 4254        | 177.25
```

Bottom 5:

```text
station_name                  | neighborhood       | docks | q4_arrivals | arrivals_per_dock
Suttree Landing Park          | South Knoxville    | 10    | 647         | 64.70
Zoo Knoxville                 | East Knoxville     | 10    | 630         | 63.00
Caswell Park                  | East Knoxville     | 10    | 525         | 52.50
Sequoyah Hills Park           | Sequoyah Hills     | 10    | 323         | 32.30
Bearden - Kingston Pike       | Bearden            | 12    | 372         | 31.00
```

### TODO 7b

The query counts trips that ended at valid stations during Q4 2025, while excluding trips outside Q4, trips without a recorded end station, and end-station IDs that do not match the station table.

### Q7c

The top five stations in the Q4 arrivals-per-dock result are the same five, in the same order, as the departures-per-dock comparison: Cumberland Ave & 17th St, The Hill - Ayres Hall, Market Square, Hodges Library, and Student Union - UT.

The difference is that the arrival ranking is based only on Q4 arrivals, while the comparison result uses full-year departures, so the actual rate values are not directly comparable.

A station that ranks high on arrivals but not departures may be accumulating bikes. A station that ranks high on departures but not arrivals may be losing bikes and may require additional rebalancing.

### Q7d

First, the Q4 date conditions are in the `ON` clause of the `LEFT JOIN`. Moving those conditions to `WHERE` could remove stations with zero qualifying arrivals.

Second, the calculation multiplies by `1.0` before division. Removing the floating-point multiplier could cause integer division and truncate the arrivals-per-dock values.

---

## Part 8

### TODO 8a

```text
neighborhood       | trip_count
UT Campus          | 78141
Downtown           | 49760
Fort Sanders       | 28408
World's Fair Park  | 21455
```

### TODO 8b

Query:

```sql
SELECT ROUND(AVG(monthly_count), 1) AS avg_monthly_trips,
       MIN(monthly_count) AS min_monthly_trips,
       MAX(monthly_count) AS max_monthly_trips
FROM (
    SELECT strftime('%Y-%m', start_time) AS month,
           COUNT(*) AS monthly_count
    FROM trips
    WHERE start_time >= '2025-01-01'
      AND start_time < '2026-01-01'
    GROUP BY strftime('%Y-%m', start_time)
) AS monthly_counts;
```

Result:

```text
avg_monthly_trips | min_monthly_trips | max_monthly_trips
20833.3           | 10335             | 31528
```

### TODO 8c

Query:

```sql
WITH monthly_counts AS (
    SELECT strftime('%Y-%m', start_time) AS month,
           COUNT(*) AS monthly_count
    FROM trips
    WHERE start_time >= '2025-01-01'
      AND start_time < '2026-01-01'
    GROUP BY strftime('%Y-%m', start_time)
)
SELECT ROUND(AVG(monthly_count), 1) AS avg_monthly_trips,
       MIN(monthly_count) AS min_monthly_trips,
       MAX(monthly_count) AS max_monthly_trips
FROM monthly_counts;
```

Result:

```text
avg_monthly_trips | min_monthly_trips | max_monthly_trips
20833.3           | 10335             | 31528
```

### TODO 8d

```text
station_name                | docks | trip_count | trips_per_dock
Bearden - Kingston Pike     | 12    | 2095       | 174.6
Sequoyah Hills Park         | 10    | 1935       | 193.5
Caswell Park                | 10    | 2835       | 283.5
Zoo Knoxville               | 10    | 3537       | 353.7
Suttree Landing Park        | 10    | 3776       | 377.6
```

### Q8e

I would hand the CTE version to a reviewer because the intermediate monthly counts are given a meaningful name and separated from the final summary. This makes the logic easier to read from top to bottom.

### Q8f

I would leave the CTE definitions in place and temporarily replace the final `SELECT` with:

```sql
SELECT *
FROM trip_counts;
```

This allows me to inspect the first CTE without deleting the rest of the query structure.

---

## Part 9

### TODO 9a

CREATE VIEW statement:

```sql
CREATE VIEW completed_trips AS
SELECT trip_id,
       start_time,
       start_station_id,
       end_station_id,
       LOWER(rider_type) AS rider_type,
       bike_type,
       ROUND(
           (julianday(end_time) - julianday(start_time)) * 24 * 60,
           1
       ) AS duration_min,
       strftime('%Y-%m', start_time) AS month
FROM trips
WHERE start_station_id <> 'S99'
  AND end_station_id IS NOT NULL
  AND (julianday(end_time) - julianday(start_time)) * 24 * 60
      BETWEEN 2 AND 720;
```

Row-count check:

```text
244115
```

First 5 rows used as an additional check:

```text
trip_id  | start_time          | start_station_id | end_station_id | rider_type | bike_type | duration_min | month
T0057984 | 2025-01-01 00:06:48 | S17              | S16            | casual     | electric  | 12.5         | 2025-01
T0073896 | 2025-01-01 00:40:20 | S09              | S08            | casual     | classic   | 40.0         | 2025-01
T0206129 | 2025-01-01 00:42:40 | S21              | S09            | member     | classic   | 27.8         | 2025-01
T0163585 | 2025-01-01 00:42:54 | S06              | S06            | casual     | electric  | 15.0         | 2025-01
T0094124 | 2025-01-01 01:19:33 | S04              | S12            | casual     | electric  | 30.8         | 2025-01
```

### TODO 9b

```text
neighborhood       | h1_casual_trips | h2_casual_trips | change_trips | total_docks | change_per_dock
Fort Sanders       | 6527            | 3650            | -2877        | 28          | -102.8
UT Campus          | 17461           | 10310           | -7151        | 76          | -94.1
Downtown           | 11228           | 6721            | -4507        | 48          | -93.9
Old City           | 3258            | 1913            | -1345        | 16          | -84.1
World's Fair Park  | 4832            | 2791            | -2041        | 30          | -68.0
UT Ag Campus       | 1686            | 986             | -700         | 12          | -58.3
West Knoxville     | 1508            | 810             | -698         | 12          | -58.2
North Knoxville    | 3857            | 2279            | -1578        | 34          | -46.4
South Knoxville    | 3665            | 2180            | -1485        | 32          | -46.4
East Knoxville     | 1372            | 841             | -531         | 20          | -26.6
Sequoyah Hills     | 432             | 251             | -181         | 10          | -18.1
Bearden            | 468             | 270             | -198         | 12          | -16.5
```

### TODO 9c

Pull request URL:

https://github.com/RaymondKojoKyei/ride-knox-analysis/pull/41

The Assignment 8 work was completed through a feature branch and merged into `main` through a pull request.

### Q9d

The raw-change ranking and the change-per-dock ranking do not agree.

By raw change, UT Campus had the largest decline at -7,151 trips, followed by Downtown at -4,507 and Fort Sanders at -2,877.

By change per dock, Fort Sanders is the hardest hit at -102.8 trips per dock, followed by UT Campus at -94.1 and Downtown at -93.9.

The change-per-dock ranking better answers the ops lead's question because she asked about ridership loss relative to the amount of installed equipment. Dividing by dock capacity accounts for differences in neighborhood network size.

### Q9e

Logic belongs in a view when it represents a shared and reusable definition that multiple analysts or queries should apply consistently. A CTE is better for intermediate logic that is specific to one query.

The `completed_trips` definition belongs in a view because the same usable-trip rules can be reused across analyses. The view would be the wrong choice if different analyses required different definitions of a usable trip, such as different duration thresholds or different rules for incomplete trips.

### Q9f

The result shows how casual ridership changed between the first and second halves of 2025, but it cannot prove that the July 1 price change caused the decline.

Seasonal demand, weather, station conditions, and other operational factors could also affect ridership.

---

## Part 10 — Challenge

### TODO 10a

```text
neighborhood       | quietest_month_trips | busiest_month_trips | busiest_to_quietest_ratio
World's Fair Park  | 850                  | 2712                | 3.19
South Knoxville    | 652                  | 2071                | 3.18
Old City           | 564                  | 1760                | 3.12
Fort Sanders       | 1140                 | 3536                | 3.10
Downtown           | 1958                 | 6031                | 3.08
UT Ag Campus       | 298                  | 911                 | 3.06
East Knoxville     | 259                  | 789                 | 3.05
North Knoxville    | 696                  | 2109                | 3.03
Bearden            | 86                   | 261                 | 3.03
UT Campus          | 3185                 | 9583                | 3.01
West Knoxville     | 269                  | 796                 | 2.96
Sequoyah Hills     | 80                   | 219                 | 2.74
```

World's Fair Park has the largest seasonal swing, with its busiest month having approximately 3.19 times as many completed trips as its quietest month.

### TODO 10b

```text
neighborhood       | total_departures | total_arrivals | departure_minus_arrival
South Knoxville    | 15975            | 15628          | 347
World's Fair Park  | 21031            | 20787          | 244
West Knoxville     | 6468             | 6448           | 20
UT Ag Campus       | 7082             | 7063           | 19
Old City           | 13921            | 13915          | 6
North Knoxville    | 16665            | 16686          | -21
Sequoyah Hills     | 1901             | 1931           | -30
Bearden            | 2046             | 2086           | -40
Downtown           | 48668            | 48753          | -85
UT Campus          | 76363            | 76464          | -101
East Knoxville     | 6252             | 6412           | -160
Fort Sanders       | 27743            | 27942          | -199
```

South Knoxville loses the most bikes over the year because it has 347 more departures than arrivals.

Fort Sanders gains the most bikes because it has 199 more arrivals than departures.

### Q10c

A neighborhood can have a full-year difference near zero while still have a strong daily imbalance, such as many bikes leaving during the morning and returning later in the day.

To detect that pattern, I would derive and group by an `hour_of_day` value from the trip timestamp, such as using `strftime('%H', start_time)` for departures.

---

## Reflection + AI Disclosure

### R1

The WHERE-versus-ON issue in TODO 6c was the hardest for me to spot because both versions ran successfully and returned reasonable-looking results.

To catch this type of mistake in the future, I would compare the number of result rows with the expected number of stations and specifically check whether stations with zero matches are still present after a `LEFT JOIN`.

### R2 — AI Disclosure

I used ChatGPT as a learning and troubleshooting assistant during this assignment. I used it to help explain SQL concepts, troubleshoot DB Browser and database-file issues, review query structure, and organize the final SQL log.

I ran the SQL queries myself in DB Browser for SQLite, checked the returned results against the database and assignment requirements, and used my actual query outputs in the final submission.