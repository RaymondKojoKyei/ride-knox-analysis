# DATA 501; Assignment 10 Shell Log

**Name:** Raymond Kojo Kyei  
**NetID:** rkyei  
**Terminal used:** Git Bash in VS Code on Windows

> The commands and analytical outputs below were checked against the Ride Knox files used for this assignment. Long terminal outputs are shortened according to the assignment requirement.

## Part 0

### TODO 0a

```bash
$ head -1 trips_2025.csv
trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,rider_type,bike_type
```

```bash
$ wc -l trips_2025.csv
250601 trips_2025.csv
```

### TODO 0b

I created this log on the required branch and committed it early.

```bash
$ git switch main
Switched to branch 'main'
```

```bash
$ git pull
remote: Enumerating objects: 1, done.
remote: Counting objects: 100% (1/1), done.
remote: Total 1 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
Unpacking objects: 100% (1/1), 912 bytes | 182.00 KiB/s, done.
From https://github.com/RaymondKojoKyei/ride-knox-analysis
   9301dcd..fae704a  main       -> origin/main
Updating 9301dcd..fae704a
Fast-forward
 .gitignore                      |    6 +-
 DATA-DICTIONARY.md              |   85 ++
... (22 more lines)
```

```bash
$ git switch -c feature/bash-week10-triage
Switched to a new branch 'feature/bash-week10-triage'
```

```bash
$ git add SHELL-LOG.md
[no terminal output]
```

```bash
$ git commit -m "Start Assignment 10 Bash shell log"
[The original early commit is recorded in Git history as commit 6d5c36f: Start Assignment 10 Bash shell log]
```

### Q0c

`wc -l` reports 250,601 because the CSV contains one header line plus 250,600 data rows. The command from the slides that can drop the header before counting is `tail -n +2`.

---

## Part 1

### TODO 1a

```bash
$ pwd
/c/Users/RAY KYEI/Documents/ride-knox-analysis
```

```bash
$ ls -lh
total 95M
-rw-r--r-- 1 RAY KYEI 197121  196 Sep 29 20:57  _config.yml
drwxr-xr-x 1 RAY KYEI 197121    0 Oct  6 12:06  2025/
drwxr-xr-x 1 RAY KYEI 197121    0 Oct  6 12:06  2026/
-rw-r--r-- 1 RAY KYEI 197121  14K Oct 13 13:03  Assignment8-final-review.zip
drwxr-xr-x 1 RAY KYEI 197121    0 Oct 26 17:04  charts/
-rw-r--r-- 1 RAY KYEI 197121  19K Sep 29 13:31  COLLAB-LOG.md
-rw-r--r-- 1 RAY KYEI 197121 5.6K Oct 26 17:04  DATA-DICTIONARY.md
-rw-r--r-- 1 RAY KYEI 197121 1.2K Sep 29 20:57  index.md
-rw-r--r-- 1 RAY KYEI 197121 136K Oct 17 11:38  M9_assignment.ipynb
... (26 more lines)
```

The `-h` option makes file sizes human-readable, such as KB or MB, instead of showing only raw byte counts.

### TODO 1b

```bash
$ mkdir -p out
[no terminal output]
```

### TODO 1c

```bash
$ echo "out/" >> .gitignore
[no terminal output]
```

```bash
$ ls -a
./           _config.yml                    COLLAB-LOG.md         out/             RELEASE-NOTE.md           ride-knox-analysis/  'SQL module project'/   trips_2026_07.csv
../          2025/                          DATA-DICTIONARY.md    project.ipynb    requirements.txt          scratch/              SQL-LOG.md             trips_2026_h1.csv
.git/        2026/                          index.md              PROJECT-LOG.md   ride_knox.db              screenshots/          stations.xlsx          venv/
.gitignore   Assignment8-final-review.zip   M9_assignment.ipynb   queries/         ride_knox_api_token.txt   SHELL-LOG.md          stations_2026.xlsx    'week 10 BASH'/
.idea/       charts/                        memo.md               README.md        ride_knox_work.db         sql/                  trips_2025.csv         WORKLOG.md
```

