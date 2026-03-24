# =============================================================================
# 07_irf_plots.R
# Impulse Response Functions — vulnerability shock -> debt response
# Full panel and Caribbean subsample
# Output: output/figures/07_irf_full.png
#         output/figures/07_irf_caribbean.png
# Note: IRFs are presented for completeness. Due to the short time dimension
# of the panel (T=24), bootstrap confidence intervals are wide and dynamic
# inference should be interpreted with caution. Primary results are the
# cointegrating vector and ECT coefficients in Tables 4-5.
# =============================================================================

library(tidyverse)
library(urca)
library(vars)

dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# -----------------------------------------------------------------------------
# Load data
# -----------------------------------------------------------------------------

panel <- read_csv("data/master_panel.csv")

# -----------------------------------------------------------------------------
# Helper: run Johansen and produce IRF
# -----------------------------------------------------------------------------

run_irf <- function(data, label, filename) {

  jo <- ca.jo(
    data %>%
      dplyr::select(vulnerability, debt, gdp_pc_ppp) %>%
      na.omit(),
    type  = "trace",
    ecdet = "trend",
    K     = 2
  )

  var_model <- vec2var(jo, r = 1)

  irf_result <- irf(
    var_model,
    impulse  = "vulnerability",
    response = "debt",
    n.ahead  = 10,
    boot     = TRUE,
    ci       = 0.95,
    runs     = 500
  )

  # Save plot
  png(filename, width = 700, height = 600, res = 100)
  plot(irf_result,
       main = paste("IRF: Vulnerability -> Debt |", label))
  dev.off()

  cat("Saved:", filename, "\n")

  irf_result
}

# -----------------------------------------------------------------------------
# Full panel IRF
# -----------------------------------------------------------------------------

cat("\n=== IRF: FULL PANEL ===\n")
irf_full <- run_irf(
  panel,
  "Full Panel",
  "output/figures/07_irf_full.png"
)

# -----------------------------------------------------------------------------
# Caribbean subsample IRF
# -----------------------------------------------------------------------------

cat("\n=== IRF: CARIBBEAN ===\n")
irf_carib <- run_irf(
  panel %>% filter(region == "Caribbean"),
  "Caribbean",
  "output/figures/07_irf_caribbean.png"
)

# -----------------------------------------------------------------------------
# Extract point estimates
# -----------------------------------------------------------------------------

irf_values <- tibble(
  horizon    = 0:10,
  full_panel = as.numeric(irf_full$irf$vulnerability),
  caribbean  = as.numeric(irf_carib$irf$vulnerability)
)

cat("\n=== IRF POINT ESTIMATES ===\n")
print(irf_values)

write_csv(irf_values, "output/tables/07_irf_values.csv")
cat("\nSaved: output/tables/07_irf_values.csv\n")
