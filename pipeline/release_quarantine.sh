#!/usr/bin/env bash
set -euo pipefail
# release_quarantine.sh -- move ONE named file from quarantine/ to accepted/,
# recording the override in the receipts. This is policy-as-code: the gate's
# verdict stands in the receipts, and the human decision to overrule it is
# equally visible. Used exactly once in build_all.sh, for the truncated
# October delivery, per the data team's documented December release decision
# ("the board can't wait"; coverage caveats handled downstream in the report).
#
# Usage: ./pipeline/release_quarantine.sh <filename> "<reason>"

FILE="${1:?usage: release_quarantine.sh <filename> <reason>}"
REASON="${2:?usage: release_quarantine.sh <filename> <reason>}"
STAMP=$(date +%Y-%m-%dT%H:%M:%S)

if [ -f "accepted/$FILE" ]; then
    echo "[$STAMP] release_quarantine: $FILE already in accepted/ (re-run); nothing to do"
    exit 0
fi
[ -f "quarantine/$FILE" ] || { echo "ERROR: quarantine/$FILE not found" >&2; exit 1; }

mv "quarantine/$FILE" accepted/
echo "quarantine/$FILE,,,,,,released,$REASON" >> out/gate_receipts.csv
echo "[$STAMP] RELEASED  $FILE from quarantine -- $REASON"
