# =============================================================================
# 03_vecm_baseline.R
# Baseline Panel VECM
# Endogenous I(1): debt, vulnerability, gdp_pc_ppp
# Exogenous I(0): gdp_growth, current_account, inflation
# Output: output/tables/03_vecm_baseline.csv
# =============================================================================

library(tidyverse)
library(tsDyn)

# -----------------------------------------------------------------------------
# Load data
# -----------------------------------------------------------------------------

panel <- read_csv("data/master_panel.csv")

# -----------------------------------------------------------------------------
# Prepare data
# -----------------------------------------------------------------------------

vecm_data <- panel %>%
  dplyr::select(iso3, year,
                debt, vulnerability, gdp_pc_ppp,
                gdp_growth, current_account, inflation) %>%
  na.omit()

cat("Observations:", nrow(vecm_data), "\n")
cat("Countries:", n_distinct(vecm_data$iso3), "\n")

# -----------------------------------------------------------------------------
# Estimate baseline VECM
# -----------------------------------------------------------------------------

pvecm_baseline <- VECM(
  vecm_data %>%
    dplyr::select(debt, vulnerability, gdp_pc_ppp),
  lag     = 2,
  r       = 1,
  estim   = "2OLS",
  include = "trend",
  exogen  = vecm_data %>%
    dplyr::select(gdp_growth, current_account, inflation) %>%
    as.matrix()
)

cat("\n=== BASELINE VECM SUMMARY ===\n")
summary(pvecm_baseline)

# -----------------------------------------------------------------------------
# Extract key results
# -----------------------------------------------------------------------------

# Cointegrating vector
beta <- pvecm_baseline$model.specific$beta
cat("\n=== COINTEGRATING VECTOR ===\n")
print(round(beta, 6))

# ECT and key coefficients
coefs <- pvecm_baseline$coefficients
cat("\n=== ECT COEFFICIENTS ===\n")
ect_table <- tibble(
  equation       = rownames(coefs),
  ect            = coefs[, "ECT"],
  ect_se         = NA_real_   # tsDyn does not store SE separately
)
print(ect_table)

# -----------------------------------------------------------------------------
# Save results table
# -----------------------------------------------------------------------------

results_baseline <- tibble(
  model          = "Baseline",
  n_obs          = nrow(vecm_data),
  vuln_beta      = beta[2],
  gdppc_beta     = beta[3],
  ect_debt       = coefs["Equation debt",          "ECT"],
  ect_vuln       = coefs["Equation vulnerability", "ECT"],
  ect_gdppc      = coefs["Equation gdp_pc_ppp",    "ECT"],
  gdp_growth_coef    = coefs["Equation debt", "gdp_growth"],
  current_acct_coef  = coefs["Equation debt", "current_account"],
  inflation_coef     = coefs["Equation debt", "inflation"]
)

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(results_baseline, "output/tables/03_vecm_baseline.csv")
cat("\nSaved: output/tables/03_vecm_baseline.csv\n")
