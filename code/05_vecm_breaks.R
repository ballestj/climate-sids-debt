# =============================================================================
# 05_vecm_breaks.R
# Panel VECM with structural break dummies
# Breaks: 2008-09 GFC, 2014-16 commodity shock, 2020-21 COVID
# Output: output/tables/05_vecm_breaks.csv
# =============================================================================

library(tidyverse)
library(tsDyn)

# -----------------------------------------------------------------------------
# Load data
# -----------------------------------------------------------------------------

panel <- read_csv("data/master_panel.csv")

# -----------------------------------------------------------------------------
# Add structural break dummies
# -----------------------------------------------------------------------------

panel <- panel %>%
  mutate(
    d_gfc   = as.integer(year >= 2008 & year <= 2009),
    d_comm  = as.integer(year >= 2014 & year <= 2016),
    d_covid = as.integer(year >= 2020 & year <= 2021)
  )

# -----------------------------------------------------------------------------
# Prepare data
# -----------------------------------------------------------------------------

vecm_data <- panel %>%
  dplyr::select(iso3, year,
                debt, vulnerability, gdp_pc_ppp,
                gdp_growth, current_account, inflation,
                fiscal_balance, remittances,
                d_gfc, d_comm, d_covid) %>%
  na.omit()

cat("Observations:", nrow(vecm_data), "\n")
cat("Countries:", n_distinct(vecm_data$iso3), "\n")

# -----------------------------------------------------------------------------
# Estimate VECM with breaks
# -----------------------------------------------------------------------------

pvecm_breaks <- VECM(
  vecm_data %>%
    dplyr::select(debt, vulnerability, gdp_pc_ppp),
  lag     = 2,
  r       = 1,
  estim   = "2OLS",
  include = "trend",
  exogen  = vecm_data %>%
    dplyr::select(gdp_growth, current_account, inflation,
                  fiscal_balance, remittances,
                  d_gfc, d_comm, d_covid) %>%
    as.matrix()
)

cat("\n=== VECM WITH STRUCTURAL BREAKS SUMMARY ===\n")
summary(pvecm_breaks)

# -----------------------------------------------------------------------------
# Extract results
# -----------------------------------------------------------------------------

beta  <- pvecm_breaks$model.specific$beta
coefs <- pvecm_breaks$coefficients

cat("\n=== COINTEGRATING VECTOR ===\n")
print(round(beta, 6))

cat("\n=== STRUCTURAL BREAK DUMMIES (DEBT EQUATION) ===\n")
cat("d_gfc:  ", round(coefs["Equation debt", "d_gfc"],  4), "\n")
cat("d_comm: ", round(coefs["Equation debt", "d_comm"], 4), "\n")
cat("d_covid:", round(coefs["Equation debt", "d_covid"],4), "\n")

# -----------------------------------------------------------------------------
# Save results
# -----------------------------------------------------------------------------

results_breaks <- tibble(
  model             = "With breaks",
  n_obs             = nrow(vecm_data),
  vuln_beta         = beta[2],
  gdppc_beta        = beta[3],
  ect_debt          = coefs["Equation debt",          "ECT"],
  ect_vuln          = coefs["Equation vulnerability", "ECT"],
  gdp_growth_coef   = coefs["Equation debt", "gdp_growth"],
  current_acct_coef = coefs["Equation debt", "current_account"],
  fiscal_coef       = coefs["Equation debt", "fiscal_balance"],
  remittances_coef  = coefs["Equation debt", "remittances"],
  d_gfc_coef        = coefs["Equation debt", "d_gfc"],
  d_comm_coef       = coefs["Equation debt", "d_comm"],
  d_covid_coef      = coefs["Equation debt", "d_covid"]
)

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(results_breaks, "output/tables/05_vecm_breaks.csv")
cat("\nSaved: output/tables/05_vecm_breaks.csv\n")
