# =============================================================================
# 06_vecm_regional.R
# Regional subsample VECMs — Caribbean, Pacific, AIS
# Output: output/tables/06_vecm_regional.csv
# =============================================================================

library(tidyverse)
library(tsDyn)

# -----------------------------------------------------------------------------
# Load data
# -----------------------------------------------------------------------------

panel <- read_csv("data/master_panel.csv")

# -----------------------------------------------------------------------------
# Helper: estimate VECM for a subsample
# -----------------------------------------------------------------------------

run_regional_vecm <- function(data, region_label) {

  vecm_data <- data %>%
    dplyr::select(iso3, year,
                  debt, vulnerability, gdp_pc_ppp,
                  gdp_growth, current_account, inflation,
                  fiscal_balance, remittances) %>%
    na.omit()

  cat("\n--- Region:", region_label, "---\n")
  cat("Countries:", n_distinct(vecm_data$iso3), "\n")
  cat("Observations:", nrow(vecm_data), "\n")

  model <- VECM(
    vecm_data %>%
      dplyr::select(debt, vulnerability, gdp_pc_ppp),
    lag     = 2,
    r       = 1,
    estim   = "2OLS",
    include = "trend",
    exogen  = vecm_data %>%
      dplyr::select(gdp_growth, current_account, inflation,
                    fiscal_balance, remittances) %>%
      as.matrix()
  )

  beta  <- model$model.specific$beta
  coefs <- model$coefficients

  cat("Cointegrating vector:\n")
  print(round(beta, 4))

  tibble(
    region      = region_label,
    n_countries = n_distinct(vecm_data$iso3),
    n_obs       = nrow(vecm_data),
    vuln_beta   = beta[2],
    gdppc_beta  = beta[3],
    ect_debt    = coefs["Equation debt",          "ECT"],
    ect_vuln    = coefs["Equation vulnerability", "ECT"]
  )
}

# -----------------------------------------------------------------------------
# Run for each region
# -----------------------------------------------------------------------------

results_caribbean <- run_regional_vecm(
  panel %>% filter(region == "Caribbean"), "Caribbean"
)

results_pacific <- run_regional_vecm(
  panel %>% filter(region == "Pacific"), "Pacific"
)

results_ais <- run_regional_vecm(
  panel %>% filter(region == "AIS"), "AIS"
)

# -----------------------------------------------------------------------------
# Combined regional results table
# -----------------------------------------------------------------------------

regional_table <- bind_rows(
  results_caribbean,
  results_pacific,
  results_ais
)

cat("\n=== REGIONAL RESULTS SUMMARY ===\n")
print(regional_table)

# -----------------------------------------------------------------------------
# Save
# -----------------------------------------------------------------------------

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(regional_table, "output/tables/06_vecm_regional.csv")
cat("\nSaved: output/tables/06_vecm_regional.csv\n")
