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
for f in incoming/\*.csv; do
  echo "=== $(basename "$f") ==="
  wc -l "$f"
  printf 'data\_rows='; awk 'END {print NR-1}' "$f"
  printf 'distinct\_rows='; tail -n +2 "$f" | sort -u | wc -l
  printf 'malformed='; awk -F',' 'NR>1 \&\& NF!=8 {c++} END {print c+0}' "$f"
  printf 'months='; awk -F',' 'NR>1 \&\& $2!="" {print substr($2,1,7)}' "$f" | sort | uniq -c
  echo
done
```

Output:

```text
trips\_2026\_07.csv: wc -l=33086, data\_rows=33085, distinct\_rows=32965, malformed=0
months: 2026-06=215, 2026-07=32830

trips\_2026\_08.csv: wc -l=30046, data\_rows=30045, distinct\_rows=29925, malformed=45
months: 2026-07=185, 2026-08=29860

trips\_2026\_09.csv: wc -l=27761, data\_rows=27760, distinct\_rows=27650, malformed=0
months: 2026-08=170, 2026-09=27590

trips\_2026\_09\_resend.csv: wc -l=27761, data\_rows=27760, distinct\_rows=27650, malformed=0
months: 2026-08=170, 2026-09=27590

trips\_2026\_10.csv: wc -l=8247, data\_rows=8247, distinct\_rows=8208, malformed=1
months: 2026-09=155, 2026-10=8092
```

The filename is not used as the month authority. Each delivery contains overlap/backlog rows from the previous month, so reporting months must come from `start\_time`.

### A2. Header contract

Command:

```bash
for f in incoming/\*.csv; do
  echo "$(basename "$f"): $(head -n 1 "$f")"
done
```

Output:

```text
trips\_2026\_07.csv: trip\_id,start\_time,end\_time,start\_station\_id,start\_station\_name,end\_station\_id,rider\_type,bike\_type
trips\_2026\_08.csv: trip\_id,start\_time,end\_time,start\_station\_id,start\_station\_name,end\_station\_id,rider\_type,bike\_type
trips\_2026\_09.csv: trip\_id,start\_time,end\_time,start\_station\_id,start\_station\_name,end\_station\_id,bike\_type,rider\_type
trips\_2026\_09\_resend.csv: trip\_id,start\_time,end\_time,start\_station\_id,start\_station\_name,end\_station\_id,rider\_type,bike\_type
trips\_2026\_10.csv: trip\_id,start\_time,end\_time,start\_station\_id,start\_station\_name,end\_station\_id,rider\_type,bike\_type
```

Decision: the original September delivery violates the contracted order by swapping `bike\_type` and `rider\_type`. The resend restores the contracted order.

### A3. Malformed-row evidence

Command:

```bash
awk -F',' 'NR>1 \&\& NF!=8 {print NR ": NF=" NF " :: " $0}' incoming/trips\_2026\_08.csv | head
awk -F',' 'NR>1 \&\& NF!=8 {print NR ": NF=" NF " :: " $0}' incoming/trips\_2026\_10.csv
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
for f in incoming/\*.csv; do
  printf '%s missing\_start=' "$(basename "$f")"
  awk -F',' 'NR>1 \&\& $2=="" {c++} END {print c+0}' "$f"
  printf ' swapped\_end\_before\_start='
  awk -F',' 'NR>1 \&\& $2!="" \&\& $3!="" \&\& $3<$2 {c++} END {print c+0}' "$f"
done
```

Output:

```text
trips\_2026\_07.csv missing\_start=40 swapped\_end\_before\_start=60
trips\_2026\_08.csv missing\_start=0 swapped\_end\_before\_start=54
trips\_2026\_09.csv missing\_start=0 swapped\_end\_before\_start=52
trips\_2026\_09\_resend.csv missing\_start=0 swapped\_end\_before\_start=52
trips\_2026\_10.csv missing\_start=0 swapped\_end\_before\_start=11
```

The vendor's claim that the timestamp-swap bug was fixed in August is not supported by these deliveries: rows with `end\_time < start\_time` continue after July. I preserve them because the project does not authorize a duration repair and they do not prevent identity/month reporting; the finding belongs in the vendor scorecard.

### A5. Cross-delivery `trip\_id` overlap

Commands used to compare unique IDs without `comm` or `join`:

```bash
mkdir -p out/audit\_ids
cut -d',' -f1 incoming/trips\_2026\_07.csv | tail -n +2 | sort -u > out/audit\_ids/07.txt
cut -d',' -f1 incoming/trips\_2026\_08.csv | tail -n +2 | sort -u > out/audit\_ids/08.txt
cut -d',' -f1 incoming/trips\_2026\_09.csv | tail -n +2 | sort -u > out/audit\_ids/09.txt
cut -d',' -f1 incoming/trips\_2026\_09\_resend.csv | tail -n +2 | sort -u > out/audit\_ids/09r.txt
cut -d',' -f1 incoming/trips\_2026\_10.csv | tail -n +2 | sort -u > out/audit\_ids/10.txt