`.gitignore` is visible with `ls -a` because `-a` includes hidden files, while plain `ls` normally does not display names that begin with a dot.

### Q1d

Generated result files should not be committed when they are reproducible outputs rather than source material. This week's `out/` files can be recreated at any time from the raw trip files by rerunning the commands recorded in this shell log, so committing them would unnecessarily duplicate derived data.

---

## Part 2

### TODO 2a

```bash
$ wc -l trips_*.csv
  250601 trips_2025.csv
   33086 trips_2026_07.csv
  137342 trips_2026_h1.csv
  421029 total
```

### TODO 2b

```bash
$ ls -lh trips_2026_*.csv
-rw-r--r-- 1 RAY KYEI 197121 2.9M Oct 17 12:31 trips_2026_07.csv
-rw-r--r-- 1 RAY KYEI 197121  12M Sep 12 20:37 trips_2026_h1.csv
```

The pattern excludes `trips_2025.csv` and matches only `trips_2026_07.csv` and `trips_2026_h1.csv`.

### TODO 2c

```bash
$ ls -lh stations*.xlsx
-rw-r--r-- 1 RAY KYEI 197121 15K Oct  6 11:43 stations.xlsx
-rw-r--r-- 1 RAY KYEI 197121 15K Sep 12 20:37 stations_2026.xlsx
```

### Q2d

The shell expands `*` into the matching filenames before `wc` runs, so `wc` receives the three trip filenames as separate arguments. For the same reason, `rm *.csv` is dangerous: the shell expands the wildcard first, making it effectively equivalent to typing every matching CSV filename after `rm`.

### Q2e

The 2026 H1 file has 137,341 data rows compared with 250,600 in the 2025 file:

\[
137341 / 250600 \times 100 \approx 54.8\%
\]

The files contain 12,535,965 bytes and 22,823,012 bytes respectively:

\[
12535965 / 22823012 \times 100 \approx 54.9\%
\]

So the H1 file has about **54.8% of the rows and 54.9% of the bytes** of the 2025 file. The close relationship suggests the average row lengths are similar in these particular files. A long free-text column could break that relationship because row byte sizes could vary substantially.

---

## Part 3

### TODO 3a

```bash
$ tail -n 3 trips_2025.csv
T0029313,2025-12-31 23:33:25,2025-12-31 23:47:31,S08,Student Union - UT,S09,CASUAL,classic
T0233859,2025-12-31 23:40:52,2025-12-31 23:51:14,S04,Old City - Jackson Ave,S04,member,electric
T0140894,2025-12-31 23:42:04,2026-01-01 00:37:04,S12,Fort Sanders - Laurel Ave,S12,casual,electric
```

Unlike `head`, `tail` shows how the file ends, including the latest records and whether an end time can cross into the next year.

### TODO 3b

Method 1:

```bash
$ head -n 504 trips_2025.csv | tail -n 5
T0193042,2025-01-02 12:56:34,2025-01-02 13:07:49,S06,HODGES LIBRARY,S08,member,classic
T0109309,2025-01-02 12:58:14,2025-01-02 13:08:04,S05,World's Fair Park,S04,casual,classic
T0017188,2025-01-02 12:59:01,2025-01-02 13:17:00,S11,Cumberland Ave & 17th St,S02,member,electric
T0004700,2025-01-02 12:59:54,2025-01-02 13:37:33,S07,The Hill - Ayres Hall,S02,member,electric
T0183710,2025-01-02 12:59:57,2025-01-02 13:14:14,S01,Market Square,S01,casual,classic
```

Method 2:

```bash
$ sed -n '500,504p' trips_2025.csv
T0193042,2025-01-02 12:56:34,2025-01-02 13:07:49,S06,HODGES LIBRARY,S08,member,classic
T0109309,2025-01-02 12:58:14,2025-01-02 13:08:04,S05,World's Fair Park,S04,casual,classic
T0017188,2025-01-02 12:59:01,2025-01-02 13:17:00,S11,Cumberland Ave & 17th St,S02,member,electric
T0004700,2025-01-02 12:59:54,2025-01-02 13:37:33,S07,The Hill - Ayres Hall,S02,member,electric
T0183710,2025-01-02 12:59:57,2025-01-02 13:14:14,S01,Market Square,S01,casual,classic
```

The two outputs match.

### TODO 3c

```bash
$ wc -l stations.xlsx
48 stations.xlsx
```

### Q3d

`wc` counted newline bytes in the workbook file; it did not count spreadsheet rows or stations. An `.xlsx` workbook is not a line-oriented CSV text file, so text commands can return misleading results when used on it. I can confirm the file type before trusting text-command output with:

```bash
$ file stations.xlsx
stations.xlsx: Microsoft Excel 2007+
```

### Q3e

```bash
$ head -1 trips_2026_07.csv
trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,rider_type,bike_type
```

This replaces the basic pandas task of inspecting `df.columns`.

---

## Part 4

### TODO 4a

```bash
$ grep -c "2025-09" trips_2025.csv
23202
```

### TODO 4b

Case-sensitive:

```bash
$ grep -c "member" trips_2025.csv
153388
```

Case-insensitive:

```bash
$ grep -ci "member" trips_2025.csv
158927
```

The difference is **5,539 trips**.

### TODO 4c

```bash
$ tail -n +2 trips_2025.csv | grep -v ',S24,' | wc -l
246852
```

The pattern `,S24,` targets the complete station-id token rather than accidentally matching something such as `S240`.

### TODO 4d

I first inspected the header to determine the field number:

```bash
$ head -1 trips_2025.csv | tr ',' '\n' | nl -ba
     1  trip_id
     2  start_time
     3  end_time
     4  start_station_id
     5  start_station_name
     6  end_station_id
     7  rider_type
     8  bike_type
```

Therefore `bike_type` is field **8**.

```bash
$ head -n 4 trips_2025.csv | cut -d',' -f8
bike_type
electric
classic
classic
```

### Q4e

The case-insensitive result, **158,927**, is the correct answer to "how many member trips are there?" because the raw data contain capitalization variants. The case-sensitive command runs successfully but misses those variants, illustrating the module's rule that a pipeline can return a clean-looking number and still answer the wrong question.

### Q4f

Yes. The case-insensitive count of **158,927** agrees with the assignment anchor. If a classmate's result did not agree, the first mistake I would check is whether they forgot the `-i` option and therefore counted only the lowercase spelling.

---

## Part 5

### TODO 5a

```bash
$ grep "2025-09" trips_2025.csv > out/trips_2025_09.csv
[no terminal output]
```

```bash
$ grep "2025-10" trips_2025.csv > out/trips_2025_10.csv
[no terminal output]
```

```bash
$ grep "2025-11" trips_2025.csv > out/trips_2025_11.csv
[no terminal output]
```

### TODO 5b

```bash
$ wc -l out/trips_2025_*.csv
  23202 out/trips_2025_09.csv
  19795 out/trips_2025_10.csv
  13750 out/trips_2025_11.csv
  56747 total
```

### TODO 5c

```bash
$ wc -l out/trips_2025_09.csv > out/summary.txt
[no terminal output]
```

```bash
$ wc -l out/trips_2025_10.csv >> out/summary.txt
[no terminal output]
```

```bash
$ wc -l out/trips_2025_11.csv >> out/summary.txt
[no terminal output]
```

```bash
$ cat out/summary.txt
23202 out/trips_2025_09.csv
19795 out/trips_2025_10.csv
13750 out/trips_2025_11.csv
```

