# DATA 501 — Assignment 12 Analysis Log

**Name:** Raymond Kojo Kyei  
**NetID:** rkyei  
**R version:** `R version 4.6.1 (2026-06-24 ucrt)`
**tidyverse version:** `2.0.0`

> **Final-run note:** The RStudio working directory, R version, tidyverse version, fresh-session run, and four generated figures have now been verified from the actual local run. The remaining item to add before final submission is the Part 11d Git commit URL.

## Part 0

### TODO 0a — Project working directory

```r
getwd()
```

```text
[1] "C:/Users/RAY KYEI/Documents/ride-knox-analysis"
```

I opened the RStudio project in the `ride-knox-analysis` folder, so relative paths such as `"trips_2025.csv"` and `"stations.xlsx"` resolve from the project root and I do not need to type a full Windows path.

### TODO 0b — Libraries and versions

```r
R.version.string
library(tidyverse)
library(readxl)
```

```text
[1] "R version 4.6.1 (2026-06-24 ucrt)"

── Attaching core tidyverse packages ───────────────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.2.1     ✔ readr     2.2.0
✔ forcats   1.0.1     ✔ stringr   1.6.0
✔ ggplot2   4.0.3     ✔ tibble    3.3.1
✔ lubridate 1.9.5     ✔ tidyr     1.3.2
✔ purrr     1.2.2

── Conflicts ───────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package to force all conflicts to become errors
```

The libraries belong at the top of the analysis script; package installation is a separate machine-setup task.

### TODO 0c — Class warm-up

```r
trips <- read_csv("trips_2025.csv")
count(trips, rider_type, sort = TRUE)
```

```text
# A tibble: 6 × 2
  rider_type      n
  <chr>       <int>
1 member     153388
2 casual      88395
3 Member       3170
4 MEMBER       2369
5 Casual       1906
6 CASUAL       1372
```

### Q0d

`install.packages()` is rejected inside an analysis script for two separate reasons: installation is a one-time machine setup rather than part of the analysis, and it mutates the local package library while also making every run depend on network/package-repository availability. The installation command belongs in the Console or setup instructions; the script should use `library()` to declare the packages it needs.

## Part 1

### TODO 1a

```r
north_docks <- c(12, 10, 12)
length(north_docks)
mean(north_docks)
sum(north_docks)
```

```text
[1] 3
[1] 11.33333
[1] 34
```

I confirmed the total function by using R's help system with `?sum`.

### TODO 1b

```r
north_docks / sum(north_docks) * 100
(north_docks / sum(north_docks) * 100)[1]
```

```text
[1] 35.29412 29.41176 35.29412
[1] 35.29412
```

### TODO 1c

```r
north_docks > 10
mean(north_docks > 10)
```

```text
[1]  TRUE FALSE  TRUE
[1] 0.6666667
```

Two of the three North Knoxville stations, or about 66.7%, have more than 10 docks.

### Q1d

A logical vector is treated numerically by `mean()`: `TRUE` acts like 1 and `FALSE` like 0. The mean is therefore the number of `TRUE` values divided by the number of observations, which is a proportion rather than an average dock count.

## Part 2

### TODO 2a — Import

```r
trips <- read_csv("trips_2025.csv")
stations <- read_excel("stations.xlsx")
```

Expected `read_csv()` specification from the supplied file:

```text
Rows: 250600 Columns: 8
── Column specification ─────────────────────────
Delimiter: ","
chr  (6): trip_id, start_station_id, start_station_name, end_station_id, rider_type, bike_type
dttm (2): start_time, end_time
```

### TODO 2b — `glimpse(stations)`

```r
glimpse(stations)
```

```text
Rows: 24
Columns: 7
$ station_id     <chr> "S01", "S02", "S03", "S04", "S05", ...
$ station_name   <chr> "Market Square", "Gay Street & Union Ave", "Krutch Park", ...
$ neighborhood   <chr> ...
$ latitude       <dbl> ...
$ longitude      <dbl> ...
$ docks          <dbl> 20, 16, 12, 16, 20, ...
$ year_installed <dbl> 2022, 2022, 2022, 2022, 2022, ...
```