grep -F -x -f out/audit\_ids/07.txt out/audit\_ids/08.txt | wc -l
grep -F -x -f out/audit\_ids/08.txt out/audit\_ids/09.txt | wc -l
grep -F -x -f out/audit\_ids/09.txt out/audit\_ids/09r.txt | wc -l
grep -F -x -f out/audit\_ids/09r.txt out/audit\_ids/10.txt | wc -l
```

Output:

```text
160
150
27650
140
```

Interpretation: August re-presents 160 July IDs; September re-presents 150 August IDs; the September resend has the same 27,650 unique IDs as the rejected September version; October overlaps the September resend by 140 IDs. The database therefore needs `trip\_id` as the identity constraint.

### A6. Triage plan

|Delivery|Gate decision|Evidence / reason|
|-|-|-|
|July|Accept|Contracted header; 33,085 rows; 120 duplicate copies are below policy; 40 missing start times will be explicitly rejected by the loader.|
|August|Accept|Contracted header; 45 malformed rows are one known, repairable comma defect; repair is visible in staging.|
|September original|Quarantine|Unapproved Export v2 column order violates the contract.|
|September resend|Accept|Restores contracted layout; same trip population as original resend subject to normal duplicate handling.|
|October|Quarantine|Only 8,247 data records, one unknown malformed/truncated final row, and the delivery ends on October 11; it is not a complete monthly delivery.|

Policy defaults: minimum 10,000 rows; maximum 50 total malformed rows; zero unknown malformed rows; maximum 10 duplicate rows per 1,000 rows. These are environment-configurable, not buried in the code.

## Part B — Intake gate

### B1. Five-file triage run

Command:

```bash
./pipeline/intake\_gate.sh 2>\&1 | tee logs/gate\_first.log
```

Key output:

```text
accepted trips\_2026\_07.csv (rows=33085 distinct=32965 malformed=0 month=2026-07)
accepted trips\_2026\_08.csv (rows=30045 distinct=29925 malformed=45 month=2026-08)
REFUSED: trips\_2026\_09.csv -> header\_contract\_mismatch
accepted trips\_2026\_09\_resend.csv (rows=27760 distinct=27650 malformed=0 month=2026-09)
REFUSED: trips\_2026\_10.csv -> below\_minimum\_rows;unknown\_malformed\_rows
```

Receipt:

```text
file,rows,distinct,malformed,content\_month,verdict,reason
trips\_2026\_07.csv,33085,32965,0,2026-07,accepted,passed
trips\_2026\_08.csv,30045,29925,45,2026-08,accepted,passed
trips\_2026\_09.csv,27760,27650,0,2026-09,quarantine,header\_contract\_mismatch
trips\_2026\_09\_resend.csv,27760,27650,0,2026-09,accepted,passed
trips\_2026\_10.csv,8247,8208,1,2026-10,quarantine,below\_minimum\_rows;unknown\_malformed\_rows
```

Exit-code policy: quarantine is a successful gate outcome because the gate has done its job and recorded the refusal. Operational errors fail non-zero. This lets Part E continue to load the deliveries that were safely accepted.

### B2. Empty inbox rerun

Command:

```bash
./pipeline/intake\_gate.sh
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
cp accepted/trips\_2026\_08.csv incoming/threshold\_demo.csv
RIDE\_KNOX\_DRY\_RUN=1 RIDE\_KNOX\_MAX\_MALFORMED=0 ./pipeline/intake\_gate.sh
rm incoming/threshold\_demo.csv
```

Key output:

```text
DRY\_RUN,threshold\_demo.csv,30045,29925,45,2026-08,quarantine,malformed\_rows\_exceed\_threshold
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
./pipeline/load\_accepted.sh
```

Receipts:

```text
July:      presented=33085 loaded=32925 rejected\_missing\_start\_time=40 skipped\_duplicate\_id\_in\_file=120 skipped\_already\_loaded=0 accounted=33085
August:    presented=30045 loaded=29765 rejected\_missing\_start\_time=0  skipped\_duplicate\_id\_in\_file=120 skipped\_already\_loaded=160 accounted=30045
September: presented=27760 loaded=27500 rejected\_missing\_start\_time=0  skipped\_duplicate\_id\_in\_file=110 skipped\_already\_loaded=150 accounted=27760
trips\_in\_database=90190
```

Closure:

```text
July:      33,085 = 32,925 + 40 + 120 + 0
August:    30,045 = 29,765 + 0 + 120 + 160
September: 27,760 = 27,500 + 0 + 110 + 150
Database total = 32,925 + 29,765 + 27,500 = 90,190
```

The 40 July rows with blank `start\_time` would be silently skipped by `INSERT OR IGNORE` against the `NOT NULL` schema if I did not count them before insertion. The loader names them explicitly as `rejected\_missing\_start\_time=40`.

### C3. Load idempotency

Command:

```bash
./pipeline/load\_accepted.sh
```

Second-run key receipts:

```text
July:      loaded=0 rejected\_missing\_start\_time=40 skipped\_duplicate\_id\_in\_file=120 skipped\_already\_loaded=32925 accounted=33085
August:    loaded=0 rejected\_missing\_start\_time=0  skipped\_duplicate\_id\_in\_file=120 skipped\_already\_loaded=29925 accounted=30045
September: loaded=0 rejected\_missing\_start\_time=0  skipped\_duplicate\_id\_in\_file=110 skipped\_already\_loaded=27650 accounted=27760
trips\_in\_database=90190
```

The database stays at 90,190.

## Part D — Fall report

Command:

```bash
sqlite3 "$RIDE\_KNOX\_DB" < pipeline/fall\_report.sql
cat out/trips\_month\_product.csv
cat out/campus\_cargo\_launch.csv
cat out/cargo\_first\_station.csv
```

Month × product output:

```text
month,rider\_type,trips
2026-06,casual,61
2026-06,day\_pass,9
2026-06,member,145
2026-07,casual,7714
2026-07,day\_pass,4945
2026-07,member,20076
2026-08,casual,6417
2026-08,day\_pass,4091
2026-08,member,19252
2026-09,casual,5480
2026-09,day\_pass,3340
2026-09,member,18660
```

The 215 June trips and the previous-month rows in later deliveries stay in their true months because the report uses `start\_time`, not delivery filename.

Campus cargo output:

```text
first\_campus\_cargo\_trip,campus\_cargo\_trips
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
./pipeline/baseline\_2025.sh
grep -E '^2025-(08|09),' out/baseline\_2025\_month\_product.csv
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

