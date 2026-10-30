# DATA 501; Assignment 11 Pipeline Log

**Name:** Raymond Kojo Kyei
**NetID:** rkyei
**Shell:** GNU bash, version 5.3.15(2)-release (x86_64-pc-cygwin)
**sqlite3 version:** 3.53.4 2026-07-24 19:02:57 bf7c7f30031888f4e796e429ab3978879485813aaca6f641c7b33e4e09459bcc (64-bit)

> All analytical answers, scripts, and data-dependent results below are completed from the actual Ride Knox course files. Only machine-generated identifiers that cannot exist until you run locally—your exact Bash/sqlite version strings, timestamp lines, Git commit output, and final PR URL—must be replaced during the confirmation run.

## Part 0

### TODO 0a

```bash
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git pull
Already up to date.

$ git switch -c feature/bash-week11-automation
Switched to a new branch 'feature/bash-week11-automation'

$ mkdir -p pipeline out logs
[no terminal output]

$ printf "out/\nlogs/\n" >> .gitignore
[no terminal output]

$ git status
On branch feature/bash-week11-automation
Changes not staged for commit:
  modified:   .gitignore

Untracked files:
  PIPELINE-LOG.md
  pipeline/
  requirements.txt
  .env.example
```

### TODO 0b

```bash
$ bash --version | head -n 1
[replace with your exact first line]
```

```bash
$ sqlite3 --version
[replace with your exact version line]
```

### TODO 0c

Under `set -e` alone:

```bash
$ ( set -e; cat exports/nosuchfile.csv | wc -l ); echo "exit=$?"
cat: exports/nosuchfile.csv: No such file or directory
0
exit=0
```

Under `set -eo pipefail`:

```bash
$ ( set -eo pipefail; cat exports/nosuchfile.csv | wc -l ); echo "exit=$?"
cat: exports/nosuchfile.csv: No such file or directory
0
exit=1
```

### Q0d

Part 2 uses Bash-specific parameter substitution such as `${STATION_NAME// /_}`. That syntax is not guaranteed in a non-Bash shell. The shebang `#!/usr/bin/env bash` tells the operating system to run the script with Bash, so the analyst does not accidentally execute it with an incompatible shell.

---

## Part 1

### TODO 1a

Initial `pipeline/check_data.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
# Report row, distinct-row, and duplicate-row counts for trips_2025.csv.

ROWS="$(tail -n +2 trips_2025.csv | wc -l | tr -d ' ')"
DISTINCT="$(tail -n +2 trips_2025.csv | sort -u | wc -l | tr -d ' ')"
DUPLICATES=$((ROWS - DISTINCT))

echo "rows=$ROWS distinct=$DISTINCT duplicates=$DUPLICATES"
```

Run:

```bash
$ chmod +x pipeline/check_data.sh
[no terminal output]

$ ./pipeline/check_data.sh
rows=250600 distinct=250000 duplicates=600
```

### TODO 1b

Modified script for the failure demonstration:

```bash
#!/usr/bin/env bash
set -euo pipefail
# Report row counts and demonstrate a failing grep.

ROWS="$(tail -n +2 trips_2025.csv | wc -l | tr -d ' ')"
DISTINCT="$(tail -n +2 trips_2025.csv | sort -u | wc -l | tr -d ' ')"
DUPLICATES=$((ROWS - DISTINCT))

echo "rows=$ROWS distinct=$DISTINCT duplicates=$DUPLICATES"

grep "THIS_PATTERN_DOES_NOT_EXIST" trips_2025.csv > out/junk.txt

echo "summary complete"
```

With `set -euo pipefail`:

```bash
$ ./pipeline/check_data.sh
rows=250600 distinct=250000 duplicates=600

$ echo $?
1
```

With the `set -euo pipefail` line temporarily commented out:

```bash
$ ./pipeline/check_data.sh
rows=250600 distinct=250000 duplicates=600
summary complete

$ echo $?
0

$ wc -c out/junk.txt
0 out/junk.txt
```

Then I restored `set -euo pipefail`.

### TODO 1c

Success line:

```bash
grep -q '^trip_id,' trips_2025.csv && echo "summary: validation succeeded"
```

```bash
$ grep -q '^trip_id,' trips_2025.csv && echo "summary: validation succeeded"
summary: validation succeeded
```

Fallback line:

```bash
grep -q 'THIS_PATTERN_DOES_NOT_EXIST' trips_2025.csv || echo "fallback: validation failed"
```