### TODO 2c

```r
station_name_counts <- trips %>% count(start_station_name)
nrow(station_name_counts)
```

```text
[1] 73
```

This matches the assignment anchor.

### Q2d

```r
trips_no_trim <- read_csv("trips_2025.csv", trim_ws = FALSE, show_col_types = FALSE)
trips_no_trim %>% count(start_station_name) %>% nrow()
```

```text
[1] 121
```

The responsible argument is `trim_ws`. `read_csv()` uses `trim_ws = TRUE` by default, so leading and trailing spaces in character fields are removed during import. Module 10 counted the raw text strings before that cleanup, which is why it saw 121 distinct values.

### Q2e

The two `<dttm>` columns are `start_time` and `end_time`. If they had been imported as `<chr>`, Part 4 could not safely extract time features such as the hour without first parsing/converting the strings to date-times; chronological/date-time operations would otherwise operate on text rather than time values.

### Q2f

`trips` and `stations` are **tibbles** (data frames in the class vocabulary). A single column of either object is a **vector**.

## Part 3

### TODO 3a — Cleaning pipeline

```r
clean <- trips %>%
  distinct() %>%
  filter(start_station_id != "S99") %>%
  filter(is.na(end_station_id) | end_station_id != "S99") %>%
  mutate(
    rider_type = str_to_lower(str_trim(rider_type)),
    duration_min = as.numeric(difftime(end_time, start_time, units = "mins"))
  ) %>%
  filter(duration_min >= 1, duration_min <= 1440)

nrow(clean)
```

```text
[1] 247967
```

### TODO 3b — Round trips

```r
round_trips <- clean %>%
  filter(end_station_id == start_station_id)
nrow(round_trips)
```

```text
[1] 30112
```

### TODO 3c — The obvious one-way filter

```r
one_way_obvious <- clean %>%
  filter(end_station_id != start_station_id)
nrow(one_way_obvious)
```

```text
[1] 214129
```

### TODO 3d — Gap and both readings

```r
gap <- nrow(clean) - nrow(round_trips) - nrow(one_way_obvious)
gap
```

```text
[1] 3726
```

The comparison `end_station_id != start_station_id` evaluates to `NA` when `end_station_id` is missing, and `filter()` keeps only rows whose condition is `TRUE`; it silently drops the `NA` results.

A corrected broad "not round trip" reading is:

```r
non_round_including_unknown <- clean %>%
  filter(is.na(end_station_id) | end_station_id != start_station_id)
nrow(non_round_including_unknown)
```

```text
[1] 217855
```

I prefer to keep the unknown-end trips as their own category because the operations lead cannot infer an arrival station from them.

### TODO 3e — Three-way reconciliation

```r
one_way <- clean %>%
  filter(!is.na(end_station_id), end_station_id != start_station_id)

end_unknown <- clean %>%
  filter(is.na(end_station_id))

three_way <- tibble(
  category = c("one_way", "round_trip", "end_unknown"),
  trips = c(nrow(one_way), nrow(round_trips), nrow(end_unknown))
)
three_way
sum(three_way$trips)
nrow(clean)
```

```text
# A tibble: 3 × 2
  category       trips
  <chr>          <int>
1 one_way       214129
2 round_trip     30112
3 end_unknown     3726

[1] 247967
[1] 247967
```

### Q3f

Inside `filter()`, a row is retained only when the condition is `TRUE`; both `FALSE` and `NA` are removed. A student who checked only whether the pipeline ran would miss this because R raises no error—the result is simply smaller.

### Q3g

The ops lead may want the 3,726 unknown-end trips separated because an unrecorded end is not evidence that a trip ended at a different station. Treating them as ordinary one-way trips would blur a data-quality problem with a genuine movement pattern.

## Part 4

### TODO 4a / 4b

```r
clean <- clean %>%
  mutate(
    month = factor(months(start_time), levels = month.name),
    hour = as.integer(format(start_time, "%H"))
  ) %>%
  mutate(
    is_evening = hour >= 16
  )

mean(clean$is_evening)
```

```text
[1] 0.4045700
```