|Month|Measure|2025 denominator|2026 count|Change|
|-|-|-:|-:|-:|
|August|member|17,249|19,252|+11.6%|
|August|casual only|7,534|6,417|-14.8%|
|August|casual + Day Pass|7,534|10,508|+39.5%|
|September|member|16,777|18,660|+11.2%|
|September|casual only|6,331|5,480|-13.4%|
|September|casual + Day Pass|6,331|8,820|+39.3%|

Fall verdict: the summer recovery held into August and September for members, and nonmember demand is substantially above last fall once Day Pass is included, although casual-only rides remain below 2025. Last fall's nonmember baseline was weak and did not include a separate Day Pass category, so the combined percentage must be interpreted with that denominator visible.

## Part E — Orchestration, environment, and clock

### E1. First full run captured to screen and file

```bash
set -o pipefail
./pipeline/run\_intake.sh 2>\&1 | tee logs/run\_intake\_first.log
```

Output anchors from the verified end-to-end test:

```text
stage=gate starting
stage=load starting
... July loaded=32925 ...
... August loaded=29765 ...
... September loaded=27500 ...
trips\_in\_database=90190
stage=report starting
stage=baseline starting
latest summary committed
intake run complete
```

### E2. Second full run: end-to-end idempotency

```bash
set -o pipefail
./pipeline/run\_intake.sh 2>\&1 | tee logs/run\_intake\_second.log
```

Output anchors:

```text
incoming/ is empty; nothing to inspect
July loaded=0
August loaded=0
September loaded=0
trips\_in\_database=90190
latest summary unchanged; no commit needed
intake run complete
```

### E3. Environment and virtual environment

`.env.example` contains variable names only. `.env` is ignored. `RIDE\_KNOX\_API\_KEY` is guarded with the `:?` pattern. The database defaults to `ride\_knox\_fall.db` and can be overridden through `RIDE\_KNOX\_DB`.

`requirements.txt` is hand-written and contains only the loader dependency:

```text
pandas==3.1.0
```

### E4. Cron schedule

```cron
45 6 3 \* \* cd "/c/Users/RAY KYEI/Documents/ride-knox-analysis" \&\& /usr/bin/env bash ./pipeline/run\_intake.sh >> logs/cron.log 2>\&1
```

