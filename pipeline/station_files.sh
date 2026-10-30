#!/usr/bin/env bash
set -euo pipefail
# Count departures for every station listed in out/stations.csv.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
YEAR="${1:-2025}"
DATA_DIR="${RIDE_KNOX_DATA:-$ROOT_DIR}"
TRIPS="$DATA_DIR/trips_${YEAR}.csv"
STATIONS_CSV="$ROOT_DIR/out/stations.csv"
OUT_DIR="$ROOT_DIR/out"

if [[ ! -f "$TRIPS" ]]; then
  echo "ERROR: trips file does not exist: $TRIPS" >&2
  exit 1
fi

if [[ ! -f "$STATIONS_CSV" ]]; then
  echo "ERROR: station list is missing: $STATIONS_CSV" >&2
  exit 1
fi

zero_count=0
total_departures=0

while IFS=, read -r station_id rest; do
  station_id="${station_id//$'\r'/}"
  [[ "$station_id" == "station_id" || -z "$station_id" ]] && continue

  count="$(awk -F',' -v id="$station_id" \
    'NR > 1 && $4 == id {count++} END {print count+0}' "$TRIPS")"

  printf '%s %s\n' "$station_id" "$count" > "$OUT_DIR/dep_${station_id}.txt"
  printf '%s %s\n' "$station_id" "$count"

  total_departures=$((total_departures + count))
  if (( count == 0 )); then
    zero_count=$((zero_count + 1))
  fi
done < "$STATIONS_CSV"

echo "zero_departure_stations=$zero_count"
echo "total_departures=$total_departures"

if (( zero_count != 0 )); then
  echo "ERROR: $zero_count station(s) produced zero departures" >&2
  exit 1
fi

echo "ranking:"
for f in "$OUT_DIR"/dep_S*.txt; do
  cat "$f"
done | sort -k2,2nr