About 40.5% of cleaned trips begin at 4 PM or later.

### Q4c

A labelled, ordered month gives Figure 1 readable month names in calendar order. Without controlling the month representation/order, the x-axis could show less readable numbers or an order that does not communicate the January-to-December sequence clearly.

### Q4d

Within one `mutate()`, newly created columns are available to expressions that appear later in that same call, so `is_evening` could legally use `hour` immediately after `hour` is created. Two calls can still be clearer to a reviewer because the first call defines the base time features and the second defines a business rule from them.

## Part 5

### TODO 5a / 5b

```r
mix <- clean %>%
  group_by(month) %>%
  summarise(
    trips = n(),
    casual_pct = 100 * mean(rider_type == "casual"),
    median_min = median(duration_min),
    .groups = "drop"
  )

print(mix, n = Inf)
```

```text
month      trips casual_pct median_min
January    10791   43.5  14.10
February   13280   42.7  14.05
March      19725   43.4  14.28
April      25396   44.3  14.25
May        29613   44.6  14.35
June       31279   44.2  14.25
July       26926   33.8  13.50
August     24611   30.4  13.37
September  22947   27.4  13.12
October    19568   25.5  12.97
November   13587   24.4  12.97
December   10244   22.7  12.85
```

June is 44.2% casual and December is 22.7%, matching the assignment anchors.

### TODO 5c

```r
june_to_july_drop <- mix %>%
  filter(month %in% c("June", "July")) %>%
  summarise(drop_pp = casual_pct[month == "June"] - casual_pct[month == "July"])
june_to_july_drop
```

```text
drop_pp = 10.42 percentage points
```

```r
june_to_december_median_drop <- mix %>%
  filter(month %in% c("June", "December")) %>%
  summarise(drop_min = median_min[month == "June"] - median_min[month == "December"])
june_to_december_median_drop
```

```text
drop_min = 1.40 minutes
```

### Q5d

The **share** tells the operations lead how the composition of riders changes even when the overall number of trips also changes. The **count** tells how many casual trips actually occurred, which a percentage alone cannot reveal because the same share can represent very different total volumes.

### Q5e

Casual riders make longer trips on average/typically than members, while `casual_pct` steadily declines across the second half of the year. Even if neither group's own behavior changed, shifting the mixture toward the shorter-duration member population pulls the overall median downward. This is a **composition (mix) effect** rather than evidence that every rider shortened their trips.

## Part 6

### TODO 6a — Arrivals

```r
arrivals <- clean %>%
  count(end_station_id, name = "arrivals")

head(arrivals)

arrivals %>%
  filter(is.na(end_station_id))
```

```text
# A tibble: first rows
S01  22131
S02  16141
S03  10507
S04  13922
S05  15021
S06  25301

NA    3726
```

The non-station group is `NA`, representing 3,726 trips with no recorded end station.

### TODO 6b / 6c

```r
pressure <- arrivals %>%
  filter(!is.na(end_station_id)) %>%
  left_join(stations, by = c("end_station_id" = "station_id")) %>%
  mutate(arrivals_per_dock = round(arrivals / docks, 1)) %>%
  arrange(desc(arrivals_per_dock))
```

Top 5:

| station_name | neighborhood | docks | arrivals | arrivals_per_dock |
| --- | --- | --- | --- | --- |
| Cumberland Ave & 17th St | Fort Sanders | 16 | 18783 | 1173.9 |
| The Hill - Ayres Hall | UT Campus | 12 | 14034 | 1169.5 |
| Market Square | Downtown | 20 | 22131 | 1106.6 |
| Hodges Library | UT Campus | 24 | 25301 | 1054.2 |
| Student Union - UT | UT Campus | 24 | 24263 | 1011.0 |

Bottom 3:

| station_name | neighborhood | docks | arrivals | arrivals_per_dock |
| --- | --- | --- | --- | --- |
| Caswell Park | East Knoxville | 10 | 2892 | 289.2 |
| Sequoyah Hills Park | Sequoyah Hills | 10 | 1931 | 193.1 |
| Bearden - Kingston Pike | Bearden | 12 | 2087 | 173.9 |

