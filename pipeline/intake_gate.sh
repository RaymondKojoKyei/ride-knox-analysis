#!/usr/bin/env bash
set -euo pipefail
# Intake policy: quarantining a vendor delivery is an expected business outcome,
# so the gate exits 0 after recording/moving it. Operational failures still exit non-zero.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INCOMING_DIR="$ROOT_DIR/incoming"
ACCEPTED_DIR="$ROOT_DIR/accepted"
QUARANTINE_DIR="$ROOT_DIR/quarantine"
OUT_DIR="$ROOT_DIR/out"
RECEIPTS="$OUT_DIR/intake_receipts.csv"

MIN_ROWS="${RIDE_KNOX_MIN_ROWS:-10000}"
MAX_MALFORMED="${RIDE_KNOX_MAX_MALFORMED:-50}"
MAX_UNKNOWN_MALFORMED="${RIDE_KNOX_MAX_UNKNOWN_MALFORMED:-0}"
MAX_DUPES_PER_1000="${RIDE_KNOX_MAX_DUPES_PER_1000:-10}"
DRY_RUN="${RIDE_KNOX_DRY_RUN:-0}"
EXPECTED_HEADER='trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,rider_type,bike_type'

mkdir -p "$INCOMING_DIR" "$ACCEPTED_DIR" "$QUARANTINE_DIR" "$OUT_DIR"

if [[ ! -f "$RECEIPTS" ]]; then
  echo 'file,rows,distinct,malformed,content_month,verdict,reason' > "$RECEIPTS"
fi

processed=0
for file in "$INCOMING_DIR"/*.csv; do
  [[ -e "$file" ]] || continue
  processed=$((processed + 1))
  name="$(basename "$file")"
  echo "[$(date '+%Y-%m-%dT%H:%M:%S')] inspecting $name"

  rows="$(awk 'END {print NR-1}' "$file")"
  distinct="$(tail -n +2 "$file" | sort -u | wc -l | tr -d ' ')"
  duplicates=$((rows - distinct))
  malformed="$(awk -F',' 'NR > 1 && NF != 8 {bad++} END {print bad+0}' "$file")"
  repairable="$(awk -F',' 'NR > 1 && NF == 9 && $4 == "S01" && $5 == "Market Square" && $6 == " Downtown" {good++} END {print good+0}' "$file")"
  unknown_malformed=$((malformed - repairable))
  header="$(head -n 1 "$file" | tr -d '\r')"
  content_month="$(awk -F',' 'NR > 1 && $2 != "" {print substr($2,1,7)}' "$file" | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')"
  content_month="${content_month:-unknown}"

  verdict="accepted"
  reason="passed"

  if [[ "$header" != "$EXPECTED_HEADER" ]]; then
    verdict="quarantine"
    reason="header_contract_mismatch"
  fi

  if (( rows < MIN_ROWS )); then
    verdict="quarantine"
    if [[ "$reason" == "passed" ]]; then reason="below_minimum_rows"; else reason="$reason;below_minimum_rows"; fi
  fi

  if (( malformed > MAX_MALFORMED )); then
    verdict="quarantine"
    if [[ "$reason" == "passed" ]]; then reason="malformed_rows_exceed_threshold"; else reason="$reason;malformed_rows_exceed_threshold"; fi
  fi

  if (( unknown_malformed > MAX_UNKNOWN_MALFORMED )); then
    verdict="quarantine"
    if [[ "$reason" == "passed" ]]; then reason="unknown_malformed_rows"; else reason="$reason;unknown_malformed_rows"; fi
  fi

  if (( duplicates * 1000 > rows * MAX_DUPES_PER_1000 )); then
    verdict="quarantine"
    if [[ "$reason" == "passed" ]]; then reason="duplicate_rate_exceeds_threshold"; else reason="$reason;duplicate_rate_exceeds_threshold"; fi
  fi

  receipt="$name,$rows,$distinct,$malformed,$content_month,$verdict,$reason"

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "DRY_RUN,$receipt"
    echo "[$(date '+%Y-%m-%dT%H:%M:%S')] dry-run: $name would be $verdict"
    continue
  fi

  echo "$receipt" >> "$RECEIPTS"
  if [[ "$verdict" == "accepted" ]]; then
    mv "$file" "$ACCEPTED_DIR/$name"
    echo "[$(date '+%Y-%m-%dT%H:%M:%S')] accepted $name (rows=$rows distinct=$distinct malformed=$malformed month=$content_month)"
  else
    mv "$file" "$QUARANTINE_DIR/$name"
    echo "REFUSED: $name -> $reason" >&2
    echo "[$(date '+%Y-%m-%dT%H:%M:%S')] quarantined $name" >&2
  fi
done

if (( processed == 0 )); then
  echo "[$(date '+%Y-%m-%dT%H:%M:%S')] incoming/ is empty; nothing to inspect"
fi
