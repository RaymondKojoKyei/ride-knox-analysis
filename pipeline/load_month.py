#!/usr/bin/env python3
"""Load one prepared Ride Knox delivery and print an auditable row receipt."""

import sqlite3
import sys
from pathlib import Path

import pandas as pd

REQUIRED = [
    "trip_id",
    "start_time",
    "end_time",
    "start_station_id",
    "start_station_name",
    "end_station_id",
    "rider_type",
    "bike_type",
]


def normalize_rider(value: str) -> str:
    value = str(value).strip()
    mapping = {
        "member": "member",
        "casual": "casual",
        "DAY PASS": "day_pass",
        "DAYPASS": "day_pass",
        "Day Pass": "day_pass",
        "day_pass": "day_pass",
    }
    return mapping.get(value, value.lower())


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: load_month.py DATABASE PREPARED_CSV", file=sys.stderr)
        return 2

    db_path = Path(sys.argv[1])
    csv_path = Path(sys.argv[2])
    if not csv_path.is_file():
        print(f"ERROR: prepared file not found: {csv_path}", file=sys.stderr)
        return 1

    try:
        df = pd.read_csv(csv_path, dtype=str, keep_default_na=False)
    except Exception as exc:
        print(f"ERROR: could not parse {csv_path}: {exc}", file=sys.stderr)
        return 1

    if list(df.columns) != REQUIRED:
        print("ERROR: prepared file does not match the eight-column contract", file=sys.stderr)
        return 1

    presented = len(df)
    months = df.loc[df["start_time"] != "", "start_time"].str[:7].value_counts()
    delivery_month = months.index[0] if not months.empty else "unknown"

    loaded = 0
    rejected_missing_trip_id = 0
    rejected_missing_start_time = 0
    skipped_duplicate_id_in_file = 0
    skipped_already_loaded = 0
    rejected_database = 0
    seen_in_file = set()

    connection = sqlite3.connect(db_path)
    cursor = connection.cursor()

    for row in df.itertuples(index=False):
        trip_id = row.trip_id.strip()
        start_time = row.start_time.strip()

        if not trip_id:
            rejected_missing_trip_id += 1
            continue
        if not start_time:
            # This is counted before INSERT OR IGNORE so the NOT NULL loss is never silent.
            rejected_missing_start_time += 1
            continue
        if trip_id in seen_in_file:
            skipped_duplicate_id_in_file += 1
            continue
        seen_in_file.add(trip_id)

        exists = cursor.execute(
            "SELECT 1 FROM trips WHERE trip_id = ?", (trip_id,)
        ).fetchone()
        if exists:
            skipped_already_loaded += 1
            continue

        cursor.execute(
            """
            INSERT OR IGNORE INTO trips (
                trip_id, start_time, end_time, start_station_id,
                start_station_name, end_station_id, rider_type, bike_type
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                trip_id,
                start_time,
                row.end_time.strip(),
                row.start_station_id.strip(),
                row.start_station_name.strip(),
                row.end_station_id.strip(),
                normalize_rider(row.rider_type),
                row.bike_type.strip().lower(),
            ),
        )
        if cursor.rowcount == 1:
            loaded += 1
        else:
            rejected_database += 1

    connection.commit()
    connection.close()

    accounted = (
        loaded
        + rejected_missing_trip_id
        + rejected_missing_start_time
        + skipped_duplicate_id_in_file
        + skipped_already_loaded
        + rejected_database
    )

    print(f"file={csv_path.name}")
    print(f"delivery_month={delivery_month}")
    print(f"presented={presented}")
    print(f"loaded={loaded}")
    print(f"rejected_missing_trip_id={rejected_missing_trip_id}")
    print(f"rejected_missing_start_time={rejected_missing_start_time}")
    print(f"skipped_duplicate_id_in_file={skipped_duplicate_id_in_file}")
    print(f"skipped_already_loaded={skipped_already_loaded}")
    print(f"rejected_database={rejected_database}")
    print(f"accounted={accounted}")

    if accounted != presented:
        print("ERROR: closure arithmetic does not close", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
