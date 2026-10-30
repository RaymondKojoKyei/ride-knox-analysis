#!/usr/bin/env bash
set -euo pipefail
# Build/update the database from accepted deliveries. Re-runs are safe because trip_id is the PK.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACCEPTED_DIR="$ROOT_DIR/accepted"
STAGING_DIR="$ROOT_DIR/staging"
DB="${RIDE_KNOX_DB:-$ROOT_DIR/ride_knox_fall.db}"
SQLITE_BIN="${RIDE_KNOX_SQLITE:-sqlite3}"
PYTHON_BIN="${RIDE_KNOX_PYTHON:-$ROOT_DIR/.venv/Scripts/python.exe}"

if [[ ! -x "$PYTHON_BIN" ]]; then
  PYTHON_BIN="$ROOT_DIR/.venv/bin/python"
fi
if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "ERROR: virtual-environment Python not found under .venv" >&2
  exit 1
fi
if ! command -v "$SQLITE_BIN" >/dev/null 2>&1 && [[ ! -x "$SQLITE_BIN" ]]; then
  echo "ERROR: sqlite3 not found; set RIDE_KNOX_SQLITE if needed" >&2
  exit 1
fi

mkdir -p "$ACCEPTED_DIR" "$STAGING_DIR"
"$SQLITE_BIN" "$DB" < "$ROOT_DIR/pipeline/schema.sql"

processed=0
for file in "$ACCEPTED_DIR"/*.csv; do
  [[ -e "$file" ]] || continue
  processed=$((processed + 1))
  name="$(basename "$file")"
  delivery_month="$(awk -F',' 'NR > 1 && $2 != "" {print substr($2,1,7)}' "$file" | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')"
  staged="$STAGING_DIR/${delivery_month}_${name}"

  echo "[$(date '+%Y-%m-%dT%H:%M:%S')] preparing $name as content month $delivery_month"
  # Known August repair: the vendor inserted an unquoted comma after "Market Square".
  # Applying the exact replacement to every accepted file is harmless when the text is absent.
  sed 's/Market Square, Downtown/Market Square/' "$file" > "$staged"

  remaining_malformed="$(awk -F',' 'NR > 1 && NF != 8 {bad++} END {print bad+0}' "$staged")"
  if (( remaining_malformed != 0 )); then
    echo "ERROR: $name still has $remaining_malformed malformed row(s) after staging" >&2
    exit 1
  fi

  if "$PYTHON_BIN" "$ROOT_DIR/pipeline/load_month.py" "$DB" "$staged" && \
    echo "[$(date '+%Y-%m-%dT%H:%M:%S')] loaded receipt complete for $name"; then
    :
  else
    echo "ERROR: loader failed for $name" >&2
    exit 1
  fi
done

if (( processed == 0 )); then
  echo "ERROR: accepted/ contains no deliveries to load" >&2
  exit 1
fi

"$SQLITE_BIN" "$DB" 'SELECT COUNT(*) AS trips_in_database FROM trips;'
