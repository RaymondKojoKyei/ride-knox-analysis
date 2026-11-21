#!/usr/bin/env python3
"""
load_warehouse.py -- build the Ride Knox warehouse from staged files.

The handoffs are real: Bash gated and staged the files; this loader is the
only code that writes trips into the database; SQL (views.sql / extracts.sql)
is the only thing the report reads from. Nothing is hand-copied between tools.

Per staged trips file:  stage (to_sql, schema-less on purpose) -> normalize
rider_type in SQL -> migrate with INSERT OR IGNORE where the PRIMARY KEY does
the identity work -- and, because SQLite's OR IGNORE silently swallows every
other violation too, the WHERE clause mirrors the FK so nothing disappears
without a name. Receipts per file; a system reconciliation ledger at the end;
the arithmetic must close, file by file, to the row.

Usage: python3 pipeline/load_warehouse.py <db_path> <staging_dir> <data_dir>
       (data_dir supplies stations_2026.xlsx and weather_knoxville_daily.csv)
"""

import csv
import sqlite3
import sys
from pathlib import Path

import pandas as pd

DOCK_HISTORY = [
    # (station_id, valid_from, docks) -- the authoritative capacity timeline
    # from the July 2026 data description. Every other station keeps its
    # directory dock count from before 2025-01-01.
    ("S06", "2026-02-15", 32),
    ("S08", "2026-02-15", 32),
    ("S25", "2026-03-01", 16),
]
PRE_2026 = {"S06": 24, "S08": 24}  # what the expanded stations held in 2025

RIDER_NORMALIZE = """
UPDATE stage SET rider_type = LOWER(TRIM(rider_type));
UPDATE stage SET rider_type = 'day_pass'
 WHERE rider_type IN ('day pass', 'daypass', 'day-pass', '1 day pass');
"""


def month_key(con):
    """Dominant YYYY-MM of the staged file, from contents (never the name)."""
    row = con.execute(
        """SELECT SUBSTR(start_time, 1, 7) AS m, COUNT(*) AS n FROM stage
           WHERE start_time IS NOT NULL AND start_time <> ''
           GROUP BY m ORDER BY n DESC LIMIT 1"""
    ).fetchone()
    return row[0] if row else "unknown"


def load_reference(con, data_dir: Path):
    stations = pd.read_excel(data_dir / "stations_2026.xlsx")
    stations.to_sql("stations", con, if_exists="append", index=False)

    hist = []
    for sid, docks in stations.set_index("station_id")["docks"].items():
        if sid == "S25":
            continue  # S25 did not exist before 2026-03-01
        base = PRE_2026.get(sid, int(docks))
        hist.append((sid, "2025-01-01", base))
    hist.extend(DOCK_HISTORY)
    con.executemany("INSERT INTO dock_history VALUES (?,?,?)", hist)

    con.executemany(
        "INSERT INTO products VALUES (?)",
        [("member",), ("casual",), ("day_pass",)],
    )
    print(f"  reference: {len(stations)} stations, {len(hist)} dock-history rows, 3 products")


def load_weather(con, data_dir: Path):
    """Audit at the door: duplicate dates collapse, the -99.9 sentinel -> NULL."""
    wx = pd.read_csv(data_dir / "weather_knoxville_daily.csv")
    raw = len(wx)
    wx.to_sql("wx_stage", con, if_exists="replace", index=False)
    sentinels = con.execute(
        "SELECT COUNT(*) FROM wx_stage WHERE precip_in <= -99"
    ).fetchone()[0]
    con.execute(
        """INSERT INTO weather
           SELECT date, tmax_f, tmin_f,
                  CASE WHEN precip_in <= -99 THEN NULL ELSE precip_in END
             FROM wx_stage
            GROUP BY date"""  # exact-duplicate dates collapse to one row
    )
    loaded = con.execute("SELECT COUNT(*) FROM weather").fetchone()[0]
    dup = raw - loaded
    print(f"  weather: {raw} raw = {loaded} loaded + {dup} duplicate-date rows; "
          f"{sentinels} sentinel precip values stored as NULL")
    return {"file": "weather_knoxville_daily.csv", "raw": raw, "loaded": loaded,
            "excluded": {"duplicate_date_rows": dup},
            "notes": f"{sentinels} precip sentinels -> NULL (rows kept)"}


def read_prepare_receipts():
    """raw row counts + structural drops recorded by prepare_accepted.sh --
    so closure runs from the ACCEPTED file's rows, not the staged copy's."""
    receipts = {}
    p = Path("out") / "prepare_receipts.csv"
    if p.exists():
        with open(p, newline="") as fh:
            for row in csv.DictReader(fh):
                receipts[row["file"]] = (int(row["raw_rows"]),
                                         int(row["dropped_structural"]))
    return receipts


