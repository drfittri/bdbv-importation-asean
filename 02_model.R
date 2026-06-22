# ============================================================
# 02_model.R
# BDBV Importation Risk - Malaysia / ASEAN
# Faithful re-implementation of the ECDC SEI1I2RD importation model
# Source: code.europa.eu/ecdc/ebola_importation_risk (ECDC GitLab)
#         Authors: Bons, Gomes Dias, Hansson, Kuhlmann Berenzon, Prasse
#         Created 2026-05-27, last update 2026-06-12
# ============================================================
# The model has two stages:
#   1. SEI1I2RD compartmental ODE (6-compartment transmission model)
#      with Monte Carlo sampling over parameter uncertainty
#   2. State-dependent importation step combining exposed/infectious
#      counts with traveller scenarios
# ============================================================

library(tidyverse)
library(deSolve)
library(here)
library(zoo)
set.seed(20260622)

# ============================================================
# SECTION 1: PARAMETERS (from ECDC parameters.R, verified)
# ============================================================

# Demographics
population <- 13392200  # Ituri + North Kivu (McCabe et al. / ECDC)

# R0 - basic reproduction number
# ECDC code: mean of grEPI highest values (1.37 + 1.11) / 2 = 1.24
R0_mean <- (1.37 + 1.11) / 2
R0_sd <- 0.1

# Probability of dying given case: uniform distribution
p_death_min <- 0.32  # MacNeil et al. J Infect Dis 2011
p_death_max <- 0.54  # Rosello et al. eLife 2015

# Incubation period (days)
incubation_mean <- 10
incubation_lower <- 2
incubation_upper <- 21

# Presymptomatic period (days, Velasquez et al. Clin Infect Dis 2015)
duration_presymptomatic <- 6.22

# Infectious period when recovering (days)
infectious_mean <- 10
infectious_lower <- 2
infectious_upper <- 26

# Infectious period when dying (days)
death_mean <- 10
death_lower <- 3
death_upper <- 21

# Dark factor: fraction of deaths not reported
# 1 - (204/1054) = 0.8064516 (from suspected deaths and total cases as of 22 May 2026)
dark_factor_death <- 0.806

# Travel parameters
ratio_p_I_given_travel_vs_p_travel <- 1
prob_detection_E <- 0.1  # dry symptoms: low detection (fever easy to hide)
prob_detection_I <- 0.9  # wet symptoms: high detection (too sick to travel)

# Traveller scenarios: per-year equivalent for 10, 25, 50, 75, 100 over 15 days
# ECDC code: travelers_per_year = c(10, 25, 50, 75, 100) * 365 / 15
travelers_per_year <- c(10, 25, 50, 75, 100) * 365 / 15

# Simulation settings
n_sim <- 10000  # ECDC used 500; we use 10000 for tighter UIs

# Study window (same as ECDC: start 18 May 2026, forecast 15 days from 10 Jun)
# ECDC run_SEI1I2RD.R: today = 2026-06-10, start_date = 2026-05-18
today_date <- as.Date("2026-06-10")
start_date <- as.Date("2026-05-18")
end_date <- today_date + 15
model_dates <- seq(from = start_date, to = end_date, by = "day")
times <- seq(0, length(model_dates) - 1, by = 1)

# ============================================================
# SECTION 2: HELPER FUNCTIONS (from ECDC helper.R)
# ============================================================

# Gamma distribution fitting from mean + lower/upper bounds
gamma_distribution <- function(Nsim, mean, lower, upper, level) {
  target_mean <- mean
  target_qL <- lower
  target_qU <- upper

  objective_gamma <- function(par) {
    shape <- exp(par[1])
    scale <- exp(par[2])

    mean_est <- shape * scale
    qL_est <- qgamma((1 - level) / 2, shape, scale = scale)
    qU_est <- qgamma(1 - (1 - level) / 2, shape, scale = scale)

    err <- (log(mean_est) - log(target_mean))^2 +
      (log(qL_est) - log(target_qL))^2 +
      (log(qU_est) - log(target_qU))^2

    return(err)
  }

  fit_g <- optim(c(log(2), log(5)), objective_gamma)

  shape <- exp(fit_g$par[1])
  scale <- exp(fit_g$par[2])

  return(rgamma(Nsim, shape = shape, scale = scale))
}

# Summarise compartment across MC runs
summarise_compartment <- function(df, value_col) {
  wide <- df |>
    pivot_wider(names_from = sim, values_from = {{ value_col }})

  mat <- t(as.matrix(wide[, -1]))

  data.frame(
    time = wide$time,
    median = apply(mat, 2, median, na.rm = TRUE),
    lower = apply(mat, 2, quantile, probs = 0.05, na.rm = TRUE),
    upper = apply(mat, 2, quantile, probs = 0.95, na.rm = TRUE)
  )
}

