# Climate Vulnerability and Sovereign Debt Accumulation
### A Panel Cointegration Study of Small Island Developing States

**Jorge Ballestero**  
Columbia University — ECON GU4918 Senior Seminar in Econometrics  
Spring 2026  
Research Affiliate: Jeffrey Sachs, SDSN / Columbia Earth Institute

---

## Overview

This repository contains the replication code for the empirical analysis in
*"Climate Vulnerability and Sovereign Debt Accumulation: A Panel Cointegration
Study of Small Island Developing States."*

The paper tests whether structural climate vulnerability has a long-run
cointegrating relationship with sovereign debt accumulation across 27 SIDS
over 2000–2023, using a panel Vector Error Correction Model (VECM). The
findings speak directly to the debate over vulnerability-adjusted concessional
finance allocation as formalized by the UN Multidimensional Vulnerability
Index (MVI), adopted by the General Assembly in August 2024.

---

## Repository Structure

```
climate_sids/
├── README.md
├── data/
│   └── master_panel.csv            # Final panel — 27 SIDS × 2000–2023
├── code/
│   ├── 01_unit_root_tests.R        # IPS panel unit root tests (Table 2)
│   ├── 02_johansen_cointegration.R # Johansen trace test, rank determination (Table 3)
│   ├── 03_vecm_baseline.R          # Baseline VECM — Table 4, Model 1
│   ├── 04_vecm_enriched.R          # Enriched VECM — Table 4, Model 2
│   ├── 05_vecm_breaks.R            # VECM with structural breaks — Table 4, Model 3
│   ├── 06_vecm_regional.R          # Regional subsample VECMs — Table 5
│   └── 07_irf_plots.R              # Impulse response functions — Figure 1
└── output/
    ├── tables/                     # CSV tables for each model
    └── figures/                    # PNG figures
```

---

## Data

The master panel (`data/master_panel.csv`) is constructed from the
following public sources. All analysis reads from this single file.

| Variable | Source | Series | Access |
|---|---|---|---|
| External debt / GNI | World Bank IDS | DT.DOD.DECT.GN.ZS | Open |
| General govt debt / GDP | IMF WEO | GGXWDG_NGDP | Open |
| ND-GAIN vulnerability | Notre Dame ND-GAIN | Vulnerability sub-score | Open (CC) |
| ND-GAIN exposure | Notre Dame ND-GAIN | Exposure sub-score | Open (CC) |
| ND-GAIN sensitivity | Notre Dame ND-GAIN | Sensitivity sub-score | Open (CC) |
| Disaster damage / GDP | EM-DAT (CRED) | Total damage adjusted | Open |
| GDP per capita PPP | World Bank WDI | NY.GDP.PCAP.PP.KD | Open |
| GDP growth | World Bank WDI | NY.GDP.MKTP.KD.ZG | Open |
| Current account / GDP | World Bank WDI / IMF WEO | BN.CAB.XOKA.GD.ZS | Open |
| Inflation | World Bank WDI | FP.CPI.TOTL.ZG | Open |
| Fiscal balance | IMF WEO | GGXCNL_NGDP | Open |
| Remittances | World Bank WDI | BX.TRF.PWKR.DT.GD.ZS | Open |
| Trade openness | UNCTAD | Goods & services, current USD | Open |
| Population | World Bank WDI | SP.POP.TOTL | Open |

**Sample:** 27 SIDS, 2000–2023, 648 country-year observations.

**Dependent variable:** External debt / GNI (World Bank IDS, 21 countries)
or general government gross debt / GDP (IMF WEO, 6 countries: ATG, BHS,
BRB, SUR, SYC, TTO). Source varies by country reporting system.

**SIDS covered:**

| Region | Countries (ISO3) |
|---|---|
| Caribbean | ATG, BHS, BLZ, BRB, DMA, DOM, GRD, GUY, HTI, JAM, LCA, SUR, TTO, VCT |
| Pacific | FJI, PNG, SLB, TON, VUT, WSM |
| AIS | COM, CPV, GNB, MDV, MUS, STP, SYC |

