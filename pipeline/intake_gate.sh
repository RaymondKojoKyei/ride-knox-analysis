#!/usr/bin/env bash
set -euo pipefail
# intake_gate.sh -- triage every trip CSV in the incoming folder (Final Project
# edition: the Bash Module Project gate, promoted to guard the FULL history --
# the 2025 export, the 2026 H1 file, and every monthly delivery, in one run).
#
# A file that passes every check moves to accepted/; a file that fails any
# check moves to quarantine/, with the reason on stderr. Every verdict is one
# line in out/gate_receipts.csv. Exit 0 = the gate ran; a quarantine is a data
# fact, not a script failure (receipts and stderr carry the alarm), so the
# && chain in build_all.sh can proceed to load whatever WAS accepted.
#
# Usage: ./pipeline/intake_gate.sh [incoming_dir]     (default: incoming)

INDIR="${1:-incoming}"
EXPECTED_HEADER="trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,rider_type,bike_type"
MIN_ROWS="${RIDE_KNOX_MIN_ROWS:-15000}"        # a real month runs ~23k-33k rows
MAX_MALFORMED="${RIDE_KNOX_MAX_MALFORMED:-100}"
MAX_DUPES="${RIDE_KNOX_MAX_DUPES:-1000}"

STAMP=$(date +%Y-%m-%dT%H:%M:%S)
[ -d "$INDIR" ] || { echo "ERROR: no incoming directory at $INDIR" >&2; exit 1; }
mkdir -p accepted quarantine out

# an empty inbox is a no-op, not an excuse to blank the last run's receipts
FOUND=0
for F in "$INDIR"/*.csv; do
    [ -f "$F" ] && FOUND=$((FOUND + 1))
done
if [ "$FOUND" -eq 0 ]; then
    echo "[$STAMP] intake_gate: nothing to triage in $INDIR/"
    exit 0
fi

RECEIPTS="out/gate_receipts.csv"
echo "file,rows,distinct,dupes,malformed,dominant_month,verdict,reason" > "$RECEIPTS"
echo "[$STAMP] intake_gate starting on $INDIR/ ($FOUND file(s); floors: rows>=$MIN_ROWS, malformed<=$MAX_MALFORMED, dupes<=$MAX_DUPES)"

for F in "$INDIR"/*.csv; do
    [ -f "$F" ] || continue

    HDR=$(head -1 "$F")
    ROWS=$(tail -n +2 "$F" | wc -l)
    DISTINCT=$(tail -n +2 "$F" | sort -u | wc -l)
    DUPES=$((ROWS - DISTINCT))
    # a well-formed row splits into exactly 8 comma fields
    MALFORMED=$(tail -n +2 "$F" | awk -F',' 'NF != 8' | wc -l)
    # the month the CONTENTS claim (most common YYYY-MM in start_time),
    # not the month the FILENAME claims -- filenames have lied before
    MONTH=$(tail -n +2 "$F" | cut -d, -f2 | cut -c1-7 | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')

    VERDICT="accept"; REASON="ok"
    if [ "$HDR" != "$EXPECTED_HEADER" ]; then
        VERDICT="quarantine"; REASON="header-mismatch"
    elif [ "$ROWS" -lt "$MIN_ROWS" ]; then
        VERDICT="quarantine"; REASON="too-few-rows"
    elif [ "$MALFORMED" -gt "$MAX_MALFORMED" ]; then
        VERDICT="quarantine"; REASON="too-many-malformed"
    elif [ "$DUPES" -gt "$MAX_DUPES" ]; then
        VERDICT="quarantine"; REASON="duplicate-rate"
    fi

    echo "$F,$ROWS,$DISTINCT,$DUPES,$MALFORMED,$MONTH,$VERDICT,$REASON" >> "$RECEIPTS"
    if [ "$VERDICT" = "accept" ]; then
        echo "[$STAMP] ACCEPT  $F ($ROWS rows, month $MONTH)"
        mv "$F" accepted/
    else
        echo "[$STAMP] QUARANTINE  $F -- $REASON ($ROWS rows, $MALFORMED malformed, $DUPES dupes)" >&2
        mv "$F" quarantine/
    fi
done

echo "[$STAMP] intake_gate done; receipts in $RECEIPTS"