Fields: minute 45; hour 6; day of month 3; every month; every day of week. The explicit `cd` sets the working directory. The run program calls `.venv/Scripts/python.exe` (or `.venv/bin/python`) directly, so no activated environment is required.

### E5. Stripped-environment proof

After `.env` contains the local key and, if needed, the absolute SQLite executable path:

```bash
env -i HOME="$HOME" PATH="/usr/bin:/bin:/mingw64/bin"   /usr/bin/bash --noprofile --norc ./pipeline/run\_intake.sh
```

Output anchors from the passing stripped-environment test:

```text
incoming/ is empty; nothing to inspect
July loaded=0
August loaded=0
September loaded=0
trips\_in\_database=90190
latest summary unchanged; no commit needed
intake run complete
```

## Part F — Director memo

See `memo.md`. It is 293 words, follows bottom line → evidence → interpretation → limitations → recommendation, contains the required denominators, names the unusable October delivery, and avoids the banned technical words.

## Optional Part G — Challenge (+5)

### G1. Dry-run mode

`RIDE\_KNOX\_DRY\_RUN=1` prints each verdict without moving any file or appending a production receipt. An operator inheriting this workflow can test a new policy threshold safely before changing production state. It also makes policy review easier because the operator can see exactly which deliveries would change verdict and why.

### G2. Off-by-one `wc -l` anchor

October is the delivery whose `wc -l` value is one below the true number of records/lines.

Commands:

```bash
wc -l incoming/trips\_2026\_10.csv
awk 'END {print NR}' incoming/trips\_2026\_10.csv
tail -c 1 incoming/trips\_2026\_10.csv | wc -l
tail -n 1 incoming/trips\_2026\_10.csv
```

Output:

```text
8247 incoming/trips\_2026\_10.csv
8248
0
T0549739,2026-10-11 17:31:41,2026-10-11 17:41:23,S17,Happy Ho
```

Mechanism: `wc -l` counts newline characters, and the truncated final record has no terminating newline. `awk` still reads that final partial record, so it reports 8,248 records including the header. The missing newline is another symptom that the October delivery ended abruptly rather than as a normal completed export.

## Reflection

The first check I would add for an unseen future failure is a controlled-value/domain check for fields such as `rider\_type`, `bike\_type`, and station IDs. A file can have eight fields, enough rows, and a low duplicate rate while still introducing a new invalid code that changes reporting. Adding that check is relatively cheap because the gate already computes one verdict per file from independent checks and builds a semicolon-separated reason; a new check can add one environment-configurable policy and one reason without redesigning movement, receipts, loading, or reporting.

## AI disclosure

I used ChatGPT to help draft and debug Bash, Python, and SQL; explain data-quality patterns; organize the audit; and proofread documentation. I reviewed the code and decisions, ran the commands against the course data, and verified the thresholds, row-accounting, report totals, and conclusions before submission. I did not treat generated suggestions as evidence; the reported results come from the provided Ride Knox files and the commands recorded above.

## Full submitted programs



### `pipeline/intake\_gate.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
# Intake policy: quarantining a vendor delivery is an expected business outcome,
# so the gate exits 0 after recording/moving it. Operational failures still exit non-zero.

ROOT\_DIR="$(cd "$(dirname "${BASH\_SOURCE\[0]}")/.." \&\& pwd)"
INCOMING\_DIR="$ROOT\_DIR/incoming"
ACCEPTED\_DIR="$ROOT\_DIR/accepted"
QUARANTINE\_DIR="$ROOT\_DIR/quarantine"
OUT\_DIR="$ROOT\_DIR/out"
RECEIPTS="$OUT\_DIR/intake\_receipts.csv"

MIN\_ROWS="${RIDE\_KNOX\_MIN\_ROWS:-10000}"
MAX\_MALFORMED="${RIDE\_KNOX\_MAX\_MALFORMED:-50}"
MAX\_UNKNOWN\_MALFORMED="${RIDE\_KNOX\_MAX\_UNKNOWN\_MALFORMED:-0}"
MAX\_DUPES\_PER\_1000="${RIDE\_KNOX\_MAX\_DUPES\_PER\_1000:-10}"
DRY\_RUN="${RIDE\_KNOX\_DRY\_RUN:-0}"
EXPECTED\_HEADER='trip\_id,start\_time,end\_time,start\_station\_id,start\_station\_name,end\_station\_id,rider\_type,bike\_type'

mkdir -p "$INCOMING\_DIR" "$ACCEPTED\_DIR" "$QUARANTINE\_DIR" "$OUT\_DIR"

