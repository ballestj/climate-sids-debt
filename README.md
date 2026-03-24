# Climate Vulnerability and Sovereign Debt Accumulation
### A Panel Cointegration Study of Small Island Developing States

**Jorge Ballestero**  
Columbia University — ECON GU4918 Senior Seminar in Econometrics  
Spring 2026

---

## Overview

This repository contains the replication code for the empirical analysis in
*"Climate Vulnerability and Sovereign Debt Accumulation: A Panel Cointegration
Study of Small Island Developing States."*

The paper tests whether structural climate vulnerability has a long-run
cointegrating relationship with sovereign debt accumulation across 27 SIDS
over 2000–2023, using a panel Vector Error Correction Model (VECM).

---

## Repository Structure

```
climate_sids/
├── README.md
├── code/
│   ├── 01_unit_root_tests.R        # IPS panel unit root tests (Table 2)
│   ├── 02_johansen_cointegration.R # Johansen trace test, rank determination (Table 3)
│   ├── 03_vecm_baseline.R          # Baseline VECM — Table 4, Model 1
│   ├── 04_vecm_enriched.R          # Enriched VECM — Table 4, Model 2
│   ├── 05_vecm_breaks.R            # VECM with structural breaks — Table 4, Model 3
│   ├── 06_vecm_regional.R          # Regional subsample VECMs — Table 5
│   └── 07_irf_plots.R              # Impulse response functions — Figure 1
├── clean_data/
│   └── master_panel.csv            # Final panel — 27 SIDS × 2000–2023
└── output/
    ├── tables/                     # CSV tables for each model
    └── figures/                    # PNG figures
```

---

## Data

The master panel (`clean_data/master_panel.csv`) is constructed from the
following public sources:

| Variable | Source | Access |
|---|---|---|
| External debt / GNI | World Bank IDS | Open |
| General govt debt / GDP | IMF WEO | Open |
| ND-GAIN vulnerability | Notre Dame ND-GAIN | Open (CC license) |
| Disaster damage / GDP | EM-DAT (CRED) | Open (registration) |
| GDP per capita PPP | World Bank WDI | Open |
| GDP growth, inflation, CA | World Bank WDI | Open |
| Fiscal balance | IMF WEO | Open |
| Remittances | World Bank WDI | Open |
| Trade openness | UNCTAD | Open |
| Population | World Bank WDI | Open |

Raw data cleaning scripts are not included in this repository as they
depend on file paths and manual download configurations. The master panel
CSV is the reproducible starting point for all analysis.

**Sample:** 27 SIDS, 2000–2023, 648 country-year observations.  
**Dependent variable:** External debt / GNI (IDS, 21 countries) or general
government gross debt / GDP (IMF WEO, 6 countries: ATG, BHS, BRB, SUR, SYC, TTO).

---

## Replication

All scripts read from `clean_data/master_panel.csv` and write outputs to
`output/tables/` and `output/figures/`. Run scripts in numbered order.

### Requirements

```r
install.packages(c("tidyverse", "plm", "urca", "vars", "tsDyn"))
```

### Run order

```r
source("code/01_unit_root_tests.R")
source("code/02_johansen_cointegration.R")
source("code/03_vecm_baseline.R")
source("code/04_vecm_enriched.R")
source("code/05_vecm_breaks.R")
source("code/06_vecm_regional.R")
source("code/07_irf_plots.R")
```

---

## Key Results

| Model | Vulnerability β | Debt ECT | N |
|---|---|---|---|
| Baseline | −108.2 | −0.156*** | 639 |
| Enriched | −105.2 | −0.163*** | 614 |
| With breaks | −105.2 | −0.164*** | 614 |

Regional subsample:

| Region | Vulnerability β | Debt ECT |
|---|---|---|
| Caribbean | −120.3 | −0.145*** |
| Pacific | −63.5 | −0.119 |
| AIS | −163.9 | −0.138 |

---

## Citation

Ballestero, J. (2026). *Climate Vulnerability and Sovereign Debt Accumulation:
A Panel Cointegration Study of Small Island Developing States.*
Columbia University, ECON GU4918.

---

## Contact

Jorge Ballestero — jdb2250@columbia.edu
