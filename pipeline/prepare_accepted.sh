#!/usr/bin/env bash
set -euo pipefail
# prepare_accepted.sh -- write a repaired staging copy of every accepted file.
# The raw files are never modified (Golden Rule): each repair happens on a
# stream into staging/, and every changed or dropped row is counted out loud.
#
# Two known vendor defects are handled here, in the shell, BEFORE Python:
#   1. The August unquoted-comma bug: "Market Square, Downtown" splits the
#      station-name field, making 9 fields. One targeted sed repairs it.
#      (Repairing keeps 45 real rides; the alternative -- excluding them --
#      is defensible but discards data. The choice and its cost: see
#      TOOL-DEFENSE.md.)
#   2. Structural filter: any row that still does not have exactly 8 fields
#      (the truncated October fragment's severed final row) is dropped and
#      counted -- it is not a trip, it is the end of a failed upload.
#
# Output: staging/<name>.csv per accepted file + a structural line per file
# appended to out/prepare_receipts.csv.

STAMP=$(date +%Y-%m-%dT%H:%M:%S)
mkdir -p staging out
RECEIPTS="out/prepare_receipts.csv"
echo "file,raw_rows,repaired_rows,dropped_structural,staged_rows" > "$RECEIPTS"

FOUND=0
for F in accepted/*.csv; do
    [ -f "$F" ] || continue
    FOUND=$((FOUND + 1))
    NAME=$(basename "$F")
    # awk's NR, not wc -l: a file truncated mid-write ends without a newline,
    # and wc -l would undercount it -- letting the severed row vanish unnamed.
    RAW=$(tail -n +2 "$F" | awk 'END { print NR }')

    # count rows the sed will change (9-field rows carrying the known defect)
    REPAIRED=$(tail -n +2 "$F" | grep -c 'Market Square, Downtown' || true)

    # header + repaired stream + structural filter, all on a copy
    head -1 "$F" > "staging/$NAME"
    tail -n +2 "$F" \
        | sed 's/Market Square, Downtown/Market Square/' \
        | awk -F',' 'NF == 8' >> "staging/$NAME"

    STAGED=$(tail -n +2 "staging/$NAME" | wc -l)
    DROPPED=$((RAW - STAGED))
    echo "$NAME,$RAW,$REPAIRED,$DROPPED,$STAGED" >> "$RECEIPTS"
    echo "[$STAMP] staged $NAME: $RAW raw -> $STAGED staged ($REPAIRED repaired, $DROPPED dropped structurally)"
done

[ "$FOUND" -gt 0 ] || echo "[$STAMP] prepare_accepted: nothing in accepted/ to stage"
echo "[$STAMP] prepare_accepted done; receipts in $RECEIPTS"
