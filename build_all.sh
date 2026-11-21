#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

DATA_DIR="${DATA_DIR:-data}"
DB="${RIDE_KNOX_DB:-ride_knox_wh.db}"

stamp() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S)] build_all: $*"
}

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

# Resolve Python on Windows Git Bash, macOS, or Linux.
if command -v python >/dev/null 2>&1; then
    PYTHON="python"
elif command -v python3 >/dev/null 2>&1; then
    PYTHON="python3"
else
    fail "Python 3 is required"
fi

command -v sqlite3 >/dev/null 2>&1 || fail "sqlite3 is required"
command -v quarto >/dev/null 2>&1 || fail "Quarto is required"
[ -d "$DATA_DIR" ] || fail "DATA_DIR=$DATA_DIR not found"

TRIP_FILES=(
    trips_2025.csv
    trips_2026_h1.csv
    trips_2026_07.csv
    trips_2026_08.csv
    trips_2026_09.csv
    trips_2026_09_resend.csv
    trips_2026_10.csv
)
REFERENCE_FILES=(stations_2026.xlsx weather_knoxville_daily.csv)

for f in "${TRIP_FILES[@]}" "${REFERENCE_FILES[@]}"; do
    [ -f "$DATA_DIR/$f" ] || fail "missing required raw file: $DATA_DIR/$f"
done

stamp "stage 0/8 - reset generated working products"
rm -rf incoming accepted quarantine staging out logs
rm -f "$DB"
mkdir -p incoming accepted quarantine staging out logs figs
rm -f figs/integration_verdict.png figs/two_year_nonmember.png

stamp "stage 1/8 - copy raw trip deliveries into the working inbox"
for f in "${TRIP_FILES[@]}"; do
    cp "$DATA_DIR/$f" "incoming/$f"
done

stamp "stage 2/8 - run intake gate and apply the documented October policy"
./pipeline/intake_gate.sh incoming
./pipeline/release_quarantine.sh \
    trips_2026_10.csv \
    "coverage-policy: release structurally valid rows through Oct 11; report the truncated coverage explicitly"

stamp "stage 3/8 - repair accepted copies and create staging files"
./pipeline/prepare_accepted.sh

stamp "stage 4/8 - rebuild the two-year warehouse and reconciliation ledger"
"$PYTHON" pipeline/load_warehouse.py "$DB" staging "$DATA_DIR"

stamp "stage 5/8 - create reporting views and SQL-to-R extracts"
{ echo "PRAGMA foreign_keys = ON;"; cat sql/views.sql; } | sqlite3 "$DB"
mkdir -p out
{ echo "PRAGMA foreign_keys = ON;"; cat sql/extracts.sql; } | sqlite3 "$DB"

stamp "stage 6/8 - render the annual report from extracts only"
quarto render report/annual_report.qmd
cp report/annual_report.html annual_report.html

stamp "stage 7/8 - verify public release assets"
[ -s annual_report.html ] || fail "annual_report.html was not created"
[ -s index.md ] || fail "index.md was not created"
[ -s figs/integration_verdict.png ] || fail "figs/integration_verdict.png was not created"
[ -s figs/two_year_nonmember.png ] || fail "figs/two_year_nonmember.png was not created"

stamp "stage 8/8 - write build summary"
WAREHOUSE_COUNT=$(sqlite3 "$DB" "SELECT COUNT(*) FROM trips;")
WAREHOUSE_2026=$(sqlite3 "$DB" "SELECT COUNT(*) FROM trips WHERE source_file LIKE 'trips_2026%';")
REPORTABLE_COUNT=$(sqlite3 "$DB" "SELECT COUNT(*) FROM trips_reportable;")

read -r RAW_TOTAL LOADED_TOTAL EXCLUDED_TOTAL < <(
    awk -F, '
        NR > 1 {
            if ($2 != "") raw += $2;
            if ($3 != "") loaded += $3;
            if ($5 != "") excluded += $5;
        }
        END { print raw+0, loaded+0, excluded+0 }
    ' out/system_reconciliation.csv
)

GATE_ACCEPT=$(awk -F, 'NR>1 && $7=="accept" {n++} END {print n+0}' out/gate_receipts.csv)
GATE_QUARANTINE=$(awk -F, 'NR>1 && $7=="quarantine" {n++} END {print n+0}' out/gate_receipts.csv)
GATE_RELEASED=$(awk -F, 'NR>1 && $7=="released" {n++} END {print n+0}' out/gate_receipts.csv)

{
    echo "Ride Knox final-project build summary"
    echo "timestamp=$(date +%Y-%m-%dT%H:%M:%S)"
    echo "data_dir=$DATA_DIR"
    echo "database=$DB"
    echo "gate_accept=$GATE_ACCEPT"
    echo "gate_quarantine=$GATE_QUARANTINE"
    echo "gate_released=$GATE_RELEASED"
    echo "warehouse_trips=$WAREHOUSE_COUNT"
    echo "warehouse_2026_trips=$WAREHOUSE_2026"
    echo "reportable_trips=$REPORTABLE_COUNT"
    echo "ledger_raw_rows=$RAW_TOTAL"
    echo "ledger_loaded_rows=$LOADED_TOTAL"
    echo "ledger_excluded_rows=$EXCLUDED_TOTAL"
    echo "annual_report=annual_report.html"
    echo "public_page=index.md"
    echo "lead_figure=figs/integration_verdict.png"
    echo "status=SUCCESS"
} | tee out/build_summary.txt

stamp "SUCCESS - one-command rebuild completed"