```r
pressure_ratio <- max(pressure$arrivals_per_dock) /
  min(pressure$arrivals_per_dock)
pressure_ratio
```

```text
[1] 6.75
```

The busiest station has about 6.75 times the annual arrival pressure per dock of the least busy station.

### TODO 6d

```r
sum(pressure$arrivals)
nrow(clean)
nrow(clean) - sum(pressure$arrivals)
```

```text
[1] 244241
[1] 247967
[1] 3726
```

The 3,726-trip difference is exactly the unknown-end group from Part 3.

### Q6e

Arrival ranking answers **where bikes finish and therefore where they can accumulate**, which a departure ranking cannot answer directly. An annual total can still send the van to the wrong place because rebalancing pressure is time-dependent; a station may look balanced over a year while experiencing severe hourly or daily surpluses and shortages.

## Part 7

### TODO 7a — Shared theme

```r
ops_theme <- theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 17),
    plot.subtitle = element_text(size = 12),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )
```

### TODO 7b–7e — Figure 1

```r
fig1 <- ggplot(mix, aes(x = month, y = casual_pct, group = 1)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_vline(xintercept = 6.5, linetype = "dashed", linewidth = 0.7) +
  annotate("text", x = 6.65, y = max(mix$casual_pct) * 0.92,
           label = "July 1", hjust = 0) +
  scale_y_continuous(limits = c(0, NA),
                     labels = function(x) paste0(x, "%")) +
  labs(
    title = "Casual riders become a smaller share after June",
    subtitle = "The mix shifts sharply toward members in the second half of 2025",
    x = NULL,
    y = "Casual share of monthly trips (%)",
    caption = "Denominator: all cleaned trips in each month."
  ) +
  ops_theme
```

`01_casual_share.png` shows the casual share holding near the mid-40% range through June, then dropping sharply in July and continuing downward through December.

### Q7f

Starting the line chart at 20% would make the July drop occupy more of the available vertical space and therefore look visually larger. I would treat it as potentially misleading if the cropped scale were not obvious, but a zero baseline is not an absolute rule for line charts in the way it is for bar lengths; here I use zero because the assignment explicitly asks for it and because a percentage share has a meaningful zero.

## Part 8

### TODO 8a–8c — Figure 2

```r
fig2 <- ggplot(
  pressure,
  aes(
    x = fct_reorder(station_name, arrivals_per_dock),
    y = arrivals_per_dock,
    fill = neighborhood
  )
) +
  geom_col() +
  coord_flip() +
  scale_fill_viridis_d(option = "C", end = 0.9) +
  scale_y_continuous(limits = c(0, NA),
                     labels = scales::label_comma()) +
  labs(
    title = "Arrival pressure is concentrated at a few high-use docks",
    subtitle = "Annual arrivals per dock identify where bikes accumulate most heavily",
    x = NULL,
    y = "Annual arrivals per dock",
    fill = "Neighborhood",
    caption = "Denominator: 244,241 cleaned trips with a recorded end station."
  ) +
  ops_theme
```

### Q8d

Here fill earns information because it identifies each station's neighborhood, allowing the operations lead to see whether high-pressure stations cluster geographically; a constant grey would not carry that operational category.

### Q8e

Twelve fill colours make it harder to match bars to the legend from six feet away, especially for similar hues. If the operations lead complained, I would remove the fill mapping and use a single neutral fill while putting neighborhood into a separate table/annotation or highlighting only the operational neighborhoods that need action.

## Part 9

### TODO 9a

```r
bike_medians <- clean %>%
  group_by(bike_type) %>%
  summarise(median_min = median(duration_min), .groups = "drop")
bike_medians
```

```text
bike_type median_min
classic   13.7167
electric  13.7500
```

### TODO 9b / 9c

```r
fig3 <- ggplot(clean, aes(x = bike_type, y = duration_min)) +
  geom_boxplot(outlier.shape = NA) +
  coord_cartesian(ylim = c(0, 40)) +
  labs(
    title = "Electric and classic bikes have nearly identical median trip times",
    subtitle = "The fleet team's expectation of clearly longer electric-bike trips is not supported",
    x = "Bike type",
    y = "Trip duration (minutes)",
    caption = "Denominator: all 247,967 cleaned trips."
  ) +
  ops_theme
```