# ============================================================
# SECTION 3: GET CASES (from ECDC get_cases.R)
# Extracts suspected deaths from INSP SitRep for Ituri + North Kivu
# and back-calculates total cases using dark factor
# ============================================================

cat("Loading suspected deaths from INSP SitRep...\n")

sdeaths_LL <- read.csv(here("data", "raw",
                            "insp_sitrep__cumulative_suspected_deaths__daily.csv"))

# Health zones in Ituri + North Kivu (per ECDC get_cases.R)
ituri_nk <- c(
  # Ituri
  "Mongbalu", "Rwampara", "Bunia", "Nyakunde", "Nyankunde",
  "Bambu", "Nizi", "Kilo", "Aru", "Fataki", "Mambasa",
  # North Kivu
  "Goma", "Katwa", "Butembo", "Oicha", "Kalunguta", "Karisimbi",
  "Kyondo", "Miti-Murhesa"
)

df_ituri_NK <- sdeaths_LL |>
  filter(nom %in% ituri_nk)

daily_total <- df_ituri_NK |>
  mutate(
    date = as.Date(date, format = "%Y-%m-%d"),
    cumulative_suspected_deaths = na_if(cumulative_suspected_deaths, "ND"),
    cumulative_suspected_deaths = as.numeric(cumulative_suspected_deaths)
  ) |>
  group_by(date) |>
  summarise(
    total_cumulative = if (all(is.na(cumulative_suspected_deaths))) NA_real_
    else sum(cumulative_suspected_deaths, na.rm = TRUE)
  ) |>
  arrange(date)

# Take latest value if some new values are lower (not possible cumulatively)
daily_total <- daily_total |>
  arrange(date) |>
  mutate(
    total_cumulative = zoo::na.locf(total_cumulative, na.rm = FALSE),
    total_cumulative = cummax(total_cumulative)
  )

# Fill missing dates
daily_total_filled <- daily_total |>
  complete(date = seq(min(date), max(date), by = "day")) |>
  arrange(date) |>
  fill(total_cumulative, .direction = "down")

# Back-calculate cases from deaths using dark factor
daily_total_filled <- daily_total_filled |>
  mutate(
    daily_deaths = total_cumulative - lag(total_cumulative)
  )
daily_total_filled$daily_deaths[1] <- daily_total_filled$total_cumulative[1]

daily_total_filled <- daily_total_filled |>
  mutate(
    daily_cases = daily_deaths / (1 - dark_factor_death)
  )

daily_total_filled <- daily_total_filled |>
  mutate(
    cumulative_cases = cumsum(daily_cases)
  )

# Filter to simulation start (after 2026-05-17)
daily_total_filled <- daily_total_filled |> filter(date > "2026-05-17")

cat("Suspected deaths data loaded:", nrow(daily_total_filled), "rows\n")
cat("Date range:", as.character(min(daily_total_filled$date)), "to",
    as.character(max(daily_total_filled$date)), "\n")

# Extract initial conditions (as per ECDC run_SEI1I2RD.R)
# Values at 22 May 2026
Total_cases_may22 <- daily_total_filled$cumulative_cases[
  which(daily_total_filled$date == "2026-05-22")
]
Suspected_deaths_may22 <- daily_total_filled$total_cumulative[
  which(daily_total_filled$date == "2026-05-22")
]
Initial_cumulative_cases <- daily_total_filled$cumulative_cases[1]

cat("Total estimated cases at 22 May:", Total_cases_may22, "\n")
cat("Suspected deaths at 22 May:", Suspected_deaths_may22, "\n")
cat("Initial cumulative cases (18 May):", Initial_cumulative_cases, "\n")

# Dark factor (recalculated from data, should match 0.806)
dark_factor <- 1 - Suspected_deaths_may22 / Total_cases_may22
cat("Dark factor (data-derived):", round(dark_factor, 4), "\n")

N <- population

# ============================================================
# SECTION 4: SEI1I2RD MONTE CARLO TRANSMISSION MODEL
# (from ECDC SEI1I2RD_MC_function.R, faithfully ported)
# ============================================================

