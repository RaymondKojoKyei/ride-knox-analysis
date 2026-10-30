#!/usr/bin/env python3
"""Convert stations.xlsx to a CSV that Bash can iterate over."""

from __future__ import annotations

import sys
from pathlib import Path

import pandas as pd


def main() -> int:
    if len(sys.argv) != 3:
        print(
            f"Usage: {Path(sys.argv[0]).name} STATIONS_XLSX OUTPUT_CSV",
            file=sys.stderr,
        )
        return 2

    source = Path(sys.argv[1])
    target = Path(sys.argv[2])

    if not source.is_file():
        print(f"ERROR: workbook does not exist: {source}", file=sys.stderr)
        return 1

    df = pd.read_excel(source)

    if "station_id" not in df.columns:
        print("ERROR: station_id column is missing", file=sys.stderr)
        return 1

    target.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(target, index=False)

    print(f"stations_written={len(df)}")
    print(f"output={target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
