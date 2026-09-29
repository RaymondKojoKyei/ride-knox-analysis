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