if \[\[ ! -f "$RECEIPTS" ]]; then
  echo 'file,rows,distinct,malformed,content\_month,verdict,reason' > "$RECEIPTS"
fi

processed=0
for file in "$INCOMING\_DIR"/\*.csv; do
  \[\[ -e "$file" ]] || continue
  processed=$((processed + 1))
  name="$(basename "$file")"
  echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] inspecting $name"

  rows="$(awk 'END {print NR-1}' "$file")"
  distinct="$(tail -n +2 "$file" | sort -u | wc -l | tr -d ' ')"
  duplicates=$((rows - distinct))
  malformed="$(awk -F',' 'NR > 1 \&\& NF != 8 {bad++} END {print bad+0}' "$file")"
  repairable="$(awk -F',' 'NR > 1 \&\& NF == 9 \&\& $4 == "S01" \&\& $5 == "Market Square" \&\& $6 == " Downtown" {good++} END {print good+0}' "$file")"
  unknown\_malformed=$((malformed - repairable))
  header="$(head -n 1 "$file" | tr -d '\\r')"
  content\_month="$(awk -F',' 'NR > 1 \&\& $2 != "" {print substr($2,1,7)}' "$file" | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')"
  content\_month="${content\_month:-unknown}"

  verdict="accepted"
  reason="passed"

  if \[\[ "$header" != "$EXPECTED\_HEADER" ]]; then
    verdict="quarantine"
    reason="header\_contract\_mismatch"
  fi

  if (( rows < MIN\_ROWS )); then
    verdict="quarantine"
    if \[\[ "$reason" == "passed" ]]; then reason="below\_minimum\_rows"; else reason="$reason;below\_minimum\_rows"; fi
  fi

  if (( malformed > MAX\_MALFORMED )); then
    verdict="quarantine"
    if \[\[ "$reason" == "passed" ]]; then reason="malformed\_rows\_exceed\_threshold"; else reason="$reason;malformed\_rows\_exceed\_threshold"; fi
  fi

  if (( unknown\_malformed > MAX\_UNKNOWN\_MALFORMED )); then
    verdict="quarantine"
    if \[\[ "$reason" == "passed" ]]; then reason="unknown\_malformed\_rows"; else reason="$reason;unknown\_malformed\_rows"; fi
  fi

  if (( duplicates \* 1000 > rows \* MAX\_DUPES\_PER\_1000 )); then
    verdict="quarantine"
    if \[\[ "$reason" == "passed" ]]; then reason="duplicate\_rate\_exceeds\_threshold"; else reason="$reason;duplicate\_rate\_exceeds\_threshold"; fi
  fi

  receipt="$name,$rows,$distinct,$malformed,$content\_month,$verdict,$reason"

  if \[\[ "$DRY\_RUN" == "1" ]]; then
    echo "DRY\_RUN,$receipt"
    echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] dry-run: $name would be $verdict"
    continue
  fi

  echo "$receipt" >> "$RECEIPTS"
  if \[\[ "$verdict" == "accepted" ]]; then
    mv "$file" "$ACCEPTED\_DIR/$name"
    echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] accepted $name (rows=$rows distinct=$distinct malformed=$malformed month=$content\_month)"
  else
    mv "$file" "$QUARANTINE\_DIR/$name"
    echo "REFUSED: $name -> $reason" >\&2
    echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] quarantined $name" >\&2
  fi
done

if (( processed == 0 )); then
  echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] incoming/ is empty; nothing to inspect"
fi
```



### `pipeline/load\_accepted.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
# Build/update the database from accepted deliveries. Re-runs are safe because trip\_id is the PK.

ROOT\_DIR="$(cd "$(dirname "${BASH\_SOURCE\[0]}")/.." \&\& pwd)"
ACCEPTED\_DIR="$ROOT\_DIR/accepted"
STAGING\_DIR="$ROOT\_DIR/staging"
DB="${RIDE\_KNOX\_DB:-$ROOT\_DIR/ride\_knox\_fall.db}"
SQLITE\_BIN="${RIDE\_KNOX\_SQLITE:-sqlite3}"
PYTHON\_BIN="${RIDE\_KNOX\_PYTHON:-$ROOT\_DIR/.venv/Scripts/python.exe}"

if \[\[ ! -x "$PYTHON\_BIN" ]]; then
  PYTHON\_BIN="$ROOT\_DIR/.venv/bin/python"
fi
if \[\[ ! -x "$PYTHON\_BIN" ]]; then
  echo "ERROR: virtual-environment Python not found under .venv" >\&2
  exit 1
