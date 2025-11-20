#' @name 13_examples_data.R
#' @title Generate Synthetic Factorial Design Data
#' @description Generates synthetic data for three factorial design examples
#' and saves them as CSV files in workshops/

# Load required packages
library(dplyr)
library(tidyr)
library(readr)

# ============================================================================
# Example 1: Plant Growth Experiment (2^2 Factorial Design)
# ============================================================================

set.seed(123)
example1_plants = expand_grid(
  fertilizer = c("none", "added"),
  watering = c("daily", "weekly")
) %>%
  group_by(fertilizer, watering) %>%
  summarize(
    # Generate growth measurements (in cm) for 15 plants per treatment
    growth = rnorm(n = 15, 
                   mean = case_when(
                     # Base growth: 10 cm
                     # Fertilizer adds 5 cm
                     # Daily watering adds 3 cm
                     # Interaction: fertilizer + daily watering adds extra 2 cm
                     fertilizer == "none" & watering == "daily" ~ 10 + 3,
                     fertilizer == "none" & watering == "weekly" ~ 10,
                     fertilizer == "added" & watering == "daily" ~ 10 + 5 + 3 + 2,
                     fertilizer == "added" & watering == "weekly" ~ 10 + 5
                   ),
                   sd = 2),
    .groups = "drop"
  ) %>%
  mutate(id = seq_len(n())) %>%
  select(id, growth, fertilizer, watering)

# Save to CSV
write_csv(example1_plants, "workshops/plants.csv")


# ============================================================================
# Example 2: Battery Life Experiment (2^3 Factorial Design)
# ============================================================================

set.seed(456)
example2_batteries = expand_grid(
  battery_type = c("alkaline", "lithium"),
  temperature = c("cold", "warm"),
  usage = c("light", "heavy")
) %>%
  group_by(battery_type, temperature, usage) %>%
  summarize(
    # Generate battery life measurements (in hours) for 12 batteries per treatment
    life_hours = rnorm(n = 12,
                       mean = case_when(
                         # Base life: 20 hours
                         # Lithium adds 8 hours
                         # Warm temperature adds 5 hours
                         # Light usage adds 4 hours
                         # Two-way: lithium + warm adds 3 hours
                         # Two-way: lithium + light adds 2 hours
                         # Two-way: warm + light adds 1 hour
                         # Three-way: lithium + warm + light adds 2 hours
                         battery_type == "alkaline" & temperature == "cold" & usage == "light" ~ 20 + 4,
                         battery_type == "alkaline" & temperature == "cold" & usage == "heavy" ~ 20,
                         battery_type == "alkaline" & temperature == "warm" & usage == "light" ~ 20 + 5 + 4 + 1,
                         battery_type == "alkaline" & temperature == "warm" & usage == "heavy" ~ 20 + 5,
                         battery_type == "lithium" & temperature == "cold" & usage == "light" ~ 20 + 8 + 4 + 2,
                         battery_type == "lithium" & temperature == "cold" & usage == "heavy" ~ 20 + 8,
                         battery_type == "lithium" & temperature == "warm" & usage == "light" ~ 20 + 8 + 5 + 4 + 3 + 2 + 1 + 2,
                         battery_type == "lithium" & temperature == "warm" & usage == "heavy" ~ 20 + 8 + 5 + 3
                       ),
                       sd = 3),
    .groups = "drop"
  ) %>%
  mutate(id = seq_len(n())) %>%
  select(id, life_hours, battery_type, temperature, usage)

# Save to CSV
write_csv(example2_batteries, "workshops/batteries.csv")


# ============================================================================
# Example 3: Website Purchase Amount (2^3 Factorial Design)
# ============================================================================

set.seed(789)
example3_website = expand_grid(
  button_color = c("blue", "green"),
  layout = c("simple", "detailed"),
  headline = c("short", "long")
) %>%
  group_by(button_color, layout, headline) %>%
  summarize(
    # Generate purchase amounts (in dollars) for 20 visitors per treatment
    purchase_amount = rnorm(n = 20,
                            mean = case_when(
                              # Base purchase: $5
                              # Green button adds $2
                              # Simple layout adds $1.50
                              # Short headline adds $1
                              # Two-way: green + simple adds $0.50
                              # Two-way: green + short adds $0.30
                              # Two-way: simple + short adds $0.20
                              # Three-way: green + simple + short adds $0.80
                              button_color == "blue" & layout == "simple" & headline == "short" ~ 5 + 1.5 + 1 + 0.2,
                              button_color == "blue" & layout == "simple" & headline == "long" ~ 5 + 1.5,
                              button_color == "blue" & layout == "detailed" & headline == "short" ~ 5 + 1,
                              button_color == "blue" & layout == "detailed" & headline == "long" ~ 5,
                              button_color == "green" & layout == "simple" & headline == "short" ~ 5 + 2 + 1.5 + 1 + 0.5 + 0.3 + 0.2 + 0.8,
                              button_color == "green" & layout == "simple" & headline == "long" ~ 5 + 2 + 1.5 + 0.5,
                              button_color == "green" & layout == "detailed" & headline == "short" ~ 5 + 2 + 1 + 0.3,
                              button_color == "green" & layout == "detailed" & headline == "long" ~ 5 + 2
                            ),
                            sd = 1.5),
    .groups = "drop"
  ) %>%
  mutate(id = seq_len(n())) %>%
  select(id, purchase_amount, button_color, layout, headline)

