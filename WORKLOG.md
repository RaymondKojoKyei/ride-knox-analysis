# DATA 501; Assignment 5 Worklog

**Name:** Raymond Kojo Kyei  
**NetID:** rkyei

## Part 0

```text
git version 2.55.0.windows.5
Raymond Kojo Kyei
raymondkojokyei@gmail.com
```

**Q0:** Git needs my name and email because each commit is stamped with the identity of the person who created it.


## Part 1

### TODO 1a — Project structure

Created the project folder with `analysis.ipynb`, `report.md`, `WORKLOG.md`, and a `charts/` folder containing two PNG files:

- `nonmember_recovery.png`
- `station_pressure_yoy.png`

### TODO 1b — Before status

```text
On branch main

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        WORKLOG.md
        analysis.ipynb
        charts/
        report.md

nothing added to commit but untracked files present (use "git add" to track)
```

### TODO 1c — First commit

Committed only `report.md` with the message:

```text
Add Ride Knox analysis report
```

### TODO 1d — Second commit

Committed `analysis.ipynb` and the two files in the `charts/` folder together with the message:

```text
Add analysis notebook and charts
```

### TODO 1e — After status

Added `WORKLOG.md` in the third commit. After the commit, `git status` showed:

```text
On branch main
nothing to commit, working tree clean
```

**Q1:** Splitting the files into separate commits would help if I later needed to undo or inspect only the report change without also affecting the notebook and charts.


## Part 2

### TODO 2a — Before `.gitignore`

Before creating `.gitignore`, `git status` showed the raw data files and scratch folder as untracked:

```text
On branch main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        scratch/
        stations.xlsx
        trips_2025.csv

nothing added to commit but untracked files present (use "git add" to track)
```

### TODO 2b — `.gitignore`

Created `.gitignore` with the following rules:

```text
trips_2025.csv
stations.xlsx
.ipynb_checkpoints/
scratch/
```

After adding the ignore rules, `git status` showed only `.gitignore` as untracked:

```text
On branch main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        .gitignore

nothing added to commit but untracked files present (use "git add" to track)
```

### TODO 2c — Commit `.gitignore`

Committed `.gitignore` with the message:

```text
Add project ignore rules
```

Final status:

```text
On branch main
nothing to commit, working tree clean
```

**Q2:** The charts are committed because they are small project outputs that help document and reproduce the analysis. The raw CSV and Excel files are ignored because they are source data files that can be large, may change independently, and do not need to be stored in the Git repository.


## Part 3

### TODO 3a — Reword minimum-duration sentence

Reworded the one-minute cutoff sentence in `report.md` without changing its meaning.

Before committing, I ran:

```text
git diff report.md
```

The diff showed:

```diff
-Trips with durations shorter than 1 minute were excluded because they were treated as likely dock fumbles rather than meaningful rides.
+Trips lasting less than 1 minute were excluded because they were considered likely dock fumbles rather than meaningful rides.
```

This confirmed that one line was removed and replaced with the revised wording.

### TODO 3b — Commit the change

Committed the report change with the message:

```text
Reword minimum trip duration cutoff
```

Then `git log --oneline` showed:

```text
f9c21e8 (HEAD -> main) Reword minimum trip duration cutoff
fe55ad5 Complete Part 2 worklog
7af5bd3 Add project ignore rules
04c0d6f Complete Part 1 worklog
b5d14b4 Add assignment worklog
0cc2ba8 Add analysis notebook and charts
f53dff0 Add Ride Knox analysis report
```

**Q3:** After the change has been committed, `git diff report.md` would show no output because there would be no uncommitted differences between the working copy and the latest commit.


### Testing staged recovery for Part 4B