fi
if ! command -v "$SQLITE\_BIN" >/dev/null 2>\&1 \&\& \[\[ ! -x "$SQLITE\_BIN" ]]; then
  echo "ERROR: sqlite3 not found; set RIDE\_KNOX\_SQLITE if needed" >\&2
  exit 1
fi

mkdir -p "$ACCEPTED\_DIR" "$STAGING\_DIR"
"$SQLITE\_BIN" "$DB" < "$ROOT\_DIR/pipeline/schema.sql"

processed=0
for file in "$ACCEPTED\_DIR"/\*.csv; do
  \[\[ -e "$file" ]] || continue
  processed=$((processed + 1))
  name="$(basename "$file")"
  delivery\_month="$(awk -F',' 'NR > 1 \&\& $2 != "" {print substr($2,1,7)}' "$file" | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')"
  staged="$STAGING\_DIR/${delivery\_month}\_${name}"

  echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] preparing $name as content month $delivery\_month"
  # Known August repair: the vendor inserted an unquoted comma after "Market Square".
  # Applying the exact replacement to every accepted file is harmless when the text is absent.
  sed 's/Market Square, Downtown/Market Square/' "$file" > "$staged"

  remaining\_malformed="$(awk -F',' 'NR > 1 \&\& NF != 8 {bad++} END {print bad+0}' "$staged")"
  if (( remaining\_malformed != 0 )); then
    echo "ERROR: $name still has $remaining\_malformed malformed row(s) after staging" >\&2
    exit 1
  fi

  if "$PYTHON\_BIN" "$ROOT\_DIR/pipeline/load\_month.py" "$DB" "$staged" \&\& \\
    echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] loaded receipt complete for $name"; then
    :
  else
    echo "ERROR: loader failed for $name" >\&2
    exit 1
  fi
done

if (( processed == 0 )); then
  echo "ERROR: accepted/ contains no deliveries to load" >\&2
  exit 1
fi

"$SQLITE\_BIN" "$DB" 'SELECT COUNT(\*) AS trips\_in\_database FROM trips;'
```



### `pipeline/load\_month.py`

```python
#!/usr/bin/env python3
"""Load one prepared Ride Knox delivery and print an auditable row receipt."""

import sqlite3
import sys
from pathlib import Path

import pandas as pd

REQUIRED = \[
    "trip\_id",
    "start\_time",
    "end\_time",
    "start\_station\_id",
    "start\_station\_name",
    "end\_station\_id",
    "rider\_type",
    "bike\_type",
]


