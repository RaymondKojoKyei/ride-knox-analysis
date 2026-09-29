# DATA 501 — Git Module Project Log

**Name:** Raymond Kojo Kyei  
**NetID:** rkyei

**Log commit policy:** I will allow `PROJECT-LOG.md` updates to be committed directly to `main`, as permitted by House Rule 1. All other project changes will reach `main` through issue-linked pull requests.

## Part 0 — Starting State

### git status

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean

git log --oneline

32abac5 Merge pull request #18 from RaymondKojoKyei/docs/final-collab-fix
f10aa33 Complete collaboration log and add required screenshots
d52ee92 Merge pull request #17 from RaymondKojoKyei/docs/final-reflection
453b511 Add final reflection and AI disclosure
58f1701 Merge pull request #16 from RaymondKojoKyei/docs/part8-log
245a327 Document Part 8 reproducibility bonus
3f3716a Merge pull request #15 from RaymondKojoKyei/chore/add-requirements
239585f Add requirements file for reproducibility
3a9485c Merge pull request #13 from RaymondKojoKyei/docs/part7-log
2cd8665 Document Part 7 portfolio polish
563fa00 Merge pull request #12 from RaymondKojoKyei/docs/readme-polish
4913a26 Highlight key finding in README
94581e2 Merge pull request #11 from RaymondKojoKyei/docs/part6-log
4b19262 Document Part 6 peer review workflow
0100b60 Merge pull request #10 from RaymondKojoKyei/docs/part5-log
bbf27ab Document Part 5 GitHub Pages workflow

I confirmed that the working tree is clean and that my Assignment 5–6 history is present.

## Part A — Release Plan

I translated the project brief into seven GitHub issues so the work could be completed in a clear dependency order.

### Issue plan

```text
#19 Protect the 2026 hand-off from accidental commits
#20 Reorganize the repository for separate 2025 and 2026 analyses
#21 Integrate the 2026 analysis bundle
#22 Update reproducibility instructions for both years
#23 Co-author the two-year README with Riley
#24 Publish the two-year GitHub Pages site
#25 Write the 2026 release note and audit history

The issues are cross-linked so later work depends on the earlier safety and organization steps.
Q-A1
Issue #19 had to be completed before Issue #21. The ignore rules needed to protect credentials, raw data, and scratch files before the 2026 hand-off was copied into the repository. Otherwise, a sensitive file such as ride_knox_api_token.txt could accidentally be staged or committed and become part of the public repository history.


## Part B — Integrate 2026

### Issue #19 — Protect the 2026 hand-off

I updated `.gitignore` before copying any 2026 hand-off files into the repository.

The added ignore rules were:

```text
trips_2026_h1.csv
stations_2026.xlsx
ride_knox_api_token.txt

The existing rules already protected:
trips_2025.csv
stations.xlsx
.ipynb_checkpoints/
scratch/

I verified the rules with git check-ignore -v. Git confirmed that the new 2026 data files, API credential, and scratch/ directory are ignored.
The change was completed on branch:
19-protect-handoff

and merged through a pull request with:
Closes #19

I also left a self-review line comment on the ride_knox_api_token.txt rule explaining that credentials must never enter repository history.

### Issue #20 — Reorganize the repository for separate yearly analyses

The existing 2025 analysis files were moved into a dedicated `2025/` directory so the repository can clearly support multiple years without confusing the 2025 and 2026 work.

The following files were reorganized:

- `analysis.ipynb` → `2025/analysis.ipynb`
- `report.md` → `2025/report.md`
- `charts/nonmember_recovery.png` → `2025/charts/nonmember_recovery.png`
- `charts/station_pressure_yoy.png` → `2025/charts/station_pressure_yoy.png`

Before moving the files, I searched the README for references to the notebook, report, and chart paths. This identified dependencies that would have broken after the reorganization.

The 2025 notebook also originally read:

`trips_2025.csv`

and

`stations.xlsx`

from its own directory. Because the notebook is now inside `2025/` while the ignored raw data remains in the repository root, I changed the notebook paths to:

`../trips_2025.csv`

and

