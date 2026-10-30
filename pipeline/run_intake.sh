#!/usr/bin/env bash
set -euo pipefail
# One-command monthly run: gate -> load -> report -> baseline -> summary snapshot.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f "$ROOT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
  set +a
fi

: "${RIDE_KNOX_API_KEY:?RIDE_KNOX_API_KEY is required}"
export RIDE_KNOX_DB="${RIDE_KNOX_DB:-$ROOT_DIR/ride_knox_fall.db}"
export RIDE_KNOX_SQLITE="${RIDE_KNOX_SQLITE:-sqlite3}"

PYTHON_BIN="$ROOT_DIR/.venv/Scripts/python.exe"
if [[ ! -x "$PYTHON_BIN" ]]; then
  PYTHON_BIN="$ROOT_DIR/.venv/bin/python"
fi
if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "ERROR: virtual-environment Python not found under .venv" >&2
  exit 1
fi
export RIDE_KNOX_PYTHON="$PYTHON_BIN"

mkdir -p "$ROOT_DIR/incoming" "$ROOT_DIR/accepted" "$ROOT_DIR/quarantine" \
  "$ROOT_DIR/staging" "$ROOT_DIR/out" "$ROOT_DIR/logs"

if ! command -v "$RIDE_KNOX_SQLITE" >/dev/null 2>&1 && [[ ! -x "$RIDE_KNOX_SQLITE" ]]; then
  echo "ERROR: sqlite3 not found; set RIDE_KNOX_SQLITE to its full path" >&2
  exit 1
fi

if echo "[$(date '+%Y-%m-%dT%H:%M:%S')] stage=gate starting" && \
  "$ROOT_DIR/pipeline/intake_gate.sh" && \
  echo "[$(date '+%Y-%m-%dT%H:%M:%S')] stage=load starting" && \
  "$ROOT_DIR/pipeline/load_accepted.sh" && \
  echo "[$(date '+%Y-%m-%dT%H:%M:%S')] stage=report starting" && \
  "$RIDE_KNOX_SQLITE" "$RIDE_KNOX_DB" < "$ROOT_DIR/pipeline/fall_report.sql" && \
  echo "[$(date '+%Y-%m-%dT%H:%M:%S')] stage=baseline starting" && \
  "$ROOT_DIR/pipeline/baseline_2025.sh"; then
  :
else
  echo "ERROR: intake run stopped because a stage failed" >&2
  exit 1
fi

{
  echo 'Ride Knox latest intake summary'
  echo
  echo '[receipts]'
  cat "$ROOT_DIR/out/intake_receipts.csv"
  echo
  echo '[database month totals]'
  "$RIDE_KNOX_SQLITE" -header -csv "$RIDE_KNOX_DB" \
    "SELECT substr(start_time,1,7) AS month, COUNT(*) AS trips FROM trips GROUP BY month ORDER BY month;"
} > "$ROOT_DIR/pipeline/latest_intake_summary.txt"

git -C "$ROOT_DIR" add pipeline/latest_intake_summary.txt
if git -C "$ROOT_DIR" diff --cached --quiet; then
  echo "[$(date '+%Y-%m-%dT%H:%M:%S')] latest summary unchanged; no commit needed"
else
  git -C "$ROOT_DIR" commit -m "Update latest intake summary"
  echo "[$(date '+%Y-%m-%dT%H:%M:%S')] latest summary committed"
fi

echo "[$(date '+%Y-%m-%dT%H:%M:%S')] intake run complete"
