# DATA 501 — Assignment 8 SQL Log

**Name:** Raymond Kojo Kyei  
**NetID:** rkyei  
**SQL tool used:** DB Browser for SQLite

## Part 0

### Q0c

`COUNT(DISTINCT start_station_id)` is a data-quality diagnostic because the
number of distinct start-station IDs can be compared with the 24 valid stations
in the stations table. An extra ID indicates a trip referencing a station that
is not in the station directory.

`COUNT(DISTINCT rider_type)` is also a diagnostic. Ride Knox has two real
2025 rider categories, but inconsistent capitalization or spelling creates
additional distinct values.

## Part 1

### Q1e

I would report the cleaned average from TODO 1c because it excludes impossible
and implausible trip durations.

I would add this note: "Average duration is calculated only from trips lasting
between 1 minute and 6 hours."

## Part 2

### Q2e

TODO 2d returned 12 rows rather than the 4 meaningful combinations in TODO 2c.
Eight of those rows represent capitalization variants rather than genuinely
different rider types.

`GROUP BY` groups rows according to the actual stored **value**, so values that
differ in capitalization are treated as separate groups.

### Q2f

The wide version would have one row for each normalized rider type and separate
columns for classic-bike and electric-bike trip counts.

In pandas, this type of wide output can be produced with `pivot_table()`.


## Part 3

### Q3c

SQLite produced a clean-looking result rather than an error. The `rider_type`
shown for each bike-type group is simply a value SQLite selected from a row in
that group; it is not a meaningful summary of all rows in the group.

A reader could easily mistake it for a valid grouped value because SQLite does
not visibly warn that the grouping rule was violated.

### Q3d

The grouping rule is that every selected column must either be included in the
`GROUP BY` or be produced by an aggregate function.

PostgreSQL would reject TODO 3b because `rider_type` is neither grouped nor
aggregated. I prefer PostgreSQL's behavior because an explicit error is safer
than receiving a plausible-looking but logically invalid result.

## Part 4

### Q4e

`WHERE` is evaluated before `GROUP BY`, so at the point where the WHERE clause
runs, the grouped counts do not yet exist. Aggregate conditions therefore
belong in `HAVING`, which is evaluated after grouping.

### Q4f

In TODO 4b, `bike_type = 'electric'` and the October date conditions filter
individual trip rows, so they belong in `WHERE`.

`HAVING COUNT(*) >= 300` filters the station groups after those trips have been
grouped. Moving the bike-type condition into HAVING would mix a row-level
condition with a group-level condition and would make the query less correct
and less portable even if SQLite happened to return the same result.

## Part 5

### Q5d

TODO 5b lost ______ rows compared with the 250,000 rows in `trips`.

Rows disappear for two reasons: some trips have `NULL` for `end_station_id`,
and some non-NULL end-station IDs do not have a matching row in `stations`.
An inner join keeps only rows for which the join key matches.

### Q5e

With the provided Ride Knox schema, the two tables do not appear to share an
identically named column, so none of the columns in these queries is actually
ambiguous in SQLite. I still use the required `t.` and `s.` prefixes because
they make the source table of every column explicit and keep join queries
readable.

If two joined tables did contain the same column name and I referred to it
without a table prefix, the database would report an ambiguous-column error.

### Q5f

No. `station_name` is not added to the `trips` table. The JOIN constructs a
temporary result by matching each trip's station ID with the corresponding
station row and returning columns from both tables.

That is the benefit of keeping the trip and station information normalized in
separate tables.


## Part 6

### Q6e

Version 2 is correct because the ops lead asked for all 24 stations, including
stations with zero matching trips.

In Version 1, a station with no matching trip has NULL values on the trips side
of the LEFT JOIN. The date and hour comparisons in the WHERE clause therefore
evaluate to **unknown**, and WHERE removes those rows. Putting the conditions in
the ON clause preserves the station and allows its count to remain zero.

### Q6f

For a station with no matching trips, `COUNT(*)` would still count the preserved
LEFT JOIN row and report 1. `COUNT(t.trip_id)` ignores the NULL trip ID created
by the unmatched join and therefore correctly reports 0.


## Part 7

### Q7c

The two rankings are similar because ____________________ appears high in both.

They differ because ____________________ ranks high for arrivals but not for
departures (or vice versa).

A station that ranks high on arrivals but not departures may be accumulating
bikes, while a station high on departures but not arrivals may be losing bikes
and may require rebalancing.

### Q7d

First, the `LEFT JOIN` and the Q4 date conditions in the `ON` clause preserve
stations with no qualifying arrivals. Changing that logic could silently remove
zero-arrival stations from the ranking.

Second, multiplying by `1.0` before dividing prevents integer division.
Removing it could truncate the arrivals-per-dock ratio and distort the ranking.

### Q7c

The two rankings are similar because ____________________ appears high in both.

They differ because ____________________ ranks high for arrivals but not for
departures (or vice versa).

A station that ranks high on arrivals but not departures may be accumulating
bikes, while a station high on departures but not arrivals may be losing bikes
and may require rebalancing.

## Part 8

### Q8f

I would leave both CTE definitions in place and temporarily replace the final
SELECT with:

