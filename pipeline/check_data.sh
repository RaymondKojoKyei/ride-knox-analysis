#!/usr/bin/env bash
set -euo pipefail
# Validate a Ride Knox yearly trip CSV before downstream reporting.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
YEAR="${1:-}"
DATA_DIR="${RIDE_KNOX_DATA:-$ROOT_DIR}"
MAX_DUPES="${RIDE_KNOX_MAX_DUPES:-1000}"

if [[ -z "$YEAR" ]]; then
  echo "Usage: $0 YEAR" >&2
  exit 1
fi

if [[ ! -d "$DATA_DIR" ]]; then
  echo "ERROR: data directory does not exist: $DATA_DIR" >&2
  exit 1
fi

TRIPS="$DATA_DIR/trips_${YEAR}.csv"

if [[ ! -f "$TRIPS" ]]; then
  echo "ERROR: trips file does not exist: $TRIPS" >&2
  exit 1
fi

: "${RIDE_KNOX_API_KEY:?RIDE_KNOX_API_KEY is required}"

ROWS="$(tail -n +2 "$TRIPS" | wc -l | tr -d ' ')"
DISTINCT="$(tail -n +2 "$TRIPS" | sort -u | wc -l | tr -d ' ')"
DUPLICATES=$((ROWS - DISTINCT))

WITH_END="$(awk -F',' 'NR > 1 && $6 != "" {count++} END {print count+0}' "$TRIPS")"
WITHOUT_END=$((ROWS - WITH_END))

echo "rows=$ROWS distinct=$DISTINCT duplicates=$DUPLICATES"
echo "with_end_station=$WITH_END without_end_station=$WITHOUT_END"

if (( DUPLICATES > MAX_DUPES )); then
  echo "ERROR: duplicate rows ($DUPLICATES) exceed threshold ($MAX_DUPES)" >&2
  exit 1
fi

STATION_NAME="Market Square"
SLUG="${STATION_NAME// /_}"
OUT_PATH="$ROOT_DIR/out/${SLUG}_${YEAR}.txt"
echo "example_output_path=$OUT_PATH"

echo "Validation succeeded for $TRIPS" && \
  echo "summary: rows=$ROWS distinct=$DISTINCT missing_end=$WITHOUT_END"