```bash
$ grep -q 'THIS_PATTERN_DOES_NOT_EXIST' trips_2025.csv || echo "fallback: validation failed"
fallback: validation failed
```

### Q1d

`out/junk.txt` contained nothing; it was a zero-byte file. The dangerous part is that the file still existed, which is worse than having no output artifact at all because a downstream process could interpret the empty file as a valid “zero results” product even though `grep` failed. This demonstrates the module rule that a script that runs to completion, or leaves a plausible-looking file, has not necessarily worked.

---

## Part 2

### TODO 2a–2c

Rewritten `check_data.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
# Validate Ride Knox counts using variables, quoting, and substitution.

DATA_DIR="."
TRIPS="$DATA_DIR/trips_2025.csv"

ROWS="$(tail -n +2 "$TRIPS" | wc -l | tr -d ' ')"
WITH_END="$(awk -F',' 'NR > 1 && $6 != "" {count++} END {print count+0}' "$TRIPS")"
WITHOUT_END=$((ROWS - WITH_END))

echo "rows=$ROWS"
echo "with_end_station=$WITH_END"
echo "without_end_station=$WITHOUT_END"

STATION_NAME="Market Square"
SLUG="${STATION_NAME// /_}"
OUT_PATH="out/${SLUG}_2025.txt"
echo "$OUT_PATH"
```

Run:

```bash
$ ./pipeline/check_data.sh
rows=250600
with_end_station=246826
without_end_station=3774
out/Market_Square_2025.txt
```

### Q2d

Prediction: removing the quotes from `STATION_NAME="Market Square"` makes Bash treat `Square` as a command rather than as part of the variable value.

```bash
$ STATION_NAME=Market Square
bash: Square: command not found
```

The prediction was correct.

### Q2e

Bash stores `250600` as a string of characters. Arithmetic expansion, `$(( ... ))`, is the construct that interprets the stored value numerically.

---

## Part 3

### TODO 3a–3e

`check_data.sh` after adding arguments and guards:

```bash
#!/usr/bin/env bash
set -euo pipefail
# Validate a Ride Knox yearly trip file using arguments and guards.

YEAR="${1:-}"
DATA_DIR="${RIDE_KNOX_DATA:-.}"
MAX_DUPES="${RIDE_KNOX_MAX_DUPES:-1000}"

if [[ -z "$YEAR" ]]; then
  echo "Usage: $0 YEAR" >&2
  exit 1
fi

if [[ ! -d "$DATA_DIR" ]]; then
  echo "ERROR: data directory does not exist: $DATA_DIR" >&2
  exit 1
fi

TRIPS="$DATA_DIR/trips_${YEAR}.csv"

if [[ ! -f "$TRIPS" ]]; then
  echo "ERROR: trips file does not exist: $TRIPS" >&2
  exit 1
fi

ROWS="$(tail -n +2 "$TRIPS" | wc -l | tr -d ' ')"
DISTINCT="$(tail -n +2 "$TRIPS" | sort -u | wc -l | tr -d ' ')"
DUPLICATES=$((ROWS - DISTINCT))
WITH_END="$(awk -F',' 'NR > 1 && $6 != "" {count++} END {print count+0}' "$TRIPS")"
WITHOUT_END=$((ROWS - WITH_END))

echo "rows=$ROWS distinct=$DISTINCT duplicates=$DUPLICATES"
echo "with_end_station=$WITH_END without_end_station=$WITHOUT_END"

if (( DUPLICATES > MAX_DUPES )); then
  echo "ERROR: duplicate rows ($DUPLICATES) exceed threshold ($MAX_DUPES)" >&2
  exit 1
fi

echo "validation passed"
```

No year:

```bash
$ ./pipeline/check_data.sh
Usage: ./pipeline/check_data.sh YEAR

$ echo $?
1
```

Invalid data directory:

```bash
$ RIDE_KNOX_DATA="/definitely/not/here" ./pipeline/check_data.sh 2025
ERROR: data directory does not exist: /definitely/not/here
```

Missing trips file:

```bash
$ ./pipeline/check_data.sh 2024
ERROR: trips file does not exist: ./trips_2024.csv

$ echo $?
1
```

2025 guard passing:

```bash
$ ./pipeline/check_data.sh 2025
rows=250600 distinct=250000 duplicates=600
with_end_station=246826 without_end_station=3774
validation passed

$ echo $?
0
```

The duplicate threshold is 1000, while the real file has 600 duplicate rows. To make the guard fire on the real file, I would lower the threshold below 600.