# Save to CSV
write_csv(example3_website, "workshops/website.csv")


# ============================================================================
# Example 4: Bikeshare Usage (2^3 Fractional Factorial Design)
# ============================================================================
# 
# A transportation planner wants to test how three factors affect bikeshare
# usage, but can only run half the experiments (fractional factorial).
# They test 4 out of 8 possible combinations:
# - Factor A: Station location (downtown vs. residential)
# - Factor B: Bike type (standard vs. electric)
# - Factor C: Pricing (flat vs. per-minute)
#
# This is a 2^(3-1) fractional factorial design (half fraction).

set.seed(101)
# Create full factorial first
full_design = expand_grid(
  location = c("downtown", "residential"),
  bike_type = c("standard", "electric"),
  pricing = c("flat", "per_minute")
)

# Select half fraction: use combinations where location * bike_type * pricing = "high"
# This creates a balanced fractional design
example4_bikeshare = full_design %>%
  mutate(
    # Create a design generator: select runs where factors align
    # For a half fraction, we use: C = A * B (modulo 2)
    select_run = case_when(
      location == "downtown" & bike_type == "standard" & pricing == "flat" ~ TRUE,
      location == "downtown" & bike_type == "electric" & pricing == "per_minute" ~ TRUE,
      location == "residential" & bike_type == "standard" & pricing == "per_minute" ~ TRUE,
      location == "residential" & bike_type == "electric" & pricing == "flat" ~ TRUE,
      TRUE ~ FALSE
    )
  ) %>%
  filter(select_run) %>%
  select(-select_run) %>%
  group_by(location, bike_type, pricing) %>%
  summarize(
    # Generate daily rides per station for 18 days per treatment
    daily_rides = rnorm(n = 18,
                        mean = case_when(
                          # Base rides: 50 per day
                          # Downtown adds 15 rides
                          # Electric adds 10 rides
                          # Per-minute pricing adds 5 rides
                          # Two-way: downtown + electric adds 3 rides
                          # Note: In fractional factorial, some effects are confounded
                          location == "downtown" & bike_type == "standard" & pricing == "flat" ~ 50 + 15,
                          location == "downtown" & bike_type == "electric" & pricing == "per_minute" ~ 50 + 15 + 10 + 5 + 3,
                          location == "residential" & bike_type == "standard" & pricing == "per_minute" ~ 50 + 5,
                          location == "residential" & bike_type == "electric" & pricing == "flat" ~ 50 + 10
                        ),
                        sd = 4),
    .groups = "drop"
  ) %>%
  mutate(id = seq_len(n())) %>%
  select(id, daily_rides, location, bike_type, pricing)

# Save to CSV
write_csv(example4_bikeshare, "workshops/bikeshare.csv")


# ============================================================================
# Example 5: Drone Flight Time (3^2 Factorial Design)
# ============================================================================
#
# A drone engineer tests how two factors with three levels each affect
# flight time. This is a 3^2 design (2 factors, 3 levels each):
# - Factor A: Propeller size (small, medium, large)
# - Factor B: Battery capacity (low, medium, high)
#
# Note: The standard factorial functions work with 2-level factors.
# For 3-level factors, you may need to compare specific level pairs
# or use alternative analysis methods.

set.seed(202)
example5_drones = expand_grid(
  propeller = c("small", "medium", "large"),
  battery = c("low", "medium", "high")
) %>%
  group_by(propeller, battery) %>%
  summarize(
    # Generate flight time measurements (in minutes) for 10 flights per treatment
    flight_time = rnorm(n = 10,
                        mean = case_when(
                          # Base flight time: 15 minutes
                          # Medium propeller adds 3 minutes
                          # Large propeller adds 6 minutes
                          # Medium battery adds 4 minutes
                          # High battery adds 8 minutes
                          # Interaction: large propeller + high battery adds 2 minutes
                          propeller == "small" & battery == "low" ~ 15,
                          propeller == "small" & battery == "medium" ~ 15 + 4,
                          propeller == "small" & battery == "high" ~ 15 + 8,
                          propeller == "medium" & battery == "low" ~ 15 + 3,
                          propeller == "medium" & battery == "medium" ~ 15 + 3 + 4,
                          propeller == "medium" & battery == "high" ~ 15 + 3 + 8,
                          propeller == "large" & battery == "low" ~ 15 + 6,
                          propeller == "large" & battery == "medium" ~ 15 + 6 + 4,
                          propeller == "large" & battery == "high" ~ 15 + 6 + 8 + 2
                        ),
                        sd = 2.5),
    .groups = "drop"
  ) %>%
  mutate(id = seq_len(n())) %>%
  select(id, flight_time, propeller, battery)

# Save to CSV
write_csv(example5_drones, "workshops/drones.csv")