ebola_sim <- function(n_sim, N, times) {

  # Draw parameter values from assigned distributions
  # 1. R0
  R0_vals <- rnorm(n_sim, mean = R0_mean, sd = R0_sd)
  # 2. Probability of dying
  p_death_vals <- runif(n_sim, min = p_death_min, max = p_death_max)
  # 3. Incubation period
  incubation_vals <- gamma_distribution(
    Nsim = n_sim, mean = incubation_mean,
    lower = incubation_lower, upper = incubation_upper, level = 0.99
  )
  # 4. Infectious period (recovery)
  infectious_vals <- gamma_distribution(
    Nsim = n_sim, mean = infectious_mean,
    lower = infectious_lower, upper = infectious_upper, level = 0.99
  )
  # 5. Time from symptoms to death (if dying)
  death_delay_vals <- gamma_distribution(
    Nsim = n_sim, mean = death_mean,
    lower = death_lower, upper = death_upper, level = 0.99
  )

  results_list <- list()

  for (i in 1:n_sim) {

    # Draw parameters
    incubation_period <- max(1, incubation_vals[i])
    infectious_period <- max(1, infectious_vals[i])
    symptom_to_death_period <- max(1, death_delay_vals[i])

    p_death <- p_death_vals[i]
    R0_value <- max(R0_vals[i], 1)

    # Create rates
    sigma <- 1 / incubation_period
    gamma <- 1 / infectious_period
    mu <- 1 / symptom_to_death_period
    beta <- R0_value / ((1 - p_death) * (1 / gamma) + p_death * (1 / mu))

    # Initial numbers in each compartment
    D_init <- daily_total_filled$total_cumulative[1]
    R_init <- (1 - p_death) * D_init / p_death

    I_total <- Initial_cumulative_cases - D_init - R_init

    IR_init <- I_total * (1 - p_death)
    ID_init <- I_total * p_death

    # Linearised system eigenvalue for E_init
    A <- matrix(c(
      -sigma, beta, beta,
      (1 - p_death) * sigma, -gamma, 0,
      p_death * sigma, 0, -mu
    ), nrow = 3, byrow = TRUE)

    eigenvalues <- eigen(A)$values
    largest_eigen <- max(Re(eigenvalues))

    part_R <- (1 - p_death) * sigma / (gamma + largest_eigen)
    part_D <- p_death * mu / (mu + largest_eigen)

    E_init <- I_total / (part_R + part_D)

    S_init <- N - IR_init - ID_init - E_init - R_init - D_init
    params <- c(beta = beta, sigma = sigma, gamma = gamma,
                mu = mu, p_death = p_death)

    # Initial state
    state <- c(S = S_init, E = E_init, IR = IR_init,
               ID = ID_init, R = R_init, D = D_init)

    # ODE model
    seir_model <- function(time, state, params) {
      with(as.list(c(state, params)), {
        dS <- -beta * S * (IR + ID) / N
        dE <- beta * S * (IR + ID) / N - sigma * E
        dIR <- (1 - p_death) * sigma * E - gamma * IR
        dID <- p_death * sigma * E - mu * ID
        dR <- gamma * IR
        dD <- mu * ID
        return(list(c(dS, dE, dIR, dID, dR, dD)))
      })
    }

    # Run ODE
    out <- ode(y = state, times = times, func = seir_model, parms = params)
    out <- as.data.frame(out)
    out$sim <- i

    results_list[[i]] <- out

    if (i %% 1000 == 0) cat("  MC iteration", i, "/", n_sim, "\n")
  }

  results <- do.call(rbind, results_list)

  # Extract results
  S_df <- results[, c("time", "sim", "S")]
  E_df <- results[, c("time", "sim", "E")]
  IR_df <- results[, c("time", "sim", "IR")]
  ID_df <- results[, c("time", "sim", "ID")]
  I_df <- IR_df[, c(1, 2)]
  I_df$I <- IR_df$IR + ID_df$ID

  R_df <- results[, c("time", "sim", "R")]
  D_df <- results[, c("time", "sim", "D")]

  Total_cumul_cases_df <- IR_df[, c(1, 2)]
  Total_cumul_cases_df$total_cumulative <- N - S_df$S - E_df$E

  Susceptible_df <- summarise_compartment(S_df, S)
  Exposed_df <- summarise_compartment(E_df, E)
  Infectious_df <- summarise_compartment(I_df, I)
  Recovered_df <- summarise_compartment(R_df, R)
  Dead_df <- summarise_compartment(D_df, D)
  Total_cumulative_df <- summarise_compartment(Total_cumul_cases_df,
                                               total_cumulative)

  return(list(
    Susceptible = Susceptible_df,
    Exposed = Exposed_df,
    Infectious = Infectious_df,
    Recovered = Recovered_df,
    Dead = Dead_df,
    Total_cumulative = Total_cumulative_df
  ))
}

# ============================================================
# SECTION 5: RUN SIMULATION
# ============================================================

cat("\nRunning SEI1I2RD Monte Carlo simulation (n_sim =", n_sim, ")...\n")
simulation_df <- ebola_sim(n_sim = n_sim, N = N, times = times)

