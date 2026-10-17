# Ride Knox v2 Data Dictionary

**Project:** DATA 501 SQL Module Project — *Own the Database: Ride Knox Goes Upstream for Good*

This document describes the production design, staging/reconciliation structures, business rules, and the trade-offs behind the design.

## Design decisions

### Rider products
I represent rider products in the `rider_products` lookup table rather than embedding a fixed two-value `CHECK` inside `trips`. The old rule already failed when Day Pass launched. With a lookup, a legitimate future product can be registered as a row rather than requiring a rebuild of the trip structure. The trade-off is that the lookup must be maintained: if a new legitimate product is not registered before a load, its rows will be refused until the team reviews and adds it.

### Bike types
Bike types use the same lookup-table approach. July introduces a `cargo` category tied to the downtown pilot, which demonstrates why a permanent `classic/electric` list would be brittle. The cost is another controlled lookup that must be maintained, but the benefit is that unexpected values cannot silently enter production.

### Historical dock capacity
Dock counts are stored in `station_capacity_history`, not overwritten in `stations`. Each row carries an effective date, so a report can derive the docks that were available at the time being analyzed. This preserves the 2025 baseline while representing the S06/S08 expansions on 2026-02-15 and S25's opening on 2026-03-01.

### Impossible versus implausible
The constrained trip store refuses business impossibilities such as duplicate trip IDs, missing required IDs/times, impossible time order, unknown stations, and unregistered products or bike types. Positive trips shorter than 1 minute or longer than 6 hours are treated as implausible rather than impossible: they are retained with `duration_flag = 1` but excluded from the shared reporting view. That keeps the source evidence available for audit while preventing unusual records from silently shaping routine reporting.

## Production tables

### `rider_products`
| Column | Type | Constraint | Meaning |
|---|---|---|---|
| `product_code` | TEXT | PRIMARY KEY, NOT NULL | Normalized code such as `member`, `casual`, `day_pass` |
| `product_name` | TEXT | NOT NULL | Human-readable product label |
| `launch_date` | TEXT | nullable | Earliest legitimate date when known |

### `bike_types`
| Column | Type | Constraint | Meaning |
|---|---|---|---|
| `bike_type` | TEXT | PRIMARY KEY, NOT NULL | Normalized equipment code |
| `description` | TEXT | NOT NULL | Human-readable description |

### `stations`
| Column | Type | Constraint | Meaning |
|---|---|---|---|
| `station_id` | TEXT | PRIMARY KEY, NOT NULL; starts with `S` | Stable station identifier |
| `station_name` | TEXT | NOT NULL | Current station name |
| `neighborhood` | TEXT | nullable | Neighborhood |
| `latitude` | REAL | -90 to 90 if present | Latitude |
| `longitude` | REAL | -180 to 180 if present | Longitude |
| `year_installed` | INTEGER | 2000–2100 | Installation year |

Station names are not repeated in `trips`; reports join to `stations` when names are needed.

### `station_capacity_history`
| Column | Type | Constraint | Meaning |
|---|---|---|---|
| `station_id` | TEXT | composite PK, FK → `stations` | Station |
| `effective_date` | TEXT | composite PK, NOT NULL | Date the capacity became effective |
| `docks` | INTEGER | NOT NULL; > 0 | Dock capacity |
| `event_type` | TEXT | baseline/expansion/opening | Capacity event type |
| `note` | TEXT | nullable | Audit explanation |

### `trips`
| Column | Type | Constraint | Meaning |
|---|---|---|---|
| `trip_id` | TEXT | PRIMARY KEY, NOT NULL; starts with `T` | Vendor trip ID |
| `start_time` | TEXT | NOT NULL | ISO start timestamp |
| `end_time` | TEXT | nullable; if present > start | End timestamp |
| `start_station_id` | TEXT | NOT NULL, FK | Origin |
| `end_station_id` | TEXT | nullable, FK | Destination |
| `rider_type` | TEXT | NOT NULL, FK | Normalized rider product |
| `bike_type` | TEXT | NOT NULL, FK | Normalized bike type |
| `duration_flag` | INTEGER | CHECK 0/1 | 1 means positive but outside 1–360 minutes |
| `source_file` | TEXT | NOT NULL | Raw delivery that supplied the accepted row |

### `trip_exclusions`
| Column | Type | Constraint | Meaning |
|---|---|---|---|
| `exclusion_id` | INTEGER | PRIMARY KEY | Audit ID |
| `source_file` | TEXT | NOT NULL | Raw delivery |
| `source_row` | INTEGER | NOT NULL | Original source row |
| `trip_id` | TEXT | nullable | Trip ID if present |
| `reason` | TEXT | NOT NULL | Why the row did not load |

## Staging and normalization
Raw data first land in loose staging tables through pandas `to_sql()`. The trip staging tables receive only one extra field, `source_row`, for traceability; source values are not cleaned in pandas. Normalized staging tables are created in SQL, where blank strings become `NULL`, whitespace/case are standardized, and Day Pass spelling variants are mapped to `day_pass`.

## Reconciliation
`recon_2025`, `recon_2026_h1`, and `recon_2026_07` assign exactly one outcome to every raw trip row. Possible outcomes include `loaded`, `loaded_july`, `loaded_backlog`, `duplicate_in_file`, `duplicate_existing`, `orphan_start_station`, `orphan_end_station`, `missing_start_time`, `impossible_timestamp`, `unknown_product`, and `unknown_bike_type`.

The station files also receive simple reconciliation tables because they contribute station facts and capacity history. For every raw file, the notebook visibly checks that raw rows equal accounted rows.