```sql
SELECT *
FROM trip_counts;

## Part 9

### TODO 9c

Pull request URL:

https://github.com/RaymondKojoKyei/ride-knox-analysis/pull/39

### Q9d

The two orderings [do / do not] agree.

The change-per-dock ranking better answers the ops lead's question because she
asked about ridership loss relative to installed equipment. Dividing by dock
capacity changes the recommendation by distinguishing a large raw decline at a
large-capacity neighborhood from the same decline at a much smaller network
footprint.

### Q9e

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

```sql
SELECT COUNT(*)
FROM completed_trips;
```

Result:

```text
244115
```

### TODO 9b

Query:

```sql
WITH h1 AS (
    SELECT s.neighborhood,
           COUNT(*) AS h1_casual_trips
    FROM completed_trips AS c
    JOIN stations AS s
      ON c.start_station_id = s.station_id
    WHERE c.rider_type = 'casual'
      AND c.start_time >= '2025-01-01'
      AND c.start_time < '2025-07-01'
    GROUP BY s.neighborhood
),
h2 AS (
    SELECT s.neighborhood,
           COUNT(*) AS h2_casual_trips
    FROM completed_trips AS c
    JOIN stations AS s
      ON c.start_station_id = s.station_id
    WHERE c.rider_type = 'casual'
      AND c.start_time >= '2025-07-01'
      AND c.start_time < '2026-01-01'
    GROUP BY s.neighborhood
),
capacity AS (
    SELECT neighborhood,
           SUM(docks) AS total_docks
    FROM stations
    GROUP BY neighborhood
)
SELECT capacity.neighborhood,
       COALESCE(h1.h1_casual_trips, 0) AS h1_casual_trips,
       COALESCE(h2.h2_casual_trips, 0) AS h2_casual_trips,
       COALESCE(h2.h2_casual_trips, 0)
           - COALESCE(h1.h1_casual_trips, 0) AS change_trips,
       capacity.total_docks,
       ROUND(
           1.0 *
           (
               COALESCE(h2.h2_casual_trips, 0)
               - COALESCE(h1.h1_casual_trips, 0)
           ) / capacity.total_docks,
           1
       ) AS change_per_dock
FROM capacity
LEFT JOIN h1
  ON capacity.neighborhood = h1.neighborhood
LEFT JOIN h2
  ON capacity.neighborhood = h2.neighborhood
ORDER BY change_per_dock ASC;
```

Result:

```text
neighborhood          | h1_casual_trips | h2_casual_trips | change_trips | total_docks | change_per_dock
Fort Sanders          | 6527            | 3650            | -2877        | 28          | -102.8
UT Campus             | 17461           | 10310           | -7151        | 76          | -94.1
Downtown              | 11228           | 6721            | -4507        | 48          | -93.9
Old City              | 3258            | 1913            | -1345        | 16          | -84.1
World's Fair Park     | 4832            | 2791            | -2041        | 30          | -68.0
UT Ag Campus          | 1686            | 986             | -700         | 12          | -58.3
West Knoxville        | 1508            | 810             | -698         | 12          | -58.2
North Knoxville       | 3857            | 2279            | -1578        | 34          | -46.4
South Knoxville       | 3665            | 2180            | -1485        | 32          | -46.4
East Knoxville        | 1372            | 841             | -531         | 20          | -26.6
Sequoyah Hills        | 432             | 251             | -181         | 10          | -18.1
Bearden               | 468             | 270             | -198         | 12          | -16.5
```

### TODO 9c

Pull request URL:

```text
https://github.com/RaymondKojoKyei/ride-knox-analysis/pull/39
```

The Assignment 8 work was completed on the `feature/sql-week8-aggregates`
branch, pushed to GitHub, and merged into `main` through a pull request.

### Q9d

The raw-change ranking and the change-per-dock ranking do not agree.

By raw change, UT Campus had the largest decline, losing 7,151 casual trips,
followed by Downtown with a decline of 4,507 trips and Fort Sanders with a
decline of 2,877 trips. However, when the decline is divided by dock capacity,
Fort Sanders ranks as the hardest-hit neighborhood at -102.8 trips per dock,
followed by UT Campus at -94.1 and Downtown at -93.9.

The change-per-dock ranking better answers the ops lead's question because she
asked which neighborhoods were hit hardest relative to the amount of equipment
installed there. The denominator accounts for differences in dock capacity, so
a smaller neighborhood can have a more severe decline relative to the amount
of equipment it has.

### Q9e

Logic belongs in a view when it represents a shared and reusable definition
that multiple analysts or queries should apply consistently. A CTE is better
for intermediate logic that is specific to one query.

The `completed_trips` definition belongs in a view because the same usable-trip
rules can be reused across different analyses. The view would be the wrong
choice if different analyses required different definitions of a usable trip,
such as different duration thresholds or different rules for incomplete trips.

### Q9f

The Part 9b result shows how casual ridership changed between the first and
second halves of 2025, but it cannot prove that the July 1 price change caused
the decline. Seasonal demand, weather, station conditions, or other operational
factors could also influence ridership.

## Part 10 — Challenge

### Q10c

A neighborhood can have departures and arrivals that balance over the full year
while still having a strong daily pattern, such as many bikes leaving every
morning and returning every evening.

To detect that pattern, I would derive and group by the hour of day from the
trip timestamp, for example with `strftime('%H', start_time)`.

## Reflection + AI Disclosure

### R1

The WHERE-versus-ON mistake in Part 6c was the hardest for me to spot because
both queries ran successfully and returned reasonable-looking counts. To catch
this in future, I would compare the number of grouped rows with the expected
number of stations and specifically check whether stations with zero matches
are still present after a LEFT JOIN.

### R2 — AI Disclosure

I used ChatGPT as a learning and troubleshooting assistant while completing
this assignment. I used it to help explain aggregation, GROUP BY, HAVING,
JOINs, LEFT JOIN behavior, CTEs, views, and SQL query structure. I ran the
queries myself in DB Browser for SQLite, checked the returned results against
the database and assignment anchors, and reviewed the final queries and
conclusions before submission.