Susceptible_df <- simulation_df$Susceptible
Infectious_df <- simulation_df$Infectious
Exposed_df <- simulation_df$Exposed
Dead_df <- simulation_df$Dead
Total_cumulative_df <- simulation_df$Total_cumulative

cat("Simulation complete.\n")
cat("Exposed (median) at t=0:", round(Exposed_df$median[1], 1), "\n")
cat("Infectious (median) at t=0:", round(Infectious_df$median[1], 1), "\n")
cat("Exposed (median) at day 23 (10 Jun):", round(Exposed_df$median[24], 1), "\n")
cat("Infectious (median) at day 23 (10 Jun):",
    round(Infectious_df$median[24], 1), "\n")

# ============================================================
# SECTION 6: IMPORTATION RISK (from ECDC E_and_I_to_risk.R)
# ============================================================

E_and_I_to_risk_one_region <- function(
    E_vector, I_vector, N_i, N_out_i, par) {
  prob_E_given_passenger <- E_vector / N_i * (1 - par$prob_detection_E)
  prob_I_given_passenger <- I_vector / N_i *
    par$ratio_p_I_given_travel_vs_p_travel * (1 - par$prob_detection_I)

  prob_importation <- 1 - (1 - prob_E_given_passenger -
                             prob_I_given_passenger)^N_out_i
  return(prob_importation)
}

E_and_I_to_risk <- function(E_matrix, I_matrix, N_all, N_out, par) {
  n_days <- ncol(E_matrix)
  N_regions <- nrow(E_matrix)

  p_import_vs_t <- array(NA, dim = c(n_days, N_regions))

  for (region_i in 1:N_regions) {
    N_i <- N_all[region_i]
    N_out_i <- N_out[, region_i]

    p_import_vs_t[, region_i] <- E_and_I_to_risk_one_region(
      E_vector = E_matrix[region_i, ],
      I_vector = I_matrix[region_i, ],
      N_i = N_i,
      N_out_i = N_out_i,
      par = par
    )
  }

  return(p_import_vs_t)
}

# ============================================================
# SECTION 7: COMPUTE IMPORTATION PROBABILITIES
# (from ECDC importation_risk_report.Rmd, faithfully ported)
# ============================================================

cat("\nComputing importation probabilities...\n")

n_days <- length(times)

# traveller scenarios: lower, median, upper for each traveller count
# ECDC code: travelers_per_year = c(10, 25, 50, 75, 100) * 365 / 15
# So 10 travellers in 15 days = 10*365/15 per year = 243.3 per year
# Daily travellers = travelers_per_year / 365
N_samples <- 3 * length(travelers_per_year)
colnames_vec <- as.vector(outer(
  c("lower_", "median_", "upper_"),
  travelers_per_year, paste0
))
N_all <- rep(population, N_samples)

# Outbound travellers per day for each scenario
N_out <- t(array(rep(travelers_per_year[1] / 365, 3 * n_days,
                     replace = TRUE), dim = c(3, n_days)))
for (i in 2:length(travelers_per_year)) {
  N_out <- cbind(N_out, t(array(
    rep(travelers_per_year[i] / 365, 3 * n_days, replace = TRUE),
    dim = c(3, n_days)
  )))
}

# Adjust prob_detection_E for fraction of incubation with dry symptoms
# ECDC code: prob_detection_E * ((incubation_mean - duration_presymptomatic) / incubation_mean)
prob_detection_E_adj <- prob_detection_E *
  ((incubation_mean - duration_presymptomatic) / incubation_mean)

cat("Adjusted prob_detection_E:", round(prob_detection_E_adj, 4), "\n")
cat("prob_detection_I:", prob_detection_I, "\n")

# Build E and I matrices (rows = scenarios, cols = days)
E_matrix <- do.call(
  cbind,
  rep(list(Exposed_df[, c("lower", "median", "upper")]),
      length(travelers_per_year))
) |>
  setNames(colnames_vec) |>
  as.matrix() |>
  t()

I_matrix <- do.call(
  cbind,
  rep(list(Infectious_df[, c("lower", "median", "upper")]),
      length(travelers_per_year))
) |>
  setNames(colnames_vec) |>
  as.matrix() |>
  t()

# Calculate daily importation risk for each scenario
p_import_vs_t <- E_and_I_to_risk(
  E_matrix = E_matrix,
  I_matrix = I_matrix,
  N_all = N_all,
  N_out = N_out,
  par = tibble(
    ratio_p_I_given_travel_vs_p_travel = ratio_p_I_given_travel_vs_p_travel,
    prob_detection_E = prob_detection_E_adj,
    prob_detection_I = prob_detection_I
  )
)
colnames(p_import_vs_t) <- colnames_vec
p_import_vs_t <- as.data.frame(p_import_vs_t) |>
  mutate(time = times, date = model_dates)

