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


## Part 4

### TODO 4a — Restore an unstaged mistake

I deleted a paragraph from `report.md` and checked the status:

```text
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   report.md

no changes added to commit (use "git add" and/or "git commit -a")
```

I restored the last committed version with:

```text
git restore report.md
```

After restoring the file:

```text
On branch main
nothing to commit, working tree clean
```

### TODO 4b — Unstage one file

I temporarily edited both `WORKLOG.md` and `analysis.ipynb`, then staged both files.

I unstaged only `analysis.ipynb` with:

```text
git restore --staged analysis.ipynb
```

The resulting status showed one staged file and one unstaged file:

```text
On branch main
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   WORKLOG.md

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   analysis.ipynb
```

I committed only `WORKLOG.md` and then restored the temporary change in `analysis.ipynb`.

### TODO 4c — Revert a committed mistake

I deliberately added a false statement to `report.md` and committed it with the required message:

```text
Add exaggerated claim (on purpose, for Part 4)
```

I then safely reversed that commit using `git revert`.

The log showed both the bad commit and the new revert commit:

```text
ea4c34b (HEAD -> main) Revert "Add exaggerated claim (on purpose, for Part 4)"
f8c04bd Add exaggerated claim (on purpose, for Part 4)
2313124 Record Part 4 staged recovery
0bd00ba Complete Part 3 worklog
f9c21e8 Reword minimum trip duration cutoff
```

**Q4:** Git keeps both commits because `git revert` does not erase history. It creates a new commit that reverses the earlier change, which preserves a clear audit trail showing what happened and how it was corrected.


## Part 5

### TODO 5a — Create the branch

Created and switched to the new branch with:

```text
git switch -c min-cutoff-2min
```

The branch list showed:

```text
  main
* min-cutoff-2min
```

### TODO 5b — Change the minimum cutoff

On the `min-cutoff-2min` branch, I changed the minimum valid trip duration in `analysis.ipynb` from 1 minute to 2 minutes and updated the matching sentence in `report.md`.

Both files were committed together with the message:

```text
Raise minimum trip cutoff to 2 minutes
```

**Q5a:** The notebook and report belong in one commit because they represent the same logical change. The notebook changes the actual cleaning rule, while the report documents that same rule.

### TODO 5c — Return to main and merge

I switched back to `main`. Before the merge, the main branch still represented the original one-minute cutoff.

I then merged the feature branch:

```text
Updating 1584042..bc2dd51
Fast-forward
 analysis.ipynb | 596 +++++++++++++++++++++++++++++----------------------------
 report.md      |   2 +-
 2 files changed, 303 insertions(+), 295 deletions(-)
```

**Q5b:** The merge was a fast-forward because `main` had not received any new commits after the `min-cutoff-2min` branch was created. Git could therefore move the `main` pointer directly to the branch's latest commit without creating a separate merge commit.

### TODO 5d — Delete the merged branch

Deleted the merged branch with:

```text
git branch -d min-cutoff-2min
```

Git confirmed:

```text
Deleted branch min-cutoff-2min (was bc2dd51).
```

The final branch list showed:

```text
* main
```

## Part 6

### TODO 6a — Create a conflicting branch change

Created and switched to the branch:

```text
reword-limitations
```

On that branch, I changed the 24-hour limitation sentence in `report.md` to:

```text
Trips exceeding 24 hours were excluded because they were considered likely cases of improper docking.
```

I committed the change with:

```text
Reword 24-hour limitation
```

### TODO 6b — Make a different change on main

I switched back to `main` and changed the same sentence differently:

```text
Trips lasting more than 24 hours were excluded because they were viewed as likely docking errors.
```

I committed that change with:

```text
Reword 24-hour limit on main
```

### TODO 6c — Merge and create a conflict

When I merged `reword-limitations` into `main`, Git reported:

```text
Auto-merging report.md
CONFLICT (content): Merge conflict in report.md
Automatic merge failed; fix conflicts and then commit the result.
```

The conflict section in `report.md` showed:

```text
<<<<<<< HEAD
Trips lasting more than 24 hours were excluded because they were viewed as likely docking errors.
=======
Trips exceeding 24 hours were excluded because they were considered likely cases of improper docking.
>>>>>>> reword-limitations
```

**Q6a:** The wording under `HEAD` came from `main` because `HEAD` pointed to the branch I was currently on when I ran the merge.

### TODO 6d — Resolve the conflict

I resolved the conflict by keeping the `main` wording:

```text
Trips lasting more than 24 hours were excluded because they were viewed as likely docking errors.
```

I removed the conflict markers, staged the resolved file, and committed with:

```text
Resolve 24-hour limitation conflict using main wording
```

The log showed:

```text
da128de (HEAD -> main) Resolve 24-hour limitation conflict using main wording
7f47f02 Reword 24-hour limit on main
70dfd64 Reword 24-hour limitation
614af31 Complete Part 5 worklog
bc2dd51 Raise minimum trip cutoff to 2 minutes
1584042 Complete Part 4 worklog
```

I then deleted the merged branch:

```text
git branch -d reword-limitations
```

