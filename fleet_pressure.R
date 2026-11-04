# DATA 501 - Assignment 12
# R I: R for Visualization - The Operations One-Pager
# Name: Raymond Kojo Kyei
# NetID: rkyei

library(tidyverse)
library(readxl)

# -----------------------------
# Part 0 / Part 2: import
# -----------------------------
trips <- read_csv("trips_2025.csv")
stations <- read_excel("stations.xlsx")

# Part 0c: class warm-up
count(trips, rider_type, sort = TRUE)

# -----------------------------
# Part 1: vectors
# -----------------------------
north_docks <- c(12, 10, 12)
length(north_docks)
mean(north_docks)
sum(north_docks)

north_docks / sum(north_docks) * 100
(north_docks / sum(north_docks) * 100)[1]

north_docks > 10
mean(north_docks > 10)

# -----------------------------
# Part 2: inspect
# -----------------------------
glimpse(stations)

station_name_counts <- trips %>%
  count(start_station_name)

nrow(station_name_counts)

# Q2d demonstration: disabling readr's whitespace trimming reproduces
# the Module 10 raw-text count of 121 distinct station-name strings.
trips_no_trim <- read_csv("trips_2025.csv", trim_ws = FALSE, show_col_types = FALSE)
trips_no_trim %>%
  count(start_station_name) %>%
  nrow()

# -----------------------------
# Part 3: cleaning + NA reconciliation
# -----------------------------
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

round_trips <- clean %>%
  filter(end_station_id == start_station_id)
nrow(round_trips)

one_way_obvious <- clean %>%
  filter(end_station_id != start_station_id)
nrow(one_way_obvious)

gap <- nrow(clean) - nrow(round_trips) - nrow(one_way_obvious)
gap

# Corrected "not round trip" reading that explicitly keeps unknown ends.
non_round_including_unknown <- clean %>%
  filter(is.na(end_station_id) | end_station_id != start_station_id)
nrow(non_round_including_unknown)

# Preferred operational decomposition: keep unknown ends as their own category.
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

# -----------------------------
# Part 4: features
# -----------------------------
clean <- clean %>%
  mutate(
    month = factor(months(start_time), levels = month.name),
    hour = as.integer(format(start_time, "%H"))
  ) %>%
  mutate(
    is_evening = hour >= 16
  )

mean(clean$is_evening)

# -----------------------------
# Part 5: casual share
# -----------------------------
mix <- clean %>%
  group_by(month) %>%
  summarise(
    trips = n(),
    casual_pct = 100 * mean(rider_type == "casual"),
    median_min = median(duration_min),
    .groups = "drop"
  )

print(mix, n = Inf)

june_to_july_drop <- mix %>%
  filter(month %in% c("June", "July")) %>%
  summarise(drop_pp = casual_pct[month == "June"] - casual_pct[month == "July"])
june_to_july_drop

june_to_december_median_drop <- mix %>%
  filter(month %in% c("June", "December")) %>%
  summarise(drop_min = median_min[month == "June"] - median_min[month == "December"])
june_to_december_median_drop

# -----------------------------
# Part 6: arrivals per dock
# -----------------------------
arrivals <- clean %>%
  count(end_station_id, name = "arrivals")

head(arrivals)

arrivals %>%
  filter(is.na(end_station_id))

pressure <- arrivals %>%
  filter(!is.na(end_station_id)) %>%
  left_join(stations, by = c("end_station_id" = "station_id")) %>%
  mutate(
    arrivals_per_dock = round(arrivals / docks, 1)
  ) %>%
  arrange(desc(arrivals_per_dock))

pressure %>%
  select(station_name, neighborhood, docks, arrivals, arrivals_per_dock) %>%
  slice_head(n = 5)

pressure %>%
  select(station_name, neighborhood, docks, arrivals, arrivals_per_dock) %>%
  slice_tail(n = 3)

pressure_ratio <- max(pressure$arrivals_per_dock) /
  min(pressure$arrivals_per_dock)
pressure_ratio

sum(pressure$arrivals)
nrow(clean)
nrow(clean) - sum(pressure$arrivals)

# -----------------------------
# Shared plotting theme
# -----------------------------
ops_theme <- theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 17),
    plot.subtitle = element_text(size = 12),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

dir.create("figs", showWarnings = FALSE)