def load_trips_file(con, path: Path, prep):
    df = pd.read_csv(path, dtype=str)
    raw, structural = prep.get(path.name, (len(df), 0))
    df.to_sql("stage", con, if_exists="replace", index=False)
    con.executescript(RIDER_NORMALIZE)
    month = month_key(con)

    before = con.execute("SELECT COUNT(*) FROM trips").fetchone()[0]

    # Refusal populations, counted BEFORE the INSERT so OR IGNORE can't hide them.
    already = con.execute(
        "SELECT COUNT(*) FROM stage WHERE trip_id IN (SELECT trip_id FROM trips)"
    ).fetchone()[0]
    in_file_dup = con.execute(
        "SELECT COUNT(*) - COUNT(DISTINCT trip_id) FROM stage "
        "WHERE trip_id NOT IN (SELECT trip_id FROM trips)"
    ).fetchone()[0]
    unknown_station = con.execute(
        """SELECT COUNT(*) FROM (SELECT DISTINCT * FROM stage) s
            WHERE s.trip_id NOT IN (SELECT trip_id FROM trips)
              AND (s.start_station_id NOT IN (SELECT station_id FROM stations)
                   OR (s.end_station_id IS NOT NULL AND s.end_station_id <> ''
                       AND s.end_station_id NOT IN (SELECT station_id FROM stations)))"""
    ).fetchone()[0]

    con.execute(
        """INSERT OR IGNORE INTO trips
           SELECT trip_id,
                  NULLIF(start_time, ''), NULLIF(end_time, ''),
                  start_station_id, NULLIF(end_station_id, ''),
                  rider_type, bike_type, ?
             FROM stage
            WHERE start_station_id IN (SELECT station_id FROM stations)
              AND (end_station_id IS NULL OR end_station_id = ''
                   OR end_station_id IN (SELECT station_id FROM stations))""",
        (path.name,),
    )
    con.commit()
    after = con.execute("SELECT COUNT(*) FROM trips").fetchone()[0]
    loaded = after - before

    excluded = {
        "dropped_structural": structural,
        "duplicate_copies_in_file": in_file_dup,
        "already_loaded_overlap": already,
        "unknown_station": unknown_station,
    }
    closes = raw == loaded + sum(excluded.values())
    print(f"  {path.name} [{month}]: {raw} raw = {loaded} loaded"
          f" + {structural} structural"
          f" + {in_file_dup} in-file duplicate copies"
          f" + {already} overlap/already-loaded"
          f" + {unknown_station} unknown-station"
          f"  -> closure {'OK' if closes else 'FAILS'}")
    if not closes:
        sys.exit(f"CLOSURE FAILURE on {path.name}: arithmetic does not add up")
    return {"file": path.name, "raw": raw, "loaded": loaded,
            "excluded": excluded, "notes": f"dominant month {month}"}


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    db_path, staging, data_dir = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])

    if db_path.exists():
        db_path.unlink()  # the database is a build product
    con = sqlite3.connect(db_path)
    con.execute("PRAGMA foreign_keys = ON;")
    con.executescript((Path("sql") / "schema.sql").read_text())

    print("load_warehouse: reference data")
    load_reference(con, data_dir)
    ledger = [load_weather(con, data_dir)]

    # Load order: chronological by each file's dominant CONTENT month, so the
    # first presentation of every trip wins deterministically. The receipts
    # from the gate already computed the month; here we sort staged files by
    # their own contents to stay self-contained.
    files = sorted(staging.glob("*.csv"))
    keyed = []
    for f in files:
        head = pd.read_csv(f, dtype=str, usecols=["start_time"])
        m = head["start_time"].dropna().str[:7].mode()
        keyed.append(((m.iloc[0] if len(m) else "9999"), f.name, f))
    keyed.sort()

    prep = read_prepare_receipts()
    print("load_warehouse: trips (chronological by content month)")
    for _, _, f in keyed:
        ledger.append(load_trips_file(con, f, prep))

    # Files the gate quarantined and never released belong in the system
    # ledger too: raw rows in, zero loaded, the whole file named as excluded.
    gate = Path("out") / "gate_receipts.csv"
    if gate.exists():
        with open(gate, newline="") as fh:
            rows = list(csv.DictReader(fh))
        released = {Path(r["file"]).name for r in rows if r["verdict"] == "released"}
        for r in rows:
            name = Path(r["file"]).name
            if r["verdict"] == "quarantine" and name not in released:
                ledger.append({"file": name, "raw": int(r["rows"]), "loaded": 0,
                               "excluded": {f"quarantined_whole_file_{r['reason']}":
                                            int(r["rows"])},
                               "notes": "never loaded; see gate receipts"})

    total = con.execute("SELECT COUNT(*) FROM trips").fetchone()[0]
    con.execute("DROP TABLE IF EXISTS stage")
    con.execute("DROP TABLE IF EXISTS wx_stage")
    con.commit()

    # The system reconciliation ledger: every raw row of every source file,
    # attributed to exactly one outcome.
    out = Path("out"); out.mkdir(exist_ok=True)
    with open(out / "system_reconciliation.csv", "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["file", "raw_rows", "loaded", "exclusion", "excluded_rows", "notes"])
        for e in ledger:
            first = True
            for reason, n in e["excluded"].items():
                w.writerow([e["file"], e["raw"] if first else "", e["loaded"] if first else "",
                            reason, n, e["notes"] if first else ""])
                first = False
            if first:  # nothing excluded
                w.writerow([e["file"], e["raw"], e["loaded"], "", 0, e["notes"]])

    print(f"load_warehouse: warehouse holds {total:,} trips; "
          f"ledger written to out/system_reconciliation.csv")
    con.close()


if __name__ == "__main__":
    main()
