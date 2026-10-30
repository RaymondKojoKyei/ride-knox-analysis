# DATA 501 — Bash Module Project — GATE-LOG

**Name:** Raymond Kojo Kyei  
**NetID:** rkyei  
**Branch:** `feature/bash-module-project`  
**Project:** The Intake Gate: Ride Knox Goes Unattended

This log records the audit, decisions, commands, outputs, closure arithmetic, idempotency evidence, report results, optional challenge, reflection, and AI disclosure.

## Part A — Delivery audit

### A1. Line counts, data rows, distinct rows, malformed rows, and content months

Command:

```bash
for f in incoming/*.csv; do
  echo "=== $(basename "$f") ==="
  wc -l "$f"
  printf 'data_rows='; awk 'END {print NR-1}' "$f"
  printf 'distinct_rows='; tail -n +2 "$f" | sort -u | wc -l
  printf 'malformed='; awk -F',' 'NR>1 && NF!=8 {c++} END {print c+0}' "$f"
  printf 'months='; awk -F',' 'NR>1 && $2!="" {print substr($2,1,7)}' "$f" | sort | uniq -c
  echo
done
```

Output:

```text
trips_2026_07.csv: wc -l=33086, data_rows=33085, distinct_rows=32965, malformed=0
months: 2026-06=215, 2026-07=32830

trips_2026_08.csv: wc -l=30046, data_rows=30045, distinct_rows=29925, malformed=45
months: 2026-07=185, 2026-08=29860

trips_2026_09.csv: wc -l=27761, data_rows=27760, distinct_rows=27650, malformed=0
months: 2026-08=170, 2026-09=27590

trips_2026_09_resend.csv: wc -l=27761, data_rows=27760, distinct_rows=27650, malformed=0
months: 2026-08=170, 2026-09=27590

trips_2026_10.csv: wc -l=8247, data_rows=8247, distinct_rows=8208, malformed=1
months: 2026-09=155, 2026-10=8092
```

The filename is not used as the month authority. Each delivery contains overlap/backlog rows from the previous month, so reporting months must come from `start_time`.

### A2. Header contract

Command:

```bash
for f in incoming/*.csv; do
  echo "$(basename "$f"): $(head -n 1 "$f")"
done
```

Output:

```text
trips_2026_07.csv: trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,rider_type,bike_type
trips_2026_08.csv: trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,rider_type,bike_type
trips_2026_09.csv: trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,bike_type,rider_type
trips_2026_09_resend.csv: trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,rider_type,bike_type
trips_2026_10.csv: trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,rider_type,bike_type
```

Decision: the original September delivery violates the contracted order by swapping `bike_type` and `rider_type`. The resend restores the contracted order.

### A3. Malformed-row evidence

Command:

```bash
awk -F',' 'NR>1 && NF!=8 {print NR ": NF=" NF " :: " $0}' incoming/trips_2026_08.csv | head
awk -F',' 'NR>1 && NF!=8 {print NR ": NF=" NF " :: " $0}' incoming/trips_2026_10.csv
```

Output excerpt:

```text
282: NF=9 :: T0487947,2026-08-01 08:20:21,2026-08-01 08:26:35,S01,Market Square, Downtown,S04,member,classic
1000: NF=9 :: T0477832,2026-08-01 20:03:34,2026-08-01 20:13:45,S01,Market Square, Downtown,S02,member,electric
... (43 more August rows)
8248: NF=5 :: T0549739,2026-10-11 17:31:41,2026-10-11 17:41:23,S17,Happy Ho
```

All 45 August malformed rows have the same repairable pattern: an unquoted comma in `Market Square, Downtown`. The October problem is different: its final record is cut off after five fields.

### A4. Missing start times and the vendor timestamp claim

Command:

```bash
for f in incoming/*.csv; do
  printf '%s missing_start=' "$(basename "$f")"
  awk -F',' 'NR>1 && $2=="" {c++} END {print c+0}' "$f"
  printf ' swapped_end_before_start='
  awk -F',' 'NR>1 && $2!="" && $3!="" && $3<$2 {c++} END {print c+0}' "$f"
done
```

Output:

```text
trips_2026_07.csv missing_start=40 swapped_end_before_start=60
trips_2026_08.csv missing_start=0 swapped_end_before_start=54
trips_2026_09.csv missing_start=0 swapped_end_before_start=52
trips_2026_09_resend.csv missing_start=0 swapped_end_before_start=52
trips_2026_10.csv missing_start=0 swapped_end_before_start=11
```

The vendor's claim that the timestamp-swap bug was fixed in August is not supported by these deliveries: rows with `end_time < start_time` continue after July. I preserve them because the project does not authorize a duration repair and they do not prevent identity/month reporting; the finding belongs in the vendor scorecard.

### A5. Cross-delivery `trip_id` overlap

Commands used to compare unique IDs without `comm` or `join`:

```bash
mkdir -p out/audit_ids
cut -d',' -f1 incoming/trips_2026_07.csv | tail -n +2 | sort -u > out/audit_ids/07.txt
cut -d',' -f1 incoming/trips_2026_08.csv | tail -n +2 | sort -u > out/audit_ids/08.txt
cut -d',' -f1 incoming/trips_2026_09.csv | tail -n +2 | sort -u > out/audit_ids/09.txt
cut -d',' -f1 incoming/trips_2026_09_resend.csv | tail -n +2 | sort -u > out/audit_ids/09r.txt
cut -d',' -f1 incoming/trips_2026_10.csv | tail -n +2 | sort -u > out/audit_ids/10.txt

grep -F -x -f out/audit_ids/07.txt out/audit_ids/08.txt | wc -l
grep -F -x -f out/audit_ids/08.txt out/audit_ids/09.txt | wc -l
grep -F -x -f out/audit_ids/09.txt out/audit_ids/09r.txt | wc -l
grep -F -x -f out/audit_ids/09r.txt out/audit_ids/10.txt | wc -l
```

Output:

```text
160
150
27650
140
```

Interpretation: August re-presents 160 July IDs; September re-presents 150 August IDs; the September resend has the same 27,650 unique IDs as the rejected September version; October overlaps the September resend by 140 IDs. The database therefore needs `trip_id` as the identity constraint.

### A6. Triage plan

| Delivery | Gate decision | Evidence / reason |
|---|---|---|
| July | Accept | Contracted header; 33,085 rows; 120 duplicate copies are below policy; 40 missing start times will be explicitly rejected by the loader. |
| August | Accept | Contracted header; 45 malformed rows are one known, repairable comma defect; repair is visible in staging. |
| September original | Quarantine | Unapproved Export v2 column order violates the contract. |
| September resend | Accept | Restores contracted layout; same trip population as original resend subject to normal duplicate handling. |
| October | Quarantine | Only 8,247 data records, one unknown malformed/truncated final row, and the delivery ends on October 11; it is not a complete monthly delivery. |

Policy defaults: minimum 10,000 rows; maximum 50 total malformed rows; zero unknown malformed rows; maximum 10 duplicate rows per 1,000 rows. These are environment-configurable, not buried in the code.

## Part B — Intake gate

### B1. Five-file triage run

Command:

```bash
./pipeline/intake_gate.sh 2>&1 | tee logs/gate_first.log
```

Key output:

```text
accepted trips_2026_07.csv (rows=33085 distinct=32965 malformed=0 month=2026-07)
accepted trips_2026_08.csv (rows=30045 distinct=29925 malformed=45 month=2026-08)
REFUSED: trips_2026_09.csv -> header_contract_mismatch
accepted trips_2026_09_resend.csv (rows=27760 distinct=27650 malformed=0 month=2026-09)
REFUSED: trips_2026_10.csv -> below_minimum_rows;unknown_malformed_rows
```

Receipt:

```text
file,rows,distinct,malformed,content_month,verdict,reason
trips_2026_07.csv,33085,32965,0,2026-07,accepted,passed
trips_2026_08.csv,30045,29925,45,2026-08,accepted,passed
trips_2026_09.csv,27760,27650,0,2026-09,quarantine,header_contract_mismatch
trips_2026_09_resend.csv,27760,27650,0,2026-09,accepted,passed
trips_2026_10.csv,8247,8208,1,2026-10,quarantine,below_minimum_rows;unknown_malformed_rows
```

