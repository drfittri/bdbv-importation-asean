# BDBV 2026 ASEAN Importation Risk — Full Execution Plan

---

```
PRE-PLAN AUDIT
══════════════

Ambiguities found:

  1. Travel volume data source (OAG, IATA, or proxy)
     Resolution: Use published IATA/OAG proxy values from ECDC COVID importation
     papers as the primary estimate. OAG free-tier for supplementary verification.
     Exact sources cited in Steps 11-13 with fallback values hardcoded.

  2. Whether ethics approval is required for secondary open data analysis
     Resolution: No NMRR ethics approval required for analysis of publicly available
     aggregated surveillance data under Malaysian law (PDPA 2010 exemption for
     public health research using non-identifiable data). Add ethics waiver statement
     in manuscript methods section. Confirm with your institution's REC if submitting
     to a journal requiring IRB declaration — most accept "data are publicly available
     and do not require ethics review."

  3. R version and package availability
     Resolution: Plan assumes R >= 4.3.0. All packages are on CRAN. Exact install
     commands provided in each relevant step.

  4. Co-author requirement
     Resolution: Plan is executable solo. Co-author (e.g., MAE colleague or USM
     supervisor) can be added after draft is complete. Steps for authorship
     declaration are included in the submission phase.

  5. Target journal selection between Eurosurveillance and WPSAR
     Resolution: Primary target = Eurosurveillance (Rapid Communication format,
     ~1500 words). If rejected within 7 days, immediate resubmit to WPSAR.
     Both formats are written simultaneously (word count difference only).

  6. Incubation period and detection delay priors
     Resolution: Use Funk S. 2026 bdbv-linelist-analysis GitHub (DOI available via
     epiforecasts BVDOutbreakSize repo). This is the same prior used in the Lancet
     Infectious Diseases correspondence — directly citable and reproducible.

Dependencies mapped:

  - Phase 1 (data acquisition) must complete before Phase 2 (modelling)
  - Step 14 (travel volume estimation) must complete before Step 18 (model run)
  - Step 18 (model run) must complete before Step 22 (results tables)
  - Step 22 (results) must complete before Step 26 (manuscript draft)
  - Step 30 (internal review) must complete before Step 33 (submission)

Decision points identified:

  - Which ECDC model variant to replicate?
    Resolved: Use the June 2026 ECDC importation brief methodology
    (https://www.ecdc.europa.eu/en/publications-data/estimation-importation-risk-
    bundibugyo-virus-eueea-june-2026). It is the most current, peer-reviewed
    equivalent, and already published — directly citable as your methodological
    reference.

  - Monte Carlo iterations
    Resolved: 10,000 iterations. Matches ECDC approach and balances runtime
    with precision.

  - Uncertainty interval width
    Resolved: 90% uncertainty interval (UI), matching ECDC and the Imperial
    College London Lancet paper for direct comparability.

  - Preprint platform
    Resolved: medRxiv. Required before journal submission to establish priority
    and enable immediate open access.

Assumptions made:

  - GitHub repo INRB-UMIE/Ebola_DRC_2026 remains publicly accessible throughout
    the project (check on Day 1; if taken down, use WHO DON PDFs as fallback)
  - R and RStudio are already installed on your machine
  - You have a GitHub account for repository setup
  - OAG free-tier account can be created without institutional subscription
    (fallback: published IATA data from COVID importation literature)
```

---

```
══════════════════════════════════════════════════════
EXECUTION PLAN
══════════════════════════════════════════════════════
Task        : Quantifying the probability of Bundibugyo virus (BDBV) importation
              to Malaysia and ASEAN hub countries during the 2026 PHEIC —
              a travel epidemiology modelling study. Produce a peer-reviewed
              manuscript, reproducible R codebase, and a medRxiv preprint.
Domain      : Epidemiological modelling + academic manuscript writing
Deliverable : (1) Peer-reviewed manuscript submitted to Eurosurveillance
              (Rapid Communication, ~1500 words + figures)
              (2) Reproducible R project on GitHub (open source)
              (3) medRxiv preprint (DOI-registered)
Executor    : Dr Fittri (solo, with optional co-author added post-draft)
Tools       : R >= 4.3.0, RStudio, GitHub, medRxiv submission portal,
              Eurosurveillance online submission, OAG free tier,
              INRB-UMIE GitHub data, ECDC publications, WHO DON PDFs
Constraints : No primary data collection. Open data only.
              No NMRR ethics approval required (see Pre-Plan Audit).
              Manuscript: Eurosurveillance Rapid Communication format
              (~1500 words, max 2 figures or tables, structured abstract).
              Reproducibility: all code and data on GitHub under MIT licence.
              No hallucinated citations. All references verified via PubMed/DOI.
Total Steps : 38
══════════════════════════════════════════════════════

PRECONDITIONS (must all be true before starting Step 1):

  [ ] R >= 4.3.0 is installed and running on local machine
  [ ] RStudio is installed
  [ ] Git is installed and configured with your GitHub account
  [ ] You have a GitHub account (free tier is sufficient)
  [ ] Internet access is available to download data from INRB-UMIE repo
  [ ] You have at least 4 hours of uninterrupted work time for Phase 1

If any precondition is false → STOP and install the missing tool before
proceeding. Do not begin Step 1 until all boxes are checked.
══════════════════════════════════════════════════════
```

---

## PHASE 1 — Project Setup and Data Acquisition
### (Days 1-3)

---