Git confirmed:

```text
Deleted branch reword-limitations (was 70dfd64).
```

The final branch list showed:

```text
* main
```

Final status:

```text
On branch main
nothing to commit, working tree clean
```

**Q6b:** A merge conflict is not Git failing; it is Git asking the user to decide which competing change should be kept.


## Part 7

### TODO 7a — Create and connect GitHub repository

Created an empty GitHub repository named:

```text
ride-knox-analysis
```

Connected the local repository with:

```text
git remote add origin https://github.com/RaymondKojoKyei/ride-knox-analysis.git
```

### TODO 7b — Push to GitHub

Pushed the `main` branch with:

```text
git push -u origin main
```

The terminal confirmed:

```text
To https://github.com/RaymondKojoKyei/ride-knox-analysis.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

I verified on GitHub that `analysis.ipynb`, `report.md`, `WORKLOG.md`, `.gitignore`, the `charts/` folder, and the full commit history were visible.

I also confirmed that the ignored files and folder were absent:

```text
trips_2025.csv
stations.xlsx
scratch/
```

**Q7:** `origin` is the local nickname for the remote GitHub repository. The `-u` option sets `origin/main` as the upstream branch, so future `git push` and `git pull` commands can be run without specifying the remote and branch each time.


Recovery clone verified successfully in a separate location.


## Part 8

### TODO 8a — Clone a recovery copy

I cloned the GitHub repository into a separate folder named `ride-knox-recovery`:

```text
git clone https://github.com/RaymondKojoKyei/ride-knox-analysis.git ride-knox-recovery
```

The recovery copy was located at:

```text
C:\Users\RAY KYEI\Documents\ride-knox-recovery
```

### TODO 8b — Verify repository history

In the recovery clone, I ran:

```text
git log --oneline --all --graph
```

The history showed the previous commits, including the merge conflict resolution and the revert:

```text
* 54cc7bb (HEAD -> main, origin/main, origin/HEAD) Complete Part 7 worklog
* 0c0395e Complete Part 6 worklog
*   da128de Resolve 24-hour limitation conflict using main wording
|\
| * 70dfd64 Reword 24-hour limitation
* | 7f47f02 Reword 24-hour limit on main
|/
* 614af31 Complete Part 5 worklog
* bc2dd51 Raise minimum trip cutoff to 2 minutes
* 1584042 Complete Part 4 worklog
* ea4c34b Revert "Add exaggerated claim (on purpose, for Part 4)"
* f8c04bd Add exaggerated claim (on purpose, for Part 4)
```

### TODO 8c — Make and push a change from the recovery clone

I added the following line to `WORKLOG.md` in the recovery clone:

```text
Recovery clone verified successfully in a separate location.
```

I committed it with:

```text
Record recovery clone verification
```

and pushed it to GitHub.

Git confirmed:

```text
54cc7bb..87d7ac5  main -> main
```

### TODO 8d — Pull the recovery change into the original repository

I returned to the original `ride-knox-analysis` repository and ran:

```text
git pull
```

The terminal showed:

```text
Updating 54cc7bb..87d7ac5
Fast-forward
 WORKLOG.md | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
```

I verified that the recovery-clone line appeared in the original `WORKLOG.md`.

The final status showed:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

**Q8:** This recovery workflow protects against losing the local project folder or computer because the repository and its history can be recreated from GitHub. A good habit is to commit meaningful work regularly and push those commits to the remote repository.



## Reflection

**R1:** The Part 4 committed-oops exercise changed how I feel about Git the most. Seeing that I could safely undo a bad commit with `git revert` while preserving the history made Git feel less intimidating because mistakes can be corrected without hiding what happened.

**R2 — AI Disclosure:** I used ChatGPT to help me understand the assignment instructions, learn the Git commands, troubleshoot errors, and organize my WORKLOG.md. I ran the commands myself, reviewed the outputs, made the required file changes, and verified the Git and GitHub results.


## Part 9

Created a throwaway branch to demonstrate two diverging Git timelines.

### Part 9 — Challenge

I created a temporary branch and made separate commits on `main` and `challenge-graph`.

I then ran:

```text
git log --oneline --all --graph -8
```

The graph showed:

```text
* 1d99545 (HEAD -> main) Start Part 9 graph challenge
| * 533b0b6 (challenge-graph) Add Part 9 branch timeline marker
|/
* 56284d5 (origin/main, origin/HEAD) Add reflection and AI disclosure
* fa37f08 Complete Part 8 worklog
* 87d7ac5 Record recovery clone verification
* 54cc7bb Complete Part 7 worklog
* 0c0395e Complete Part 6 worklog
*   da128de Resolve 24-hour limitation conflict using main wording
|\
```

The `main` timeline contains commit `1d99545`, while the `challenge-graph` timeline contains commit `533b0b6`. The two timelines split after commit `56284d5`.

**Q9:** A future merge at this point would not be able to fast-forward because both `main` and `challenge-graph` contain different commits after their common commit `56284d5`. Git would need to combine the two histories instead of simply moving the `main` pointer forward.