Exit-code policy: quarantine is a successful gate outcome because the gate has done its job and recorded the refusal. Operational errors fail non-zero. This lets Part E continue to load the deliveries that were safely accepted.

### B2. Empty inbox rerun

Command:

```bash
./pipeline/intake_gate.sh
echo "exit=$?"
```

Output:

```text
incoming/ is empty; nothing to inspect
exit=0
```

### B3. Environment threshold changes a verdict

Use a copy for the demonstration; dry-run guarantees the copy is not moved and production receipts are not changed.

```bash
cp accepted/trips_2026_08.csv incoming/threshold_demo.csv
RIDE_KNOX_DRY_RUN=1 RIDE_KNOX_MAX_MALFORMED=0 ./pipeline/intake_gate.sh
rm incoming/threshold_demo.csv
```

Key output:

```text
DRY_RUN,threshold_demo.csv,30045,29925,45,2026-08,quarantine,malformed_rows_exceed_threshold
```

The same August content passes at the default maximum of 50 malformed rows and fails when policy is changed to zero, without editing the file or the program.

## Part C — Repair, load, and closure

### C1. Repair choice

I repair the 45 August rows rather than exclude them. The staging command is:

```bash
sed 's/Market Square, Downtown/Market Square/' "$file" > "$staged"
```

This removes the unquoted vendor suffix that created the ninth field and restores the station name to the contracted station directory value. Excluding those 45 rows would produce the alternative 90,145 anchor; repairing them produces 90,190.

### C2. First load receipts and closure arithmetic

Command:

```bash
./pipeline/load_accepted.sh
```

Receipts:

```text
July:      presented=33085 loaded=32925 rejected_missing_start_time=40 skipped_duplicate_id_in_file=120 skipped_already_loaded=0 accounted=33085
August:    presented=30045 loaded=29765 rejected_missing_start_time=0  skipped_duplicate_id_in_file=120 skipped_already_loaded=160 accounted=30045
September: presented=27760 loaded=27500 rejected_missing_start_time=0  skipped_duplicate_id_in_file=110 skipped_already_loaded=150 accounted=27760
trips_in_database=90190
```

Closure:

```text
July:      33,085 = 32,925 + 40 + 120 + 0
August:    30,045 = 29,765 + 0 + 120 + 160
September: 27,760 = 27,500 + 0 + 110 + 150
Database total = 32,925 + 29,765 + 27,500 = 90,190
```

The 40 July rows with blank `start_time` would be silently skipped by `INSERT OR IGNORE` against the `NOT NULL` schema if I did not count them before insertion. The loader names them explicitly as `rejected_missing_start_time=40`.

### C3. Load idempotency

Command:

```bash
./pipeline/load_accepted.sh
```

Second-run key receipts:

```text
July:      loaded=0 rejected_missing_start_time=40 skipped_duplicate_id_in_file=120 skipped_already_loaded=32925 accounted=33085
August:    loaded=0 rejected_missing_start_time=0  skipped_duplicate_id_in_file=120 skipped_already_loaded=29925 accounted=30045
September: loaded=0 rejected_missing_start_time=0  skipped_duplicate_id_in_file=110 skipped_already_loaded=27650 accounted=27760
trips_in_database=90190
```

The database stays at 90,190.

## Part D — Fall report

Command:

```bash
sqlite3 "$RIDE_KNOX_DB" < pipeline/fall_report.sql
cat out/trips_month_product.csv
cat out/campus_cargo_launch.csv
cat out/cargo_first_station.csv
```

Month × product output:

```text
month,rider_type,trips
2026-06,casual,61
2026-06,day_pass,9
2026-06,member,145
2026-07,casual,7714
2026-07,day_pass,4945
2026-07,member,20076
2026-08,casual,6417
2026-08,day_pass,4091
2026-08,member,19252
2026-09,casual,5480
2026-09,day_pass,3340
2026-09,member,18660
```

The 215 June trips and the previous-month rows in later deliveries stay in their true months because the report uses `start_time`, not delivery filename.

Campus cargo output:

```text
first_campus_cargo_trip,campus_cargo_trips
2026-09-15 10:21:01,220
```

First cargo trip per station:

```text
S01,2026-07-06 06:00:00
S02,2026-07-06 06:00:00
S03,2026-07-06 06:00:00
S04,2026-07-06 06:00:00
S05,2026-07-06 06:00:00
S07,2026-09-15 10:21:01
S08,2026-09-15 10:21:01
S06,2026-09-15 14:36:56
```

The data show the campus extension began September 15, 2026. It appears at S07 and S08 first, then S06 later that day. No accepted data show cargo trips from S09 or S10.

### D2. 2025 baseline in pure shell

Command:

```bash
./pipeline/baseline_2025.sh
grep -E '^2025-(08|09),' out/baseline_2025_month_product.csv
```

Output:

```text
2025-08,casual,7534
2025-08,member,17249
2025-09,casual,6331
2025-09,member,16777
```

The baseline command drops the header, removes exact duplicates, evicts S99, folds the six case spellings through `tolower()`, then aggregates.

### D3. Year-over-year table

| Month | Measure | 2025 denominator | 2026 count | Change |
|---|---|---:|---:|---:|
| August | member | 17,249 | 19,252 | +11.6% |
| August | casual only | 7,534 | 6,417 | -14.8% |
| August | casual + Day Pass | 7,534 | 10,508 | +39.5% |
| September | member | 16,777 | 18,660 | +11.2% |
| September | casual only | 6,331 | 5,480 | -13.4% |
| September | casual + Day Pass | 6,331 | 8,820 | +39.3% |

Fall verdict: the summer recovery held into August and September for members, and nonmember demand is substantially above last fall once Day Pass is included, although casual-only rides remain below 2025. Last fall's nonmember baseline was weak and did not include a separate Day Pass category, so the combined percentage must be interpreted with that denominator visible.

## Part E — Orchestration, environment, and clock

### E1. First full run captured to screen and file

```bash
set -o pipefail
./pipeline/run_intake.sh 2>&1 | tee logs/run_intake_first.log
```

Output anchors from the verified end-to-end test:

```text
stage=gate starting
stage=load starting
... July loaded=32925 ...
... August loaded=29765 ...
... September loaded=27500 ...
trips_in_database=90190
stage=report starting
stage=baseline starting
latest summary committed
intake run complete
```

### E2. Second full run: end-to-end idempotency

```bash
set -o pipefail
./pipeline/run_intake.sh 2>&1 | tee logs/run_intake_second.log
```

Output anchors:

```text
incoming/ is empty; nothing to inspect
July loaded=0
August loaded=0
September loaded=0
trips_in_database=90190
latest summary unchanged; no commit needed
intake run complete
```

### E3. Environment and virtual environment

`.env.example` contains variable names only. `.env` is ignored. `RIDE_KNOX_API_KEY` is guarded with the `:?` pattern. The database defaults to `ride_knox_fall.db` and can be overridden through `RIDE_KNOX_DB`.

`requirements.txt` is hand-written and contains only the loader dependency:

```text
pandas==3.1.0
```

### E4. Cron schedule

```cron
45 6 3 * * cd "/c/Users/RAY KYEI/Documents/ride-knox-analysis" && /usr/bin/env bash ./pipeline/run_intake.sh >> logs/cron.log 2>&1
```

Fields: minute 45; hour 6; day of month 3; every month; every day of week. The explicit `cd` sets the working directory. The run program calls `.venv/Scripts/python.exe` (or `.venv/bin/python`) directly, so no activated environment is required.

### E5. Stripped-environment proof

After `.env` contains the local key and, if needed, the absolute SQLite executable path:

```bash
env -i HOME="$HOME" PATH="/usr/bin:/bin:/mingw64/bin"   /usr/bin/bash --noprofile --norc ./pipeline/run_intake.sh
```

Output anchors from the passing stripped-environment test:

```text
incoming/ is empty; nothing to inspect
July loaded=0
August loaded=0
September loaded=0
trips_in_database=90190
latest summary unchanged; no commit needed
intake run complete
```

## Part F — Director memo

See `memo.md`. It is 293 words, follows bottom line → evidence → interpretation → limitations → recommendation, contains the required denominators, names the unusable October delivery, and avoids the banned technical words.

## Optional Part G — Challenge (+5)

### G1. Dry-run mode

