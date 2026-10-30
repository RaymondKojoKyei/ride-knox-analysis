#!/usr/bin/env python3
"""Summarize the station-pressure CSV produced by sqlite3."""

from __future__ import annotations

import sys
from pathlib import Path

import pandas as pd


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {Path(sys.argv[0]).name} CSV_PATH", file=sys.stderr)
        return 2

    csv_path = Path(sys.argv[1])

    try:
        df = pd.read_csv(csv_path)
    except Exception as exc:
        print(f"ERROR: could not read {csv_path}: {exc}", file=sys.stderr)
        return 1

    if df.empty:
        print(f"ERROR: {csv_path} has no data rows", file=sys.stderr)
        return 1

    required = {"station_id", "station_name", "docks", "departures", "trips_per_dock"}
    missing = required.difference(df.columns)
    if missing:
        print(f"ERROR: missing columns: {sorted(missing)}", file=sys.stderr)
        return 1

    df = df.sort_values(["trips_per_dock", "station_id"], ascending=[False, True])

    print(f"stations_read={len(df)}")
    print(f"trips_represented={int(df['departures'].sum())}")

    print("most_pressured:")
    for row in df.head(3).itertuples(index=False):
        print(
            f"{row.station_id} | {row.station_name} | "
            f"departures={int(row.departures)} | "
            f"trips_per_dock={row.trips_per_dock:.1f}"
        )

    print("least_pressured:")
    for row in df.tail(3).sort_values(
        ["trips_per_dock", "station_id"], ascending=[True, True]
    ).itertuples(index=False):
        print(
            f"{row.station_id} | {row.station_name} | "
            f"departures={int(row.departures)} | "
            f"trips_per_dock={row.trips_per_dock:.1f}"
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