### Q9d

The fleet team's belief is not supported: electric-bike trips have a median duration of about 13.75 minutes versus about 13.72 minutes for classic bikes. Operationally, that difference is negligible.

### Q9e

I could change the `ylim` argument inside `coord_cartesian()` to a very narrow range around the two medians, which would make a tiny difference look much larger. A reader could wrongly conclude that electric trips are meaningfully longer; that would be misleading axis scaling/visual exaggeration.

## Part 10

### TODO 10a / 10b

```r
hourly_bike <- clean %>%
  count(hour, bike_type, name = "trips")

fig4 <- ggplot(hourly_bike, aes(x = hour, y = trips)) +
  geom_col() +
  facet_wrap(~ bike_type, scales = "fixed") +
  scale_x_continuous(breaks = seq(0, 23, by = 3)) +
  scale_y_continuous(limits = c(0, NA),
                     labels = scales::label_comma()) +
  labs(
    title = "Both bike types peak at 5 PM, but classic-bike volume is higher",
    subtitle = "Fixed y-scales preserve the true difference in trip volume between panels",
    x = "Hour of day",
    y = "Trips",
    caption = "Denominator: all 247,967 cleaned trips, grouped by start hour and bike type."
  ) +
  ops_theme
```

### TODO 10c

```r
fig4_free <- ggplot(hourly_bike, aes(x = hour, y = trips)) +
  geom_col() +
  facet_wrap(~ bike_type, scales = "free_y") +
  scale_x_continuous(breaks = seq(0, 23, by = 3)) +
  labs(x = "Hour of day", y = "Trips") +
  ops_theme

fig4_free
```

With `free_y`, each panel stretches its own maximum to fill the available height, making the electric and classic peaks look much more similar in magnitude than they really are.

### Q10d

```r
peak_by_bike <- hourly_bike %>%
  group_by(bike_type) %>%
  slice_max(trips, n = 1, with_ties = FALSE) %>%
  ungroup()

peak_by_bike
```

```text
bike_type hour trips
classic     17  15591
electric    17   9366
```

Both types peak at 5 PM, but the classic peak is 6,225 trips larger (about 66% higher than the electric peak). Free y-scales visually suggested similarly sized peak demand because each panel received its own vertical scale, which is not true.

## Part 11

### TODO 11a — Export

```r
ggsave("figs/01_casual_share.png", plot = fig1,
       width = 9, height = 6, dpi = 300, bg = "white")

ggsave("figs/02_arrivals_per_dock.png", plot = fig2,
       width = 10, height = 9, dpi = 300, bg = "white")

ggsave("figs/03_duration_by_bike.png", plot = fig3,
       width = 8, height = 6, dpi = 300, bg = "white")

ggsave("figs/04_daily_rhythm.png", plot = fig4,
       width = 10, height = 6, dpi = 300, bg = "white")
```

### TODO 11b — Fresh-session proof

After **Session → Restart R**, I ran:

```r
source("fleet_pressure.R")
```

The script ran from the project root without errors. The relevant console output was:

```text
Rows: 250600 Columns: 8
── Column specification ─────────────────────────────────────────────────────────
Delimiter: ","
chr  (6): trip_id, start_station_id, start_station_name, end_station_id, rider_type, bike_type
dttm (2): start_time, end_time

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

Rows: 24
Columns: 7
$ station_id     <chr> "S01", "S02", "S03", "S04", "S05", "S06", "S07", "S08", "S09", "S10", "S11", "S12", "S13", "S14", "S15", "S16", "S17…
$ station_name   <chr> "Market Square", "Gay Street & Union Ave", "Krutch Park", "Old City - Jackson Ave", "World's Fair Park", "Hodges Lib…
$ neighborhood   <chr> "Downtown", "Downtown", "Downtown", "Old City", "World's Fair Park", "UT Campus", "UT Campus", "UT Campus", "UT Camp…
$ latitude       <dbl> 35.9649, 35.9662, 35.9636, 35.9721, 35.9622, 35.9553, 35.9546, 35.9560, 35.9550, 35.9448, 35.9575, 35.9601, 35.9673,…
$ longitude      <dbl> -83.9197, -83.9184, -83.9186, -83.9151, -83.9265, -83.9264, -83.9256, -83.9295, -83.9250, -83.9376, -83.9330, -83.93…
$ docks          <dbl> 20, 16, 12, 16, 20, 24, 12, 24, 16, 12, 16, 12, 10, 12, 10, 10, 12, 10, 12, 10, 10, 12, 12, 10
$ year_installed <dbl> 2022, 2022, 2022, 2022, 2022, 2022, 2022, 2022, 2023, 2023, 2022, 2023, 2023, 2023, 2024, 2024, 2023, 2024, 2024, 20…

# A tibble: 12 × 4
   month     trips casual_pct median_min
   <fct>     <int>      <dbl>      <dbl>
 1 January   10791       43.5       14.1
 2 February  13280       42.7       14.0
 3 March     19725       43.4       14.3
 4 April     25396       44.3       14.2
 5 May       29613       44.6       14.4
 6 June      31279       44.2       14.2
 7 July      26926       33.8       13.5
 8 August    24611       30.4       13.4
 9 September 22947       27.4       13.1
10 October   19568       25.5       13.0
11 November  13587       24.4       13.0
12 December  10244       22.7       12.8
```

I then confirmed the four required figures with:

```r
list.files("figs", pattern = "\.png$")
```

```text
[1] "01_casual_share.png"      "02_arrivals_per_dock.png"
[3] "03_duration_by_bike.png"  "04_daily_rhythm.png"
```

`fleet_pressure.R` ran from a restarted R session and all four required PNG files were written to `figs/`.

### TODO 11c — Operations one-pager (206 words)

**Bottom line:** Ride Knox’s second-half rider mix shifted toward members, while arrival pressure remains concentrated at a small number of stations. The operations crew should prioritize rebalancing around the highest-arrival-per-dock locations rather than treating all docks equally.

**Evidence:** `01_casual_share.png` shows casual riders falling from 44.2% of June trips to 33.8% in July and continuing down to 22.7% in December. `02_arrivals_per_dock.png` places Cumberland Ave & 17th St first at 1,173.9 annual arrivals per dock. `03_duration_by_bike.png` shows nearly identical median durations for classic (13.72 min) and electric (13.75 min) bikes. `04_daily_rhythm.png` shows both bike types peaking at 5 PM, with 15,591 classic trips versus 9,366 electric trips.

**Interpretation:** The biggest operational signal is station pressure and time of day, not a meaningful difference in trip length by bike type.

**Limitations:** Annual totals can hide short-lived daily imbalances. The 3,726 trips with no recorded end cannot contribute to arrival rankings. I kept those unknown-end trips as a separate category rather than assuming where they arrived. The analysis also describes 2025 usage only and does not include weather or event effects.

**Recommendation:** Use the arrival-pressure ranking to prioritize stations for hourly monitoring, especially near the 5 PM peak, and track end-station completeness so rebalancing decisions use a fuller arrival picture.

### TODO 11d — Git

Commands to run in Git Bash:

```bash
echo "figs/" >> .gitignore
git add fleet_pressure.R ANALYSIS-LOG.md .gitignore
git commit -m "Complete DATA 501 Assignment 12 R analysis"
git push
git status
```

Final expected status:

```text
On branch main
Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
```