# -----------------------------
# Part 7: Figure 1 - casual mix over time
# -----------------------------
fig1 <- ggplot(mix, aes(x = month, y = casual_pct, group = 1)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  # July 1 is the boundary between June (position 6) and July (position 7).
  geom_vline(xintercept = 6.5, linetype = "dashed", linewidth = 0.7) +
  annotate(
    "text",
    x = 6.65,
    y = max(mix$casual_pct) * 0.92,
    label = "July 1",
    hjust = 0
  ) +
  scale_y_continuous(
    limits = c(0, NA),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title = "Casual riders become a smaller share after June",
    subtitle = "The mix shifts sharply toward members in the second half of 2025",
    x = NULL,
    y = "Casual share of monthly trips (%)",
    caption = "Denominator: all cleaned trips in each month."
  ) +
  ops_theme

fig1

# -----------------------------
# Part 8: Figure 2 - arrival pressure
# -----------------------------
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
  scale_y_continuous(
    limits = c(0, NA),
    labels = scales::label_comma()
  ) +
  labs(
    title = "Arrival pressure is concentrated at a few high-use docks",
    subtitle = "Annual arrivals per dock identify where bikes accumulate most heavily",
    x = NULL,
    y = "Annual arrivals per dock",
    fill = "Neighborhood",
    caption = "Denominator: 244,241 cleaned trips with a recorded end station."
  ) +
  ops_theme

fig2

# -----------------------------
# Part 9: Figure 3 - duration by bike type
# -----------------------------
bike_medians <- clean %>%
  group_by(bike_type) %>%
  summarise(
    median_min = median(duration_min),
    .groups = "drop"
  )

bike_medians

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

fig3

# -----------------------------
# Part 10: Figure 4 - daily rhythm
# -----------------------------
hourly_bike <- clean %>%
  count(hour, bike_type, name = "trips")

fig4 <- ggplot(hourly_bike, aes(x = hour, y = trips)) +
  geom_col() +
  facet_wrap(~ bike_type, scales = "fixed") +
  scale_x_continuous(breaks = seq(0, 23, by = 3)) +
  scale_y_continuous(limits = c(0, NA), labels = scales::label_comma()) +
  labs(
    title = "Both bike types peak at 5 PM, but classic-bike volume is higher",
    subtitle = "Fixed y-scales preserve the true difference in trip volume between panels",
    x = "Hour of day",
    y = "Trips",
    caption = "Denominator: all 247,967 cleaned trips, grouped by start hour and bike type."
  ) +
  ops_theme

fig4

# Required comparison only; do not save this free-scale version.
fig4_free <- ggplot(hourly_bike, aes(x = hour, y = trips)) +
  geom_col() +
  facet_wrap(~ bike_type, scales = "free_y") +
  scale_x_continuous(breaks = seq(0, 23, by = 3)) +
  labs(
    title = "Free y-scales hide the difference in bike-type volume",
    x = "Hour of day",
    y = "Trips"
  ) +
  ops_theme

fig4_free

peak_by_bike <- hourly_bike %>%
  group_by(bike_type) %>%
  slice_max(trips, n = 1, with_ties = FALSE) %>%
  ungroup()

peak_by_bike

# -----------------------------
# Part 11: save required figures
# -----------------------------
ggsave(
  "figs/01_casual_share.png",
  plot = fig1,
  width = 9,
  height = 6,
  dpi = 300,
  bg = "white"
)

ggsave(
  "figs/02_arrivals_per_dock.png",
  plot = fig2,
  width = 10,
  height = 9,
  dpi = 300,
  bg = "white"
)

ggsave(
  "figs/03_duration_by_bike.png",
  plot = fig3,
  width = 8,
  height = 6,
  dpi = 300,
  bg = "white"
)

ggsave(
  "figs/04_daily_rhythm.png",
  plot = fig4,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

list.files("figs", pattern = "\\.png$")

# -----------------------------
# Part 12 challenge (+5)
# -----------------------------

# C1: duration distribution by rider type
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

# C2: arrivals minus departures
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

net_flow %>%
  select(station_id, station_name, arrivals, departures, net_flow) %>%
  slice_head(n = 5)

net_flow %>%
  select(station_id, station_name, arrivals, departures, net_flow) %>%
  slice_tail(n = 5)

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