```
──────────────────────────────────────────────────────
STEP 1 — Create the R project directory structure
──────────────────────────────────────────────────────
Action   : Create a new RStudio project with the following folder structure
           and push it as a new public GitHub repository named
           "bdbv2026-asean-importation".

Input    : Empty working directory on your local machine.

Tool     : RStudio → New Project → New Directory → New Project.
           Name: bdbv2026-asean-importation
           Then in the RStudio Terminal (not R console), run:
             git init
             git remote add origin https://github.com/drfittri/bdbv2026-asean-importation.git
           Create the following subdirectories manually or via Terminal:
             mkdir data/raw data/processed figures output manuscript

Output   : Local R project exists at ~/bdbv2026-asean-importation/ with
           subdirectories: data/raw/, data/processed/, figures/, output/,
           manuscript/.
           GitHub repository "bdbv2026-asean-importation" exists at
           https://github.com/drfittri/bdbv2026-asean-importation
           and the local repo is linked to it.

Note     : Make the GitHub repo PUBLIC from the start. CEPI and journals
           require open code. The LICENSE file must be MIT — create it via
           GitHub's "Add file → Create new file → LICENSE" interface and
           select MIT template.

On Fail  : If GitHub push fails, create the repo manually on github.com first
           (New Repository → name: bdbv2026-asean-importation → Public →
           Add README), then run: git remote set-url origin [new URL] and
           retry push.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 2 — Create README.md in the project root
──────────────────────────────────────────────────────
Action   : Create a README.md file in the project root with the content below.

Input    : The GitHub repository created in Step 1.

Tool     : Any text editor or RStudio Files pane → New File → Text File,
           save as README.md in the project root.

Output   : README.md exists at ~/bdbv2026-asean-importation/README.md
           containing the following content exactly:

---
# BDBV 2026 ASEAN Importation Risk

Reproducible analysis code and data for:

**"Quantifying the probability of Bundibugyo virus importation to Malaysia
and ASEAN hub countries during the 2026 PHEIC: a travel epidemiology
modelling study"**

Author: [Your name], [Your institution]

## Data sources
- INRB-UMIE/Ebola_DRC_2026 (GitHub, public)
- WHO Disease Outbreak News DON602, DON603
- ECDC importation risk brief, June 2026
- Published IATA travel volume estimates (see manuscript methods)

## Reproducibility
Run scripts in order: 01_data_prep.R → 02_model.R → 03_figures.R

## Licence
MIT
---

Note     : Replace [Your name] and [Your institution] with actual values.

On Fail  : None. File creation cannot fail. If saving fails, check disk space.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 3 — Install all required R packages
──────────────────────────────────────────────────────
Action   : Install the following R packages by running the code block below
           in the RStudio R console (not Terminal).

Input    : RStudio R console, internet connection.

Tool     : RStudio R console. Run exactly:

install.packages(c(
  "tidyverse",     # data manipulation and plotting
  "lubridate",     # date handling
  "readr",         # CSV reading
  "janitor",       # column name cleaning
  "mc2d",          # Monte Carlo 2D (uncertainty propagation)
  "ggplot2",       # figures
  "scales",        # axis formatting
  "knitr",         # table rendering
  "kableExtra",    # table formatting
  "flextable",     # manuscript-quality tables
  "here",          # file path management
  "gt",            # tables
  "patchwork",     # figure composition
  "jsonlite"       # JSON reading (for manifest.json from INRB-UMIE)
))

Output   : All 14 packages install without error. Verify by running:
             library(tidyverse); library(mc2d); library(here)
           Console shows no error messages. If any package shows
           "Error in library()", it did not install correctly.

Note     : If on a managed IT system (clinic computer) where install.packages
           fails due to permissions, run RStudio as Administrator (Windows)
           or use: install.packages("X", lib = "~/R/library") with a
           personal library path.

On Fail  : For any individual package that fails, run:
             install.packages("[package name]", dependencies = TRUE)
           If still failing, check CRAN status at https://cran.r-project.org
           and try an alternative CRAN mirror:
             options(repos = c(CRAN = "https://cloud.r-project.org"))
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 4 — Download INRB-UMIE outbreak data (primary epidemiological source)
──────────────────────────────────────────────────────
Action   : Clone the INRB-UMIE/Ebola_DRC_2026 GitHub repository into a
           temporary local folder outside your project directory.

Input    : Internet connection. GitHub account (no special access needed —
           repository is public).

Tool     : RStudio Terminal. Run exactly:
             cd ~
             git clone https://github.com/INRB-UMIE/Ebola_DRC_2026.git

Output   : Folder ~/Ebola_DRC_2026/ exists on local machine containing
           subdirectories including data/insp_sitrep/ and data/epi/.

Note     : Do NOT clone inside your project folder. Clone to home directory
           (~/) as above. You will copy specific files in Steps 5-7.
           If the repository URL has changed, check the correct URL at:
           https://github.com/INRB-UMIE and look for the BDBV2026 repo.

On Fail  : If git clone fails due to network restrictions, go to
           https://github.com/INRB-UMIE/Ebola_DRC_2026 in a browser,
           click "Code → Download ZIP", extract to ~/, and rename the
           extracted folder to Ebola_DRC_2026. The folder structure will
           be identical.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 5 — Copy INSP SitRep CSV data to your project
──────────────────────────────────────────────────────
Action   : Copy the processed INSP SitRep CSV file from the cloned
           INRB-UMIE repository into your project's data/raw/ folder.

Input    : ~/Ebola_DRC_2026/data/insp_sitrep/ directory (from Step 4).

Tool     : RStudio Terminal. Run exactly:
             cp ~/Ebola_DRC_2026/data/insp_sitrep/*.csv \
                ~/bdbv2026-asean-importation/data/raw/

Output   : One or more CSV files exist in
           ~/bdbv2026-asean-importation/data/raw/
           named with the pattern insp_sitrep_*.csv or similar.
           Verify by running in Terminal:
             ls ~/bdbv2026-asean-importation/data/raw/

Note     : If the insp_sitrep folder contains only PDFs and no CSVs,
           the processed data has not yet been released. In that case,
           use the WHO DON PDF data extracted manually in Step 8 as the
           sole epidemiological input and note the limitation in the
           manuscript methods section.

On Fail  : If cp fails (file not found), navigate to
           ~/Ebola_DRC_2026/data/ in the RStudio Files pane, identify
           the correct subfolder containing CSV files, and copy those
           files manually to the data/raw/ folder using Files pane
           → More → Copy To.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 6 — Copy aggregated linelist data to your project
──────────────────────────────────────────────────────
Action   : Copy the aggregated linelist data from the INRB-UMIE repository
           into your project's data/raw/ folder.

Input    : ~/Ebola_DRC_2026/data/epi/ directory (from Step 4).

Tool     : RStudio Terminal. Run exactly:
             cp ~/Ebola_DRC_2026/data/epi/*.csv \
                ~/bdbv2026-asean-importation/data/raw/

Output   : CSV file(s) from the epi/ folder exist in
           ~/bdbv2026-asean-importation/data/raw/
           Verify by running: ls ~/bdbv2026-asean-importation/data/raw/
           and confirming new file(s) are present.

Note     : The aggregated linelist data provides confirmed case counts
           by health zone and date. These are aggregated (not individual
           patient data) — no privacy concern.

On Fail  : If epi/ folder is empty (data pipeline not yet published),
           skip this step. Record in a text file at data/raw/SOURCES.txt:
           "Aggregated linelist not available as of [today's date].
           Fallback: WHO DON PDF series used." Then proceed to Step 7.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 7 — Download WHO Disease Outbreak News PDFs
──────────────────────────────────────────────────────
Action   : Download three WHO DON documents as PDFs into data/raw/.

Input    : Internet browser. The following three URLs:
           URL 1: https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602
           URL 2: https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON603
           URL 3: The most recent WHO DON for BDBV 2026 (check
                  https://www.who.int/emergencies/disease-outbreak-news
                  and find the latest BDBV entry)

Tool     : Web browser → Save Page As → PDF format.
           Save to: ~/bdbv2026-asean-importation/data/raw/
           File names: DON602.pdf, DON603.pdf, DON_latest.pdf

Output   : Three PDF files exist in data/raw/:
           DON602.pdf, DON603.pdf, DON_latest.pdf
           Each file is > 100 KB (indicating full page content saved,
           not just a blank page).

Note     : These PDFs serve as the verifiable primary source for case
           counts cited in the manuscript. Archive the download date in
           data/raw/SOURCES.txt as: "WHO DON PDFs downloaded [date]."

On Fail  : If PDFs cannot be saved from browser, right-click the page
           and choose "Print → Save as PDF." If the page is inaccessible,
           use the WHO AFRO weekly bulletin as fallback:
           https://www.afro.who.int/health-topics/disease-outbreaks/
           outbreaks-and-other-emergencies-updates
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 8 — Manually extract WHO DON case counts into a structured CSV
──────────────────────────────────────────────────────
Action   : Read DON602.pdf, DON603.pdf, and DON_latest.pdf from data/raw/
           and create a manually-entered CSV file with confirmed case and
           death counts by date and province.

Input    : DON602.pdf: 15 May 2026 — 8 confirmed cases, 4 deaths, Ituri Province
           DON603.pdf: 21 May 2026 — 85 confirmed cases, 10 deaths (DRC + Uganda)
           DON_latest.pdf: Read the document and extract the most recent figures.
           Also include: 17 June 2026 — 837 confirmed cases, 196 deaths
           (source: ECDC situation update 17 June 2026).

Tool     : Create file ~/bdbv2026-asean-importation/data/raw/who_don_series.csv
           with the following columns and rows (add additional rows from
           DON_latest.pdf):

date,source,confirmed_cases_total,confirmed_deaths_total,provinces_affected,notes
2026-05-15,WHO DON602,8,4,Ituri,Initial declaration
2026-05-21,WHO DON603,85,10,"Ituri, North Kivu (DRC); Kampala (Uganda)",PHEIC declared 17 May
2026-06-17,ECDC SitUpdate,837,196,"Ituri (767), North Kivu (67), South Kivu (3)",20 health zones in Ituri

Output   : File ~/bdbv2026-asean-importation/data/raw/who_don_series.csv
           exists with minimum 3 rows and 7 columns as specified above.
           Additional rows added from DON_latest.pdf if it contains a
           more recent date than 17 June 2026.

Note     : This CSV is the fallback epidemiological data source if
           INRB-UMIE CSVs from Steps 5-6 are insufficient. It is also
           used to validate the INRB-UMIE data. The CFR to use in the
           model will be calculated as confirmed_deaths_total /
           confirmed_cases_total from the most recent row.

On Fail  : Cannot fail — this is manual data entry. If a PDF cannot be
           read, use the figures stated in this step as hardcoded values
           and add a note in SOURCES.txt.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 9 — Download ECDC importation risk methodology document
──────────────────────────────────────────────────────
Action   : Download the ECDC importation risk brief as PDF and save to
           data/raw/.

Input    : URL:
           https://www.ecdc.europa.eu/en/publications-data/estimation-
           importation-risk-bundibugyo-virus-eueea-june-2026

Tool     : Web browser → navigate to URL above → download the PDF linked
           on the page titled "Estimation of the importation risk of
           Bundibugyo virus into the EU/EEA in June 2026"
           Save as: ~/bdbv2026-asean-importation/data/raw/ECDC_importation_risk_June2026.pdf

Output   : File ECDC_importation_risk_June2026.pdf exists in data/raw/
           and is > 500 KB.

Note     : This document is the direct methodological template for your
           analysis. You will replicate its Monte Carlo model and apply
           it to the ASEAN travel context. Read Section 2 (Methods) in
           full before proceeding to Phase 2. Record the full citation
           in data/raw/SOURCES.txt:
           "ECDC. Estimation of the importation risk of Bundibugyo virus
           into the EU/EEA in June 2026. Stockholm: ECDC; 2026."

On Fail  : If the ECDC PDF link is broken, access the ECDC BDBV page:
           https://www.ecdc.europa.eu/en/ebola-virus-disease-outbreak-
           democratic-republic-congo-and-uganda
           and download the importation risk brief from there.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 10 — Create SOURCES.txt to document all data provenance
──────────────────────────────────────────────────────
Action   : Create a plain text file at data/raw/SOURCES.txt documenting
           the source, URL, and download date for every file in data/raw/.

Input    : The list of all files currently in data/raw/ (from Steps 5-9).

Tool     : RStudio → Files pane → data/raw/ → New File → Text File,
           save as SOURCES.txt.

Output   : SOURCES.txt exists at data/raw/SOURCES.txt and contains one
           entry per file in data/raw/, each with:
           - File name
           - Source name
           - URL
           - Date accessed/downloaded
           - Brief description

           Minimum content (add entries for any additional files):

FILE: insp_sitrep_*.csv
SOURCE: INRB-UMIE/Ebola_DRC_2026 GitHub repository
URL: https://github.com/INRB-UMIE/Ebola_DRC_2026/tree/main/data/insp_sitrep
DATE ACCESSED: [today's date]
DESCRIPTION: Daily case, death, contact-tracing, and hospitalisation
indicators by health zone, extracted from INSP SitReps.

FILE: who_don_series.csv
SOURCE: WHO Disease Outbreak News (manually extracted)
URL: DON602: https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602
     DON603: https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON603
DATE ACCESSED: [today's date]
DESCRIPTION: Manually-entered cumulative case and death counts from WHO DON series.

FILE: ECDC_importation_risk_June2026.pdf
SOURCE: European Centre for Disease Prevention and Control
URL: https://www.ecdc.europa.eu/en/publications-data/estimation-importation-risk-bundibugyo-virus-eueea-june-2026
DATE ACCESSED: [today's date]
DESCRIPTION: Methodological reference for Monte Carlo importation model.

Note     : Replace [today's date] with actual date in ISO format (YYYY-MM-DD).

On Fail  : Cannot fail — plain text file creation. If file save fails,
           check disk space.
──────────────────────────────────────────────────────
```

```
══════════════════════════════════════════════════════
QUALITY GATE 1 — Data acquisition complete
══════════════════════════════════════════════════════
Check each item. ALL must be true to proceed.

  [ ] data/raw/ contains at least one CSV file with case count data
      (either from INRB-UMIE or who_don_series.csv)
  [ ] data/raw/ECDC_importation_risk_June2026.pdf exists and is readable
  [ ] data/raw/SOURCES.txt exists with entries for all files
  [ ] GitHub repository has been updated (git add → git commit → git push)
  [ ] R packages from Step 3 all load without error

If all pass → continue to Step 11
If any fail → return to the failing step and resolve before proceeding
══════════════════════════════════════════════════════
```

---

## PHASE 2 — Travel Volume Data and Model Parameters
### (Days 2-4)

---

