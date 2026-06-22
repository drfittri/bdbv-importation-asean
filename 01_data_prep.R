# =============================================================================
# 01_data_prep.R
# BDBV Importation Risk - Malaysia/ASEAN
# Phase 2, Step 14: Extract epidemiological parameters from INRB-UMIE/INSP data
#
# Inputs:  data/raw/insp_sitrep__national_cumulative_confirmed_{cases,deaths}__daily.csv
#          data/raw/who_don_series.csv (cross-validation)
#          data/raw/insp_sitrep__cumulative_confirmed_cases__daily.csv (provincial)
# Outputs: data/processed/epi_parameters.csv
#          data/processed/national_timeseries.csv
#          data/processed/provincial_latest.csv
# =============================================================================

set.seed(20260622)

pacman::p_load(tidyverse, lubridate, janitor, here)

# --- Load INSP national cumulative data ---
cases_nat <- read_csv(here("data", "raw", "insp_sitrep__national_cumulative_confirmed_cases__daily.csv"),
                      show_col_types = FALSE) |>
  clean_names() |>
  mutate(date = as_date(date))

deaths_nat <- read_csv(here("data", "raw", "insp_sitrep__national_cumulative_confirmed_deaths__daily.csv"),
                       show_col_types = FALSE) |>
  clean_names() |>
  mutate(date = as_date(date))

# Merge cases + deaths
nat_ts <- cases_nat |>
  select(date, confirmed_cases = national_cumulative_confirmed_cases) |>
  left_join(
    deaths_nat |> select(date, confirmed_deaths = national_cumulative_confirmed_deaths),
    by = "date"
  ) |>
  arrange(date) |>
  mutate(
    cfr = confirmed_deaths / confirmed_cases,
    cfr_pct = round(cfr * 100, 1)
  )

message("National time series: ", nrow(nat_ts), " rows, ",
        min(nat_ts$date), " to ", max(nat_ts$date))

# --- Cross-validate with WHO DON series ---
don <- read_csv(here("data", "raw", "who_don_series.csv"), show_col_types = FALSE) |>
  mutate(date = as_date(date))

# Check latest INSP vs WHO DON
insp_latest <- nat_ts |>
  filter(date == max(date)) |>
  select(date, insp_cases = confirmed_cases, insp_deaths = confirmed_deaths)

don_latest <- don |>
  filter(date == max(date)) |>
  select(date, don_cases = confirmed_cases, don_deaths = confirmed_deaths)

message("Latest INSP: ", insp_latest$date, " cases=", insp_latest$insp_cases,
        " deaths=", insp_latest$insp_deaths)

# --- Key parameters ---
latest_date <- max(nat_ts$date)
latest_cases <- nat_ts |> filter(date == latest_date) |> pull(confirmed_cases)
latest_deaths <- nat_ts |> filter(date == latest_date) |> pull(confirmed_deaths)
cfr <- latest_deaths / latest_cases

# Daily growth rate (r) from log-linear regression on cumulative confirmed cases
# Using all data points with confirmed_cases > 0
growth_df <- nat_ts |>
  filter(confirmed_cases > 0) |>
  mutate(date_num = as.numeric(date))

growth_model <- lm(log(confirmed_cases) ~ date_num, data = growth_df)
daily_growth_rate <- coef(growth_model)[["date_num"]]
doubling_time <- log(2) / daily_growth_rate
r_squared <- summary(growth_model)$r.squared

# Also compute growth rate for the ECDC study window proxy (last 15 days of data)
# ECDC window is 11-25 June; our data goes to 19 June
window_df <- nat_ts |>
  filter(date >= as_date("2026-06-05") & date <= as_date("2026-06-19")) |>
  filter(confirmed_cases > 0) |>
  mutate(date_num = as.numeric(date))

if (nrow(window_df) >= 3) {
  window_model <- lm(log(confirmed_cases) ~ date_num, data = window_df)
  daily_growth_rate_window <- coef(window_model)[["date_num"]]
  doubling_time_window <- log(2) / daily_growth_rate_window
} else {
  daily_growth_rate_window <- NA_real_
  doubling_time_window <- NA_real_
}

# R0 estimate (for reference, from ECDC Annex 3 Table A)
r0_ecdc <- 1.24

# --- Provincial breakdown (latest date) ---
prov_cases <- read_csv(here("data", "raw", "insp_sitrep__cumulative_confirmed_cases__daily.csv"),
                       show_col_types = FALSE) |>
  clean_names() |>
  mutate(date = as_date(date)) |>
  filter(date == latest_date) |>
  group_by(nom) |>
  summarise(cumulative_confirmed_cases = max(cumulative_confirmed_cases, na.rm = TRUE), .groups = "drop") |>
  arrange(desc(cumulative_confirmed_cases))

# --- Assemble parameter table ---
params <- tibble(
  parameter = c(
    "latest_date",
    "confirmed_cases",
    "confirmed_deaths",
    "cfr",
    "cfr_pct",
    "daily_growth_rate_r",
    "doubling_time_days",
    "growth_r_squared",
    "daily_growth_rate_r_window",
    "doubling_time_days_window",
    "r0_ecdc_reference",
    "ecdc_study_window",
    "outbreak_region_population_N"
  ),
  value = c(
    as.character(latest_date),
    as.character(latest_cases),
    as.character(latest_deaths),
    round(cfr, 4),
    round(cfr * 100, 2),
    round(daily_growth_rate, 6),
    round(doubling_time, 1),
    round(r_squared, 4),
    if_else(is.na(daily_growth_rate_window), "NA", as.character(round(daily_growth_rate_window, 6))),
    if_else(is.na(doubling_time_window), "NA", as.character(round(doubling_time_window, 1))),
    as.character(r0_ecdc),
    "2026-06-11 to 2026-06-25",
    "13392200"
  ),
  source = c(
    "INSP SitRep national cumulative",
    "INSP SitRep national cumulative",
    "INSP SitRep national cumulative",
    "confirmed_deaths / confirmed_cases",
    "confirmed_deaths / confirmed_cases * 100",
    "log-linear regression on cumulative cases",
    "log(2) / daily_growth_rate_r",
    "summary(growth_model)$r.squared",
    "log-linear regression, 5-19 Jun 2025",
    "log(2) / daily_growth_rate_r_window",
    "ECDC Annex 3 Table A (Choi et al. mean)",
    "ECDC brief",
    "McCabe et al. / ECDC Annex 3"
  )
)

# --- Save outputs ---
write_csv(params, here("data", "processed", "epi_parameters.csv"))
write_csv(nat_ts, here("data", "processed", "national_timeseries.csv"))
write_csv(prov_cases, here("data", "processed", "provincial_latest.csv"))

message("\n=== Epi Parameters ===")
print(params, n = Inf)

message("\n=== Provincial breakdown (latest: ", latest_date, ") ===")
print(prov_cases, n = Inf)

message("\n=== Growth model summary ===")
print(summary(growth_model))

message("\nOutputs saved:")
message("  data/processed/epi_parameters.csv")
message("  data/processed/national_timeseries.csv")
message("  data/processed/provincial_latest.csv")