### TODO 5d

```bash
$ grep "member" file_that_does_not_exist.csv 2> out/errors.log
[no standard output; the error is redirected]
```

```bash
$ cat out/errors.log
grep: file_that_does_not_exist.csv: No such file or directory
```

### Q5e

If I had used `>` for all three commands, each new command would have overwritten the previous contents of `summary.txt`. Only the November count would have survived. The one-character difference between `>` and `>>` therefore determines whether previous results are destroyed or preserved.

### Q5f

Errors use a separate stream so they can be redirected independently from normal results. Otherwise, an error message could be mixed into a results file and be mistaken for part of the data output.

---

## Part 6

### TODO 6a

```bash
$ tail -n +2 trips_2025.csv | cut -d',' -f8 | sort | uniq -c | sort -rn
 155300 classic
  95300 electric
```

Check:

\[
155300 + 95300 = 250600
\]

so the counts reconcile exactly with the total number of data rows.

### TODO 6b

Numeric reverse sort:

```bash
$ tail -n +2 trips_2025.csv | cut -d',' -f4 | sort | uniq -c | sort -rn | head -n 5
  26112 S06
  25044 S08
  22656 S01
  18983 S11
  16570 S02
```

Text reverse sort:

```bash
$ tail -n +2 trips_2025.csv | cut -d',' -f4 | sort | uniq -c | sort -r | head -n 5
  26112 S06
  25044 S08
  22656 S01
  18983 S11
  16570 S02
```

### Q6c

The orderings agree here because `uniq -c` prints the counts in a padded, right-aligned field, and the leading counts in this ranking have comparable aligned widths. They stop behaving safely like numeric values when the counts are printed without that padding and different digit lengths are compared as text; Part 8 demonstrates exactly that case.

### TODO 6d

```bash
$ tail -n +2 trips_2025.csv | cut -d',' -f1 | sort | uniq -d | wc -l
600
```

### TODO 6e

```bash
$ tail -n +2 trips_2025.csv | cut -d',' -f1 | sort | uniq -d | head -n 1
T0000118
```

```bash
$ grep '^T0000118,' trips_2025.csv
T0000118,2025-04-23 15:56:40,2025-04-23 16:15:49,S16,Ijams Nature Center,S14,member,electric
T0000118,2025-04-23 15:56:40,2025-04-23 16:15:49,S16,Ijams Nature Center,S14,member,electric
```

The two rows are identical in every column.

### Q6f

The file carries **exact duplicate rows**. `sort -u` can collapse exact duplicate lines. The anchor arithmetic is:

\[
250600 - 600 = 250000
\]

which matches the assignment's 250,000 unique-row anchor.

---

## Part 7

### TODO 7a

```bash
$ tail -n +2 trips_2025.csv | cut -d',' -f5 | grep -i 'market square' | sort | uniq -c | sort -rn
  20781 Market Square
    644   Market Square
    461 MARKET SQUARE
    429 Market Square  
    341 market square
```

There are **5 distinct raw spellings/whitespace forms** of Market Square.

### TODO 7b

```bash
$ tail -n +2 trips_2025.csv | cut -d',' -f5 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -n 5
  26112 hodges library
  25044 student union - utk
  22656 market square
  18983 cumberland ave & 17th st
  16570 gay street & union ave
```

### Q7c

The normalized Market Square count is 22,656, while its largest single raw spelling has 20,781 trips:

\[
22656 - 20781 = 1875
\]

A naïve ranking would therefore fail to credit **1,875 trips** to Market Square.

### Q7d

| Rank | Part 6 station ID | Count | Part 7 normalized name | Count |
|---|---|---:|---|---:|
| 1 | S06 | 26,112 | hodges library | 26,112 |
| 2 | S08 | 25,044 | student union - utk | 25,044 |
| 3 | S01 | 22,656 | market square | 22,656 |
| 4 | S11 | 18,983 | cumberland ave & 17th st | 18,983 |
| 5 | S02 | 16,570 | gay street & union ave | 16,570 |

