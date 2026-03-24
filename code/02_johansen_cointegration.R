# =============================================================================
# 02_johansen_cointegration.R
# Johansen trace test — cointegrating rank determination
# Output: output/tables/02_johansen_cointegration.csv
# =============================================================================

library(tidyverse)
library(urca)
library(vars)

# -----------------------------------------------------------------------------
# Load data
# -----------------------------------------------------------------------------

panel <- read_csv("data/master_panel.csv")

# -----------------------------------------------------------------------------
# Prepare system variables — I(1) endogenous only
# -----------------------------------------------------------------------------

johansen_data <- panel %>%
  dplyr::select(debt, vulnerability, gdp_pc_ppp) %>%
  na.omit()

cat("Observations for Johansen test:", nrow(johansen_data), "\n")

# -----------------------------------------------------------------------------
# Johansen trace test
# -----------------------------------------------------------------------------

jo_test <- ca.jo(
  johansen_data,
  type  = "trace",
  ecdet = "trend",
  K     = 2
)

cat("\n=== JOHANSEN TRACE TEST ===\n")
summary(jo_test)

# -----------------------------------------------------------------------------
# Extract trace statistics into tidy table
# -----------------------------------------------------------------------------

jo_summary <- summary(jo_test)

trace_stats <- jo_test@teststat
crit_values <- jo_test@cval

johansen_table <- tibble(
  hypothesis  = rownames(crit_values),
  trace_stat  = round(trace_stats, 3),
  crit_10pct  = crit_values[, "10pct"],
  crit_5pct   = crit_values[, "5pct"],
  crit_1pct   = crit_values[, "1pct"]
) %>%
  mutate(
    reject_5pct = trace_stat > crit_5pct,
    reject_1pct = trace_stat > crit_1pct
  )

cat("\n=== JOHANSEN TABLE ===\n")
print(johansen_table)

# -----------------------------------------------------------------------------
# Cointegrating vector
# -----------------------------------------------------------------------------

cat("\n=== COINTEGRATING VECTOR (r=1) ===\n")
beta <- jo_test@V[, 1]
beta_norm <- beta / beta["debt"]
print(round(beta_norm, 6))

# -----------------------------------------------------------------------------
# Save
# -----------------------------------------------------------------------------

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(johansen_table, "output/tables/02_johansen_cointegration.csv")
cat("\nSaved: output/tables/02_johansen_cointegration.csv\n")
