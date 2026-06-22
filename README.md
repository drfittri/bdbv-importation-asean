# BDBV Importation Risk — Malaysia / ASEAN

Reproducible analysis code and data for:

**"Quantifying the probability of Bundibugyo virus (BDBV) importation
into Malaysia and ASEAN hub countries during the 2026 PHEIC:
a travel-epidemiology modelling study"**

## Author

Dr Mohd Fittri Fahmi bin Fauzi  
Ministry of Health Malaysia / Universiti Sains Malaysia (USM)

## Background

Bundibugyo virus (BDBV, family *Filoviridae*, genus *Orthoebolavirus*)
was declared a Public Health Emergency of International Concern (PHEIC)
by WHO on 17 May 2026, following an outbreak in eastern Democratic
Republic of the Congo (Ituri and North Kivu provinces) and Uganda.
This project adapts the ECDC importation-risk methodology (June 2026)
to estimate the probability of BDBV importation into Malaysia and
selected ASEAN hub countries over the 11–25 June 2026 study window.

## Data sources (verified, June 2026)

- INRB-UMIE outbreak data: <https://github.com/INRB-UMIE/Ebola_DRC_2026>
  (build 30 May 2026; aggregated surveillance only, no individual data)
- ECDC importation brief (June 2026): <https://www.ecdc.europa.eu/en/publications-data/estimation-importation-risk-bundibugyo-virus-eueea-june-2026>
- WHO Disease Outbreak News: <https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602>
- ECDC outbreak page: <https://www.ecdc.europa.eu/en/ebola-outbreak-democratic-republic-congo-and-uganda>
- McCabe et al., *Lancet Infect Dis* 2026: <https://doi.org/10.1016/S1473-3099(26)00299-9>
- Bayesian outbreak-size model: <https://github.com/epiforecasts/BVDOutbreakSize>
- Imperial College GIDA report (20 May 2026): imperial.ac.uk

## Repository layout

```
01_data_prep.R     # cleans INRB + WHO data, builds analysis-ready CSVs
02_model.R         # state-dependent importation model (reuses ECDC approach)
03_figures.R       # ASEAN scenarios + Malaysia-focused figures
data/raw/          # immutable source data (PDFs gitignored; provenance in SOURCES.txt)
data/processed/    # analysis-ready datasets
output/            # CSV results + tables
figures/           # PNG/PDF figures
manuscript/        # draft manuscript + supplementary
PROGRESS.md        # step-by-step tracker (project memory)
research plan.md   # full execution plan (v2 corrections)
```

## Reproducibility

1. Clone: `git clone https://github.com/drfittri/bdbv-importation-asean`
2. Open in R ≥ 4.3.0.
3. Install packages (see `01_data_prep.R` header for the package list).
4. Run in order: `01_data_prep.R` → `02_model.R` → `03_figures.R`.
5. Manuscript rendered from `manuscript/` with Quarto / pandoc.

Random seed: `set.seed(20260622)`.

## Licence

MIT. See `LICENSE`. Data sources retain their original licences; see
`data/raw/SOURCES.txt` for provenance and download dates.

## Disclaimer

Modelling only, not a forecast. Estimates carry wide uncertainty
(see manuscript Limitations). No primary data were collected; this
project uses publicly available aggregated surveillance data and
required no ethics review.