# ============================================================
# SECTION 8: CUMULATIVE IMPORTATION PROBABILITY
# (from ECDC Rmd: 1 - prod(1 - p) over 15-day window)
# ============================================================

# Filter to study window: 11-25 June 2026 (15 days from 10 Jun)
# ECDC uses date >= today (10 Jun) and date < today + 15
p_import_plot_df <- p_import_vs_t |>
  filter(date >= today_date) |>
  pivot_longer(
    cols = -c(time, date),
    names_to = "scenario", values_to = "probability"
  ) |>
  separate(scenario, into = c("statistic", "travellers"), sep = "_") |>
  pivot_wider(names_from = statistic, values_from = probability) |>
  mutate(travellers = as.numeric(travellers) * 15 / 365)

# Cumulative: 1 - product(1 - p) over study window
cumulative_results <- p_import_plot_df |>
  filter(date >= today_date & date <= today_date + 15) |>
  group_by(travellers) |>
  summarise(
    median = 1 - prod(1 - median),
    lower = 1 - prod(1 - lower),
    upper = 1 - prod(1 - upper)
  ) |>
  arrange(median) |>
  mutate(
    median_pct = round(median * 100, 4),
    lower_pct = round(lower * 100, 4),
    upper_pct = round(upper * 100, 4),
    travellers_per_import = round(1 / median, 0)
  )

cat("\n=== CUMULATIVE IMPORTATION PROBABILITY (15-day window) ===\n")
print(cumulative_results)

# ============================================================
# SECTION 9: PER-TRAVELLER RISK
# (from ECDC Rmd: 1 / ((E/N)*(1-p_E) + (I/N)*(1-p_I)))
# ============================================================

per_travel_risk <- 1 / (
  (Exposed_df / population) * (1 - prob_detection_E_adj) +
    (Infectious_df / population) * (1 - prob_detection_I)
)

per_travel_risk <- per_travel_risk |>
  mutate(date = model_dates) |>
  mutate(
    per_travel_prob = 1 / median,
    per_travel_prob_lower = 1 / upper,
    per_travel_prob_upper = 1 / lower
  )

# Average per-traveller risk over the 15-day window
per_travel_risk_cumulative <- per_travel_risk |>
  filter(date >= today_date & date < today_date + 15) |>
  summarise(
    median = median(median),
    upper = median(upper),
    lower = median(lower)
  ) |>
  rename(Median = median, Lower = upper, Upper = lower) |>
  mutate(across(c(Median, Lower, Upper), round))

cat("\n=== PER-TRAVELLER RISK (avg over 15-day window) ===\n")
print(per_travel_risk_cumulative)

# ============================================================
# SECTION 10: VALIDATION AGAINST ECDC PUBLISHED ESTIMATE
# ============================================================

cat("\n=== VALIDATION: ECDC published 0.45% (90% UI 0.20-0.85%) for 100 travellers ===\n")
val_100 <- cumulative_results |> filter(abs(travellers - 100) < 1)
cat(sprintf(
  "Our result (100 travellers): %.2f%% (90%% UI: %.2f%% - %.2f%%)\n",
  val_100$median_pct, val_100$lower_pct, val_100$upper_pct
))
cat(sprintf(
  "ECDC published:              0.45%% (90%% UI: 0.20%% - 0.85%%)\n"
))

val_10 <- cumulative_results |> filter(abs(travellers - 10) < 1)
cat(sprintf(
  "Our result (10 travellers):  %.3f%% (90%% UI: %.3f%% - %.3f%%)\n",
  val_10$median_pct, val_10$lower_pct, val_10$upper_pct
))
cat("ECDC published (10):         0.05% (90% UI: 0.02% - 0.09%)\n")

# ============================================================
# SECTION 11: SAVE MAIN RESULTS
# ============================================================

# Save cumulative results for all traveller scenarios
write_csv(
  cumulative_results |>
    select(travellers, median_pct, lower_pct, upper_pct, travellers_per_import),
  here("output", "importation_results.csv")
)
cat("\nMain results saved to output/importation_results.csv\n")

# Save model trajectories (E and I over time)
trajectory_df <- tibble(
  date = model_dates,
  exposed_median = Exposed_df$median,
  exposed_lower = Exposed_df$lower,
  exposed_upper = Exposed_df$upper,
  infectious_median = Infectious_df$median,
  infectious_lower = Infectious_df$lower,
  infectious_upper = Infectious_df$upper,
  dead_median = Dead_df$median,
  dead_lower = Dead_df$lower,
  dead_upper = Dead_df$upper,
  total_cumulative_median = Total_cumulative_df$median,
  total_cumulative_lower = Total_cumulative_df$lower,
  total_cumulative_upper = Total_cumulative_df$upper
)
write_csv(trajectory_df, here("output", "model_trajectory.csv"))
cat("Model trajectory saved to output/model_trajectory.csv\n")

