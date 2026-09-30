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
```

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
```

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
```

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
- `stations_2026.xlsx`
- `trips_2025.csv`
- `trips_2026_h1.csv`
- `2025/.ipynb_checkpoints/`

The credential and scratch files were present on disk but remained invisible to normal Git tracking.

#### Q-B1

One non-data hand-off item that must never be committed is `ride_knox_api_token.txt`. It contains an application credential rather than analysis content. I protected it by adding its exact filename to `.gitignore` before bringing the hand-off into the working repository. I then verified the rule with `git check-ignore` and later confirmed with `git status --ignored` that the file could exist locally without being tracked. If the token entered Git history, simply deleting it in a later commit would not remove it from earlier history, creating a credential-exposure risk.


## Part C - Co-authoring the README with Riley

### Issue #23 - Co-author the two-year README with Riley

This exercise used two separate clones of the same repository and one shared branch, `23-coauthor-readme`.

The original Raymond clone was:

`C:\Users\RAY KYEI\Documents\ride-knox-analysis`

The second clone used for Riley was:

`C:\Users\RAY KYEI\Documents\ride-knox-riley`

### Two-clone shared-branch transcript

#### [Raymond]

I created and pushed the shared branch from the original clone:

```text
git switch -c 23-coauthor-readme
git push -u origin 23-coauthor-readme
```

I updated the README with a two-year headline, placed a 2026 chart near the top, and added separate 2025 and 2026 analysis sections.

I committed and pushed the first README contribution:
cb6b024 Rewrite README for two-year Ride Knox story

[Riley]
I created a second clone:
git clone https://github.com/RaymondKojoKyei/ride-knox-analysis.git ride-knox-riley

I joined the same shared branch:
git switch 23-coauthor-readme

Riley changed the README headline differently and added an Interpretation Notes section.
The Riley contribution was committed locally as:
2340536 Add Riley interpretation notes

Riley did not push at this point.
[Raymond]
Back in the original clone, I changed the README headline again and pushed the new commit first:
7a258b4 Refine Ride Knox two-year headline

[Riley]
Riley then attempted to push the earlier local commit:
git push

Git rejected the push:
! [rejected]        23-coauthor-readme -> 23-coauthor-readme (fetch first)
error: failed to push some refs to 'https://github.com/RaymondKojoKyei/ride-knox-analysis.git'
hint: Updates were rejected because the remote contains work that you do not
hint: have locally. This is usually caused by another repository pushing to
hint: the same ref. If you want to integrate the remote changes, use
hint: 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.

The push was rejected because the remote shared branch contained Raymond's newer commit while Riley's local clone did not yet contain that work.
Riley then pulled the shared branch:
git pull --no-rebase origin 23-coauthor-readme

Git reported:
Auto-merging README.md
CONFLICT (content): Merge conflict in README.md
Automatic merge failed; fix conflicts and then commit the result.

The conflict markers showed the two competing README headlines:
> <<<<<<< HEAD
# Ride Knox Ridership and Station Performance: 2025-2026
> =======
# Ride Knox 2025-2026: Ridership Recovery, Station Pressure, and Operations
> >>>>>>> 7a258b49922f8da00e9408c4d58adb82422e7da8

The conflict markers are reproduced below with a leading `>` so Git does not mistake the documented evidence for an unresolved conflict:

In this conflict, HEAD represented Riley's local version. The lower section represented the newer remote version that Raymond had already pushed.
The conflict-resolution work was committed as:
c40600b Resolve shared README headline conflict

and pushed to the shared branch.
[Raymond]
The original clone then pulled the resolved shared branch and received both Riley's contribution and the conflict-resolution commit.
A pull request was opened from:
23-coauthor-readme

into:
main

The pull request description included:
Closes #23

The full diff was reviewed on GitHub. I also added a line-level review comment explaining why the 2026 chart was positioned near the top of the README.
The pull request was merged into main.
Synchronizing both clones
After the merge, both clones were switched to main and updated.
The Raymond clone reached:
4105a206ed7b157f394060728569f68717686f92

The Riley clone also reached:
4105a206ed7b157f394060728569f68717686f92

This confirmed that both clones were synchronized to the same version of main after the Issue #23 merge.
Post-merge cleanup
During a later verification of README.md, I found that a leftover merge-conflict marker, <<<<<<< HEAD, had remained at the top of the committed README.
I corrected this through a separate cleanup branch and pull request rather than editing main directly.
The cleanup was merged through pull request #32, and the updated main contained no remaining conflict markers.
I verified this with:
Select-String -Path README.md -Pattern "<<<<<<<|=======|>>>>>>>"


The command returned no matches.

I kept Riley's shorter headline because it described both ridership and station performance clearly while keeping the README concise and easy to read.


Q-C1
The rejected push occurred because the remote shared branch had advanced after Riley created a local commit. Raymond pushed another commit first, so Riley's clone did not contain the newest remote history. Git rejected Riley's push rather than allowing newer remote work to be overwritten.
This differed from the earlier clone-and-push exercise because the remote branch had not independently advanced between the local commit and push in that earlier exercise.

Q-C2
The conflict occurred on the shared feature branch 23-coauthor-readme, not on main. Riley encountered it locally while pulling Raymond's newer work into the shared branch.
This kept main protected because the competing edits were handled before the feature work was merged. In a real team, frequent pulls, smaller commits, regular pushes, and communication before multiple people edit the same lines would help make conflicts less frequent and smaller when they do occur.

Q-C3
During the conflict in Riley's clone, HEAD represented Riley's local version because Riley was currently on the local 23-coauthor-readme branch.

The content below the ======= separator represented the incoming remote version that Raymond had already pushed. Git displayed both versions so the competing changes could be compared and reconciled.


## Part D - Publish the two-year GitHub Pages site

### Issue #24 - Publish the two-year GitHub Pages site

I created a new `index.md` homepage for the public Ride Knox site and updated `_config.yml` to use the `jekyll-theme-slate` theme.

The public homepage now leads with the 2026 verdict and the 2026 ridership recovery chart.

The homepage also links directly to:

- the 2025 analysis report;
- the 2026 operations memo;
- the 2026 public release note;
- the project README.

The site title and description were updated to reflect the two-year 2025-2026 analysis.

After the pull request was merged, I tested the live GitHub Pages site in a browser.

I confirmed that:

- the new Slate theme loaded;
- the 2026 verdict appeared near the top of the page;
- the 2026 recovery chart loaded correctly;
- the 2025 report link opened;
- the 2026 memo link opened;
- the 2026 release note link opened;
- the README link opened;
- no broken-image icons were visible.

### Q-D1

Before this update, the GitHub Pages site mainly reflected the README and the earlier single-year presentation. There was no dedicated `index.md` homepage for the two-year release.

Adding `index.md` changed what visitors see first. The site now opens with a public-facing 2025-2026 homepage that emphasizes the 2026 verdict, supporting chart, and links to the main analysis documents.


## Part E - Release communication and audit history

### Issue #26 - Document release audit history

The public release can be traced through the repository history. Five important changes are listed below with the date and a plain-English explanation of what each change accomplished.


1. **2026-09-29 — `ab14d11 Write 2026 public release note`**
   Added the stakeholder-facing release note explaining the updated public analysis, the main 2026 findings, one caveat, and where readers should begin.

2. **2026-09-29 — `eddaf7c Publish two-year Ride Knox homepage`**
   Created the new public homepage that leads with the 2026 verdict, recovery chart, and links to the main supporting documents.

3. **2026-09-29 — `cb6b024 Rewrite README for two-year Ride Knox story`**
   Reframed the project from a single-year analysis into a clearer 2025-2026 story and brought the 2026 analysis into the main project narrative.

4. **2026-09-29 — `5da7304 Document reproducibility workflow`**
   Added instructions explaining the required data files, package installation, and how to run both the 2025 and 2026 notebooks.

5. **2026-09-29 — `7f6d2bb Remove leftover README conflict marker`**
   Corrected a visible collaboration artifact that remained after the shared-branch conflict exercise so the public README was clean.

### Why the public page is auditable

Unlike a normal website where changes may appear without a visible history, this project keeps a dated record of how the analysis, public communication, and supporting documentation changed over time. A reviewer can connect the public page to specific changes and supporting files, making it easier to understand what was added, when it changed, and why.


## Final Reflection

The rejected push and merge conflict showed me that collaboration problems are easier to manage when team members pull frequently and keep their commits small. In a real team, I would pull before starting work, communicate before editing shared sections, and push changes regularly so conflicting work does not build up for too long.

This exercise also showed me why `main` should remain protected. The conflict happened on a feature branch, which allowed the problem to be resolved and reviewed before the work reached the public version of the project.

## AI Disclosure

I used ChatGPT as a learning and troubleshooting assistant during this project. I used it to help interpret Git messages, understand the required workflow, organize project steps, review Markdown formatting, and explain how to carry out Git and GitHub tasks.

I reviewed the suggestions, ran the commands myself, checked the outputs, made decisions based on the assignment requirements, and revised the written material before including it in the project. The repository history, conflict exercise, browser testing, issue management, and final verification were completed through my own Git and GitHub work.


## Final Repository Verification

At the end of the project, the repository was synchronized with GitHub, the working tree was clean, and all feature branches had been removed.

Final branch state:

```text
* main

