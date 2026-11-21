-- schema.sql -- the Ride Knox warehouse, Final Project edition.
-- One database, both years, every source file. Philosophy (carried over from
-- the SQL project and the fall warehouse, reconciled here in writing):
--   * REFUSE the impossible-to-identify: duplicate trip_ids (PRIMARY KEY)
--     and trips at stations that do not exist (foreign-key mirror in load.sql).
--   * STORE the implausible as delivered: missing timestamps, negative and
--     absurd durations survive the load; the reporting VIEW judges them.
--     The warehouse is the vendor's word; judging it is the analyst's job.
--   * The products lookup resolves Module 9's open question the lookup-table
--     way: the next product launch is one INSERT, not a schema rebuild.
--   * dock_history solves "the number moved": each year's capacity analysis
--     derives its own denominator instead of trusting the current directory.

CREATE TABLE stations (
    station_id      TEXT PRIMARY KEY,
    station_name    TEXT NOT NULL,
    neighborhood    TEXT,
    latitude        REAL,
    longitude       REAL,
    docks           INTEGER,          -- CURRENT docks; history lives below
    year_installed  INTEGER
);

-- The authoritative capacity timeline (published in the July 2026 data
-- description). valid_from is the first day the dock count applies.
CREATE TABLE dock_history (
    station_id  TEXT NOT NULL REFERENCES stations(station_id),
    valid_from  TEXT NOT NULL,        -- 'YYYY-MM-DD'
    docks       INTEGER NOT NULL CHECK (docks > 0),
    PRIMARY KEY (station_id, valid_from)
);

CREATE TABLE products (
    product_code  TEXT PRIMARY KEY    -- 'member' | 'casual' | 'day_pass'
);

CREATE TABLE trips (
    trip_id           TEXT PRIMARY KEY,
    start_time        TEXT,           -- nullable: the July 14 outage rows are
                                      -- stored and counted, not vanished
    end_time          TEXT,
    start_station_id  TEXT REFERENCES stations(station_id),
    end_station_id    TEXT REFERENCES stations(station_id),
    product_code      TEXT NOT NULL REFERENCES products(product_code),
    bike_type         TEXT NOT NULL,  -- classic | electric | cargo; kept open
                                      -- on purpose: the cargo pilot arrived
                                      -- unannounced once already
    source_file       TEXT NOT NULL   -- which delivery first presented it
);

CREATE TABLE weather (
    date       TEXT PRIMARY KEY,      -- audited: one row per date
    tmax_f     REAL,
    tmin_f     REAL,
    precip_in  REAL                   -- NULL where the vendor sent its -99.9
                                      -- missing-value sentinel; the sentinel
                                      -- never reaches an average
);
