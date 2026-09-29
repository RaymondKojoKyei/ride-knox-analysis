# DATA 501 — Assignment 6 Collaboration Log

**Name:** Raymond Kojo Kyei  
**NetID:** rkyei

## Part 0

### TODO 0a — Starting state

`git status` showed:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean

I confirmed that the Assignment 5 history is intact, including the split first commits, the `.gitignore` commit, and the resolved-conflict merge commit.

**Q0:** Module 5 put the project under version control and backed it up on GitHub, while Assignment 6 completes the collaboration and sharing workflow by adding issues, pull requests, peer review, documentation, and GitHub Pages.

## Part 1

## Part 2

## Part 3

## Part 4

## Part 5

## Part 6

## Part 7

## Part 8

## Reflection


### TODO 1a — README issue

Created GitHub issue #1:

```text
Add a project README

https://github.com/RaymondKojoKyei/ride-knox-analysis/issues/1


Do **not** add my instruction text such as:

```text
Do not commit the worklog yet...
Next is Part 1b...
Let’s get those counts...


### TODO 1b — Data-quality issues

Created GitHub issue #2:

```text
Investigate trips with missing end_station_id
```

Issue URL:

```text
https://github.com/RaymondKojoKyei/ride-knox-analysis/issues/2
```

Label: `bug`

Full issue body:

```text
### What/where
The 2025 trip data contain records where `end_station_id` is missing.

### Expected vs. actual
Expected: 0 trips with a missing `end_station_id`.
Actual: 3,774 trips have a missing `end_station_id`.

### Why it matters
Missing end-station information can affect station-level analysis because these trips cannot be reliably assigned to a destination station.

@RaymondKojoKyei This issue is related to #1 because the README should document important data-quality limitations.
```

Created GitHub issue #3:

```text
Investigate trips with negative duration
```

Issue URL:

```text
https://github.com/RaymondKojoKyei/ride-knox-analysis/issues/3
```

Label: `question`

Full issue body:

```text
### What/where
The 2025 trip data contain records where `end_time` occurs before `start_time`.

### Expected vs. actual
Expected: 0 trips with negative duration.
Actual: 749 trips have negative duration.

### Why it matters
Negative trip durations are not physically meaningful and can distort calculations of trip duration and summary statistics.
```

### TODO 1c — Mention and cross-reference

In issue #2, I mentioned `@RaymondKojoKyei` and referenced README issue `#1`, linking the two issues.

**Q1:** Expected: 0 trips with a missing `end_station_id`. Actual: 3,774 trips have a missing `end_station_id`.

Screenshot showing the rendered mention and issue cross-reference:

![Part 1 issue mention and cross-reference](screenshots/part1-issue-link.png)


### TODO 2a — Create the branch

Created and switched to the required branch:

```text
chore/tidy-report
```

### TODO 2b — Improve the report

I made one small change to `report.md` clarifying that the raw data files are intentionally stored outside the Git repository and are not tracked in version control.

### TODO 2c — Commit, push, and open pull request

Commit message:

```text
Clarify raw data availability in report
```

Pull request:

```text
#5 — Clarify raw data availability in report
```

PR URL:

```text
https://github.com/RaymondKojoKyei/ride-knox-analysis/pull/5
```

PR description:

```text
This pull request adds a short clarification to report.md explaining that the raw trip and station data are stored outside the Git repository and are not included in version control.
```

### TODO 2d — Self-review

On the pull request's `Files changed` tab, I left a line comment explaining why the clarification was added.

The line comment explained that the sentence helps readers understand that the raw data are intentionally stored outside the Git repository.

### TODO 2e — Merge and update main

After merging pull request #5, I switched back to `main` and ran `git pull`.

The log showed:

```text
1dae9a8 Merge pull request #5 from RaymondKojoKyei/chore/tidy-report
d64d600 Clarify raw data availability in report
7494561 Merge pull request #4 from RaymondKojoKyei/docs/part1-log
e63ab7f Document Part 1 issues and cross-link
eee886d Complete Part 0 collaboration log
1d74942 Add Assignment 6 collaboration log
```

**Q2:** While the pull request was open but not yet merged, `main` had not changed because the proposed change still existed only on the `chore/tidy-report` branch.

Ride Knox station demand is uneven: busy campus stations face the greatest capacity pressure, while Bearden and Sequoyah Hills show comparatively low use.


### TODO 4a — Create conflicting changes

The `docs/project-readme` branch and `main` were deliberately changed differently on the same report headline so that the pull request would produce a merge conflict.

### TODO 4b — Open README pull request

Opened pull request #7:

```text
Add project README

https://github.com/RaymondKojoKyei/ride-knox-analysis/pull/7

Closes #1

<<<<<<< HEAD
Ride Knox station demand is uneven: busy campus stations face the greatest capacity pressure, while Bearden and Sequoyah Hills show comparatively low use.
=======
Ride Knox ridership and station demand vary across the network, with some locations showing much greater use than others.
>>>>>>> main

Ride Knox station demand is uneven: busy campus stations face the greatest capacity pressure, while Bearden and Sequoyah Hills show comparatively low use.

Resolve report headline conflict using specific station finding

029c7e7 Merge pull request #7 from RaymondKojoKyei/docs/project-readme
ec4a0ca Resolve report headline conflict using specific station finding
b7886ca Reword report headline on main
c913e30 Add project README and update report headline
77541c9 Merge pull request #6 from RaymondKojoKyei/docs/part2-log
9ec4468 Document Part 2 pull request workflow

### Q5

The site uses the **Cayman** theme. If an image worked in the repository but broke on GitHub Pages, I would first check the relative file path, filename, capitalization, and whether the image file was actually committed to the repository.


## Part 6 — Peer Review / Fork Contribution

Because I did not have a partner available, I used the fallback fork workflow.

I worked from my fork of the public repository:

```text
https://github.com/RaymondKojoKyei/Student-PerfoStudent-Performance-Analysisrmance-Analysis

I created the branch:

```text
docs/readme-clarification

I made a small genuine documentation improvement by closing an unfinished Markdown code block in the README so the Getting Started section would render correctly.

The commit message was:

```text
Close README code block

I opened a cross-repository pull request to the original repository:

```text
https://github.com/pachehitesh/Student-Performance-Analysis/pull/1

I also added a line-level review comment explaining why the README fix was needed.

The comment permalink is:

```text
https://github.com/pachehitesh/Student-Performance-Analysis/pull/1/changes#r4129483828

**Q6:** A “Request changes” review can feel less personal than verbal criticism because it focuses on a specific line or change, gives a clear written explanation of what should be improved, and gives the author time to respond without being put on the spot.