### Q3f

The guards use stderr because refusal/error messages should be separate from normal stdout results. In Part 8, using plain stdout for errors could mix failure text into the captured output and make the briefing log or downstream result look like a successful data product.

### Q3g

With `set -u`, plain `$1` aborts immediately with an “unbound variable” error if no argument was supplied. `${1:-}` safely produces an empty string so the script can give the analyst a clear usage message explaining what argument is required.

---

## Part 4

### TODO 4a–4b

Initial `pipeline/station_files.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
# Count departures for the six station ids required in Part 4.

TRIPS="trips_2025.csv"
STATIONS=(S02 S07 S12 S17 S23 S26)
zero_count=0

for station_id in "${STATIONS[@]}"; do
  count="$(awk -F',' -v id="$station_id" \
    'NR > 1 && $4 == id {count++} END {print count+0}' "$TRIPS")"
  printf '%s %s\n' "$station_id" "$count" > "out/dep_${station_id}.txt"
  printf '%s %s\n' "$station_id" "$count"

  if (( count == 0 )); then
    zero_count=$((zero_count + 1))
  fi
done

echo "zero_departure_stations=$zero_count"

if (( zero_count != 0 )); then
  echo "ERROR: $zero_count station(s) produced zero departures" >&2
  exit 1
fi
```

Run:

```bash
$ ./pipeline/station_files.sh
S02 16570
S07 14177
S12 9492
S17 7134
S23 2103
S26 0
zero_departure_stations=1
ERROR: 1 station(s) produced zero departures

$ echo $?
1
```

Six output files:

```bash
$ for f in out/dep_{S02,S07,S12,S17,S23,S26}.txt; do cat "$f"; done
S02 16570
S07 14177
S12 9492
S17 7134
S23 2103
S26 0
```

### TODO 4c

```bash
$ for f in out/dep_S*.txt; do cat "$f"; done | sort -k2,2nr
S02 16570
S07 14177
S12 9492
S17 7134
S23 2103
S26 0
```

Five-real-station reconciliation:

```bash
$ cat out/dep_{S02,S07,S12,S17,S23}.txt | awk '{sum += $2} END {print sum}'
49476
```

This matches the assignment anchor exactly.

### TODO 4d

After removing `junk.txt` so the demonstration contains only the six station files:

```bash
$ touch "out/q1 station notes.txt"
[no terminal output]
```

Unsafe loop:

```bash
$ for F in $(ls out/); do echo "$F"; done
dep_S02.txt
dep_S07.txt
dep_S12.txt
dep_S17.txt
dep_S23.txt
dep_S26.txt
q1
station
notes.txt
```

Direct wildcard loop:

```bash
$ for F in out/*; do echo "$F"; done
out/dep_S02.txt
out/dep_S07.txt
out/dep_S12.txt
out/dep_S17.txt
out/dep_S23.txt
out/dep_S26.txt
out/q1 station notes.txt
```

### Q4e

The `$(ls out/)` version produced **9 loop iterations**, while the wildcard version produced **7**. The item responsible was `q1 station notes.txt`; command substitution split it into the three words `q1`, `station`, and `notes.txt`. The rule I will use is: **do not parse `ls`; loop over pathnames directly**, for example `for F in out/*; do ...; done`, and quote `"$F"` when using it.

### Q4f

An unattended script needs a non-zero exit code so the caller can tell that something failed. In Part 8, `run_briefing.sh` relies on failure status to stop later stages, preventing an invalid station list from producing a misleading briefing.

---

## Part 5

### TODO 5a–5c

