# =============================================================================
# 01_unit_root_tests.R
# Im-Pesaran-Shin panel unit root tests
# Output: output/tables/01_unit_root_tests.csv
# =============================================================================

library(tidyverse)
library(plm)

# -----------------------------------------------------------------------------
# Load data
# -----------------------------------------------------------------------------

panel <- read_csv("data/master_panel.csv")
panel_p <- pdata.frame(panel, index = c("iso3", "year"))

# -----------------------------------------------------------------------------
# Helper: run IPS test and return tidy result
# -----------------------------------------------------------------------------

run_ips <- function(x, label, exo = "trend", pmax = 2) {
  result <- tryCatch(
    purtest(x, test = "ips", exo = exo, lags = "AIC", pmax = pmax),
    error = function(e) NULL
  )
  if (is.null(result)) {
    return(tibble(variable = label, wtbar = NA, pvalue = NA, 
                  exo = exo, note = "Test failed"))
  }
  tibble(
    variable = label,
    wtbar    = round(result$statistic$statistic, 4),
    pvalue   = round(result$statistic$p.value, 4),
    exo      = exo,
    note     = ""
  )
}

# -----------------------------------------------------------------------------
# Panel unit root tests — levels
# -----------------------------------------------------------------------------

cat("\n=== UNIT ROOT TESTS: LEVELS ===\n")

levels_results <- bind_rows(
  run_ips(panel_p$debt,            "debt",            exo = "trend"),
  run_ips(panel_p$vulnerability,   "vulnerability",   exo = "trend"),
  run_ips(panel_p$gdp_pc_ppp,      "gdp_pc_ppp",      exo = "trend"),
  run_ips(panel_p$gdp_growth,      "gdp_growth",      exo = "trend"),
  run_ips(panel_p$current_account, "current_account", exo = "trend"),
  run_ips(panel_p$inflation,       "inflation",       exo = "trend"),
  run_ips(panel_p$fiscal_balance,  "fiscal_balance",  exo = "trend"),
  run_ips(
    pdata.frame(
      panel %>% filter(iso3 != "BHS"),
      index = c("iso3", "year")
    )$remittances,
    "remittances (ex. BHS)", exo = "intercept"
  )
) %>%
  mutate(
    series    = "Level",
    order     = case_when(
      pvalue > 0.05 ~ "I(1)",
      pvalue <= 0.05 ~ "I(0)",
      TRUE ~ "—"
    )
  )

print(levels_results)

# -----------------------------------------------------------------------------
# Panel unit root tests — first differences (for I(1) candidates)
# -----------------------------------------------------------------------------

cat("\n=== UNIT ROOT TESTS: FIRST DIFFERENCES ===\n")

diff_results <- bind_rows(
  run_ips(diff(panel_p$debt),          "D.debt",          exo = "intercept"),
  run_ips(diff(panel_p$vulnerability), "D.vulnerability", exo = "intercept"),
  run_ips(diff(panel_p$gdp_pc_ppp),    "D.gdp_pc_ppp",    exo = "intercept")
) %>%
  mutate(
    series = "First difference",
    order  = case_when(
      pvalue <= 0.05 ~ "I(0) ✓ confirms I(1) in levels",
      TRUE ~ "—"
    )
  )

print(diff_results)

# -----------------------------------------------------------------------------
# Combined table
# -----------------------------------------------------------------------------

unit_root_table <- bind_rows(levels_results, diff_results) %>%
  dplyr::select(variable, series, wtbar, pvalue, order, note)

cat("\n=== COMBINED UNIT ROOT TABLE ===\n")
print(unit_root_table, n = Inf)

# -----------------------------------------------------------------------------
# Save
# -----------------------------------------------------------------------------

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(unit_root_table, "output/tables/01_unit_root_tests.csv")
cat("\nSaved: output/tables/01_unit_root_tests.csv\n")