# Save per-traveller risk
per_travel_summary <- per_travel_risk |>
  filter(date >= today_date & date < today_date + 15) |>
  summarise(
    per_travel_prob = median(per_travel_prob),
    per_travel_prob_lower = median(per_travel_prob_lower),
    per_travel_prob_upper = median(per_travel_prob_upper)
  )
write_csv(per_travel_summary, here("output", "per_traveller_risk.csv"))
cat("Per-traveller risk saved to output/per_traveller_risk.csv\n")

# ============================================================
# SECTION 12: MALAYSIA / ASEAN SCENARIO ANALYSIS
# ============================================================
# ECDC's per-traveller importation probability is destination-independent
# (ECDC: "the underlying per-traveller probabilities are independent
# of the destination"). We apply the same model to ASEAN traveller
# scenarios using the exact same E(t) and I(t) trajectories.

cat("\n=== MALAYSIA / ASEAN SCENARIO ANALYSIS ===\n")

# Load travel scenarios (skip CONTEXT lines at bottom of CSV)
travel <- read_csv(here("data", "processed", "travel_volumes.csv"),
                   show_col_types = FALSE, n_max = 8)

cat("Travel scenarios loaded:", nrow(travel), "rows\n")

# For each travel scenario row, compute cumulative importation probability
# using the same E/I trajectories and importation formula
# travel_volumes.csv columns:
#   origin, destination, destination_country, scenario_label,
#   travellers_2week_central, travellers_2week_low, travellers_2week_high

asean_results_list <- list()

for (j in 1:nrow(travel)) {
  row <- travel[j, ]

  # Daily travellers = 2-week total / 15 (ECDC uses 15-day window)
  n_out_central <- row$travellers_2week_central / 15
  n_out_low <- row$travellers_2week_low / 15
  n_out_high <- row$travellers_2week_high / 15

  # Compute daily importation probability for each bound
  # Using median E and I trajectories (as ECDC does for the summary table)
  E_vec <- Exposed_df$median
  I_vec <- Infectious_df$median
  E_vec_lo <- Exposed_df$lower
  I_vec_lo <- Infectious_df$lower
  E_vec_hi <- Exposed_df$upper
  I_vec_hi <- Infectious_df$upper

  # Daily p for central, lower, upper
  p_daily_central <- E_and_I_to_risk_one_region(
    E_vector = E_vec, I_vector = I_vec,
    N_i = population, N_out_i = rep(n_out_central, n_days),
    par = tibble(
      ratio_p_I_given_travel_vs_p_travel = ratio_p_I_given_travel_vs_p_travel,
      prob_detection_E = prob_detection_E_adj,
      prob_detection_I = prob_detection_I
    )
  )
  p_daily_low <- E_and_I_to_risk_one_region(
    E_vector = E_vec_lo, I_vector = I_vec_lo,
    N_i = population, N_out_i = rep(n_out_low, n_days),
    par = tibble(
      ratio_p_I_given_travel_vs_p_travel = ratio_p_I_given_travel_vs_p_travel,
      prob_detection_E = prob_detection_E_adj,
      prob_detection_I = prob_detection_I
    )
  )
  p_daily_high <- E_and_I_to_risk_one_region(
    E_vector = E_vec_hi, I_vector = I_vec_hi,
    N_i = population, N_out_i = rep(n_out_high, n_days),
    par = tibble(
      ratio_p_I_given_travel_vs_p_travel = ratio_p_I_given_travel_vs_p_travel,
      prob_detection_E = prob_detection_E_adj,
      prob_detection_I = prob_detection_I
    )
  )

  # Cumulative over 15-day study window (indices for 10 Jun - 24 Jun)
  # day 23 = 10 Jun (0-indexed: time=23)
  window_idx <- which(model_dates >= today_date &
                        model_dates <= today_date + 14)

  cum_median <- 1 - prod(1 - p_daily_central[window_idx])
  cum_lower <- 1 - prod(1 - p_daily_high[window_idx])  # high E/I = lower bound for travellers_per_import
  cum_upper <- 1 - prod(1 - p_daily_low[window_idx])   # low E/I = upper bound

  # Actually for UI: lower bound of prob = high E/I with low travellers
  # upper bound of prob = low E/I with high travellers
  # But ECDC approach: they report lower/median/upper from the MC draws
  # For scenario-based, we follow ECDC's pattern:
  # median uses median E/I + central travellers
  # lower uses lower E/I + low travellers (conservative: fewer infected, fewer travellers)
  # upper uses upper E/I + high travellers (worst case: more infected, more travellers)

  cum_lower_adj <- 1 - prod(1 - p_daily_low[window_idx])
  cum_upper_adj <- 1 - prod(1 - p_daily_high[window_idx])

  # Use the proper combination: low E/I + low travellers for lower bound
  # high E/I + high travellers for upper bound
  p_daily_lo_lo <- E_and_I_to_risk_one_region(
    E_vector = E_vec_lo, I_vector = I_vec_lo,
    N_i = population, N_out_i = rep(n_out_low, n_days),
    par = tibble(
      ratio_p_I_given_travel_vs_p_travel = ratio_p_I_given_travel_vs_p_travel,
      prob_detection_E = prob_detection_E_adj,
      prob_detection_I = prob_detection_I
    )
  )
  p_daily_hi_hi <- E_and_I_to_risk_one_region(
    E_vector = E_vec_hi, I_vector = I_vec_hi,
    N_i = population, N_out_i = rep(n_out_high, n_days),
    par = tibble(
      ratio_p_I_given_travel_vs_p_travel = ratio_p_I_given_travel_vs_p_travel,
      prob_detection_E = prob_detection_E_adj,
      prob_detection_I = prob_detection_I
    )
  )

  cum_lower_final <- 1 - prod(1 - p_daily_lo_lo[window_idx])
  cum_upper_final <- 1 - prod(1 - p_daily_hi_hi[window_idx])

  asean_results_list[[j]] <- tibble(
    origin = row$origin,
    destination = row$destination,
    destination_country = row$destination_country,
    scenario_label = row$scenario_label,
    travellers_2week = row$travellers_2week_central,
    p_import_median_pct = round(cum_median * 100, 4),
    p_import_lower_pct = round(cum_lower_final * 100, 4),
    p_import_upper_pct = round(cum_upper_final * 100, 4),
    travellers_per_import = if (!is.na(cum_median) && cum_median > 0) round(1 / cum_median, 0) else NA_integer_
  )

  cat(sprintf(
    "  %s -> %s (%s): %.4f%% (90%% UI: %.4f%% - %.4f%%)\n",
    row$origin, row$destination, row$scenario_label,
    cum_median * 100, cum_lower_final * 100, cum_upper_final * 100
  ))
}

