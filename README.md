# Ride Knox 2025–2026: Ridership Recovery, Station Pressure, and Operations

A reproducible analysis of Ride Knox ridership patterns, station activity, and station-capacity pressure.
![2026 Ridership Recovery](2026/charts/recovery_vs_2025.png)

## Key Finding

Ride Knox station demand is uneven: busy campus stations face the greatest capacity pressure, while Bearden and Sequoyah Hills show comparatively low use.

![Station Pressure: 2025 vs. 2026](2025/charts/station_pressure_yoy.png)

## Overview

This project addresses two operational questions for Ride Knox:

1. What patterns may help explain the decline in ridership?
2. Which stations appear to have the greatest need for additional capacity?

The analysis uses trip-level data together with station information to examine ridership patterns and compare station activity relative to available dock capacity.

## 2025 Analysis

The 2025 work provides the starting point for understanding Ride Knox ridership and how stations were being used. It looks at rider activity and station pressure to show where demand was concentrated and where capacity issues may have been developing.

The 2025 notebook and report are stored in the `2025/` folder.

## 2026 Analysis

The 2026 analysis builds on the 2025 results by looking at the first half of 2026 and comparing recent ridership and station activity with the earlier baseline.

The results show that casual ridership was still below the previous year, while the picture improved when day-pass riders were included. The analysis also shows that station pressure changed at some locations after dock capacity was expanded.

The 2026 notebook, memo, and charts are stored in the `2026/` folder.

## Data

The raw data files are intentionally excluded from this GitHub repository and remain ignored by Git.

To reproduce the 2025 and 2026 analyses, obtain the following four course data files:

- `trips_2025.csv`
- `stations.xlsx`
- `trips_2026_h1.csv`
- `stations_2026.xlsx`

Place all four files in the repository root:

```text
ride-knox-analysis/
├── trips_2025.csv
├── stations.xlsx
├── trips_2026_h1.csv
├── stations_2026.xlsx
├── 2025/
└── 2026/
```

The raw data files should remain local and should not be committed to GitHub.

### `trips_2025.csv`

| Column | Description |
|---|---|
| `trip_id` | Unique identifier for each trip |
| `start_time` | Date and time the trip began |
| `end_time` | Date and time the trip ended |
| `start_station_id` | Identifier of the station where the trip began |
| `start_station_name` | Name of the station where the trip began |
| `end_station_id` | Identifier of the station where the trip ended |
| `rider_type` | Rider category associated with the trip |
| `bike_type` | Type of bicycle used |

### `stations.xlsx`

| Column | Description |
|---|---|
| `station_id` | Unique station identifier |
| `station_name` | Station name |
| `neighborhood` | Neighborhood where the station is located |
| `latitude` | Station latitude |
| `longitude` | Station longitude |
| `docks` | Number of docks available at the station |
| `year_installed` | Year the station was installed |

## How to Run

1. Clone or download this repository.

2. Obtain the four raw course data files:
   - `trips_2025.csv`
   - `stations.xlsx`
   - `trips_2026_h1.csv`
   - `stations_2026.xlsx`

3. Place all four raw data files in the repository root folder.

4. Open PowerShell or the VS Code terminal in the repository root.

5. Install the required Python packages by running:

   ```bash
   pip install -r requirements.txt
   ```

6. Start Jupyter Notebook by running:

   ```bash
   jupyter notebook
   ```

7. To reproduce the 2025 analysis:
   - open `2025/analysis.ipynb`
   - run the notebook from top to bottom

8. To reproduce the 2026 analysis:
   - open `2026/analysis_2026.ipynb`
   - run the notebook from top to bottom

Both notebooks use relative paths to read the raw data files from the repository root. The raw data files are intentionally excluded from GitHub and should remain local.

## Key Findings

The station-capacity analysis shows that activity is not evenly distributed across the Ride Knox network. Busy campus stations experience substantially greater trips-per-dock pressure, while stations in Bearden and Sequoyah Hills have comparatively low activity. This suggests that future capacity decisions should consider station utilization rather than simply adding docks uniformly across the system.

![Ride Knox station capacity pressure](2025/charts/station_pressure_yoy.png)

## Limitations

- The analysis covers only one year of trip data, so it cannot establish long-term trends by itself.
- The results are observational and should not be interpreted as proof that any single factor caused the observed ridership patterns.
- Trip-cleaning rules affect the final sample. Trips shorter than 2 minutes and trips longer than 24 hours were excluded as likely data-quality problems.
- Missing or incomplete station information may affect some station-level calculations.

## Repository Structure

```text
ride-knox-analysis/
├── 2025/
│   ├── analysis.ipynb
│   ├── report.md
│   └── charts/
│       ├── nonmember_recovery.png
│       └── station_pressure_yoy.png
├── 2026/
│   ├── analysis_2026.ipynb
│   ├── memo_2026.md
│   └── charts/
│       ├── daypass_vs_others.png
│       ├── recovery_vs_2025.png
│       └── station_pressure_change.png
├── screenshots/
├── README.md
├── requirements.txt
├── _config.yml
├── PROJECT-LOG.md
├── COLLAB-LOG.md
├── WORKLOG.md
└── .gitignore
```