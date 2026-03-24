# =============================================================================
# 04_vecm_enriched.R
# Enriched Panel VECM — adds fiscal_balance and remittances
# Endogenous I(1): debt, vulnerability, gdp_pc_ppp
# Exogenous I(0): gdp_growth, current_account, inflation,
#                 fiscal_balance, remittances
# Output: output/tables/04_vecm_enriched.csv
# =============================================================================

library(tidyverse)
library(tsDyn)

# -----------------------------------------------------------------------------
# Load data
# -----------------------------------------------------------------------------

panel <- read_csv("clean_data/master_panel.csv")

# -----------------------------------------------------------------------------
# Prepare data
# -----------------------------------------------------------------------------

vecm_data <- panel %>%
  dplyr::select(iso3, year,
                debt, vulnerability, gdp_pc_ppp,
                gdp_growth, current_account, inflation,
                fiscal_balance, remittances) %>%
  na.omit()

cat("Observations:", nrow(vecm_data), "\n")
cat("Countries:", n_distinct(vecm_data$iso3), "\n")

# -----------------------------------------------------------------------------
# Estimate enriched VECM
# -----------------------------------------------------------------------------

pvecm_enriched <- VECM(
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

cat("\n=== ENRICHED VECM SUMMARY ===\n")
summary(pvecm_enriched)

# -----------------------------------------------------------------------------
# Extract key results
# -----------------------------------------------------------------------------

beta  <- pvecm_enriched$model.specific$beta
coefs <- pvecm_enriched$coefficients

cat("\n=== COINTEGRATING VECTOR ===\n")
print(round(beta, 6))

# -----------------------------------------------------------------------------
# Save results
# -----------------------------------------------------------------------------

results_enriched <- tibble(
  model              = "Enriched",
  n_obs              = nrow(vecm_data),
  vuln_beta          = beta[2],
  gdppc_beta         = beta[3],
  ect_debt           = coefs["Equation debt",          "ECT"],
  ect_vuln           = coefs["Equation vulnerability", "ECT"],
  ect_gdppc          = coefs["Equation gdp_pc_ppp",    "ECT"],
  gdp_growth_coef    = coefs["Equation debt", "gdp_growth"],
  current_acct_coef  = coefs["Equation debt", "current_account"],
  inflation_coef     = coefs["Equation debt", "inflation"],
  fiscal_coef        = coefs["Equation debt", "fiscal_balance"],
  remittances_coef   = coefs["Equation debt", "remittances"]
)

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(results_enriched, "output/tables/04_vecm_enriched.csv")
cat("\nSaved: output/tables/04_vecm_enriched.csv\n")