asean_results_df <- bind_rows(asean_results_list)
write_csv(asean_results_df, here("output", "importation_results.csv"))
cat("\nASEAN results saved to output/importation_results.csv\n")

# ============================================================
# SECTION 13: MALAYSIA-SPECIFIC SENSITIVITY ANALYSIS
# ============================================================

cat("\n=== MALAYSIA SENSITIVITY ANALYSIS ===\n")

# Sensitivity dimensions:
# 1. Traveller count: 10, 25, 50, 100 (from travel_volumes.csv)
# 2. Outbreak growth: current, 50% growth, 100% growth
# 3. Ascertainment (dark factor): 0.806 (baseline), 0.70, 0.90
# 4. Travel reduction: baseline (p_E=0.1, p_I=0.9), optimistic (p_E=0.2, p_I=0.95),
#    pessimistic (p_E=0.05, p_I=0.8)

# We already have the full MC E/I trajectories. For sensitivity, we scale
# the E and I trajectories proportionally for growth scenarios.

malaysia_rows <- travel |> filter(grepl("Malaysia", destination))

# Define sensitivity scenarios
sensitivity_scenarios <- list(
  list(name = "Baseline",
       scale_E = 1.0, scale_I = 1.0,
       p_E = prob_detection_E_adj, p_I = prob_detection_I),
  list(name = "50% outbreak growth",
       scale_E = 1.5, scale_I = 1.5,
       p_E = prob_detection_E_adj, p_I = prob_detection_I),
  list(name = "100% outbreak growth",
       scale_E = 2.0, scale_I = 2.0,
       p_E = prob_detection_E_adj, p_I = prob_detection_I),
  list(name = "Higher ascertainment (dark=0.70)",
       scale_E = 1.0 / 0.70 * (1 - dark_factor_death),
       scale_I = 1.0 / 0.70 * (1 - dark_factor_death),
       p_E = prob_detection_E_adj, p_I = prob_detection_I),
  list(name = "Lower ascertainment (dark=0.90)",
       scale_E = 1.0 / 0.90 * (1 - dark_factor_death),
       scale_I = 1.0 / 0.90 * (1 - dark_factor_death),
       p_E = prob_detection_E_adj, p_I = prob_detection_I),
  list(name = "Optimistic travel screening",
       scale_E = 1.0, scale_I = 1.0,
       p_E = 0.2 * ((incubation_mean - duration_presymptomatic) / incubation_mean),
       p_I = 0.95),
  list(name = "Pessimistic travel screening",
       scale_E = 1.0, scale_I = 1.0,
       p_E = 0.05 * ((incubation_mean - duration_presymptomatic) / incubation_mean),
       p_I = 0.8)
)

