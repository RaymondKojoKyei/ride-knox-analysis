#!/usr/bin/env bash
set -euo pipefail
# Run the complete Monday Ride Knox station-pressure briefing.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SQLITE_DIR="/c/Users/RAY KYEI/AppData/Local/Microsoft/WinGet/Packages/SQLite.SQLite_Microsoft.Winget.Source_8wekyb3d8bbwe"
export PATH="$SQLITE_DIR:/usr/local/bin:/usr/bin:/bin:/mingw64/bin:${PATH:-}"DB_PATH="${RIDE_KNOX_DB:-ride_knox.db}"
export TEMP="${TEMP:-/tmp}"
export TMP="${TMP:-/tmp}"

YEAR="${1:-}"
if [[ -z "$YEAR" ]]; then
  echo "Usage: $0 YEAR" >&2
  exit 1
fi

if [[ -f "$ROOT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
  set +a
fi

PYTHON_BIN="$ROOT_DIR/.venv/Scripts/python.exe"
if [[ ! -x "$PYTHON_BIN" ]]; then
  PYTHON_BIN="$ROOT_DIR/.venv/bin/python"
fi

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "ERROR: virtual-environment Python not found under .venv" >&2
  exit 1
fi

DB_PATH="${RIDE_KNOX_DB:-$ROOT_DIR/ride_knox.db}"
DATA_DIR="${RIDE_KNOX_DATA:-$ROOT_DIR}"

timestamp() {
  date '+[%Y-%m-%dT%H:%M:%S]'
}

echo "$(timestamp) validation starting"
"$ROOT_DIR/pipeline/check_data.sh" "$YEAR"

echo "$(timestamp) station workbook conversion starting"
"$PYTHON_BIN" "$ROOT_DIR/pipeline/stations_to_csv.py" \
  "$DATA_DIR/stations.xlsx" "$ROOT_DIR/out/stations.csv"

echo "$(timestamp) station departure files starting"
"$ROOT_DIR/pipeline/station_files.sh" "$YEAR"

echo "$(timestamp) sqlite station-pressure query starting"
sqlite3 "$DB_PATH" < "$ROOT_DIR/pipeline/station_pressure.sql"

echo "$(timestamp) Python summary starting"
"$PYTHON_BIN" "$ROOT_DIR/pipeline/summarize.py" \
  "$ROOT_DIR/out/station_pressure.csv"

echo "$(timestamp) writing latest summary"
"$PYTHON_BIN" "$ROOT_DIR/pipeline/summarize.py" \
  "$ROOT_DIR/out/station_pressure.csv" > "$ROOT_DIR/pipeline/latest_summary.txt"

git -C "$ROOT_DIR" add pipeline/latest_summary.txt
if git -C "$ROOT_DIR" diff --cached --quiet; then
  echo "$(timestamp) latest summary unchanged; no commit needed"
else
  git -C "$ROOT_DIR" commit -m "Update latest station pressure summary"
  echo "$(timestamp) latest summary committed"
fi

echo "$(timestamp) briefing complete"