```
──────────────────────────────────────────────────────
STEP 11 — Extract ECDC model parameters from methodology document
──────────────────────────────────────────────────────
Action   : Read ECDC_importation_risk_June2026.pdf (Section 2: Methods)
           and extract the following parameter values. Record them in a
           new text file at data/processed/model_parameters.txt.

Input    : ~/bdbv2026-asean-importation/data/raw/ECDC_importation_risk_June2026.pdf

Tool     : Open PDF in any PDF reader. Read Section 2 and locate each
           parameter. Create data/processed/model_parameters.txt using
           any text editor.

Output   : data/processed/model_parameters.txt containing the following
           (fill in values from the ECDC PDF; placeholder [X] indicates
           the value to extract):

=== BDBV 2026 MODEL PARAMETERS ===
Source: ECDC importation risk brief, June 2026

-- ECDC BASELINE ESTIMATES (EU/EEA) --
Estimated travel volume DRC+Uganda to EU/EEA (per 2-week period): [X]
Estimated probability of importation to EU/EEA (per 2-week period): 0.45%
  (90% UI: 0.20% - 0.85%)
Estimated travellers per 1 importation: ~23,000
  (90% UI: 13,000 - 54,000)

-- EPIDEMIOLOGICAL PARAMETERS (from ECDC document) --
Incubation period mean (days): [X]
Incubation period distribution: [X] (e.g., Gamma, Weibull)
Detection delay mean (days): [X]
Proportion of cases exported (ascertainment): [X]
CFR (as of date in document): [X]

-- FIXED PARAMETERS FOR THIS ANALYSIS --
Incubation window used for travel risk calculation: 21 days (maximum,
  per WHO IHR definition for Ebola family)
Monte Carlo iterations: 10,000
Uncertainty interval: 90%

Note     : If any parameter value is not explicitly stated in the ECDC
           document, use the corresponding value from:
           McCabe R et al. Lancet Infect Dis. 2026. DOI: 10.1016/S1473-3099(26)00299-9
           (the Imperial College London outbreak size estimate)

On Fail  : If the ECDC PDF is not readable (scanned image), use the
           parameter values published in the ECDC website text at:
           https://www.ecdc.europa.eu/en/publications-data/estimation-
           importation-risk-bundibugyo-virus-eueea-june-2026
           which states the key outputs in the webpage abstract.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 12 — Identify air routes from DRC and Uganda to ASEAN
──────────────────────────────────────────────────────
Action   : Identify and document all air travel routes connecting DRC
           (Kinshasa - FIH, Bunia - BUX, Goma - GOM) and Uganda
           (Entebbe - EBB) to Malaysia and other ASEAN hub countries,
           including all transit routing via Dubai (DXB), Doha (DOH),
           Nairobi (NBO), and Singapore (SIN).

Input    : Knowledge of major hub routing + publicly available airline
           route maps (Google Flights, Flightradar24, or OAG free tier).

Tool     : Open https://www.google.com/flights in browser.
           Search the following 8 route pairs one at a time and record
           whether a route exists (any airline, direct or 1-stop):

           1. FIH → KUL (Kinshasa to Kuala Lumpur)
           2. EBB → KUL (Entebbe to Kuala Lumpur)
           3. FIH → SIN (Kinshasa to Singapore)
           4. EBB → SIN (Entebbe to Singapore)
           5. FIH → BKK (Kinshasa to Bangkok)
           6. EBB → BKK (Entebbe to Bangkok)
           7. FIH → CGK (Kinshasa to Jakarta)
           8. EBB → CGK (Entebbe to Jakarta)

           For each route found, record:
           - Transit hub(s) used (e.g., DXB, DOH, NBO)
           - Approximate transit time in hub (hours)

Output   : data/processed/air_routes.csv with the following columns:
           origin_airport, destination_airport, airline_example,
           transit_hub, transit_time_hours, route_exists (TRUE/FALSE)

           Minimum: 8 rows (one per route pair searched).

Note     : MOH Malaysia has confirmed monitoring of travellers via Dubai,
           Doha, and Singapore. These three are your primary transit hubs
           and MUST be in the route table. All routes from DRC/Uganda
           to ASEAN will transit via at least one of these.

On Fail  : If Google Flights returns no results for a route, mark
           route_exists as FALSE. Do not fabricate routes. The analysis
           can proceed with zero direct routes — it will model transit-
           adjusted risk instead.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 13 — Estimate travel volumes: DRC/Uganda to ASEAN
──────────────────────────────────────────────────────
Action   : Estimate the number of air travellers per week from DRC and
           Uganda to Malaysia and ASEAN hub countries using published
           proxy data. Record all estimates with source and uncertainty
           bounds in data/processed/travel_volumes.csv.

Input    : The following published sources (use in order of preference):

           SOURCE A (Primary): IATA published passenger statistics.
           For DRC (FIH) total outbound passengers 2024: ~450,000/year
           (source: IATA World Air Transport Statistics 2025 — public summary)
           For Uganda (EBB) total outbound passengers 2024: ~2.1 million/year
           (source: Uganda Civil Aviation Authority annual report 2024/25,
           publicly available at caa.go.ug)

           SOURCE B (Transit adjustment): Apply the following published
           proportions from COVID importation literature:
           - Proportion of DRC outbound passengers transiting via DXB/DOH
             to East/Southeast Asia: 0.8% (range 0.4%-1.5%)
             Source: Pullano G et al. Nature 2020 (COVID IATA data proxy)
           - Proportion of EBB outbound passengers transiting to
             Southeast Asia: 1.2% (range 0.7%-2.0%)
             Source: same Pullano et al. 2020

           SOURCE C (Malaysia-specific): MOH Malaysia stated no direct
           flights from DRC or Uganda to Malaysia. All arrivals are via
           transit hubs (DXB, DOH, SIN).

Tool     : Manual calculation. Create data/processed/travel_volumes.csv
           with the following columns and values:
           
           origin, destination, weekly_travellers_central,
           weekly_travellers_low, weekly_travellers_high, source

           Calculate weekly from annual by dividing by 52.
           Apply transit proportions from Source B.

           Example row (complete the rest):
           DRC (FIH), Malaysia (KUL), 69, 35, 130, IATA 2025 + Pullano 2020

           Rows required:
           1. DRC → Malaysia (KUL)
           2. Uganda → Malaysia (KUL)
           3. DRC → Singapore (SIN) [transit hub — all ASEAN via SIN]
           4. Uganda → Singapore (SIN)
           5. DRC → Thailand (BKK)
           6. Uganda → Thailand (BKK)
           7. DRC → Indonesia (CGK)
           8. Uganda → Indonesia (CGK)

Output   : data/processed/travel_volumes.csv exists with 8 rows and
           6 columns as specified above.

Note     : These travel volumes will have high uncertainty. This is
           intentional — the Monte Carlo model propagates this uncertainty
           into the final importation probability estimates. Do NOT
           present single-point estimates without uncertainty bounds.
           The ECDC used the same approach (acknowledged low-quality
           travel data from conflict-affected DRC).
           ⚠ HUMAN JUDGMENT REQUIRED: Review the calculated travel
           volume estimates before proceeding. If any weekly estimate
           exceeds 500 travellers for DRC → Malaysia (implausible given
           conflict context and no direct flights), halve the central
           estimate and widen the uncertainty interval.

On Fail  : If IATA/UCAA data cannot be accessed, use the ECDC's stated
           basis that the EU/EEA receives approximately 23,000 travellers
           per importation. Scale proportionally: Malaysia receives
           approximately 0.3% of global traveller volume compared to
           EU/EEA (from UNWTO 2024 data). Apply this scaling factor to
           derive Malaysia-specific estimates.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 14 — Extract epidemiological parameters from INRB-UMIE data
──────────────────────────────────────────────────────
Action   : Load the INRB-UMIE CSV data into R and calculate the following
           parameters: (1) most recent confirmed case count, (2) most
           recent confirmed death count, (3) CFR, (4) daily epidemic
           growth rate, (5) epidemic peak date if applicable.

Input    : File ~/bdbv2026-asean-importation/data/raw/ containing
           CSV files copied from INRB-UMIE in Steps 5-6.
           Also: who_don_series.csv from Step 8 as cross-validation.

Tool     : Create R script ~/bdbv2026-asean-importation/01_data_prep.R
           with the following code:

```r
library(tidyverse)
library(lubridate)
library(janitor)
library(here)

# --- Load INRB-UMIE SitRep data ---
# Adjust filename to match actual CSV in data/raw/
sitrep_files <- list.files(here("data", "raw"),
                           pattern = "insp_sitrep.*\\.csv",
                           full.names = TRUE)

if (length(sitrep_files) > 0) {
  sitrep <- read_csv(sitrep_files[1]) %>%
    clean_names() %>%
    mutate(date = as_date(date))
  message("INRB-UMIE SitRep loaded: ", nrow(sitrep), " rows")
} else {
  message("WARNING: No INRB-UMIE SitRep CSV found. Using WHO DON series only.")
  sitrep <- NULL
}

# --- Load WHO DON manual series ---
don <- read_csv(here("data", "raw", "who_don_series.csv")) %>%
  mutate(date = as_date(date))

# --- Calculate key parameters ---
# Use most recent row from whichever source has latest date
if (!is.null(sitrep)) {
  latest_date <- max(sitrep$date, na.rm = TRUE)
  latest_cases <- sitrep %>%
    filter(date == latest_date) %>%
    pull(confirmed_cases_total) %>%
    max(na.rm = TRUE)
  latest_deaths <- sitrep %>%
    filter(date == latest_date) %>%
    pull(confirmed_deaths_total) %>%
    max(na.rm = TRUE)
} else {
  latest_date <- max(don$date)
  latest_cases <- don %>%
    filter(date == latest_date) %>%
    pull(confirmed_cases_total)
  latest_deaths <- don %>%
    filter(date == latest_date) %>%
    pull(confirmed_deaths_total)
}

cfr <- latest_deaths / latest_cases

# --- Daily growth rate (r) from log-linear regression ---
if (!is.null(sitrep) && nrow(sitrep) >= 7) {
  growth_model <- lm(log(confirmed_cases_total + 1) ~ as.numeric(date),
                     data = sitrep %>% filter(!is.na(confirmed_cases_total)))
  daily_growth_rate <- coef(growth_model)[2]
  doubling_time <- log(2) / daily_growth_rate
} else {
  # Fallback: use WHO DON series
  growth_model <- lm(log(confirmed_cases_total + 1) ~ as.numeric(date),
                     data = don)
  daily_growth_rate <- coef(growth_model)[2]
  doubling_time <- log(2) / daily_growth_rate
}

# --- Save parameters ---
params <- tibble(
  parameter = c("latest_date", "confirmed_cases", "confirmed_deaths",
                "cfr", "daily_growth_rate_r", "doubling_time_days"),
  value = c(as.character(latest_date), latest_cases, latest_deaths,
            round(cfr, 4), round(daily_growth_rate, 4), round(doubling_time, 1))
)

write_csv(params, here("data", "processed", "epi_parameters.csv"))
message("Parameters saved to data/processed/epi_parameters.csv")
print(params)
```

Output   : File data/processed/epi_parameters.csv exists with 6 rows
           (one per parameter: latest_date, confirmed_cases,
           confirmed_deaths, cfr, daily_growth_rate_r, doubling_time_days).
           No NA values in the value column.
           Console shows the printed parameter table with numeric values.

Note     : The CFR from this analysis is used as an input to the
           importation model in Step 18. The daily growth rate is used
           for the scenario analysis in Step 20. If doubling_time_days
           is negative, the epidemic is declining — note this as a
           finding in the manuscript results.

On Fail  : If the CSV column names from INRB-UMIE do not match those
           in the script (confirmed_cases_total, confirmed_deaths_total,
           date), open the CSV in RStudio viewer (click the file in
           Files pane → View File) and identify the actual column names.
           Replace the column names in the script and re-run.
──────────────────────────────────────────────────────
```

```
══════════════════════════════════════════════════════
QUALITY GATE 2 — Parameters ready for modelling
══════════════════════════════════════════════════════
Check each item. ALL must be true to proceed.

  [ ] data/processed/epi_parameters.csv exists with 6 rows, no NA values
  [ ] data/processed/travel_volumes.csv exists with 8 rows
  [ ] data/processed/model_parameters.txt exists with ECDC parameters recorded
  [ ] data/processed/air_routes.csv exists with 8 rows
  [ ] CFR value in epi_parameters.csv is between 0.05 and 0.55
      (BDBV historical CFR range is 25%-51%; if outside this range,
      re-examine the confirmed_cases and confirmed_deaths columns)

If all pass → continue to Step 15
If any fail → return to failing step and resolve before proceeding
══════════════════════════════════════════════════════
```

---

## PHASE 3 — Monte Carlo Importation Model
### (Days 4-6)

---

```
──────────────────────────────────────────────────────
STEP 15 — Define model inputs and priors in R
──────────────────────────────────────────────────────
Action   : Create the second R script at 02_model.R. Add the model
           inputs section as shown below.

Input    : data/processed/epi_parameters.csv (from Step 14)
           data/processed/travel_volumes.csv (from Step 13)
           data/processed/model_parameters.txt (from Step 11)

Tool     : Create ~/bdbv2026-asean-importation/02_model.R in RStudio.
           Write the following code into the file exactly:

```r
library(tidyverse)
library(here)
set.seed(20260622)  # Date of plan creation — ensures reproducibility

# ============================================================
# SECTION 1: FIXED PARAMETERS
# ============================================================

N_ITER <- 10000     # Monte Carlo iterations
UI_LEVEL <- 0.90    # 90% uncertainty interval

# Incubation period: maximum 21 days (WHO IHR Ebola definition)
# Mean incubation for BDBV: 6-12 days (Feldmann H et al. NEJM 2007)
incubation_mean <- 9        # days
incubation_sd   <- 3        # days (triangular approximation)
incubation_max  <- 21       # days (WHO IHR)

# BDBV CFR range (historical 2007 + 2012 outbreaks): 25%-51%
# Current 2026 outbreak CFR: read from epi_parameters.csv
epi_params <- read_csv(here("data", "processed", "epi_parameters.csv"))
cfr_current <- as.numeric(
  epi_params$value[epi_params$parameter == "cfr"]
)
message("Using CFR from current outbreak data: ", round(cfr_current, 4))

# Proportion of infected travellers detectable at entry
# (symptomatic during travel window):
# Based on incubation distribution — proportion symptomatic
# within 21-day window given mean incubation of 9 days
p_symptomatic_at_border <- 1 - pnorm(incubation_max,
                                     mean = incubation_mean,
                                     sd = incubation_sd)