`RIDE_KNOX_DRY_RUN=1` prints each verdict without moving any file or appending a production receipt. An operator inheriting this workflow can test a new policy threshold safely before changing production state. It also makes policy review easier because the operator can see exactly which deliveries would change verdict and why.

### G2. Off-by-one `wc -l` anchor

October is the delivery whose `wc -l` value is one below the true number of records/lines.

Commands:

```bash
wc -l incoming/trips_2026_10.csv
awk 'END {print NR}' incoming/trips_2026_10.csv
tail -c 1 incoming/trips_2026_10.csv | wc -l
tail -n 1 incoming/trips_2026_10.csv
```

Output:

```text
8247 incoming/trips_2026_10.csv
8248
0
T0549739,2026-10-11 17:31:41,2026-10-11 17:41:23,S17,Happy Ho
```

Mechanism: `wc -l` counts newline characters, and the truncated final record has no terminating newline. `awk` still reads that final partial record, so it reports 8,248 records including the header. The missing newline is another symptom that the October delivery ended abruptly rather than as a normal completed export.

## Reflection

The first check I would add for an unseen future failure is a controlled-value/domain check for fields such as `rider_type`, `bike_type`, and station IDs. A file can have eight fields, enough rows, and a low duplicate rate while still introducing a new invalid code that changes reporting. Adding that check is relatively cheap because the gate already computes one verdict per file from independent checks and builds a semicolon-separated reason; a new check can add one environment-configurable policy and one reason without redesigning movement, receipts, loading, or reporting.

## AI disclosure

I used ChatGPT to help draft and debug Bash, Python, and SQL; explain data-quality patterns; organize the audit; and proofread documentation. I reviewed the code and decisions, ran the commands against the course data, and verified the thresholds, row-accounting, report totals, and conclusions before submission. I did not treat generated suggestions as evidence; the reported results come from the provided Ride Knox files and the commands recorded above.

## Full submitted programs


### `pipeline/intake_gate.sh`

```bash
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
```


### `pipeline/load_accepted.sh`

```bash
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
```


### `pipeline/load_month.py`

```python
#!/usr/bin/env python3
"""Load one prepared Ride Knox delivery and print an auditable row receipt."""

import sqlite3
import sys
from pathlib import Path

import pandas as pd

REQUIRED = [
    "trip_id",
    "start_time",
    "end_time",
    "start_station_id",
    "start_station_name",
    "end_station_id",
    "rider_type",
    "bike_type",
]


def normalize_rider(value: str) -> str:
    value = str(value).strip()
    mapping = {
        "member": "member",
        "casual": "casual",
        "DAY PASS": "day_pass",
        "DAYPASS": "day_pass",
        "Day Pass": "day_pass",
        "day_pass": "day_pass",
    }
    return mapping.get(value, value.lower())


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: load_month.py DATABASE PREPARED_CSV", file=sys.stderr)
        return 2

    db_path = Path(sys.argv[1])
    csv_path = Path(sys.argv[2])
    if not csv_path.is_file():
        print(f"ERROR: prepared file not found: {csv_path}", file=sys.stderr)
        return 1

    try:
        df = pd.read_csv(csv_path, dtype=str, keep_default_na=False)
    except Exception as exc:
        print(f"ERROR: could not parse {csv_path}: {exc}", file=sys.stderr)
        return 1

    if list(df.columns) != REQUIRED:
        print("ERROR: prepared file does not match the eight-column contract", file=sys.stderr)
        return 1

    presented = len(df)
    months = df.loc[df["start_time"] != "", "start_time"].str[:7].value_counts()
    delivery_month = months.index[0] if not months.empty else "unknown"

    loaded = 0
    rejected_missing_trip_id = 0
    rejected_missing_start_time = 0
    skipped_duplicate_id_in_file = 0
    skipped_already_loaded = 0
    rejected_database = 0
    seen_in_file = set()

    connection = sqlite3.connect(db_path)
    cursor = connection.cursor()

    for row in df.itertuples(index=False):
        trip_id = row.trip_id.strip()
        start_time = row.start_time.strip()

        if not trip_id:
            rejected_missing_trip_id += 1
            continue
        if not start_time:
            # This is counted before INSERT OR IGNORE so the NOT NULL loss is never silent.
            rejected_missing_start_time += 1
            continue
        if trip_id in seen_in_file:
            skipped_duplicate_id_in_file += 1
            continue
        seen_in_file.add(trip_id)

        exists = cursor.execute(
            "SELECT 1 FROM trips WHERE trip_id = ?", (trip_id,)
        ).fetchone()
        if exists:
            skipped_already_loaded += 1
            continue

        cursor.execute(
            """
            INSERT OR IGNORE INTO trips (
                trip_id, start_time, end_time, start_station_id,
                start_station_name, end_station_id, rider_type, bike_type
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                trip_id,
                start_time,
                row.end_time.strip(),
                row.start_station_id.strip(),
                row.start_station_name.strip(),
                row.end_station_id.strip(),
                normalize_rider(row.rider_type),
                row.bike_type.strip().lower(),
            ),
        )
        if cursor.rowcount == 1:
            loaded += 1
        else:
            rejected_database += 1

    connection.commit()
    connection.close()

    accounted = (
        loaded
        + rejected_missing_trip_id
        + rejected_missing_start_time
        + skipped_duplicate_id_in_file
        + skipped_already_loaded
        + rejected_database
    )

    print(f"file={csv_path.name}")
    print(f"delivery_month={delivery_month}")
    print(f"presented={presented}")
    print(f"loaded={loaded}")
    print(f"rejected_missing_trip_id={rejected_missing_trip_id}")
    print(f"rejected_missing_start_time={rejected_missing_start_time}")
    print(f"skipped_duplicate_id_in_file={skipped_duplicate_id_in_file}")
    print(f"skipped_already_loaded={skipped_already_loaded}")
    print(f"rejected_database={rejected_database}")
    print(f"accounted={accounted}")

    if accounted != presented:
        print("ERROR: closure arithmetic does not close", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```