def normalize\_rider(value: str) -> str:
    value = str(value).strip()
    mapping = {
        "member": "member",
        "casual": "casual",
        "DAY PASS": "day\_pass",
        "DAYPASS": "day\_pass",
        "Day Pass": "day\_pass",
        "day\_pass": "day\_pass",
    }
    return mapping.get(value, value.lower())


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: load\_month.py DATABASE PREPARED\_CSV", file=sys.stderr)
        return 2

    db\_path = Path(sys.argv\[1])
    csv\_path = Path(sys.argv\[2])
    if not csv\_path.is\_file():
        print(f"ERROR: prepared file not found: {csv\_path}", file=sys.stderr)
        return 1

    try:
        df = pd.read\_csv(csv\_path, dtype=str, keep\_default\_na=False)
    except Exception as exc:
        print(f"ERROR: could not parse {csv\_path}: {exc}", file=sys.stderr)
        return 1

    if list(df.columns) != REQUIRED:
        print("ERROR: prepared file does not match the eight-column contract", file=sys.stderr)
        return 1

    presented = len(df)
    months = df.loc\[df\["start\_time"] != "", "start\_time"].str\[:7].value\_counts()
    delivery\_month = months.index\[0] if not months.empty else "unknown"

    loaded = 0
    rejected\_missing\_trip\_id = 0
    rejected\_missing\_start\_time = 0
    skipped\_duplicate\_id\_in\_file = 0
    skipped\_already\_loaded = 0
    rejected\_database = 0
    seen\_in\_file = set()

    connection = sqlite3.connect(db\_path)
    cursor = connection.cursor()

    for row in df.itertuples(index=False):
        trip\_id = row.trip\_id.strip()
        start\_time = row.start\_time.strip()

        if not trip\_id:
            rejected\_missing\_trip\_id += 1
            continue
        if not start\_time:
            # This is counted before INSERT OR IGNORE so the NOT NULL loss is never silent.
            rejected\_missing\_start\_time += 1
            continue
        if trip\_id in seen\_in\_file:
            skipped\_duplicate\_id\_in\_file += 1
            continue
        seen\_in\_file.add(trip\_id)

        exists = cursor.execute(
            "SELECT 1 FROM trips WHERE trip\_id = ?", (trip\_id,)
        ).fetchone()
        if exists:
            skipped\_already\_loaded += 1
            continue

        cursor.execute(
            """
            INSERT OR IGNORE INTO trips (
                trip\_id, start\_time, end\_time, start\_station\_id,
                start\_station\_name, end\_station\_id, rider\_type, bike\_type
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                trip\_id,
                start\_time,
                row.end\_time.strip(),
                row.start\_station\_id.strip(),
                row.start\_station\_name.strip(),
                row.end\_station\_id.strip(),
                normalize\_rider(row.rider\_type),
                row.bike\_type.strip().lower(),
            ),
        )
        if cursor.rowcount == 1:
            loaded += 1
        else:
            rejected\_database += 1

    connection.commit()
    connection.close()

    accounted = (
        loaded
        + rejected\_missing\_trip\_id
        + rejected\_missing\_start\_time
        + skipped\_duplicate\_id\_in\_file
        + skipped\_already\_loaded
        + rejected\_database
    )

    print(f"file={csv\_path.name}")
    print(f"delivery\_month={delivery\_month}")
    print(f"presented={presented}")
    print(f"loaded={loaded}")
    print(f"rejected\_missing\_trip\_id={rejected\_missing\_trip\_id}")
    print(f"rejected\_missing\_start\_time={rejected\_missing\_start\_time}")
    print(f"skipped\_duplicate\_id\_in\_file={skipped\_duplicate\_id\_in\_file}")
    print(f"skipped\_already\_loaded={skipped\_already\_loaded}")
    print(f"rejected\_database={rejected\_database}")
    print(f"accounted={accounted}")

    if accounted != presented:
        print("ERROR: closure arithmetic does not close", file=sys.stderr)
        return 1

    return 0


if \_\_name\_\_ == "\_\_main\_\_":
    raise SystemExit(main())
```



### `pipeline/schema.sql`

```sql
PRAGMA foreign\_keys = ON;

CREATE TABLE IF NOT EXISTS trips (
    trip\_id TEXT PRIMARY KEY,
    start\_time TEXT NOT NULL,
    end\_time TEXT,
    start\_station\_id TEXT,
    start\_station\_name TEXT,
    end\_station\_id TEXT,
    rider\_type TEXT,
    bike\_type TEXT
);
```



### `pipeline/fall\_report.sql`

```sql
.headers on
.mode csv

.output out/trips\_month\_product.csv
SELECT
    substr(start\_time, 1, 7) AS month,
    rider\_type,
    COUNT(\*) AS trips
FROM trips
GROUP BY month, rider\_type
ORDER BY month, rider\_type;

.output out/cargo\_month\_station.csv
SELECT
    substr(start\_time, 1, 7) AS month,
    start\_station\_id,
    COUNT(\*) AS cargo\_trips
FROM trips
WHERE bike\_type = 'cargo'
GROUP BY month, start\_station\_id
ORDER BY month, start\_station\_id;

.output out/cargo\_first\_station.csv
SELECT
    start\_station\_id,
    MIN(start\_time) AS first\_cargo\_trip
FROM trips
WHERE bike\_type = 'cargo'
GROUP BY start\_station\_id
ORDER BY first\_cargo\_trip, start\_station\_id;

.output out/campus\_cargo\_launch.csv
SELECT
    MIN(start\_time) AS first\_campus\_cargo\_trip,
    COUNT(\*) AS campus\_cargo\_trips
FROM trips
WHERE bike\_type = 'cargo'
  AND start\_station\_id IN ('S06','S07','S08','S09','S10');

.output out/month\_totals.csv
SELECT
    substr(start\_time, 1, 7) AS month,
    COUNT(\*) AS trips
FROM trips
GROUP BY month
ORDER BY month;

.output stdout
```



### `pipeline/baseline\_2025.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
# Pure-shell 2025 baseline: drop header, exact duplicates, S99, and fold case variants.

ROOT\_DIR="$(cd "$(dirname "${BASH\_SOURCE\[0]}")/.." \&\& pwd)"
BASELINE="$ROOT\_DIR/trips\_2025.csv"
OUT\_FILE="$ROOT\_DIR/out/baseline\_2025\_month\_product.csv"

if \[\[ ! -f "$BASELINE" ]]; then
  echo "ERROR: missing baseline file: $BASELINE" >\&2
  exit 1
fi

mkdir -p "$ROOT\_DIR/out"
echo 'month,rider\_type,trips' > "$OUT\_FILE"

tail -n +2 "$BASELINE" | \\
  sort -u | \\
  awk -F',' '$4 != "S99" {print substr($2,1,7) "," tolower($7)}' | \\
  sort | \\
  uniq -c | \\
  awk '{print $2 "," $1}' >> "$OUT\_FILE"

echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] wrote $OUT\_FILE"
```



### `pipeline/run\_intake.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
# One-command monthly run: gate -> load -> report -> baseline -> summary snapshot.

ROOT\_DIR="$(cd "$(dirname "${BASH\_SOURCE\[0]}")/.." \&\& pwd)"
cd "$ROOT\_DIR"

if \[\[ -f "$ROOT\_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT\_DIR/.env"
  set +a
fi

: "${RIDE\_KNOX\_API\_KEY:?RIDE\_KNOX\_API\_KEY is required}"
export RIDE\_KNOX\_DB="${RIDE\_KNOX\_DB:-$ROOT\_DIR/ride\_knox\_fall.db}"
export RIDE\_KNOX\_SQLITE="${RIDE\_KNOX\_SQLITE:-sqlite3}"

PYTHON\_BIN="$ROOT\_DIR/.venv/Scripts/python.exe"
if \[\[ ! -x "$PYTHON\_BIN" ]]; then
  PYTHON\_BIN="$ROOT\_DIR/.venv/bin/python"
fi
if \[\[ ! -x "$PYTHON\_BIN" ]]; then
  echo "ERROR: virtual-environment Python not found under .venv" >\&2
  exit 1
fi
export RIDE\_KNOX\_PYTHON="$PYTHON\_BIN"

mkdir -p "$ROOT\_DIR/incoming" "$ROOT\_DIR/accepted" "$ROOT\_DIR/quarantine" \\
  "$ROOT\_DIR/staging" "$ROOT\_DIR/out" "$ROOT\_DIR/logs"

if ! command -v "$RIDE\_KNOX\_SQLITE" >/dev/null 2>\&1 \&\& \[\[ ! -x "$RIDE\_KNOX\_SQLITE" ]]; then
  echo "ERROR: sqlite3 not found; set RIDE\_KNOX\_SQLITE to its full path" >\&2
  exit 1
fi

if echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] stage=gate starting" \&\& \\
  "$ROOT\_DIR/pipeline/intake\_gate.sh" \&\& \\
  echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] stage=load starting" \&\& \\
  "$ROOT\_DIR/pipeline/load\_accepted.sh" \&\& \\
  echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] stage=report starting" \&\& \\
  "$RIDE\_KNOX\_SQLITE" "$RIDE\_KNOX\_DB" < "$ROOT\_DIR/pipeline/fall\_report.sql" \&\& \\
  echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] stage=baseline starting" \&\& \\
  "$ROOT\_DIR/pipeline/baseline\_2025.sh"; then
  :
else
  echo "ERROR: intake run stopped because a stage failed" >\&2
  exit 1
fi

{
  echo 'Ride Knox latest intake summary'
  echo
  echo '\[receipts]'
  cat "$ROOT\_DIR/out/intake\_receipts.csv"
  echo
  echo '\[database month totals]'
  "$RIDE\_KNOX\_SQLITE" -header -csv "$RIDE\_KNOX\_DB" \\
    "SELECT substr(start\_time,1,7) AS month, COUNT(\*) AS trips FROM trips GROUP BY month ORDER BY month;"
} > "$ROOT\_DIR/pipeline/latest\_intake\_summary.txt"

git -C "$ROOT\_DIR" add pipeline/latest\_intake\_summary.txt
if git -C "$ROOT\_DIR" diff --cached --quiet; then
  echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] latest summary unchanged; no commit needed"
else
  git -C "$ROOT\_DIR" commit -m "Update latest intake summary"
  echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] latest summary committed"
fi

echo "\[$(date '+%Y-%m-%dT%H:%M:%S')] intake run complete"
```



## Final submission checks

Commands to run immediately before push:

```bash
git status
git ls-files -s pipeline/\*.sh
git ls-files | grep -E '^(incoming/|accepted/|quarantine/|staging/|out/|logs/|\\.venv/|\\.env$|ride\_knox\_fall\\.db$|trips\_.\*\\.csv$|stations.\*\\.xlsx$)'
git diff --check
```

Expected: working tree clean after the final commit; every `.sh` mode is `100755`; the forbidden-file grep prints nothing; `git diff --check` prints nothing.

**Pull request URL:** https://github.com/RaymondKojoKyei/ride-knox-analysis/pull/50