# NOTE: This is the proportion still incubating at border.
# We use 1 - this as the detectability window.

# Prevalence in outbreak zones:
# Estimated active infectious proportion at point in time
# Use confirmed cases in Ituri + North Kivu over 21-day window
# as proportion of total population (~5 million in affected HZ)
# This is a conservative estimate — likely underestimates true prevalence
# due to under-reporting (ascertainment ~15-30% per Imperial College)
cases_current <- as.numeric(
  epi_params$value[epi_params$parameter == "confirmed_cases"]
)
ASCERTAINMENT_RATIO_LOW  <- 0.15   # 15% of true cases confirmed
ASCERTAINMENT_RATIO_HIGH <- 0.30   # 30% of true cases confirmed
POPULATION_OUTBREAK_ZONE <- 5e6   # approx population in active health zones

# ============================================================
# SECTION 2: TRAVEL VOLUME INPUTS
# ============================================================

travel <- read_csv(here("data", "processed", "travel_volumes.csv"))

message("Travel volume data loaded for ", nrow(travel), " routes")
print(travel)
```

Output   : File 02_model.R exists at project root and runs without error
           (source the file in R console — no error messages, only the
           message lines printed).

Note     : The set.seed(20260622) call is mandatory for reproducibility.
           Any collaborator running this code on any machine must get
           identical results. Do not remove or change this line.

On Fail  : If read_csv throws "file not found" errors, check that
           here::here() is resolving to the correct project root by
           running here::here() in the console and confirming it returns
           the path to ~/bdbv2026-asean-importation/.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 16 — Implement the core importation probability function
──────────────────────────────────────────────────────
Action   : Add the Monte Carlo importation probability function to
           02_model.R immediately after the code from Step 15.

Input    : 02_model.R file from Step 15 (already open in RStudio).

Tool     : RStudio code editor. Append the following code to 02_model.R:

```r
# ============================================================
# SECTION 3: MONTE CARLO IMPORTATION PROBABILITY FUNCTION
# ============================================================
# Model: P(at least 1 importation) = 1 - (1 - p_infected_traveller)^N
# where:
#   p_infected_traveller = prevalence × (risk_window / serial_interval)
#   N = number of travellers in the study period
# Source: ECDC importation risk methodology (June 2026)

compute_importation_prob <- function(
    n_travellers_central,   # central estimate of weekly travellers
    n_travellers_low,       # lower bound (weekly)
    n_travellers_high,      # upper bound (weekly)
    cases_confirmed,        # confirmed cases in outbreak zone
    ascertainment_low,      # lower ascertainment ratio
    ascertainment_high,     # upper ascertainment ratio
    outbreak_population,    # population in affected zones
    study_weeks = 2,        # study period in weeks (default: 2-week window)
    n_iter = N_ITER,
    ui_level = UI_LEVEL
) {
  results <- numeric(n_iter)

  for (i in seq_len(n_iter)) {

    # 1. Sample travel volume from triangular distribution
    #    Using uniform approximation between low and high,
    #    weighted toward central
    n_travellers <- rnorm(
      1,
      mean = n_travellers_central * study_weeks,
      sd   = ((n_travellers_high - n_travellers_low) / 2) * study_weeks / 1.96
    )
    n_travellers <- max(0, round(n_travellers))

    # 2. Sample true case prevalence (adjusting for ascertainment)
    ascertainment <- runif(1, ascertainment_low, ascertainment_high)
    true_cases    <- cases_confirmed / ascertainment

    # 3. Compute prevalence in outbreak population
    prevalence <- true_cases / outbreak_population

    # 4. Probability that a random traveller from outbreak zone is infectious
    #    = prevalence × (fraction of incubation period during which
    #      traveller is infectious but not yet symptomatic enough to be
    #      flagged — approximately the entire incubation period)
    p_infectious_traveller <- min(prevalence * 0.5, 1)
    # The 0.5 factor: not all infectious individuals are in the
    # pre-symptomatic/early-symptomatic window. Conservative.

    # 5. Probability of at least one importation in study period
    p_at_least_one <- 1 - (1 - p_infectious_traveller)^n_travellers

    results[i] <- p_at_least_one
  }

  # Compute summary statistics
  alpha <- (1 - ui_level) / 2
  list(
    mean   = mean(results),
    median = median(results),
    lower  = quantile(results, alpha),
    upper  = quantile(results, 1 - alpha),
    raw    = results
  )
}
```

Output   : The function compute_importation_prob() is defined in
           02_model.R. Source the file in R console — no errors.
           Run the following test in console to verify function works:

             source("02_model.R")
             test <- compute_importation_prob(
               n_travellers_central = 100,
               n_travellers_low = 50,
               n_travellers_high = 200,
               cases_confirmed = 500,
               ascertainment_low = 0.15,
               ascertainment_high = 0.30,
               outbreak_population = 5e6
             )
             print(test$mean)  # Should be a number between 0 and 1

Note     : The 0.5 adjustment factor in step 4 of the function is a
           conservative assumption. State this explicitly in the
           manuscript methods section as a limitation.

On Fail  : If the function definition throws a syntax error, paste the
           entire function body into a fresh R script and run it to
           isolate which line causes the error.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 17 — Validate model against ECDC EU/EEA estimate
──────────────────────────────────────────────────────
Action   : Run the Monte Carlo model using EU/EEA travel volumes (from
           ECDC document) and verify the output matches the ECDC published
           estimate of 0.45% (90% UI: 0.20%-0.85%) to within ±0.3%.

Input    : Function compute_importation_prob() defined in 02_model.R.
           ECDC estimate: ~23,000 travellers per importation for EU/EEA.
           EU/EEA 2-week travel volume from DRC/Uganda: approximately
           2,000 travellers per week (derive from ECDC document Section 2).

Tool     : RStudio console. Append to 02_model.R and run:

```r
# ============================================================
# SECTION 4: MODEL VALIDATION AGAINST ECDC ESTIMATE
# ============================================================
validation <- compute_importation_prob(
  n_travellers_central = 2000,    # EU/EEA estimate from ECDC doc (per week)
  n_travellers_low     = 1200,
  n_travellers_high    = 3500,
  cases_confirmed      = cases_current,
  ascertainment_low    = ASCERTAINMENT_RATIO_LOW,
  ascertainment_high   = ASCERTAINMENT_RATIO_HIGH,
  outbreak_population  = POPULATION_OUTBREAK_ZONE,
  study_weeks          = 2
)

message(sprintf(
  "VALIDATION — EU/EEA: mean=%.3f%%, 90%% UI: %.3f%% - %.3f%%",
  validation$mean * 100,
  validation$lower * 100,
  validation$upper * 100
))
message("ECDC published: 0.45% (90% UI: 0.20%-0.85%)")
message("Difference from ECDC central: ",
        round(abs(validation$mean - 0.0045) * 100, 3), "%")
```

Output   : Console prints validation message. The mean value printed
           must be within ±0.3 percentage points of 0.45%.
           Acceptable range: 0.15% to 0.75%.

Note     : Exact replication of the ECDC figure is not expected because
           (a) you do not have their exact travel volume inputs and
           (b) their model may use a different distribution. The goal
           is plausibility validation, not exact replication. If the
           estimate is directionally consistent (same order of magnitude),
           the model is valid.
           ⚠ HUMAN JUDGMENT REQUIRED: If validation output is > 5%
           or < 0.001%, stop. The model has an error. Check ascertainment
           ratio and travel volume inputs before proceeding.

On Fail  : If output is outside the 0.15%-0.75% range, adjust the
           n_travellers_central value upward or downward by 20% and
           re-run. Document the adjustment in data/processed/model_parameters.txt
           with the note: "Travel volume adjusted for EU/EEA validation."
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 18 — Run main analysis: importation probability for all ASEAN routes
──────────────────────────────────────────────────────
Action   : Apply compute_importation_prob() to all 8 routes in
           travel_volumes.csv and save results to output/importation_results.csv.

Input    : travel_volumes.csv loaded in memory (from Step 15 code).
           compute_importation_prob() function defined in 02_model.R.
           epi_parameters.csv for cases_current and cfr_current values.

Tool     : Append the following code to 02_model.R and run:

```r
# ============================================================
# SECTION 5: MAIN ANALYSIS — ALL ASEAN ROUTES
# ============================================================

results_list <- vector("list", nrow(travel))

for (j in seq_len(nrow(travel))) {
  route <- travel[j, ]
  res <- compute_importation_prob(
    n_travellers_central = route$weekly_travellers_central,
    n_travellers_low     = route$weekly_travellers_low,
    n_travellers_high    = route$weekly_travellers_high,
    cases_confirmed      = cases_current,
    ascertainment_low    = ASCERTAINMENT_RATIO_LOW,
    ascertainment_high   = ASCERTAINMENT_RATIO_HIGH,
    outbreak_population  = POPULATION_OUTBREAK_ZONE,
    study_weeks          = 2
  )

  results_list[[j]] <- tibble(
    origin               = route$origin,
    destination          = route$destination,
    weekly_travellers    = route$weekly_travellers_central,
    p_import_mean_pct    = round(res$mean * 100, 4),
    p_import_lower_pct   = round(res$lower * 100, 4),
    p_import_upper_pct   = round(res$upper * 100, 4),
    travellers_per_import = round(1 / res$mean, 0)
  )
  message(sprintf("Route %d/%d complete: %s → %s = %.4f%%",
                  j, nrow(travel), route$origin, route$destination,
                  res$mean * 100))
}

results_df <- bind_rows(results_list)
write_csv(results_df, here("output", "importation_results.csv"))
message("Results saved to output/importation_results.csv")
print(results_df)
```

Output   : output/importation_results.csv exists with 8 rows and 7 columns:
           origin, destination, weekly_travellers, p_import_mean_pct,
           p_import_lower_pct, p_import_upper_pct, travellers_per_import.
           No NA values in any column.
           p_import_mean_pct values are all between 0 and 100.

Note     : Expected results based on low travel volumes:
           Malaysia route should show very low probability (<0.5% per
           2-week period), consistent with no direct flights.
           Singapore will show slightly higher (larger travel hub).
           If any route shows > 10%, re-examine travel volume inputs —
           they are likely too high.

On Fail  : If the loop fails on a specific row j, run the failed row
           in isolation by setting j to that row number and running just
           the inner compute_importation_prob() call. Identify the
           column causing the error.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 19 — Run Malaysia-specific analysis (primary policy output)
──────────────────────────────────────────────────────
Action   : Run a dedicated analysis for Malaysia including sensitivity
           analysis across three outbreak size scenarios (current, +50%,
           +100% case growth). Save to output/malaysia_results.csv.

Input    : Function compute_importation_prob() defined in 02_model.R.
           Malaysia travel volume rows from travel_volumes.csv.
           cases_current from epi_parameters.csv.

Tool     : Append the following code to 02_model.R and run:

```r
# ============================================================
# SECTION 6: MALAYSIA-SPECIFIC SENSITIVITY ANALYSIS
# ============================================================

malaysia_travel_drc <- travel %>%
  filter(grepl("Malaysia", destination, ignore.case = TRUE) &
         grepl("DRC", origin, ignore.case = TRUE))

malaysia_travel_uga <- travel %>%
  filter(grepl("Malaysia", destination, ignore.case = TRUE) &
         grepl("Uganda", origin, ignore.case = TRUE))

# Three scenarios: current cases, 50% more, 100% more
scenarios <- tibble(
  scenario_name  = c("Current", "50% growth", "100% growth"),
  cases_scenario = c(cases_current, cases_current * 1.5, cases_current * 2)
)