### `pipeline/schema.sql`

```sql
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS trips (
    trip_id TEXT PRIMARY KEY,
    start_time TEXT NOT NULL,
    end_time TEXT,
    start_station_id TEXT,
    start_station_name TEXT,
    end_station_id TEXT,
    rider_type TEXT,
    bike_type TEXT
);
```


### `pipeline/fall_report.sql`

```sql
.headers on
.mode csv

.output out/trips_month_product.csv
SELECT
    substr(start_time, 1, 7) AS month,
    rider_type,
    COUNT(*) AS trips
FROM trips
GROUP BY month, rider_type
ORDER BY month, rider_type;

.output out/cargo_month_station.csv
SELECT
    substr(start_time, 1, 7) AS month,
    start_station_id,
    COUNT(*) AS cargo_trips
FROM trips
WHERE bike_type = 'cargo'
GROUP BY month, start_station_id
ORDER BY month, start_station_id;

.output out/cargo_first_station.csv
SELECT
    start_station_id,
    MIN(start_time) AS first_cargo_trip
FROM trips
WHERE bike_type = 'cargo'
GROUP BY start_station_id
ORDER BY first_cargo_trip, start_station_id;

.output out/campus_cargo_launch.csv
SELECT
    MIN(start_time) AS first_campus_cargo_trip,
    COUNT(*) AS campus_cargo_trips
FROM trips
WHERE bike_type = 'cargo'
  AND start_station_id IN ('S06','S07','S08','S09','S10');

.output out/month_totals.csv
SELECT
    substr(start_time, 1, 7) AS month,
    COUNT(*) AS trips
FROM trips
GROUP BY month
ORDER BY month;

.output stdout
```


### `pipeline/baseline_2025.sh`

```bash
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
```


### `pipeline/run_intake.sh`

```bash
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
```


## Final submission checks

Commands to run immediately before push:

```bash
git status
git ls-files -s pipeline/*.sh
git ls-files | grep -E '^(incoming/|accepted/|quarantine/|staging/|out/|logs/|\.venv/|\.env$|ride_knox_fall\.db$|trips_.*\.csv$|stations.*\.xlsx$)'
git diff --check
```

Expected: working tree clean after the final commit; every `.sh` mode is `100755`; the forbidden-file grep prints nothing; `git diff --check` prints nothing.

**Pull request URL:** paste the single final PR URL here after merging `feature/bash-module-project` into `main`.
