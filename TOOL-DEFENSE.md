# Tool-Selection Defense

The system uses Bash, Python, SQL, R/Quarto, Git, and GitHub Pages as a chain rather than as interchangeable tools. The main design rule is that each stage owns one kind of decision, then hands a concrete artifact to the next stage. That makes failures visible and gives a successor a place to look when something breaks.

## Bash: intake, policy, and orchestration

Bash owns the boundary before structured analysis begins. The intake gate has to inspect filenames, headers, row counts, field counts, and duplicate pressure before a parser is allowed to treat a delivery as trustworthy. It also needs to move files between `incoming/`, `accepted/`, and `quarantine/`, narrate stage boundaries, and stop downstream work if a command fails. Those are operating-system jobs, so Bash is the shortest and clearest tool for them. `build_all.sh` uses `set -euo pipefail`, timestamps each stage, checks prerequisites, and chains the build so failure is honest rather than hidden.

The deliberate "worse tool" choice is the August repair in `prepare_accepted.sh`. Python would be more expressive for general text cleaning, and a CSV-aware parser would be easier to extend if the defect pattern became complicated. I still use targeted `sed` and `awk` here because the defect is structural: an unquoted comma changes the field count before a normal table parser has a reliable record. Repairing that one known pattern at the intake boundary keeps the raw file untouched, makes the change count visible, and lets the following `awk NF==8` check name the severed October row instead of allowing it to disappear. The cost is that the shell repair is intentionally narrow; a new malformed pattern would require a new rule.

## Python: the warehouse writer

Python owns loading because it has to bridge tabular files, Excel station metadata, weather data, and SQLite while enforcing row-level closure. Pandas handles the file formats already used in the course, while Python's SQLite interface allows the loader to turn foreign-key and primary-key rules into explicit counts. The loader counts duplicate copies, already-loaded overlaps, unknown stations, and structural exclusions before completing each file. If the arithmetic does not close, it exits instead of producing a plausible-looking partial result. Keeping one writer also prevents competing load rules from developing in separate scripts.

## SQL: definitions and reporting extracts

SQL owns the shared data definitions after loading. The constrained tables, `trips_reportable` view, and `docks_by_year` view belong close to the data because every downstream use should inherit the same rules. A reportable trip is therefore defined once, not rewritten independently in Python and R. The year-correct dock denominator is also derived from `dock_history` instead of typed into a report. SQL writes the five reporting extracts in `out/`; those files are the contract handed to R.

That handoff has a real cost. CSV extracts duplicate a small amount of information already present in the warehouse, add file-management work, and can become stale if someone bypasses the build. I accept that friction because it makes the dependency visible and testable. `build_all.sh` deletes `out/` before rebuilding it, and the report has no fallback path to raw files or the warehouse. If `out/` is deleted, the report fails as it should. The cost is contained by treating the extracts as disposable build products rather than long-lived source files.

## R and Quarto: analysis, figures, and the report

R owns the Integration Question because the course's taught statistical shapes and figure standards already live there. The final comparison uses `lm()` with a 2026 indicator plus temperature, precipitation, month, and weekday controls. Quarto keeps the calculations, figure generation, interpretation, and inline headline values together, so changing an upstream extract forces the public numbers to change at the same time. The annual report reads only SQL's extracts, saves the required figures with `ggsave()`, and writes the public-page verdict from the same calculated values.

## Git and GitHub Pages: handover and publication

Git carries the source history, branch review, and reasons for changes. GitHub Pages gives the public audience a stable place to read the result without opening code. The awkward exception is the committed `annual_report.html` and its release figures. Normally generated output should stay out of version control, but Pages must serve a file that exists in the published branch. Committing the release artifact adds noisy diffs and creates a risk that source and output could diverge. I contain that cost by committing only the public report and two release figures, rebuilding them through `build_all.sh`, and keeping the warehouse, raw files, working folders, receipts, and other generated products ignored.

## What a sixth tool would change

With a sixth tool, I would add a dependency-aware build or continuous-integration service such as Make or GitHub Actions. The current Bash orchestrator is readable, but it does not independently prove on every push that a fresh environment can rebuild the system. A CI runner could clone the project, inject test data, run the clean-clone and broken-handoff checks, and block publication when either fails. That would reduce the risk that a local machine has an undeclared dependency. I did not add it here because it is outside the course tool set; the final system instead makes the same checks explicit in the one-command build and README.