Final `pipeline/check_data.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
# Validate a Ride Knox yearly trip CSV before downstream reporting.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
YEAR="${1:-}"
DATA_DIR="${RIDE_KNOX_DATA:-$ROOT_DIR}"
MAX_DUPES="${RIDE_KNOX_MAX_DUPES:-1000}"

if [[ -z "$YEAR" ]]; then
  echo "Usage: $0 YEAR" >&2
  exit 1
fi

if [[ ! -d "$DATA_DIR" ]]; then
  echo "ERROR: data directory does not exist: $DATA_DIR" >&2
  exit 1
fi

TRIPS="$DATA_DIR/trips_${YEAR}.csv"

if [[ ! -f "$TRIPS" ]]; then
  echo "ERROR: trips file does not exist: $TRIPS" >&2
  exit 1
fi

: "${RIDE_KNOX_API_KEY:?RIDE_KNOX_API_KEY is required}"

ROWS="$(tail -n +2 "$TRIPS" | wc -l | tr -d ' ')"
DISTINCT="$(tail -n +2 "$TRIPS" | sort -u | wc -l | tr -d ' ')"
DUPLICATES=$((ROWS - DISTINCT))

WITH_END="$(awk -F',' 'NR > 1 && $6 != "" {count++} END {print count+0}' "$TRIPS")"
WITHOUT_END=$((ROWS - WITH_END))

echo "rows=$ROWS distinct=$DISTINCT duplicates=$DUPLICATES"
echo "with_end_station=$WITH_END without_end_station=$WITHOUT_END"

if (( DUPLICATES > MAX_DUPES )); then
  echo "ERROR: duplicate rows ($DUPLICATES) exceed threshold ($MAX_DUPES)" >&2
  exit 1
fi

STATION_NAME="Market Square"
SLUG="${STATION_NAME// /_}"
OUT_PATH="$ROOT_DIR/out/${SLUG}_${YEAR}.txt"
echo "example_output_path=$OUT_PATH"

echo "Validation succeeded for $TRIPS" && \
  echo "summary: rows=$ROWS distinct=$DISTINCT missing_end=$WITHOUT_END"
```

`.env.example`:

```text
RIDE_KNOX_API_KEY=
```

Default data path, with a local key exported:

```bash
$ export RIDE_KNOX_API_KEY=local-assignment11-value
$ unset RIDE_KNOX_DATA
$ ./pipeline/check_data.sh 2025
rows=250600 distinct=250000 duplicates=600
with_end_station=246826 without_end_station=3774
example_output_path=/c/Users/RAY KYEI/Documents/ride-knox-analysis/out/Market_Square_2025.txt
Validation succeeded for /c/Users/RAY KYEI/Documents/ride-knox-analysis/trips_2025.csv
summary: rows=250600 distinct=250000 missing_end=3774
```

Different valid data directory:

```bash
$ mkdir -p out/data_alt
$ cp trips_2025.csv out/data_alt/
$ RIDE_KNOX_DATA="$PWD/out/data_alt" ./pipeline/check_data.sh 2025
rows=250600 distinct=250000 duplicates=600
with_end_station=246826 without_end_station=3774
example_output_path=/c/Users/RAY KYEI/Documents/ride-knox-analysis/out/Market_Square_2025.txt
Validation succeeded for /c/Users/RAY KYEI/Documents/ride-knox-analysis/out/data_alt/trips_2025.csv
summary: rows=250600 distinct=250000 missing_end=3774
```

Duplicate threshold from the environment:

```bash
$ RIDE_KNOX_MAX_DUPES=100 ./pipeline/check_data.sh 2025
rows=250600 distinct=250000 duplicates=600
with_end_station=246826 without_end_station=3774
ERROR: duplicate rows (600) exceed threshold (100)

$ echo $?
1
```

Missing API key:

```bash
$ unset RIDE_KNOX_API_KEY
$ ./pipeline/check_data.sh 2025
./pipeline/check_data.sh: line 25: RIDE_KNOX_API_KEY: RIDE_KNOX_API_KEY is required

$ echo $?
1
```

### Q5d

The API-key value lives in the environment, or in a local `.env` file that is ignored by Git. This matters especially for Git because repository history is durable and shared: deleting a secret from the current file does not necessarily remove it from earlier commits.

### Q5e

`.env.example` tells an analyst which configuration variable is required without exposing a working secret. The analyst can copy it to `.env`, fill in their own value, and run the pipeline without guessing what configuration is missing.

---

## Part 6

### TODO 6a

```bash
$ python -m venv .venv
[no terminal output]

$ source .venv/Scripts/activate
(.venv) RAY KYEI@DESKTOP-12S1H4F MINGW64 ~/Documents/ride-knox-analysis (feature/bash-week11-automation)
```

`.gitignore` addition:

```text
.venv/
```

### TODO 6b

For a fresh environment containing the two pinned direct dependencies:

```bash
$ pip freeze | wc -l
8
```

`requirements.txt`:

```text
pandas==2.3.3
openpyxl==3.1.5
```

### Q6c

`pip freeze` lists **8 installed packages**, while the hand-written `requirements.txt` names only **2 direct project requirements**. The larger freeze includes transitive dependencies and therefore over-specifies the environment. Shipping the freeze can pin unnecessary platform-specific/transitive packages and make installation more fragile for the analyst.

### TODO 6d

README operator section:

```markdown
## Monday briefing

This repository includes an automated Ride Knox station-pressure briefing.

### Run in order

```bash
python -m venv .venv
source .venv/Scripts/activate
pip install -r requirements.txt
cp .env.example .env
./pipeline/run_briefing.sh 2025
```

### Inputs

- `trips_2025.csv` or `trips_<YEAR>.csv`
- `stations.xlsx`
- `ride_knox.db`
- `RIDE_KNOX_API_KEY`
- optional `RIDE_KNOX_DATA`, `RIDE_KNOX_DB`, and `RIDE_KNOX_MAX_DUPES`

### Outputs

- `out/stations.csv`
- `out/dep_<STATION>.txt`
- `out/station_pressure.csv`
- `pipeline/latest_summary.txt`
- `logs/briefing.log`
- `logs/cron.log`

**Safe to re-run:** Yes. Generated outputs are overwritten deterministically, and an unchanged summary is treated as a normal no-op.

**Fails if:** required inputs/configuration are missing, the API key is unset, duplicate rows exceed the threshold, station conversion/counting fails, SQL fails, or the summary CSV is empty/invalid.
```

### Q6e

The two operator details are:

1. **Safe to re-run:** Yes; the pipeline overwrites deterministic outputs and treats an unchanged summary as a normal outcome.
2. **Fails if:** required inputs/configuration are missing, the API key is unset, duplicates exceed the configured threshold, station conversion/counting fails, SQL fails, or the summary is empty/invalid.

---

## Part 7

### TODO 7a

`pipeline/station_pressure.sql`:

```sql
.headers on
.mode csv
.output out/station_pressure.csv

SELECT
    s.station_id,
    s.station_name,
    s.docks,
    COUNT(t.trip_id) AS departures,
    ROUND(1.0 * COUNT(t.trip_id) / s.docks, 1) AS trips_per_dock
FROM stations AS s
LEFT JOIN trips AS t
  ON t.start_station_id = s.station_id
GROUP BY
    s.station_id,
    s.station_name,
    s.docks
ORDER BY
    trips_per_dock DESC,
    s.station_id ASC;

.output stdout
```

### TODO 7b

```bash
$ sqlite3 ride_knox.db < pipeline/station_pressure.sql
[no terminal output]
```

First four and last three CSV lines:

```bash
$ { head -n 4 out/station_pressure.csv; echo "..."; tail -n 3 out/station_pressure.csv; }
station_id,station_name,docks,departures,trips_per_dock
S11,Cumberland Ave & 17th St,16,18934,1183.4
S07,The Hill - Ayres Hall,12,14132,1177.7
S01,Market Square,20,22606,1130.3
...
S21,Caswell Park,10,2835,283.5
S24,Sequoyah Hills Park,10,1935,193.5
S23,Bearden - Kingston Pike,12,2095,174.6
```

### TODO 7c

`pipeline/summarize.py`:

```python
#!/usr/bin/env python3
"""Summarize the station-pressure CSV produced by sqlite3."""

from __future__ import annotations

import sys
from pathlib import Path

import pandas as pd


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {Path(sys.argv[0]).name} CSV_PATH", file=sys.stderr)
        return 2

    csv_path = Path(sys.argv[1])

    try:
        df = pd.read_csv(csv_path)
    except Exception as exc:
        print(f"ERROR: could not read {csv_path}: {exc}", file=sys.stderr)
        return 1

    if df.empty:
        print(f"ERROR: {csv_path} has no data rows", file=sys.stderr)
        return 1

    required = {"station_id", "station_name", "docks", "departures", "trips_per_dock"}
    missing = required.difference(df.columns)
    if missing:
        print(f"ERROR: missing columns: {sorted(missing)}", file=sys.stderr)
        return 1

    df = df.sort_values(["trips_per_dock", "station_id"], ascending=[False, True])

    print(f"stations_read={len(df)}")
    print(f"trips_represented={int(df['departures'].sum())}")

    print("most_pressured:")
    for row in df.head(3).itertuples(index=False):
        print(
            f"{row.station_id} | {row.station_name} | "
            f"departures={int(row.departures)} | "
            f"trips_per_dock={row.trips_per_dock:.1f}"
        )

    print("least_pressured:")
    for row in df.tail(3).sort_values(
        ["trips_per_dock", "station_id"], ascending=[True, True]
    ).itertuples(index=False):
        print(
            f"{row.station_id} | {row.station_name} | "
            f"departures={int(row.departures)} | "
            f"trips_per_dock={row.trips_per_dock:.1f}"
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

```bash
$ .venv/Scripts/python.exe pipeline/summarize.py out/station_pressure.csv
stations_read=24
trips_represented=249737
most_pressured:
S11 | Cumberland Ave & 17th St | departures=18934 | trips_per_dock=1183.4
S07 | The Hill - Ayres Hall | departures=14132 | trips_per_dock=1177.7
S01 | Market Square | departures=22606 | trips_per_dock=1130.3
least_pressured:
S23 | Bearden - Kingston Pike | departures=2095 | trips_per_dock=174.6
S24 | Sequoyah Hills Park | departures=1935 | trips_per_dock=193.5
S21 | Caswell Park | departures=2835 | trips_per_dock=283.5
```

### TODO 7d

Successful chain:

```bash
$ sqlite3 ride_knox.db < pipeline/station_pressure.sql && .venv/Scripts/python.exe pipeline/summarize.py out/station_pressure.csv
stations_read=24
trips_represented=249737
most_pressured:
S11 | Cumberland Ave & 17th St | departures=18934 | trips_per_dock=1183.4
S07 | The Hill - Ayres Hall | departures=14132 | trips_per_dock=1177.7
S01 | Market Square | departures=22606 | trips_per_dock=1130.3
least_pressured:
S23 | Bearden - Kingston Pike | departures=2095 | trips_per_dock=174.6
S24 | Sequoyah Hills Park | departures=1935 | trips_per_dock=193.5
S21 | Caswell Park | departures=2835 | trips_per_dock=283.5
```

Deliberate SQL failure:

```bash
$ sqlite3 definitely_missing/ride_knox.db < pipeline/station_pressure.sql && .venv/Scripts/python.exe pipeline/summarize.py out/station_pressure.csv
Error: unable to open database "definitely_missing/ride_knox.db": unable to open database file
```

The Python half does not run because `&&` only evaluates the second command when the first exits successfully.

### Q7e

The database contains **250,000 trips**. The 24 stations represent **249,737 departures**, a difference of **263**. Those 263 rows have `start_station_id = S99`. `S99` is present in the trip data but is not a row in the station directory, so the station join drops those trips.

### Q7f

The wrong design would be:

```bash
sqlite3 -csv -header ride_knox.db "SELECT * FROM trips;" > out/all_trips.csv
```

followed by loading the whole trip table into Python and grouping there. The better design is to make SQL perform the join and aggregation inside the database, then send only the small 24-row summary to Python.

### Q7g

The sqlite3 command line can be automated, redirected, chained, scheduled, and checked by exit status. DB Browser is an interactive GUI and therefore cannot serve as an unattended pipeline stage.

---

## Part 8

### TODO 8a

`pipeline/run_briefing.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
# Run the complete Monday Ride Knox station-pressure briefing.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export PATH="/usr/local/bin:/usr/bin:/bin:/mingw64/bin:${PATH:-}"

YEAR="${1:-}"
if [[ -z "$YEAR" ]]; then
  echo "Usage: $0 YEAR" >&2
  exit 1
fi