`../stations.xlsx`

The README image paths and repository structure were also updated to match the new layout.

The work was completed on branch `20-reorganize-years` and merged through an issue-linked pull request using `Closes #20`.

#### Q-B2

One path dependency that would have broken was the station-pressure chart referenced by the README. Before the move, the README used `charts/station_pressure_yoy.png`. After moving the chart into the 2025 directory, that path would no longer exist. I caught the dependency by searching the README before making the move and updated the path to `2025/charts/station_pressure_yoy.png`.

The notebook had a second path dependency: it expected the raw 2025 CSV and Excel files in the same directory as the notebook. Moving the notebook into `2025/` would therefore have caused file-not-found errors. I searched the notebook for the data filenames and changed the relative paths so it continues to read the ignored raw data from the repository root.

### Issue #21 — Integrate the 2026 analysis bundle

The 2026 starter-pack hand-off was reviewed before any files were committed. It contained the 2026 notebook, memo, three charts, a credential file, and a scratch-notes folder.

The following analysis files were added under `2026/`:

- `2026/analysis_2026.ipynb`
- `2026/memo_2026.md`
- `2026/charts/daypass_vs_others.png`
- `2026/charts/recovery_vs_2025.png`
- `2026/charts/station_pressure_change.png`

The hand-off also included `ride_knox_api_token.txt` and `scratch/download_notes.txt`. These were not committed. The credential file and scratch directory are protected by `.gitignore`.

Because the 2026 notebook was moved into the `2026/` directory while the raw data files remain in the repository root, its file-reading paths were changed to:

- `../trips_2025.csv`
- `../stations.xlsx`
- `../trips_2026_h1.csv`
- `../stations_2026.xlsx`

The notebook introduction was also updated so that its instructions match the new repository layout.

Before staging, `git status` showed only the intended `2026/` directory. `git status --ignored` confirmed that the credential, scratch files, and existing 2025 raw data were excluded from Git.

The work was completed on branch `21-integrate-2026` and merged through an issue-linked pull request using `Closes #21`.

#### Q-B1

One non-data hand-off item that must never be committed is `ride_knox_api_token.txt`. It contains an API credential from the app vendor. I protected it with a specific `.gitignore` rule before copying it into the repository working directory. I then used `git status --ignored` to verify that Git recognized the file as ignored. The risk is that committing a credential to public repository history could expose access to the vendor API, and simply deleting the file in a later commit would not remove it from earlier history.


### Issue #22 — Update reproducibility instructions for both years

The README was updated so another analyst can reproduce both the 2025 and 2026 analyses.

The documentation now identifies all four required raw data files:

- `trips_2025.csv`
- `stations.xlsx`
- `trips_2026_h1.csv`
- `stations_2026.xlsx`

All four files are expected to remain in the repository root and are intentionally excluded from Git.

The README now explains how to:

1. obtain and place the raw data files;
2. install the required packages using `pip install -r requirements.txt`;
3. start Jupyter Notebook;
4. open and run `2025/analysis.ipynb`;
5. open and run `2026/analysis_2026.ipynb`.

The existing `requirements.txt` already contained the required packages:

- pandas
- matplotlib
- openpyxl
- jupyter

The work was completed on branch `22-update-reproducibility` and merged through an issue-linked pull request using `Closes #22`.

### Part B — Ignore verification

After the 2026 hand-off material was present locally, I ran:

`git status --ignored`

Git showed the following excluded items:

- `ride_knox_api_token.txt`
- `scratch/`
- `stations.xlsx`
- `trips_2025.csv`
- `2025/.ipynb_checkpoints/`

The credential and scratch files were present on disk but remained invisible to normal Git tracking.

#### Q-B1

One non-data hand-off item that must never be committed is `ride_knox_api_token.txt`. It contains an application credential rather than analysis content. I protected it by adding its exact filename to `.gitignore` before bringing the hand-off into the working repository. I then verified the rule with `git check-ignore` and later confirmed with `git status --ignored` that the file could exist locally without being tracked. If the token entered Git history, simply deleting it in a later commit would not remove it from earlier history, creating a credential-exposure risk.