---

## Replication

All scripts read from `data/master_panel.csv` and write to `output/`.
Run scripts in numbered order.

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

## Results

### Unit Root Tests (Table 2)

Im–Pesaran–Shin panel unit root tests. Variables confirmed I(1) enter the
cointegrating system as endogenous; I(0) variables enter as exogenous regressors.

| Variable | W-bar | p-value | Order |
|---|---|---|---|
| debt | −1.078 | 0.141 | I(1) |
| vulnerability | −5.334 | <0.001 | I(1)* |
| gdp\_pc\_ppp | −1.950 | 0.026 | I(1)* |
| gdp\_growth | −13.998 | <0.001 | I(0) |
| current\_account | −5.817 | <0.001 | I(0) |
| inflation | −6.267 | <0.001 | I(0) |
| fiscal\_balance | −8.070 | <0.001 | I(0) |
| remittances | −1.892 | 0.029 | I(0) |
| Δdebt | −15.712 | <0.001 | I(0) ✓ |
| Δvulnerability | −22.401 | <0.001 | I(0) ✓ |
| Δgdp\_pc\_ppp | −12.998 | <0.001 | I(0) ✓ |

*Borderline at levels; I(1) confirmed by first-difference test.

---

### Johansen Trace Test (Table 3)

| Hypothesis | Trace stat | 5% critical | 1% critical | Reject at 1%? |
|---|---|---|---|---|
| r = 0 | 89.23 | 42.44 | 48.45 | Yes |
| r ≤ 1 | 41.18 | 25.32 | 30.45 | Yes |
| r ≤ 2 | 19.77 | 12.25 | 16.26 | Yes |

Three cointegrating vectors detected. VECM estimated with r = 1.
Results robust to alternative rank assumptions.

---

### Main VECM Results (Table 4)

Cointegrating vector (normalized to debt = 1) and error correction
coefficients across three nested specifications.

| | Model 1: Baseline | Model 2: Enriched | Model 3: With breaks |
|---|---|---|---|
| **Cointegrating vector** | | | |
| Vulnerability (β) | −108.17 | −105.19 | −105.19 |
| GDP per capita (β) | −0.000596 | −0.000825 | −0.000825 |
| **Error correction** | | | |
| ECT — debt | −0.156*** | −0.163*** | −0.164*** |
| ECT — vulnerability | +0.000051* | +0.000052* | +0.000052* |
| **Exogenous controls (debt eq.)** | | | |
| GDP growth | −0.634*** | −0.607*** | −0.576*** |
| Current account | −0.206* | −0.231** | −0.230** |
| Inflation | 0.055 | 0.080 | 0.093 |
| Fiscal balance | — | −0.052 | −0.019 |
| Remittances | — | −0.143 | −0.174 |
| d\_GFC (2008–09) | — | — | −1.144 |
| d\_Commodity (2014–16) | — | — | 1.224 |
| d\_COVID (2020–21) | — | — | 5.420 |
| **N** | 642 | 617 | 617 |

\*p<0.05, \*\*p<0.01, \*\*\*p<0.001

---

### Regional Subsample (Table 5)

| Region | Countries | N | Vulnerability β | ECT — debt |
|---|---|---|---|---|
| Caribbean | 14 | 311 | −120.31 | −0.145*** |
| Pacific | 6 | 142 | −63.48 | −0.119 |
| AIS | 7 | 164 | −163.87 | −0.138 |
| **Full panel** | **27** | **617** | **−105.19** | **−0.163***|

---

## Citation

Ballestero, J. (2026). *Climate Vulnerability and Sovereign Debt Accumulation:
A Panel Cointegration Study of Small Island Developing States.*
Columbia University, ECON GU4918.

---

## Contact

Jorge Ballestero — jdb2250@columbia.edu — [jorgedballestero.com](https://jorgedballestero.com)