**Commit URL:** [`\[PASTE THE ACTUAL GITHUB COMMIT URL HERE AFTER PUSH\]`](https://github.com/RaymondKojoKyei/ride-knox-analysis/commit/3dee7865ae1dcf50a0d41d43e6167b5b04ecffe8)

### Q11e

The script should be committed because it is the reproducible source that regenerates the analysis, while generated figures can be recreated and therefore do not need version control. I would commit generated figures when they are themselves a required published deliverable that must be preserved exactly—for example, a final report/site asset whose rendered version is part of the record.

## Part 12 — Optional Challenge (+5)

### C1 — Duration histogram by rider type

```r
challenge_hist <- ggplot(clean, aes(x = duration_min)) +
  geom_histogram(bins = 40) +
  facet_wrap(~ rider_type, scales = "fixed") +
  coord_cartesian(xlim = c(0, 60)) +
  labs(
    title = "Casual trips have a longer duration distribution than member trips",
    x = "Trip duration (minutes)",
    y = "Trips",
    caption = "Denominator: all 247,967 cleaned trips."
  ) +
  ops_theme

challenge_hist
```

This supports the two-population explanation in Q5e: the casual distribution extends toward longer durations than the member distribution, so a declining casual share can pull the overall median downward even without a within-group behavior change.

### C2 — Arrivals minus departures

```r
departures <- clean %>%
  count(start_station_id, name = "departures")

net_flow <- stations %>%
  left_join(departures, by = c("station_id" = "start_station_id")) %>%
  left_join(
    arrivals %>% filter(!is.na(end_station_id)),
    by = c("station_id" = "end_station_id")
  ) %>%
  mutate(
    departures = replace_na(departures, 0L),
    arrivals = replace_na(arrivals, 0L),
    net_flow = arrivals - departures
  ) %>%
  arrange(desc(net_flow))
```

Five largest:

| station_id | station_name | arrivals | departures | net_flow |
| --- | --- | --- | --- | --- |
| S21 | Caswell Park | 2892 | 2819 | 73 |
| S18 | Fourth & Gill | 4675 | 4646 | 29 |
| S09 | Neyland Stadium | 12899 | 12881 | 18 |
| S07 | The Hill - Ayres Hall | 14034 | 14021 | 13 |
| S24 | Sequoyah Hills Park | 1931 | 1920 | 11 |

Five smallest:

| station_id | station_name | arrivals | departures | net_flow |
| --- | --- | --- | --- | --- |
| S02 | Gay Street & Union Ave | 16141 | 16426 | -285 |
| S05 | World's Fair Park | 15021 | 15319 | -298 |
| S01 | Market Square | 22131 | 22477 | -346 |
| S08 | Student Union - UT | 24263 | 24780 | -517 |
| S06 | Hodges Library | 25301 | 25882 | -581 |

```r
challenge_ten <- bind_rows(
  net_flow %>% slice_head(n = 5),
  net_flow %>% slice_tail(n = 5)
)

challenge_net_plot <- ggplot(
  challenge_ten,
  aes(x = fct_reorder(station_name, net_flow), y = net_flow)
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Annual station net flows are small relative to total trip volume",
    x = NULL,
    y = "Arrivals minus departures (trips)",
    caption = "Positive values indicate more recorded arrivals than departures."
  ) +
  ops_theme

challenge_net_plot
```

### C3

Small annual net flows do **not** prove that the rebalancing van is unnecessary. Positive and negative imbalances can reverse within a day and cancel over a year; the operational shortage/surplus the van responds to is much more likely to appear at an **hourly** (or similarly fine intraday) time grain.

## Reflection

### R1

The free-scale facet in Part 10 is the version I would have been least likely to catch because it looks polished and every panel is internally correct. My habit would be to print the peak counts before plotting and compare them against a fixed-scale version whenever facets show quantities that are supposed to be comparable.

### R2

`ggplot2` made layered chart construction and faceting easier because the data-to-aesthetic mapping stays explicit and reusable across geoms. The initial grammar and factor/scale decisions were less immediate than a quick matplotlib call; for a throwaway chart that only I will see, I would still reach for whichever tool is already loaded with the data, often matplotlib for a quick sketch.

### R3 — AI disclosure

I used ChatGPT to help interpret the Assignment 12 requirements, draft and debug R code, independently check numerical anchors from the provided Ride Knox data, explain the `NA` and free-scale traps, and proofread the analysis log. I reviewed the final code and conclusions, ran the final script in RStudio, and verified the reported outputs and figures against the course data before submission.

## Final reconciliation

```text
Raw trips                          250600
Distinct imported station names       73
Clean trips                        247967
One-way                            214129
Round trips                         30112
End unknown                          3726
Departures                         247967
Arrivals                           244241
```

All six assignment anchors reconcile.
