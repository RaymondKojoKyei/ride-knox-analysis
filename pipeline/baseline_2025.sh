#!/usr/bin/env bash
set -euo pipefail
# Pure-shell 2025 baseline: drop header, exact duplicates, S99, and fold case variants.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASELINE="$ROOT_DIR/trips_2025.csv"
OUT_FILE="$ROOT_DIR/out/baseline_2025_month_product.csv"

if [[ ! -f "$BASELINE" ]]; then
  echo "ERROR: missing baseline file: $BASELINE" >&2
  exit 1
fi

mkdir -p "$ROOT_DIR/out"
echo 'month,rider_type,trips' > "$OUT_FILE"

tail -n +2 "$BASELINE" | \
  sort -u | \
  awk -F',' '$4 != "S99" {print substr($2,1,7) "," tolower($7)}' | \
  sort | \
  uniq -c | \
  awk '{print $2 "," $1}' >> "$OUT_FILE"

echo "[$(date '+%Y-%m-%dT%H:%M:%S')] wrote $OUT_FILE"
