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