The counts and order match. If they had not matched, it would indicate that the Part 7 name-normalization pipeline had split or merged station observations incorrectly.

---

## Part 8

### TODO 8a

Whole-line grep:

```bash
$ grep -c "S11" trips_2025.csv
35415
```

Field-specific `awk`:

```bash
$ awk -F',' 'NR>1 && $4=="S11" {count++} END {print count}' trips_2025.csv
18983
```

### Q8b

`grep` searches the entire line, so its extra matches include trips where `S11` appears as the **end_station_id**, not only as the start station. The general rule is that `grep` matches text anywhere on a line, while `awk` can restrict a condition to a specific column.

### TODO 8c

```bash
$ awk -F',' 'NR>1 && $6=="" && tolower($7)=="member" {count++} END {print count}' trips_2025.csv
2371
```

### Q8d

\[
2371 / 3774 \times 100 \approx 62.8\%
\]

So about **62.8%** of trips with no end station were member trips. This suggests members make up the majority of the missing-end-station population, but it does not tell us why the end station is missing or establish that membership caused the missing value.

### TODO 8e

```bash
$ awk -F',' 'NR>1 && tolower($8)=="electric" {month=substr($2,1,7); count[month]++} END {for (month in count) print month, count[month]}' trips_2025.csv | sort
2025-01 4186
2025-02 5090
2025-03 7526
2025-04 9749
2025-05 11331
2025-06 12067
2025-07 10447
2025-08 9348
2025-09 8837
2025-10 7571
2025-11 5287
2025-12 3861
```

### TODO 8f

Text sort:

```bash
$ awk -F',' 'NR>1 && tolower($8)=="electric" {month=substr($2,1,7); count[month]++} END {for (month in count) print month, count[month]}' trips_2025.csv | sort -k2 -r | head -n 4
2025-04 9749
2025-08 9348
2025-09 8837
2025-10 7571
```

Numeric sort:

```bash
$ awk -F',' 'NR>1 && tolower($8)=="electric" {month=substr($2,1,7); count[month]++} END {for (month in count) print month, count[month]}' trips_2025.csv | sort -k2 -rn | head -n 4
2025-06 12067
2025-05 11331
2025-07 10447
2025-04 9749
```

### Q8g

The text sort incorrectly identifies **April 2025** as the busiest month, while the numeric sort correctly identifies **June 2025** with 12,067 electric trips. Unlike `uniq -c` in Part 6, the `awk` output contains unpadded counts with different digit lengths, so text sorting compares character strings rather than numerical magnitude. A colleague reading only the wrong version would incorrectly conclude that April had the highest electric-bike activity.

---

## Part 9

### TODO 9a

```bash
$ awk -F',' '{month=substr($2,1,7); key=month " " $8; count[key]++} END {for (key in count) print key, count[key]}' out/trips_2025_*.csv | sort
2025-08 classic 6
2025-08 electric 4
2025-09 classic 14361
2025-09 electric 8842
2025-10 classic 12215
2025-10 electric 7576
2025-11 classic 8456
2025-11 electric 5287
```

### Q9b

I got **8 groups**, not the expected 6. The unexpected groups are:

- `2025-08 classic 6`
- `2025-08 electric 4`

They entered the September output file because Part 5 used whole-line `grep "2025-09"`. A trip that **started in August but ended in September** contains `2025-09` in its `end_time`, so the whole-line grep selected it even though its start month was August.

### Q9c

The Part 9 counts sum to:

\[
6 + 4 + 14361 + 8842 + 12215 + 7576 + 8456 + 5287 = 56747
\]

This matches the Part 5b total:

```text
56747 total
```

To count only trips that genuinely **started** in each target month, the pipeline must apply the month condition specifically to the `start_time` field rather than anywhere on the row. The commands taught in this module can do this because `awk` can test a specific field.