malaysia_results_list <- list()

for (s in sensitivity_scenarios) {
  for (j in 1:nrow(malaysia_rows)) {
    row <- malaysia_rows[j, ]

    n_out_central <- row$travellers_2week_central / 15
    n_out_low <- row$travellers_2week_low / 15
    n_out_high <- row$travellers_2week_high / 15

    # Scale E and I
    E_vec <- Exposed_df$median * s$scale_E
    I_vec <- Infectious_df$median * s$scale_I
    E_vec_lo <- Exposed_df$lower * s$scale_E
    I_vec_lo <- Infectious_df$lower * s$scale_I
    E_vec_hi <- Exposed_df$upper * s$scale_E
    I_vec_hi <- Infectious_df$upper * s$scale_I

    par_s <- tibble(
      ratio_p_I_given_travel_vs_p_travel = ratio_p_I_given_travel_vs_p_travel,
      prob_detection_E = s$p_E,
      prob_detection_I = s$p_I
    )

    # Daily probabilities
    p_med <- E_and_I_to_risk_one_region(
      E_vector = E_vec, I_vector = I_vec,
      N_i = population, N_out_i = rep(n_out_central, n_days),
      par = par_s
    )
    p_lo <- E_and_I_to_risk_one_region(
      E_vector = E_vec_lo, I_vector = I_vec_lo,
      N_i = population, N_out_i = rep(n_out_low, n_days),
      par = par_s
    )
    p_hi <- E_and_I_to_risk_one_region(
      E_vector = E_vec_hi, I_vector = I_vec_hi,
      N_i = population, N_out_i = rep(n_out_high, n_days),
      par = par_s
    )

    window_idx <- which(model_dates >= today_date &
                          model_dates <= today_date + 14)

    cum_median <- 1 - prod(1 - p_med[window_idx])
    cum_lower <- 1 - prod(1 - p_lo[window_idx])
    cum_upper <- 1 - prod(1 - p_hi[window_idx])

    malaysia_results_list[[length(malaysia_results_list) + 1]] <- tibble(
      sensitivity_scenario = s$name,
      traveller_scenario = row$scenario_label,
      travellers_2week = row$travellers_2week_central,
      p_import_median_pct = round(cum_median * 100, 4),
      p_import_lower_pct = round(cum_lower * 100, 4),
      p_import_upper_pct = round(cum_upper * 100, 4)
    )
  }
}

malaysia_results_df <- bind_rows(malaysia_results_list)
write_csv(malaysia_results_df, here("output", "malaysia_results.csv"))
cat("Malaysia results saved to output/malaysia_results.csv\n")
cat("Rows:", nrow(malaysia_results_df), "\n")

# ============================================================
# SECTION 14: SUMMARY OUTPUT
# ============================================================

cat("\n")
cat("======================================================\n")
cat("PHASE 3 MODEL COMPLETE\n")
cat("======================================================\n")
cat("\n")
cat("Model: SEI1I2RD compartmental ODE (ECDC Annex 1)\n")
cat("MC iterations:", n_sim, "\n")
cat("Study window:", as.character(today_date), "to",
    as.character(today_date + 14), "(15 days)\n")
cat("Population N:", population, "\n")
cat("R0:", R0_mean, "(sd", R0_sd, ")\n")
cat("CFR range:", p_death_min, "-", p_death_max, "\n")
cat("Dark factor:", dark_factor_death, "\n")
cat("\n")
cat("Per-traveller risk (median, 15-day avg):",
    per_travel_risk_cumulative$Median, "\n")
cat("  90% UI:", per_travel_risk_cumulative$Lower, "-",
    per_travel_risk_cumulative$Upper, "\n")
cat("\n")
cat("ECDC validation (100 travellers):\n")
cat("  Our result:", val_100$median_pct, "% (90% UI:",
    val_100$lower_pct, "-", val_100$upper_pct, "%)\n")
cat("  ECDC published: 0.45% (90% UI: 0.20-0.85%)\n")
cat("\n")
cat("Output files:\n")
cat("  output/importation_results.csv  - ASEAN scenarios\n")
cat("  output/malaysia_results.csv     - Malaysia sensitivity\n")
cat("  output/model_trajectory.csv     - E/I/D trajectories\n")
cat("  output/per_traveller_risk.csv   - per-traveller risk\n")
cat("\n")
cat("DONE.\n")