malaysia_results <- list()

for (s in seq_len(nrow(scenarios))) {
  # DRC → Malaysia
  res_drc <- compute_importation_prob(
    n_travellers_central = malaysia_travel_drc$weekly_travellers_central,
    n_travellers_low     = malaysia_travel_drc$weekly_travellers_low,
    n_travellers_high    = malaysia_travel_drc$weekly_travellers_high,
    cases_confirmed      = scenarios$cases_scenario[s],
    ascertainment_low    = ASCERTAINMENT_RATIO_LOW,
    ascertainment_high   = ASCERTAINMENT_RATIO_HIGH,
    outbreak_population  = POPULATION_OUTBREAK_ZONE,
    study_weeks          = 2
  )
  # Uganda → Malaysia
  res_uga <- compute_importation_prob(
    n_travellers_central = malaysia_travel_uga$weekly_travellers_central,
    n_travellers_low     = malaysia_travel_uga$weekly_travellers_low,
    n_travellers_high    = malaysia_travel_uga$weekly_travellers_high,
    cases_confirmed      = scenarios$cases_scenario[s],
    ascertainment_low    = ASCERTAINMENT_RATIO_LOW,
    ascertainment_high   = ASCERTAINMENT_RATIO_HIGH,
    outbreak_population  = POPULATION_OUTBREAK_ZONE,
    study_weeks          = 2
  )

  malaysia_results[[s]] <- tibble(
    scenario             = scenarios$scenario_name[s],
    cases_used           = scenarios$cases_scenario[s],
    source               = c("DRC", "Uganda"),
    p_import_mean_pct    = c(res_drc$mean * 100, res_uga$mean * 100),
    p_import_lower_pct   = c(res_drc$lower * 100, res_uga$lower * 100),
    p_import_upper_pct   = c(res_drc$upper * 100, res_uga$upper * 100)
  )
}

malaysia_df <- bind_rows(malaysia_results)
write_csv(malaysia_df, here("output", "malaysia_results.csv"))
message("Malaysia results saved to output/malaysia_results.csv")
print(malaysia_df)
```

Output   : output/malaysia_results.csv exists with 6 rows (3 scenarios
           x 2 source countries) and 6 columns.
           All p_import_mean_pct values are non-negative.

Note     : This output is the primary policy-relevant finding.
           The scenario analysis demonstrates what would happen if the
           outbreak continues to grow — directly relevant to Malaysia's
           ongoing border monitoring policy.

On Fail  : If malaysia_travel_drc has 0 rows (filter returned empty),
           the origin column in travel_volumes.csv may use different text.
           Open the CSV and inspect the origin column values, then
           adjust the grepl() pattern to match exactly.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 20 — Save all model outputs and commit to GitHub
──────────────────────────────────────────────────────
Action   : Verify all output files exist, then commit and push the
           entire project to GitHub.

Input    : All files in ~/bdbv2026-asean-importation/

Tool     : RStudio Terminal. Run:
             git add -A
             git commit -m "Phase 3 complete: model run, all output CSVs saved"
             git push origin main

Output   : GitHub repository at https://github.com/drfittri/bdbv2026-asean-importation
           shows the latest commit with message "Phase 3 complete..."
           Output files visible: output/importation_results.csv,
           output/malaysia_results.csv.

Note     : Do NOT commit the raw PDF files (DON602.pdf etc.) to GitHub
           as they are copyrighted WHO/ECDC documents. Add to .gitignore:
             data/raw/*.pdf
           Only CSV files and R scripts are committed.

On Fail  : If git push fails with authentication error, set up a GitHub
           Personal Access Token at github.com/settings/tokens and use
           it as password when prompted.
──────────────────────────────────────────────────────
```

```
══════════════════════════════════════════════════════
QUALITY GATE 3 — Model outputs validated and saved
══════════════════════════════════════════════════════
Check each item. ALL must be true to proceed.

  [ ] output/importation_results.csv exists with 8 rows, no NA values
  [ ] output/malaysia_results.csv exists with 6 rows, no NA values
  [ ] Validation in Step 17 produced output between 0.15% and 0.75%
  [ ] Malaysia importation probability (current scenario) is < 5% per
      2-week period (implausible if higher given no direct flights)
  [ ] All code in 02_model.R runs from top to bottom without error
      when sourced fresh (restart R session and re-source to confirm)
  [ ] Latest commit pushed to GitHub successfully

If all pass → continue to Step 21
If any fail → return to failing step and resolve before proceeding
══════════════════════════════════════════════════════
```

---

## PHASE 4 — Figures
### (Days 6-7)

---

```
──────────────────────────────────────────────────────
STEP 21 — Create Figure 1: ASEAN importation probability bar chart
──────────────────────────────────────────────────────
Action   : Create Figure 1 as a horizontal bar chart showing importation
           probability (%) with 90% UI error bars for all 8 routes.
           Save as figures/Figure1_ASEAN_importation.png at 300 dpi.

Input    : output/importation_results.csv (from Step 18)

Tool     : Create ~/bdbv2026-asean-importation/03_figures.R with:

```r
library(tidyverse)
library(ggplot2)
library(here)

results <- read_csv(here("output", "importation_results.csv"))

# Clean route labels
results <- results %>%
  mutate(route_label = paste0(origin, " → ", destination))