Final remote branch state:
origin/HEAD -> origin/main
origin/main

Final git status:
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean

Final git log --oneline snapshot, captured immediately before this final log-only update:
5dc519c Document deliberate conflict resolution decision
1e48599 Record final repository verification
3c476f3 Add final reflection and AI disclosure
675b41a Clean audit log formatting
7e05807 Document release audit history
66c9f31 Document public Pages verification
a26c654 Merge pull request #35 from RaymondKojoKyei/24-publish-two-year-site
eddaf7c Publish two-year Ride Knox homepage
9bc8392 Merge pull request #34 from RaymondKojoKyei/25-write-release-note
ab14d11 Write 2026 public release note
9e90da0 Clarify documented conflict markers
5328fcd Document two-clone collaboration exercise
a30f2b5 Merge pull request #32 from RaymondKojoKyei/24-fix-readme-marker
7f6d2bb Remove leftover README conflict marker
4105a20 Merge pull request #31 from RaymondKojoKyei/23-coauthor-readme
c40600b Resolve shared README headline conflict
7a258b4 Refine Ride Knox two-year headline
2340536 Add Riley interpretation notes
cb6b024 Rewrite README for two-year Ride Knox story
```

Final ignored-file verification confirmed that the raw datasets, credential, and scratch material remained local and were not tracked by Git.