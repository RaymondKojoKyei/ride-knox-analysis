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