### TODO 9d

Final commit and push commands:

```bash
$ git add SHELL-LOG.md .gitignore
[no terminal output]
```

```bash
$ git status
On branch feature/bash-week10-triage
Your branch is ahead of 'origin/feature/bash-week10-triage' by 2 commits.
  (use "git push" to publish your local commits)

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   SHELL-LOG.md

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        Assignment8-final-review.zip
        M9_assignment.ipynb
        SQL module project/
        ride-knox-analysis/
        week 10 BASH/
```

```bash
$ git commit -m "Complete Assignment 10 shell log"
[feature/bash-week10-triage 8cf1afa] Complete Assignment 10 shell log
 1 file changed, 29 insertions(+)
```

```bash
$ git push -u origin feature/bash-week10-triage
Enumerating objects: 11, done.
Counting objects: 100% (11/11), done.
Delta compression using up to 8 threads
Compressing objects: 100% (8/8), done.
Writing objects: 100% (9/9), 1024 bytes | 512.00 KiB/s, done.
Total 9 (delta 4), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (4/4), completed with 2 local objects.
To https://github.com/RaymondKojoKyei/ride-knox-analysis.git
   fae704a..8cf1afa  feature/bash-week10-triage -> feature/bash-week10-triage
branch 'feature/bash-week10-triage' set up to track 'origin/feature/bash-week10-triage'.
```

I made additional updates to `SHELL-LOG.md` on the feature branch before the pull request was merged. The final feature branch was later recorded at commit `84c72f5` when I deleted the merged local branch.

**Pull request URL:** https://github.com/RaymondKojoKyei/ride-knox-analysis/pull/43

For reviewer verification, the key field-specific command is:

```bash
awk -F',' 'NR>1 && $6=="" && tolower($7)=="member" {count++} END {print count}' trips_2025.csv
```

This command combines the missing-end-station condition with the member condition, uses the correct fields, and handles capitalization with `tolower()`.


### Final merge verification

After PR #43 was merged, I updated local `main` and verified the final repository state.

```bash
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
```

```bash
$ git pull
remote: Enumerating objects: 1, done.
remote: Counting objects: 100% (1/1), done.
remote: Total 1 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
Unpacking objects: 100% (1/1), 931 bytes | 77.00 KiB/s, done.
From https://github.com/RaymondKojoKyei/ride-knox-analysis
   fae704a..8c4abc2  main       -> origin/main
Updating fae704a..8c4abc2
Fast-forward
 .gitignore   |   2 +
 SHELL-LOG.md | 768 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 770 insertions(+)
 create mode 100644 SHELL-LOG.md
```

```bash
$ git branch -d feature/bash-week10-triage
Deleted branch feature/bash-week10-triage (was 84c72f5).
```

The unrelated local files were added to `.git/info/exclude` so they would remain on my computer without being committed to the repository.

```bash
$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

```bash
$ git push
Everything up-to-date
```

---

## Part 10 — Optional Challenge

Not attempted. Part 10 is optional extra credit; Parts 0–9 and the required reflection are complete.

---

## Reflection

### R1

The error I would have been least likely to catch on my own is the field-blind `grep` in Part 8a because the command runs normally and returns a plausible count. My checking habit will be to compare whole-line text searches against a field-specific `awk` count whenever the question refers to one particular CSV column.

### R2

Counting month-by-category combinations in Part 9 would be faster and clearer for me in pandas or SQL because both tools provide explicit column selection and grouping. The shell becomes less convenient when several field-specific conditions and grouped calculations must be combined.

### R3 — AI Disclosure

I used ChatGPT to help interpret the Assignment 10 instructions, check the structure of Bash pipelines, and explain why some commands can run successfully while answering the wrong question. I ran the Bash commands against the course files, checked the results against the assignment anchors, and reviewed the final commands, outputs, and conclusions before submission.