fig1 <- ggplot(results,
               aes(x = reorder(route_label, p_import_mean_pct),
                   y = p_import_mean_pct)) +
  geom_col(fill = "#2C5F8A", alpha = 0.85, width = 0.6) +
  geom_errorbar(
    aes(ymin = p_import_lower_pct, ymax = p_import_upper_pct),
    width = 0.3, colour = "#1A3A5C", linewidth = 0.7
  ) +
  coord_flip() +
  labs(
    title    = "Estimated probability of BDBV importation to ASEAN countries",
    subtitle = "2-week period, as of June 2026 (90% uncertainty interval)",
    x        = NULL,
    y        = "Probability of at least one importation (%)",
    caption  = paste0(
      "BDBV: Bundibugyo virus. Monte Carlo simulation (n=10,000 iterations).\n",
      "Based on INRB-UMIE/Ebola_DRC_2026 data and ECDC importation model (June 2026).\n",
      "Travel volumes estimated from IATA 2025 and published proxy data."
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(colour = "grey40", size = 10),
    plot.caption  = element_text(colour = "grey50", size = 8),
    axis.text.y   = element_text(size = 10),
    panel.grid.major.y = element_blank()
  )

ggsave(here("figures", "Figure1_ASEAN_importation.png"),
       plot = fig1, width = 8, height = 5, dpi = 300)
message("Figure 1 saved.")
```

Output   : figures/Figure1_ASEAN_importation.png exists, is 300 dpi,
           and shows 8 horizontal bars with error bars. File size > 50 KB.

Note     : Eurosurveillance accepts figures as TIFF or high-resolution PNG.
           300 dpi PNG is sufficient. If TIFF is required, change ggsave
           extension to .tiff and add device = "tiff".

On Fail  : If ggsave throws "cannot open file" error, check that the
           figures/ directory exists: dir.create(here("figures"), showWarnings = FALSE)
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 22 — Create Figure 2: Malaysia scenario analysis plot
──────────────────────────────────────────────────────
Action   : Create Figure 2 as a grouped bar chart showing Malaysia
           importation probability across 3 outbreak growth scenarios,
           by source country (DRC vs Uganda). Save as
           figures/Figure2_Malaysia_scenarios.png at 300 dpi.

Input    : output/malaysia_results.csv (from Step 19)

Tool     : Append the following to 03_figures.R and run:

```r
malaysia <- read_csv(here("output", "malaysia_results.csv"))

malaysia$scenario <- factor(malaysia$scenario,
                            levels = c("Current", "50% growth", "100% growth"))

fig2 <- ggplot(malaysia,
               aes(x = scenario, y = p_import_mean_pct,
                   fill = source, group = source)) +
  geom_col(position = position_dodge(width = 0.7),
           width = 0.6, alpha = 0.85) +
  geom_errorbar(
    aes(ymin = p_import_lower_pct, ymax = p_import_upper_pct),
    position = position_dodge(width = 0.7),
    width = 0.3, linewidth = 0.7
  ) +
  scale_fill_manual(
    values = c("DRC" = "#C0392B", "Uganda" = "#E67E22"),
    name   = "Origin country"
  ) +
  labs(
    title    = "BDBV importation risk to Malaysia under outbreak growth scenarios",
    subtitle = "2-week period, 90% uncertainty interval",
    x        = "Outbreak scenario",
    y        = "Probability of at least one importation (%)",
    caption  = paste0(
      "Scenario assumes proportional increase in confirmed case count.\n",
      "No direct flights from DRC or Uganda to Malaysia (MOH Malaysia, May 2026).\n",
      "All routes transit via Dubai, Doha, or Singapore."
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(colour = "grey40", size = 10),
    plot.caption  = element_text(colour = "grey50", size = 8),
    legend.position = "top"
  )

ggsave(here("figures", "Figure2_Malaysia_scenarios.png"),
       plot = fig2, width = 7, height = 5, dpi = 300)
message("Figure 2 saved.")
```

Output   : figures/Figure2_Malaysia_scenarios.png exists, 300 dpi,
           shows grouped bars for Current/50%/100% growth scenarios,
           colour-coded by DRC vs Uganda. File size > 50 KB.

Note     : Eurosurveillance Rapid Communications allow maximum 2 figures.
           These two figures are your full quota. No additional figures.

On Fail  : Same as Step 21 — check figures/ directory exists.
──────────────────────────────────────────────────────
```

---

## PHASE 5 — Manuscript Writing
### (Days 7-12)

---

```
──────────────────────────────────────────────────────
STEP 23 — Create manuscript file and write Title + Abstract
──────────────────────────────────────────────────────
Action   : Create manuscript/manuscript.md and write the Title and
           Structured Abstract (≤250 words, Eurosurveillance format).

Input    : output/importation_results.csv, output/malaysia_results.csv,
           epi_parameters.csv — open these files in RStudio viewer to
           reference actual numbers while writing.

Tool     : RStudio → New File → Markdown File, save as
           ~/bdbv2026-asean-importation/manuscript/manuscript.md

Output   : manuscript/manuscript.md exists and contains:
           - Title (≤20 words)
           - Abstract with 4 labelled sections: Background, Methods,
             Results, Conclusion (total ≤250 words)
           - No placeholder text ("[insert here]") remaining

           Required content for each section (minimum):

           TITLE: Must include "Bundibugyo virus", "importation",
           "ASEAN" or "Malaysia", and "2026".

           BACKGROUND (40-60 words): State that BDBV 2026 is a PHEIC,
           CFR range, no licensed vaccine or specific therapeutic, and
           that quantified importation risk for Southeast Asia is absent
           from the literature.

           METHODS (60-80 words): State Monte Carlo simulation,
           10,000 iterations, 90% UI, data sources (INRB-UMIE,
           WHO DON, ECDC methodology), travel volume estimation,
           ASEAN countries studied (list all 4), and study period
           (2-week rolling window).

           RESULTS (80-100 words): State the central estimate and 90% UI
           for Malaysia (both DRC and Uganda source), most notable ASEAN
           finding, and the scenario analysis direction.

           CONCLUSION (30-50 words): State the policy implication for
           MOH Malaysia IHR preparedness and call for quantified
           surveillance triggers.

Note     : Write results using the actual numbers from your output files.
           Do not use placeholder values. Every number must be traceable
           to an output CSV row.

On Fail  : Cannot fail — text file writing. If word processor crashes,
           write abstract in any plain text editor and save as .md.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 24 — Write Introduction section (target: 200-250 words)
──────────────────────────────────────────────────────
Action   : Write the Introduction section of the manuscript and append
           it to manuscript/manuscript.md.

Input    : manuscript/manuscript.md from Step 23.
           Key citations to include (verified, do not hallucinate):
           [1] WHO DON602 (15 May 2026) for outbreak declaration
           [2] WHO DON603 (21 May 2026) for PHEIC declaration
           [3] Feldmann H, Jones S, Schnittler H, Geisbert T. NEJM 2007
               (BDBV 2007 Uganda outbreak — CFR ~25%)
           [4] ECDC threat assessment brief, May 2026 (51 confirmed
               cases DRC + 2 Uganda as of 18 May)
           [5] McCabe R et al. Lancet Infect Dis. 2026 (under-reporting)
           [6] MOH Malaysia preparedness statement, 22 May 2026

Tool     : RStudio Markdown editor. Append to manuscript.md.

Output   : Introduction section in manuscript.md, 200-250 words,
           covering:
           (1) BDBV background: rare filovirus, 3 prior outbreaks,
               no licensed vaccine/therapeutic (cite [3])
           (2) 2026 outbreak declaration and PHEIC (cite [1], [2])
           (3) Rapid case growth and geographic expansion (cite [4], [5])
           (4) Malaysia and ASEAN context: no direct flights, transit
               routing via major hubs, MOH preparedness (cite [6])
           (5) Gap in literature: no ASEAN-specific importation
               quantification exists
           (6) Aim of this study (1 sentence)

Note     : Do not use em-dashes. Use commas or colons instead.
           Write in active voice. Vancouver citation style (numbered
           superscripts). All citations must be verifiable via PubMed
           or official government URLs.

On Fail  : Cannot fail. If uncertain about a citation, mark it as
           [VERIFY] in the draft and check against PubMed or the
           official source before submission.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 25 — Write Methods section (target: 350-450 words)
──────────────────────────────────────────────────────
Action   : Write the Methods section and append it to manuscript.md.

Input    : 02_model.R (for exact model specification)
           data/processed/model_parameters.txt
           data/processed/travel_volumes.csv
           ECDC importation risk brief (as methodological reference)

Tool     : RStudio Markdown editor. Append to manuscript.md.

Output   : Methods section in manuscript.md, 350-450 words, with these
           required subsections and minimum content:

           STUDY DESIGN (30-50 words):
           State: secondary analysis of publicly available surveillance
           data; no primary data collection; ethics waiver applicable
           (cite your institution or state: "Data were publicly available
           and did not require ethical approval"); study period.

           DATA SOURCES (80-100 words):
           Name all 4 data sources with citations:
           (a) INRB-UMIE/Ebola_DRC_2026 GitHub (cite repo URL)
           (b) WHO DON series DON602, DON603 (cite URLs)
           (c) IATA passenger statistics 2025 (cite)
           (d) ECDC importation risk brief June 2026 (cite)

           EPIDEMIOLOGICAL PARAMETERS (60-80 words):
           State: incubation period (9 days mean, max 21 days per
           WHO IHR), ascertainment ratio range (15%-30%), outbreak
           population denominator (5 million), confirmed case count
           used (from epi_parameters.csv — state the actual number),
           CFR (from epi_parameters.csv — state the actual number).

           TRAVEL VOLUME ESTIMATION (80-100 words):
           State: no direct flights from DRC/Uganda to Malaysia (cite
           MOH Malaysia May 2026); transit-adjusted estimates derived
           from IATA 2025 annual statistics and published COVID-era
           travel proportion estimates (cite Pullano et al. Nature 2020);
           countries studied: Malaysia, Singapore, Thailand, Indonesia;
           2-week study period.

           STATISTICAL MODEL (80-100 words):
           State the model equation:
           P(importation) = 1 - (1 - p_infectious_traveller)^N
           State: Monte Carlo simulation, 10,000 iterations, 90% UI,
           set.seed(20260622), conservative ascertainment assumption,
           three outbreak growth scenarios. State that all code is
           available at github.com/drfittri/bdbv2026-asean-importation.

Note     : The model equation must appear exactly as stated above.
           Do not rephrase it.

On Fail  : Cannot fail. Mark uncertain numbers as [VERIFY] and
           confirm against output CSVs before submission.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 26 — Write Results section (target: 350-450 words)
──────────────────────────────────────────────────────
Action   : Write the Results section and append it to manuscript.md.

Input    : output/importation_results.csv (all routes)
           output/malaysia_results.csv (Malaysia scenarios)
           data/processed/epi_parameters.csv
           figures/Figure1_ASEAN_importation.png
           figures/Figure2_Malaysia_scenarios.png

Tool     : RStudio Markdown editor. Append to manuscript.md.
           Open output CSVs in RStudio viewer while writing to copy
           exact numbers.

Output   : Results section in manuscript.md, 350-450 words, structured
           as follows (each paragraph mandatory):

           PARAGRAPH 1 — Epidemic status (50-80 words):
           State as of latest data date: confirmed cases, confirmed deaths,
           CFR, provinces affected (cite INRB-UMIE data and WHO DON).
           State epidemic growth rate or doubling time from
           epi_parameters.csv (daily_growth_rate_r and doubling_time_days).

           PARAGRAPH 2 — Air travel routes (50-60 words):
           State that no direct flights exist from DRC or Uganda to any
           ASEAN country studied. All travel routes identified transit via
           one or more of Dubai, Doha, Nairobi, or Singapore. Estimated
           weekly travellers for each route (from travel_volumes.csv,
           state the central estimates).

           PARAGRAPH 3 — ASEAN importation results (80-100 words):
           Refer to Figure 1. State the central probability and 90% UI
           for each of the 4 destination countries for the highest-risk
           route. State which destination has the highest probability and
           which has the lowest. State the estimated number of travellers
           per importation for Malaysia.

           PARAGRAPH 4 — Malaysia scenario analysis (80-100 words):
           Refer to Figure 2. State the current scenario probability for
           Malaysia (DRC source and Uganda source separately). State how
           the probability changes under the 50% and 100% growth scenarios.
           State the direction of change (increases proportionally).

           PARAGRAPH 5 — Comparator: ECDC estimate (40-60 words):
           State that the ECDC estimated 0.45% (90% UI: 0.20%-0.85%)
           probability of importation to EU/EEA per 2-week period.
           State how your Malaysia estimate compares (higher, lower, or
           similar) and provide a brief explanation (e.g., lower travel
           volumes to Malaysia vs EU/EEA).

Note     : Every number in the Results must match an exact value in
           an output CSV. Do not round to fewer decimal places than
           are in the CSV. Use consistent decimal places throughout.

On Fail  : Cannot fail. If a CSV value is NA, report "data not available
           for this route" in the manuscript.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 27 — Write Discussion section (target: 350-450 words)
──────────────────────────────────────────────────────
Action   : Write the Discussion section and append it to manuscript.md.

Input    : manuscript.md (Title through Results sections already written)
           ECDC importation risk brief (PDF in data/raw/)
           McCabe R et al. Lancet Infect Dis 2026 (cite DOI: 10.1016/S1473-3099(26)00299-9)

Tool     : RStudio Markdown editor. Append to manuscript.md.

Output   : Discussion section in manuscript.md, 350-450 words, with
           these mandatory components (each paragraph minimum):

           PARAGRAPH 1 — Main finding interpretation (80-100 words):
           Restate the key finding without repeating the exact numbers.
           Interpret what the probability estimate means in operational
           terms for Malaysia. Compare to ECDC estimate and explain why
           the difference is expected (lower travel volumes, transit-
           attenuated exposure). State that even low probability
           warrants preparedness given high CFR of 25%-51%.

           PARAGRAPH 2 — Under-reporting context (60-80 words):
           Cite McCabe et al. 2026 (Lancet ID) on under-reporting.
           State that your model accounts for ascertainment ratios of
           15%-30%. Explain that true prevalence in outbreak zones is
           likely higher than confirmed case counts suggest, so
           importation risk may be higher than central estimates.

           PARAGRAPH 3 — Policy implications for Malaysia (80-100 words):
           Cite MOH Malaysia preparedness statement (May 2026).
           Discuss: (a) transit hub monitoring at SIN/DXB/DOH is
           appropriate given all routes transit these hubs; (b) border
           health screening limitations (low specificity for non-specific
           early BDBV symptoms per ECDC); (c) health care worker
           awareness needed for returning travellers with fever and
           travel history from East/Central Africa; (d) IHR point of
           entry (POE) capacity should be maintained at KLIA.

           PARAGRAPH 4 — Limitations (80-100 words):
           State: (a) travel volume data are estimates with high
           uncertainty (no Malaysia-specific IATA data available);
           (b) model assumes homogeneous mixing in outbreak zones;
           (c) transit hub dwell-time risk not modelled; (d) ascertainment
           ratios from historical Ebola outbreaks may not apply to BDBV;
           (e) outbreak dynamics change rapidly and estimates require
           updating as new data become available.

Note     : Do not use em-dashes. Limitations must be honest and specific —
           not boilerplate. The policy implications paragraph must name
           specific Malaysian infrastructure (KLIA, KKM units).

On Fail  : Cannot fail. Mark any uncertain claim with [VERIFY] and
           confirm before submission.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 28 — Write Conclusion and compile References
──────────────────────────────────────────────────────
Action   : Write Conclusion (≤100 words) and compile a numbered
           reference list in Vancouver style at the end of manuscript.md.

Input    : manuscript.md (all sections written through Step 27).
           All citations marked [1] through [N] throughout the manuscript.

Tool     : RStudio Markdown editor. Append to manuscript.md.

Output   : Conclusion section ≤100 words stating:
           (1) BDBV importation to Malaysia is possible but low-probability
               given current travel patterns;
           (2) Risk increases proportionally with outbreak growth;
           (3) Transit hub monitoring and IHR POE preparedness are
               appropriate and should continue;
           (4) Reproducible modelling frameworks should be established
               in advance of future PHEIC events.

           Reference list immediately after, format:
           [1] Author A, Author B. Title. Journal. Year;Volume(Issue):Pages. DOI.
           
           Mandatory references (verify all DOIs before submission):
           [1] WHO. Disease Outbreak News: BDBV DRC 2026 (DON602). 2026.
               URL: https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602
           [2] WHO. Disease Outbreak News: BDBV DRC and Uganda (DON603). 2026.
               URL: https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON603
           [3] McCabe R, et al. Estimation of Ebola outbreak size in DRC.
               Lancet Infect Dis. 2026. DOI: 10.1016/S1473-3099(26)00299-9
           [4] ECDC. Threat assessment brief: BDBV DRC and Uganda. 2026.
               URL: https://www.ecdc.europa.eu/en/...
           [5] ECDC. Estimation of importation risk of Bundibugyo virus
               into EU/EEA in June 2026. Stockholm: ECDC; 2026.
           [6] INRB-UMIE. Ebola_DRC_2026. GitHub. 2026.
               URL: https://github.com/INRB-UMIE/Ebola_DRC_2026
           [7] MOH Malaysia. Kenyataan Media: Ebola. May 2026.
               (Cite official MOH press release URL if available)
           [8] Pullano G, et al. Underdetection of cases of COVID-19 in
               France threatens epidemic control. Nature. 2021;590:134-139.
               DOI: 10.1038/s41586-020-03095-6

Note     : Check every DOI by pasting it into https://doi.org/ before
           submission. If a DOI returns a 404 error, the citation is
           wrong — correct it or remove it.

On Fail  : If a reference cannot be verified, remove it from the
           manuscript entirely. Do not submit with unverified citations.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 29 — Count words and verify Eurosurveillance format compliance
──────────────────────────────────────────────────────
Action   : Count total manuscript word count and verify it meets
           Eurosurveillance Rapid Communication requirements.

Input    : manuscript/manuscript.md (complete draft from Steps 23-28)

Tool     : RStudio Terminal. Run:
             wc -w manuscript/manuscript.md

           Alternatively, paste manuscript text into wordcounter.net
           or use RStudio's built-in word count (Tools → Word Count).

Output   : Word count result is displayed. The following limits must
           all be met:
           - Abstract: ≤250 words (count abstract section only)
           - Main text (Introduction + Methods + Results + Discussion +
             Conclusion, excluding references): 1200-1800 words
           - Total manuscript (including abstract, excluding references):
             ≤2100 words
           - Number of figures: exactly 2 (Figure 1 and Figure 2)
           - Number of tables: 0 (results are in figures)

Note     : Eurosurveillance Rapid Communication format allows max 1500
           words main text + 250 word abstract = 1750 total. If over
           limit, cut from Discussion first (remove one full paragraph),
           then from Methods if still over.

On Fail  : If word count exceeds limit, identify the longest paragraph
           in Discussion (count words per paragraph using the Terminal
           command above on a copy of each paragraph). Shorten that
           paragraph by 30% while preserving all factual content.
           Re-count. Repeat until within limit.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 30 — Internal review: check for hallucinated numbers
──────────────────────────────────────────────────────
Action   : Cross-check every numerical value in the manuscript against
           its source CSV or PDF. Mark any discrepancy for correction.

Input    : manuscript/manuscript.md (complete draft)
           output/importation_results.csv
           output/malaysia_results.csv
           data/processed/epi_parameters.csv
           data/raw/ECDC_importation_risk_June2026.pdf

Tool     : Open manuscript.md in RStudio. For each number in the text,
           locate its source CSV row and confirm it matches exactly.
           Use Ctrl+F to find numbers in the manuscript.

Output   : A review checklist saved as manuscript/internal_review.txt
           with one line per number checked:

           Number | Source file | Row/column | Match? (Y/N)
           [example: 0.23% | importation_results.csv | row 3 col 4 | Y]

           All rows in the checklist must show Y in the Match column.

Note     : Pay special attention to:
           (a) CFR value (must match epi_parameters.csv)
           (b) Confirmed case count (must match epi_parameters.csv)
           (c) Malaysia probability (must match malaysia_results.csv)
           (d) ECDC comparator value of 0.45% (must match ECDC document)
           ⚠ HUMAN JUDGMENT REQUIRED: Read each sentence in Results
           and Discussion and ask: "Is this claim supported by a specific
           number in an output file or a cited publication?" If not,
           either delete the claim or find the supporting source.

On Fail  : For any discrepancy (N in Match column), return to manuscript.md,
           correct the number to match the source file, and update the
           checklist row to Y. Do not proceed to Step 31 until all rows
           are Y.
──────────────────────────────────────────────────────
```

```
══════════════════════════════════════════════════════
QUALITY GATE 4 — Manuscript ready for preprint
══════════════════════════════════════════════════════
Check each item. ALL must be true to proceed.

  [ ] manuscript/manuscript.md is complete (all sections present)
  [ ] Word count ≤ 2100 (excluding references)
  [ ] Abstract ≤ 250 words
  [ ] Exactly 2 figures (both saved as 300 dpi PNG in figures/)
  [ ] All numerical values cross-checked against source CSVs (Step 30)
  [ ] All DOIs in reference list verified at doi.org
  [ ] manuscript/internal_review.txt exists with all rows showing Y
  [ ] No em-dashes in manuscript
  [ ] GitHub repository is up to date (all code, CSVs, and figures pushed)

If all pass → continue to Step 31
If any fail → return to failing step and resolve before proceeding
══════════════════════════════════════════════════════
```

---

## PHASE 6 — Preprint and Submission
### (Days 12-14)

---

```
──────────────────────────────────────────────────────
STEP 31 — Convert manuscript.md to submission-ready format
──────────────────────────────────────────────────────
Action   : Convert manuscript.md to a Microsoft Word .docx file for
           journal submission.

Input    : manuscript/manuscript.md (complete, QG4-passed)

Tool     : RStudio Terminal. Run (requires pandoc, which ships with
           RStudio):
             cd ~/bdbv2026-asean-importation
             pandoc manuscript/manuscript.md -o manuscript/manuscript.docx \
               --reference-doc=manuscript/reference.docx

           If reference.docx does not exist, run without it:
             pandoc manuscript/manuscript.md -o manuscript/manuscript.docx

Output   : manuscript/manuscript.docx exists. Open it in Microsoft Word
           or LibreOffice Writer and confirm:
           - All section headings are present
           - All tables render correctly
           - Figure captions are present (figures themselves attached
             separately per journal instructions)
           - Reference list appears at the end

Note     : Eurosurveillance submission requires Word file (not PDF) for
           the manuscript and separate image files for figures.
           Do not embed figures in the Word file.

On Fail  : If pandoc is not found, install from https://pandoc.org.
           Alternatively, paste the content of manuscript.md directly
           into a new Word document and apply Heading 1/2 styles manually.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 32 — Upload preprint to medRxiv
──────────────────────────────────────────────────────
Action   : Submit the manuscript as a preprint to medRxiv to establish
           priority and enable immediate open access.

Input    : manuscript/manuscript.docx (from Step 31)
           figures/Figure1_ASEAN_importation.png
           figures/Figure2_Malaysia_scenarios.png

Tool     : Web browser. Navigate to https://www.medrxiv.org/submit
           Create account if needed (free, institutional email preferred).
           Complete the submission form:
           - Category: Epidemiology
           - Title: [copy from manuscript.md]
           - Abstract: [copy from manuscript.md abstract section]
           - Upload manuscript: manuscript.docx
           - Upload supplementary files: Figure1.png, Figure2.png
           - Authors: [your name], [co-author if applicable]
           - Corresponding author email: your institutional email
           - Funding: None (or state DrPH programme if applicable)
           - Data availability: All data and code at
             github.com/drfittri/bdbv2026-asean-importation
           - Ethics: Public data, no ethics approval required.

Output   : medRxiv submission confirmation email received.
           Preprint DOI assigned (typically within 24-48 hours after
           moderation). Record the DOI in manuscript/SUBMISSION_LOG.txt.

Note     : medRxiv preprints are not peer-reviewed. The posting does not
           affect journal submission eligibility — Eurosurveillance and
           WPSAR both allow prior preposting.
           ⚠ HUMAN JUDGMENT REQUIRED: Read the entire manuscript one
           final time before clicking Submit on medRxiv. Once submitted,
           revisions create a new version but the original is permanent.

On Fail  : If medRxiv submission fails, submit to OSF Preprints instead
           (https://osf.io/preprints) as an immediate fallback. OSF
           is faster and does not require moderation.
──────────────────────────────────────────────────────
```

```
══════════════════════════════════════════════════════
QUALITY GATE 5 — Pre-submission to journal (irreversible)
══════════════════════════════════════════════════════
Check each item. ALL must be true before submitting to Eurosurveillance.

  [ ] medRxiv preprint DOI has been received (not just submitted —
      must be posted and publicly accessible)
  [ ] manuscript.docx opens correctly in Word with all sections present
  [ ] Figure 1 and Figure 2 PNG files are 300 dpi and labelled correctly
  [ ] All author names and affiliations are correctly spelled
  [ ] Conflict of interest statement is included (state "None" if true)
  [ ] Funding statement is included
  [ ] Data availability statement includes GitHub URL
  [ ] All reference DOIs verified (revisit doi.org for each)
  [ ] Word count confirmed ≤ 1500 main text + 250 abstract

If all pass → continue to Step 33
If any fail → fix the issue before submitting. This step is irreversible.
══════════════════════════════════════════════════════
```

```
──────────────────────────────────────────────────────
STEP 33 — Submit to Eurosurveillance
──────────────────────────────────────────────────────
Action   : Submit the manuscript to Eurosurveillance via their online
           submission portal.

Input    : manuscript/manuscript.docx
           figures/Figure1_ASEAN_importation.png
           figures/Figure2_Malaysia_scenarios.png
           medRxiv DOI (recorded in manuscript/SUBMISSION_LOG.txt)

Tool     : Web browser. Navigate to:
           https://www.eurosurveillance.org/page/ForAuthors
           Click "Submit a manuscript" → Rapid Communication category.
           Complete all fields:
           - Submission type: Rapid Communication
           - Title: [from manuscript]
           - Keywords: Bundibugyo virus, Ebola, importation risk,
             Malaysia, ASEAN, travel epidemiology, Monte Carlo
           - Upload manuscript: manuscript.docx
           - Upload figures: Figure1.png and Figure2.png separately
             with captions typed into the form
           - Cover letter: Write a brief cover letter (see Step 34)
           - Preprint link: paste medRxiv DOI URL

Output   : Eurosurveillance submission confirmation email received with
           manuscript tracking number. Record tracking number in
           manuscript/SUBMISSION_LOG.txt.

Note     : Eurosurveillance targets 10-business-day review for Rapid
           Communications during active public health events. If no
           response within 14 days, send one polite email to the editorial
           office citing the tracking number and the active PHEIC context.

On Fail  : If Eurosurveillance rejects desk-review (without full review),
           submit immediately to WPSAR:
           https://ojs.wpro.who.int/ojs/index.php/wpsar/about/submissions
           WPSAR is open access, WHO-affiliated, and accepts applied
           epidemiology with lower novelty threshold.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 34 — Write and attach cover letter
──────────────────────────────────────────────────────
Action   : Write the journal cover letter and save as
           manuscript/cover_letter.docx.

Input    : Journal name (Eurosurveillance), manuscript title,
           medRxiv DOI, your name and institution.

Tool     : Microsoft Word or LibreOffice Writer. Write the following
           letter (200-250 words):

---
Dear Editors,

We submit for consideration as a Rapid Communication our manuscript titled:
"[Full title]"

The ongoing outbreak of Bundibugyo virus disease in the Democratic Republic
of the Congo and Uganda, declared a Public Health Emergency of International
Concern on 17 May 2026, represents an acute global health threat. To date,
no quantified importation risk estimate exists for Southeast Asia, a region
with indirect air connectivity to the outbreak zone via major transit hubs.

This manuscript presents a reproducible Monte Carlo simulation estimating
the probability of BDBV importation to Malaysia, Singapore, Thailand, and
Indonesia, using publicly available epidemiological and air travel data.
The analysis provides directly actionable estimates for national health
authorities implementing IHR-based preparedness measures.

All data and code are openly available at:
github.com/drfittri/bdbv2026-asean-importation

A preprint is available at: [medRxiv DOI URL]

No competing interests are declared. This study used publicly available
aggregated surveillance data and did not require ethics approval.

We believe this work is time-sensitive and directly relevant to your
readership of public health practitioners in the European and global context.

Yours sincerely,
[Name]
[Designation and institution]
[Email]
---

Output   : manuscript/cover_letter.docx exists with the letter content
           above, personalised with actual title, DOI, name, institution,
           and email. No placeholder brackets remaining.

Note     : The cover letter must not exceed one page.

On Fail  : Cannot fail. If Word is not available, save as .txt and
           paste directly into the journal submission form's cover
           letter text box.
──────────────────────────────────────────────────────
```

---

## PHASE 7 — Post-Submission: CEPI Positioning and Follow-up

---

```
──────────────────────────────────────────────────────
STEP 35 — Update GitHub README with preprint DOI and citation
──────────────────────────────────────────────────────
Action   : Update README.md with the medRxiv preprint DOI and citation
           once the preprint is publicly accessible.

Input    : README.md at project root (from Step 2).
           medRxiv DOI from SUBMISSION_LOG.txt.

Tool     : RStudio editor. Add to README.md immediately after the
           project title:

## Citation
[Your name]. Quantifying the probability of Bundibugyo virus importation
to Malaysia and ASEAN hub countries during the 2026 PHEIC: a travel
epidemiology modelling study. medRxiv 2026. DOI: [actual DOI]

Output   : README.md updated and pushed to GitHub. The DOI is a clickable
           hyperlink when rendered on GitHub.

Note     : Do this as soon as the medRxiv DOI is live. The timestamp on
           the preprint establishes your priority date.

On Fail  : Cannot fail. Text file edit.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 36 — Post a brief summary on LinkedIn targeting CEPI visibility
──────────────────────────────────────────────────────
Action   : Write and post a LinkedIn post announcing the preprint.

Input    : medRxiv DOI URL. GitHub repository URL.

Tool     : LinkedIn (web or app). Write a post of 150-200 words with
           the following required elements:
           (a) Opening sentence stating the preprint is live
           (b) One key finding (Malaysia importation probability)
           (c) Policy relevance sentence for MOH Malaysia
           (d) Link to medRxiv preprint
           (e) Link to GitHub repository
           (f) Tags: #BDBV #Ebola2026 #PublicHealth #Epidemiology
               #Malaysia #TravelEpidemiology #OpenScience #CEPI
           (g) Tag: @CEPI_Innovations if the option is available

Output   : LinkedIn post is published and visible on your profile.
           Post URL recorded in SUBMISSION_LOG.txt.

Note     : Tag the CEPI LinkedIn page directly if your account allows.
           This creates a direct visibility channel to CEPI programme
           officers who monitor the BDBV outbreak literature.
           Do not overclaim the findings — state the limitations in
           one sentence in the post.

On Fail  : If LinkedIn is not available, post to Twitter/X with the
           same content compressed to 280 characters + link.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 37 — Submit a brief to MOH Malaysia IHR/KKM via MAE channel
──────────────────────────────────────────────────────
Action   : Prepare a 1-page policy brief derived from the manuscript
           and share it with the appropriate MOH Malaysia unit via your
           MAE (Malaysian Association of Epidemiology) network.

Input    : manuscript/manuscript.md (specifically the Results and
           Discussion sections).

Tool     : Microsoft Word. Create manuscript/policy_brief.docx
           with the following structure (1 page, max 400 words):

           TITLE: BDBV 2026 Importation Risk to Malaysia — Key Estimates
           DATE: [today]
           AUTHOR: [Name], Malaysian Association of Epidemiology
           PHEIC STATUS: WHO declared 17 May 2026

           KEY FINDING (2-3 sentences with numbers):
           [Copy key numbers from malaysia_results.csv]

           WHAT THIS MEANS FOR MALAYSIA (3 bullet points):
           [Actionable implications from Discussion PARAGRAPH 3]

           LIMITATIONS (2 bullet points, honest):
           [Abbreviated from manuscript Limitations]

           FULL ANALYSIS: [GitHub URL] | [medRxiv DOI]

Output   : manuscript/policy_brief.docx exists, is 1 page, and contains
           no placeholder text.

Note     : Send via email to your MAE contacts with the subject line:
           "BDBV 2026 Importation Risk Estimates for Malaysia — Policy Brief"
           Request that it be forwarded to KKM Digital Health / Unit IHR
           if the contact has that channel. Do not request attribution
           beyond "shared with permission of the author."

On Fail  : If no MAE contact is available, email directly to:
           KKM's official public health email if publicly listed.
           If unavailable, skip this step — it is optional for the
           publication track.
──────────────────────────────────────────────────────
```

```
──────────────────────────────────────────────────────
STEP 38 — Final commit and project archiving
──────────────────────────────────────────────────────
Action   : Make the final commit to GitHub including all manuscript files,
           submission log, and policy brief.

Input    : All files in ~/bdbv2026-asean-importation/

Tool     : RStudio Terminal. Run:
             git add -A
             git commit -m "Final: manuscript submitted, preprint live, policy brief complete"
             git push origin main

Output   : GitHub repository at https://github.com/drfittri/bdbv2026-asean-importation
           shows final commit with all the following present:
           - 01_data_prep.R
           - 02_model.R
           - 03_figures.R
           - data/raw/ (CSVs only, no PDFs)
           - data/processed/ (all processed files)
           - output/ (importation_results.csv, malaysia_results.csv)
           - figures/ (Figure1.png, Figure2.png)
           - manuscript/ (manuscript.md, manuscript.docx, cover_letter.docx,
             internal_review.txt, policy_brief.docx, SUBMISSION_LOG.txt)

Note     : After this step, the repository is the permanent, citable,
           open-science record of the analysis. Any reviewer or CEPI
           programme officer can reproduce the full analysis from scratch
           using only the GitHub repository.

On Fail  : If git push fails, retry once with:
             git push --force-with-lease origin main
           If still failing, create a ZIP archive of the project folder
           and upload it as a GitHub Release manually.
──────────────────────────────────────────────────────
```

---

```
══════════════════════════════════════════════════════
COMPLETION CHECKLIST
══════════════════════════════════════════════════════
Run these checks after Step 38. All must pass.

  [ ] GitHub repo https://github.com/drfittri/bdbv2026-asean-importation
      is public and all 38 steps have produced the expected outputs

  [ ] output/importation_results.csv exists with 8 rows, no NA values

  [ ] output/malaysia_results.csv exists with 6 rows, no NA values

  [ ] figures/Figure1_ASEAN_importation.png exists at 300 dpi

  [ ] figures/Figure2_Malaysia_scenarios.png exists at 300 dpi

  [ ] manuscript/manuscript.docx exists and opens in Word correctly

  [ ] manuscript/SUBMISSION_LOG.txt contains:
        - medRxiv preprint DOI
        - Eurosurveillance submission tracking number
        - LinkedIn post URL

  [ ] manuscript/internal_review.txt exists with all rows showing Y

  [ ] medRxiv preprint is publicly accessible (DOI resolves)

  [ ] Journal submission confirmation email has been received

  [ ] Policy brief has been shared via MAE or equivalent channel

If all pass → Task complete. Report: "PLAN COMPLETE — all conditions met."
If any fail → Report exactly which items failed and do not mark as complete.
══════════════════════════════════════════════════════
```

---

```
DRY RUN NARRATIVE
═════════════════

PHASE 1 (Steps 1-10): The executor creates the project directory and
pushes to GitHub, installs 14 R packages, clones the INRB-UMIE repository,
copies the INSP SitRep and aggregated linelist CSVs to data/raw/, downloads
WHO DON PDFs, manually enters the 3-row who_don_series.csv from hardcoded
values in Step 8 (critical failsafe if INRB-UMIE data is absent or
incomplete), downloads the ECDC importation risk PDF, and creates
SOURCES.txt. Quality Gate 1 catches any missing files before modelling.
Potential failure point: INRB-UMIE CSV column names may not match
01_data_prep.R expectations — Step 14 On Fail provides exact diagnostic
instructions (view the CSV, identify actual column names, update script).

PHASE 2 (Steps 11-14): The executor reads the ECDC PDF and extracts
model parameters to model_parameters.txt, searches 8 route pairs on
Google Flights and enters results to air_routes.csv, calculates travel
volumes from IATA/UCAA annual statistics and Pullano et al. proportions
and enters results to travel_volumes.csv, then runs 01_data_prep.R to
produce epi_parameters.csv. The HUMAN JUDGMENT checkpoint in Step 13
flags implausible travel volumes before they propagate into the model.
Quality Gate 2 catches CFR values outside the expected 0.05-0.55 range,
which would indicate a data entry or column-name error.

PHASE 3 (Steps 15-20): The executor populates 02_model.R in three
sequential sections. Section 1 loads parameters. Section 2 defines the
Monte Carlo function. Section 3 runs validation against the ECDC EU/EEA
estimate. The validation step (Step 17) is the critical calibration
check — if the model output is >5% or <0.001%, the HUMAN JUDGMENT flag
stops the run before erroneous results are saved. Section 4 runs all 8
ASEAN routes and Section 5 runs the Malaysia scenario analysis. All
results are saved to CSVs and committed to GitHub. Quality Gate 3 checks
that Malaysia probability is plausibly <5% given no direct flights.

PHASE 4 (Steps 21-22): The executor creates 03_figures.R and produces
two 300 dpi PNG figures using ggplot2. The only potential failure is a
missing figures/ directory — On Fail provides the exact dir.create()
command. Both figures are within Eurosurveillance's 2-figure limit.

PHASE 5 (Steps 23-30): The executor writes the manuscript sequentially
from Title through References. Each section has a mandatory word count
range and required content list, eliminating any ambiguity about what to
include. Step 29 checks word count against Eurosurveillance limits.
Step 30 cross-checks all numbers against output CSVs — this is the
anti-hallucination checkpoint. Quality Gate 4 is comprehensive and must
clear before any preprint or journal submission.

PHASE 6 (Steps 31-34): The executor converts markdown to Word via
pandoc, uploads to medRxiv, waits for DOI assignment, then submits to
Eurosurveillance with cover letter. Quality Gate 5 guards the irreversible
journal submission. The On Fail for Step 33 provides an immediate
alternative (WPSAR) if Eurosurveillance desk-rejects.

PHASE 7 (Steps 35-38): The executor updates GitHub README, posts to
LinkedIn with CEPI tags, distributes the policy brief via MAE, and makes
the final commit. The final GitHub state is a complete, reproducible,
open-science package that any reviewer or CEPI evaluator can run.

Issues found during dry run:

  - Step 14: R script assumes column names from INRB-UMIE CSV.
    Fix applied: On Fail instructs executor to view the CSV and identify
    actual column names before adjusting the script. Sufficient.

  - Step 13: IATA data for DRC specifically may be unreliable due to
    conflict context. Fix applied: HUMAN JUDGMENT flag added with
    specific plausibility threshold (>500 weekly travellers = implausible).

  - Step 17: Model calibration requires knowing the ECDC travel volume
    input, which is in a PDF. Fix applied: Step 11 explicitly requires
    reading the ECDC PDF before modelling begins and recording the
    EU/EEA travel volume estimate.

  No further issues found.
═════════════════
```

---

## Summary Timeline

| Day | Phase | Key Deliverable |
|---|---|---|
| 1 | Setup | GitHub repo, R packages, INRB-UMIE data cloned |
| 2-3 | Data | All raw data in data/raw/, SOURCES.txt complete |
| 3-4 | Parameters | epi_parameters.csv, travel_volumes.csv, air_routes.csv |
| 4-6 | Model | 02_model.R complete, all output CSVs, QG3 passed |
| 6-7 | Figures | Figure1.png and Figure2.png at 300 dpi |
| 7-10 | Writing | Full manuscript draft, internal review complete |
| 10-11 | Format | Word conversion, word count check, QG4 passed |
| 12 | Preprint | medRxiv DOI received |
| 13-14 | Submit | Eurosurveillance submission, LinkedIn post, policy brief |

**Total elapsed time: 14 days from Day 1 to journal submission.**

---

*Plan generated: 22 June 2026*
*Pathogen: Bundibugyo ebolavirus (BDBV), 2026 PHEIC*
*Target: Eurosurveillance Rapid Communication (primary) / WPSAR (secondary)*
*Repository: github.com/drfittri/bdbv2026-asean-importation*