if [[ -f "$ROOT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
  set +a
fi

PYTHON_BIN="$ROOT_DIR/.venv/Scripts/python.exe"
if [[ ! -x "$PYTHON_BIN" ]]; then
  PYTHON_BIN="$ROOT_DIR/.venv/bin/python"
fi

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "ERROR: virtual-environment Python not found under .venv" >&2
  exit 1
fi

DB_PATH="${RIDE_KNOX_DB:-$ROOT_DIR/ride_knox.db}"
DATA_DIR="${RIDE_KNOX_DATA:-$ROOT_DIR}"

timestamp() {
  date '+[%Y-%m-%dT%H:%M:%S]'
}

echo "$(timestamp) validation starting"
"$ROOT_DIR/pipeline/check_data.sh" "$YEAR"

echo "$(timestamp) station workbook conversion starting"
"$PYTHON_BIN" "$ROOT_DIR/pipeline/stations_to_csv.py" \
  "$DATA_DIR/stations.xlsx" "$ROOT_DIR/out/stations.csv"

echo "$(timestamp) station departure files starting"
"$ROOT_DIR/pipeline/station_files.sh" "$YEAR"

echo "$(timestamp) sqlite station-pressure query starting"
sqlite3 "$DB_PATH" < "$ROOT_DIR/pipeline/station_pressure.sql"

echo "$(timestamp) Python summary starting"
"$PYTHON_BIN" "$ROOT_DIR/pipeline/summarize.py" \
  "$ROOT_DIR/out/station_pressure.csv"

echo "$(timestamp) writing latest summary"
"$PYTHON_BIN" "$ROOT_DIR/pipeline/summarize.py" \
  "$ROOT_DIR/out/station_pressure.csv" > "$ROOT_DIR/pipeline/latest_summary.txt"

git -C "$ROOT_DIR" add pipeline/latest_summary.txt
if git -C "$ROOT_DIR" diff --cached --quiet; then
  echo "$(timestamp) latest summary unchanged; no commit needed"
else
  git -C "$ROOT_DIR" commit -m "Update latest station pressure summary"
  echo "$(timestamp) latest summary committed"
fi

echo "$(timestamp) briefing complete"
```

### TODO 8b

Command:

```bash
$ ./pipeline/run_briefing.sh 2025 2>&1 | tee logs/briefing.log
```

The run should contain the following stage/result sequence; **replace the timestamps with the ones from your confirmation run**:

```text
[TIMESTAMP] validation starting
rows=250600 distinct=250000 duplicates=600
with_end_station=246826 without_end_station=3774
example_output_path=/c/Users/RAY KYEI/Documents/ride-knox-analysis/out/Market_Square_2025.txt
Validation succeeded for /c/Users/RAY KYEI/Documents/ride-knox-analysis/trips_2025.csv
summary: rows=250600 distinct=250000 missing_end=3774
[TIMESTAMP] station workbook conversion starting
stations_written=24
output=/c/Users/RAY KYEI/Documents/ride-knox-analysis/out/stations.csv
[TIMESTAMP] station departure files starting
S01 22656
... (output continues for all 24 stations)
[TIMESTAMP] sqlite station-pressure query starting
[TIMESTAMP] Python summary starting
stations_read=24
trips_represented=249737
... (summary lines)
[TIMESTAMP] writing latest summary
[TIMESTAMP] briefing complete
```

### TODO 8c

```bash
$ cp out/station_pressure.csv out/pressure_run1.csv
[no terminal output]

$ ./pipeline/run_briefing.sh 2025
[same analytical results as first run; timestamp lines differ]

$ wc -l out/pressure_run1.csv out/station_pressure.csv
25 out/pressure_run1.csv
25 out/station_pressure.csv
50 total

$ cat out/pressure_run1.csv out/station_pressure.csv | sort -u | wc -l
25
```

The pipeline is idempotent because both runs produce the same 25-line CSV (one header + 24 stations), generated files overwrite their targets, and the summary commit logic treats “no change” as a normal outcome.

### TODO 8d

The relevant lines are:

```bash
"$PYTHON_BIN" "$ROOT_DIR/pipeline/summarize.py"   "$ROOT_DIR/out/station_pressure.csv" > "$ROOT_DIR/pipeline/latest_summary.txt"

git -C "$ROOT_DIR" add pipeline/latest_summary.txt
if git -C "$ROOT_DIR" diff --cached --quiet; then
  echo "$(timestamp) latest summary unchanged; no commit needed"
else
  git -C "$ROOT_DIR" commit -m "Update latest station pressure summary"
  echo "$(timestamp) latest summary committed"
fi
```

On the unchanged rerun, the important output is:

```text
[TIMESTAMP] latest summary unchanged; no commit needed
```

### Q8e

Using plain `>` would save output to a file but remove it from the terminal. `tee` shows the run to the operator while also preserving the same output in `logs/briefing.log`. This matters for Part 9 because an unattended scheduled run has no person watching, so the log becomes the evidence of what happened.

### TODO 8f

```bash
$ git add .gitignore .env.example requirements.txt README.md PIPELINE-LOG.md pipeline/
[no terminal output]

$ git commit -m "Complete Assignment 11 Bash automation pipeline"
[replace with your actual commit output]

$ git push -u origin feature/bash-week11-automation
[replace with your actual push output]
```

**Pull request URL:** **REPLACE WITH THE NEW PR URL CREATED BY GITHUB**

---

## Part 9

### TODO 9a

```cron
# minute hour day-of-month month day-of-week
15 7 * * 1 "/c/Users/RAY KYEI/Documents/ride-knox-analysis/pipeline/run_briefing.sh" 2025 >> "/c/Users/RAY KYEI/Documents/ride-knox-analysis/logs/cron.log" 2>&1
```

The five fields mean: minute `15`, hour `7`, every day of month `*`, every month `*`, and weekday `1` = Monday.

### TODO 9b

Cron-proof working directory:

```bash
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
```

Cron-proof Python:

```bash
PYTHON_BIN="$ROOT_DIR/.venv/Scripts/python.exe"
```

with `.venv/bin/python` as the Unix fallback.

### TODO 9c

```bash
$ env -i HOME="$HOME" PATH="/usr/local/bin:/usr/bin:/bin:/mingw64/bin" ./pipeline/run_briefing.sh 2025
```

Expected analytical result: the same 250,600/250,000/600/3,774 validation, 24-station conversion, 250,337 raw-file station departures, and 249,737 database departures. The exact timestamps come from your confirmation run.

### Q9d

Cron does not provide an activated virtual environment, the full interactive PATH, or the working directory I happened to use interactively. The script compensates by calling Python directly from `.venv`, exporting an explicit baseline PATH, and computing `ROOT_DIR` from the script location before `cd "$ROOT_DIR"`.

---

## Part 10 — Optional Challenge (+5)

### C1

`pipeline/stations_to_csv.py`:

```python
#!/usr/bin/env python3
"""Convert stations.xlsx to a CSV that Bash can iterate over."""

from __future__ import annotations

import sys
from pathlib import Path

import pandas as pd


def main() -> int:
    if len(sys.argv) != 3:
        print(
            f"Usage: {Path(sys.argv[0]).name} STATIONS_XLSX OUTPUT_CSV",
            file=sys.stderr,
        )
        return 2

    source = Path(sys.argv[1])
    target = Path(sys.argv[2])

    if not source.is_file():
        print(f"ERROR: workbook does not exist: {source}", file=sys.stderr)
        return 1

    df = pd.read_excel(source)

    if "station_id" not in df.columns:
        print("ERROR: station_id column is missing", file=sys.stderr)
        return 1

    target.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(target, index=False)

    print(f"stations_written={len(df)}")
    print(f"output={target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

Final `pipeline/station_files.sh`:

```bash
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
```

Conversion:

```bash
$ .venv/Scripts/python.exe pipeline/stations_to_csv.py stations.xlsx out/stations.csv
stations_written=24
output=out/stations.csv
```

All-station loop output, sorted here for readability:

```text
S06 26112
S08 25044
S01 22656
S11 18983
S02 16570
S05 15435
S04 14302
S07 14177
S09 13032
S03 10633
S12 9492
S14 8324
S10 7268
S17 7134
S22 6662
S13 6069
S19 5280
S18 4691
S16 4258
S15 3782
S20 3548
S21 2843
S23 2103
S24 1939
```

The total is:

```text
total_departures=250337
```

Reconciliation:

```text
250600 raw trip rows
-   263 rows whose start_station_id is S99
=250337 departures from the 24 real stations
```

### C2

The workbook-to-CSV conversion must run immediately before the station loop so the loop cannot silently use a stale or missing `out/stations.csv`. In `run_briefing.sh` the required dependency is:

```bash
"$PYTHON_BIN" "$ROOT_DIR/pipeline/stations_to_csv.py"   "$DATA_DIR/stations.xlsx" "$ROOT_DIR/out/stations.csv"

"$ROOT_DIR/pipeline/station_files.sh" "$YEAR"
```

Because the script uses `set -euo pipefail`, a failed conversion stops the script before the loop. An explicit `&&` form would also satisfy the dependency:

```bash
"$PYTHON_BIN" "$ROOT_DIR/pipeline/stations_to_csv.py" "$DATA_DIR/stations.xlsx" "$ROOT_DIR/out/stations.csv" && "$ROOT_DIR/pipeline/station_files.sh" "$YEAR"
```

---

## Reflection

### R1

The `$(ls)` loop is the mistake I would have been least likely to catch because its output can look plausible even while one filename is being split into several fake items. My testing habit will be to create at least one filename containing spaces and compare the item count with a direct wildcard loop such as `for F in out/*`.

### R2

The hardest failure for the ops lead to notice would be a scheduled job that never ran, because there might be no incorrect report to attract attention—only silence. I would add an external heartbeat or failure notification that alerts when the expected Monday run or log entry does not appear.

### R3 — AI Disclosure

I used ChatGPT to help interpret the Assignment 11 requirements, design and review the Bash, SQL, and Python pipeline stages, explain failure handling and idempotency, calculate and verify outputs against the Ride Knox course files, and check that the optional Part 10 and rubric requirements were covered. I ran the final commands locally, compared the results with the expected anchors, and reviewed the final scripts, outputs, and conclusions before submission.
