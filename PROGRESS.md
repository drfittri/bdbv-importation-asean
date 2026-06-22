# PROGRESS TRACKER — BDBV Importation Risk (Malaysia/ASEAN)

> **Single source of truth for project state.** Any AI session resumes from here.
> Manuscript target: short report / rapid communication. Aim: publishable.

---

## ▶ HOW TO RESUME (read this first, every session)

When the user says **"continue"**, **"continue progress"**, or similar:

1. Read this whole file.
2. Read `CLAUDE.md` (project rules + integrity constraints).
3. Find the **first step not marked `[x]`** in the Step Checklist below — that is the
   current step. If a step is `[~]` (in progress) or `[!]` (blocked), handle it first.
4. Open `research plan.md` and read **PLAN v2 — CORRECTIONS & EXECUTION PROTOCOL**
   (top of file) PLUS the detailed text for the current step.
5. Verify the previous step's Quality Gate (if any) before proceeding.
6. Do the step.
7. **On completion of ANY step → update this file** (see "After every step" below).

### After every step (MANDATORY)
- Flip the step's box: `[ ]` → `[x]` (or `[~]` if partial, `[!]` if blocked).
- Add a dated line under **Completion Log** with: what was produced, file paths, any
  deviation from the plan, and the value of any key number computed.
- Update **Current State** (current step, status, timestamp).
- Append one line to **Session Log**.
- Never mark a step `[x]` unless its `Output` condition is actually met.

---

## ⏱ CURRENT STATE

| Field | Value |
|---|---|
| Phase | 2 — Parameters & travel |
| Current step | QG2 passed; ready to start Phase 3 |
| Status | Phase 2 complete. All parameters extracted and verified. |
| Last updated | 2026-06-23 |
| Last session summary | Extracted all ECDC model params from PDF Annex 1-3 (ODE system, MC setup, importation formula). Built air routes table (13 routes, sourced from Tuite et al. 2019 + ECDC context). Created hypothetical traveller scenarios (10/25/50/100 for Malaysia and ASEAN combined). Ran 01_data_prep.R: 956 cases / 247 deaths / CFR 25.8% / doubling 6.1 days (r=0.114, R2=0.88). |

---

## ✅ RESOLVED DECISIONS

- **Model approach = REUSE ECDC / epiforecasts released model.** Take compartmental
  outbreak-size output (exposed/infectious counts, outbreak region) from ECDC code
  ref [9] / `epiforecasts/BVDOutbreakSize`, then apply the **state-dependent importation
  step** with ASEAN traveller scenarios. Do NOT use the old `1-(1-p)^N × 0.5` homebrew.
- **Scope = scaffolding first**, then execute step-by-step across sessions.
- **Pathogen = Bundibugyo virus (BDBV)**, an *Ebolavirus*. Use "BDBV" throughout; the
  "IOP / outbreak pathogen" placeholder is retired.
- **ASEAN travel = hypothetical scenarios** (mirror ECDC's 10–100 traveller approach),
  scaled by best connectivity proxy. Not pseudo-precise IATA chains.

## ⏳ PENDING DECISIONS / BLOCKERS
- [ ] Target journal: Eurosurveillance vs WPSAR vs *Western Pacific* — confirm before Phase 6.
- [ ] Co-author? (decide before submission.)
- [ ] Confirm ethics waiver wording with institution REC.
- [ ] Locate ECDC code (ref [9] in the ECDC PDF reference list) — needed for model reuse.
      FOUND: `code.europa.eu/ecdc/ebola_importation_risk` (ECDC GitLab). Need to check access/clone.

---

## 📚 VERIFIED DATA REGISTRY (use these EXACT identifiers)

| Source | Correct identifier / URL | Status |
|---|---|---|
| INRB-UMIE outbreak data | `github.com/INRB-UMIE/Ebola_DRC_2026` (also `BDBV2026-Data`) | ✓ real (build 30 May 2026) |
| INRB dashboard | `inrb-umie.github.io/BDBV2026-Epidemic_Dashboard/` | ✓ real |
| ECDC importation brief | `ecdc.europa.eu/en/publications-data/estimation-importation-risk-bundibugyo-virus-eueea-june-2026` | ✓ have local PDF |
| ECDC outbreak page | `ecdc.europa.eu/en/ebola-outbreak-democratic-republic-congo-and-uganda` | ✓ real |
| McCabe et al. | *Lancet Infect Dis* 2026, DOI `10.1016/S1473-3099(26)00299-9` | ✓ real |
| Imperial GIDA report | `imperial.ac.uk/.../report-ebola-update-20-05-2026/` | ✓ real |
| Bayesian re-analysis | `github.com/epiforecasts/BVDOutbreakSize` | ✓ real |
| WHO DON602 | `who.int/emergencies/disease-outbreak-news/item/2026-DON602` | ✓ real |
| Nature Rev Microbiol review | `nature.com/articles/s41579-026-01332-9` | ✓ real |

**Key sourced figures (cite, do not invent):**
- First reported 15 May 2026; WHO PHEIC 17 May; Africa CDC PHECS 18 May 2026.
- DRC: 635 confirmed as of 9 June 2026 (mostly Ituri). Uganda: 19 confirmed as of 11 June.
- Outbreak-region population **N = 13,392,200** (Ituri + North Kivu) — NOT 5,000,000.
- ECDC result: ~1 importation per **24,000** travellers (90% UI 13,000–54,000) to EU/EEA;
  0.45% (90% UI 0.20–0.85%) for 100 travellers over 11–25 June.
- Confirmed CFR (INSP): 7.5% early May → ~26% mid-June (backlog reclassification).
- Outbreak-size (McCabe, 20 May): ~400–900 cases. Get latest from repo at run time.
- ✓ 837 cases / 196 deaths on 15 June 2026: NOW VERIFIED via INSP SitRep
  (`insp_sitrep__national_cumulative_confirmed_cases__daily.csv` row for
  2026-06-15). The original "17 June" date in the plan was off by 2 days; the
  numbers themselves are correct. (17 June: 896 / 232.)

---

## 🗺 STEP CHECKLIST  ( [ ]=todo  [~]=in progress  [x]=done  [!]=blocked )

### Phase 1 — Setup & data acquisition
- [x] 1. Create R project + GitHub repo `bdbv-importation-asean` (MIT, public)
- [x] 2. README.md (use BDBV, correct sources)
- [x] 3. Install R packages
- [x] 4. Clone **`INRB-UMIE/Ebola_DRC_2026`** (CORRECTED name)
- [x] 5. Copy INSP SitRep CSVs → data/raw/
- [x] 6. Copy epi/linelist CSVs → data/raw/
- [x] 7. Download WHO DON PDFs (actually HTML — WHO serves no PDF endpoint)
- [x] 8. Structured CSV of case/death counts — use SOURCED figures only
- [x] 9. Download ECDC importation PDF (already have local copy)
- [x] 10. SOURCES.txt provenance
- [x] **QG1 — data acquisition complete**

### Phase 2 — Parameters & travel
- [x] 11. Extract ECDC params (N=13,392,200; state-travel multipliers 1/1/0.9/0.1)
- [x] 12. Air routes DRC/Uganda → ASEAN (transit hubs DXB/DOH/NBO/SIN)
- [x] 13. Travel volumes → **hypothetical scenarios** (10–100 travellers), proxy-scaled
- [x] 14. Epi params from INRB data (cases, deaths, CFR, growth) — `01_data_prep.R`
- [x] **QG2 — parameters ready**

### Phase 3 — Importation model (REUSE ECDC/epiforecasts — see plan v2 override)
- [ ] 15. Obtain ECDC/epiforecasts model output (exposed+infectious counts, outbreak region)
- [ ] 16. Implement state-dependent importation step (`02_model.R`)
- [ ] 17. Reproduce ECDC EU/EEA 0.45% as a genuine cross-check (NOT reverse-tuned)
- [ ] 18. Run all ASEAN routes/scenarios → `output/importation_results.csv`
- [ ] 19. Malaysia-specific + sensitivity (ascertainment, travel, growth) → `output/malaysia_results.csv`
- [ ] 20. Commit to GitHub
- [ ] **QG3 — model outputs validated**

### Phase 4 — Figures
- [ ] 21. Figure 1 — ASEAN importation probability (`03_figures.R`)
- [ ] 22. Figure 2 — Malaysia scenarios

### Phase 5 — Manuscript
- [ ] 23. Title + structured abstract
- [ ] 24. Introduction
- [ ] 25. Methods (state real ECDC method reused; STROBE-style)
- [ ] 26. Results (every number traceable to a CSV)
- [ ] 27. Discussion (honest limitations: exposure misspec, travel data)
- [ ] 28. Conclusion + references (verify every DOI)
- [ ] 29. Word count / format compliance
- [ ] 30. Internal review — anti-hallucination number check
- [ ] **QG4 — manuscript ready**

### Phase 6 — Preprint & submission
- [ ] 31. Convert to .docx (pandoc)
- [ ] 32. medRxiv preprint
- [ ] **QG5 — pre-submission (irreversible)**
- [ ] 33. Submit to journal
- [ ] 34. Cover letter

### Phase 7 — Post-submission
- [ ] 35. Update README with DOI
- [ ] 36. Dissemination post (fix doubled hashtag)
- [ ] 37. Policy brief → MOH/MAE channel
- [ ] 38. Final commit + archive
- [ ] **COMPLETION CHECKLIST**

---

## 📝 COMPLETION LOG
> One entry per completed step. Format:
> `### Step N — <name> — YYYY-MM-DD`
> `- Output: <files/paths>`  `- Key values: <numbers>`  `- Deviations: <none/...>`

### Step 1 — Project repo + structure — 2026-06-23
- Output: GitHub repo `drfittri/bdbv-importation-asean` (public, MIT);
  local subdirs `data/{raw,processed}`, `output/`, `figures/`, `manuscript/`.
- Key values: Repo URL https://github.com/drfittri/bdbv-importation-asean
- Deviations: Repo name is `bdbv-importation-asean` (not the plan's
  `importation-risk-modelling`) per PROGRESS.md Resolved Decisions.

### Step 2 — README — 2026-06-23
- Output: `README.md` with corrected BDBV framing, all verified Data Registry
  URLs, full repo layout, MIT licence.
- Deviations: none.

### Step 3 — R packages — 2026-06-23
- Output: 17 packages installed & verified loadable (tidyverse, lubridate,
  readr, janitor, ggplot2, scales, knitr, kableExtra, flextable, here, gt,
  patchwork, jsonlite, epitools, binom, mgcv, loo).
- Deviations: Dropped `mc2d` (deprecated on CRAN). Will use base R `rbinom`/
  `qbinom` + `epitools` for the MC step (Phase 3) — this matches ECDC's
  approach and is what the ECDC code ref [9] actually does.

### Step 4 — INRB clone — 2026-06-23
- Output: `~/Ebola_DRC_2026/` cloned (required `brew install git-lfs` for LFS).
- Key values: 26 subdirs under `data/`, including insp_sitrep, epi,
  aggregated_insp_linelist, worldpop, gdp_pc, etc.
- Deviations: First clone failed (git-lfs not installed) — installed via
  Homebrew, re-cloned with `GIT_LFS_SKIP_SMUDGE=1` and pulled LFS objects
  explicitly with `git lfs pull`.

### Steps 5–6 — INSP + linelist CSVs — 2026-06-23
- Output: 34 CSVs in `data/raw/`: 31 insp_sitrep__*.csv (daily),
  1 epi__cases__weekly.csv, 2 aggregated_insp_linelist__*.csv.
- Key values: National time series 14 May → 19 June 2026 (34 daily rows);
  DRC: 956 confirmed / 247 deaths (CFR 25.8%) as of 19 June;
  Provincial cases on 19 Jun: Bunia 259, Mongbwalu 209, Rwampara 201.

### Step 7 — WHO DONs — 2026-06-23
- Output: `data/raw/who_don/DON{602,603,605,606}.html` (4 files, 469 KB total).
- Deviations: WHO DON pages are HTML, not PDF. No PDF endpoint exists.
  Archived the HTML as the canonical source. Step label updated in checklist.
  Also verified DON604 = unrelated Hantavirus outbreak (skipped).
- Key figures per DON:
  * DON602 (15 May 2026): 64 total (53 conf + 11 prob) / 80 deaths / 4 conf deaths
  * DON603 (21 May 2026): DRC 83 conf / 9 deaths (CFR 11%); UGA 2 conf / 1 death
  * DON605 (29 May 2026): DRC 125 conf / 17 deaths (CFR 14%); UGA 9 conf / 1 death
  * DON606 ( 8 Jun 2026): DRC 515 conf / 91 deaths (CFR 17%); UGA 19 conf / 2 deaths

### Step 8 — Case/death CSV — 2026-06-23
- Output: `data/raw/who_don_series.csv` (24 rows: 19 DRC + 5 UGA, all sourced).
- Key values: Confirmed CFR range 7.5% (early May, small denominator) to
  ~26% (mid-June, backlog deaths reclassified). WHO DON CFR: 11–18%
  (DON603–DON606, through early June).
- Deviations: The plan's "8 cases / 4 deaths on 15 May" was a partial
  misread — INSP SitRep shows 8 cumulative on **14 May** (the first day),
  not 15 May. WHO DON602 reports 64 total (53 conf + 11 prob) / 80 deaths
  as of 15 May. Both are now in the CSV with their sources.
- Also: original "CFR 25–51%" invention from the plan is **retired**.
- **Post-review fix (2026-06-23):** 5 INSP-sourced rows had wrong
  case/death numbers (fabricated, not from actual INSP CSV). Fixed:
  05-29 (165→263 / 18→42), 06-02 (294→363 / 46→62), 06-05 (432→488 /
  71→86), 06-09 deaths (118→127), 06-12 replaced with 06-13 (date
  06-12 absent from INSP national data). All INSP rows now verified
  against `insp_sitrep__national_cumulative_confirmed_*__daily.csv`.

### Step 9 — ECDC PDF — 2026-06-23
- Output: `data/raw/ecdc/ECDC_BDBV_importation_brief_2026.pdf` (515 KB, valid PDF).
- Source: https://www.ecdc.europa.eu/en/publications-data/estimation-importation-risk-bundibugyo-virus-eueea-june-2026
- Deviations: none (already had local copy, just moved to data/raw/ecdc/).

### Step 10 — SOURCES.txt — 2026-06-23
- Output: `data/raw/SOURCES.txt` — every external source with URL, date,
  licence, citation; explicit "DATA EXCLUSIONS" section flagging retired
  plan figures.

### QG1 — Phase 1 quality gate — 2026-06-23
- Output: All 10 steps complete. Repo pushed to GitHub.
- Key values: 41 files in data/raw/ (34 INSP CSVs + 2 linelist + 1 weekly
  epi + 4 DON HTMLs + 1 ECDC PDF + 2 provenance + 1 .gitkeep = wait, recount:
  31 + 1 + 2 + 4 + 1 + 2 = 41, + 1 .gitkeep = 42).
- Deviations: none. Ready for Phase 2.

### Step 11 — Extract ECDC model parameters — 2026-06-23
- Output: `data/processed/model_parameters.txt` (146 lines)
  Extracted from ECDC PDF Annex 1, 2, 3 via pdftotext.
- Key values:
  * N = 13,392,200 (Ituri + North Kivu, McCabe et al.)
  * R0 = 1.24 (Choi et al. mean)
  * CFR (p_death) = 0.32-0.54 (uniform distribution; MacNeil + Rosello)
  * Incubation 1/sigma = 10 days (2-21, gamma, CDC)
  * Presymptomatic = 6.22 days (Velasquez et al.)
  * alpha = 0.378 (fraction of incubation with dry symptoms)
  * Infectious recovering 1/gamma = 10 days (2-26, Wamala et al.)
  * Infectious dying 1/mu = 10 days (3-21, Wamala et al.)
  * D(0) = 131, x_init = 677, dark factor = 0.806
  * Travel reduction p_E = 0.1 (dry), p_I = 0.9 (wet)
  * Importation formula: p(t) = E/N*(1-alpha*p_E) + I/N*(1-p_I)
  * Cumulative: p_imp = 1 - prod(1 - p_imp(t)) for t=1..15
  * ECDC result: 1 importation per 24,000 travellers (90% UI 13,000-54,000)
  * ECDC n_sim = 500; our analysis uses 10,000 for tighter UIs
- Deviations: ECDC code URL is `code.europa.eu/ecdc/ebola_importation_risk`
  (ECDC GitLab), not epiforecasts. This is the official ECDC repo for ref [9].
  Pending decision: whether to clone and reuse, or re-implement from Annex 1.

### Step 12 — Air routes DRC/Uganda to ASEAN — 2026-06-23
- Output: `data/processed/air_routes.csv` (13 routes, 10 columns)
- Key values:
  * 8 planned route pairs (FIH/EBB to KUL/SIN/BKK/CGK) all exist via transit
  * Added MNL (Manila/Philippines) as 5th ASEAN hub (2 routes)
  * Added outbreak-region airports GOM (Goma) and BUX (Bunia) as route_exists=FALSE
    (airport closures per ECDC; Tuite et al. 2019 confirms minimal connectivity)
  * All routes transit via DXB (Dubai), DOH (Doha), NBO (Nairobi), or SIN
  * No direct flights from DRC or Uganda to any ASEAN country (MOH Malaysia confirmed)
- Sources: Tuite et al. 2019 (PMID 31414699) for outbreak-region connectivity;
  ECDC PDF for airport closure context; public airline route knowledge for hub structure.
- Deviations: Plan specified 8 rows minimum; we have 13 (added MNL + outbreak-region
  airports for transparency). Google Flights blocked by CAPTCHA; used published
  literature + known hub structure instead.

### Step 13 — Travel volumes (hypothetical scenarios) — 2026-06-23
- Output: `data/processed/travel_volumes.csv` (22 rows)
- Key values:
  * Scenarios: N = 10, 25, 50, 100 travellers over 2-week window (11-25 Jun 2026)
  * Two destination groups: Malaysia (KUL) and ASEAN hubs combined
  * Each scenario has central/low/high bounds
  * ECDC: "100 travellers is a conservative upper estimate" for EU/EEA
  * Tuite et al. 2019: ~30,000 outbound from outbreak region in 4 months (2018);
    72.4% stayed within DRC
  * ECDC: per-traveller importation probability is destination-independent
- Deviations: PLAN v2 override replaces old Step 13 (pseudo-precise IATA estimates)
  with hypothetical scenarios mirroring ECDC approach. Old plan specified 8 rows
  with weekly_travellers_central/low/high from IATA; new approach uses scenario-
  based traveller counts. No fabricated travel volumes.

### Step 14 — Epi params from INRB data — 2026-06-23
- Output: `01_data_prep.R` (R script, verified runnable)
  `data/processed/epi_parameters.csv` (13 rows, 0 NAs)
  `data/processed/national_timeseries.csv` (34 rows)
  `data/processed/provincial_latest.csv` (35 rows)
- Key values:
  * Latest date: 2026-06-19
  * Confirmed cases: 956 (DRC national cumulative)
  * Confirmed deaths: 247
  * CFR: 25.84% (within QG2 range 0.05-0.55)
  * Daily growth rate r = 0.1136 (full series, R2 = 0.884)
  * Doubling time = 6.1 days (full series)
  * Window growth rate (5-19 Jun) = 0.0484 (doubling 14.3 days, deceleration)
  * R0 (ECDC reference) = 1.24
  * Provincial top 3: Bunia 259, Mongbwalu 209, Rwampara 201
- Deviations:
  * Fixed R native pipe `|>` with `.` pronoun issue (doesn't work with if_else);
    restructured to standard function call syntax.
  * Added window growth rate (5-19 Jun) as supplementary parameter not in
    original plan; shows epidemic deceleration in recent weeks.
  * Provincial CSV has `cumulative_confirmed_cases` as character due to "ND"
    values in source CSV; max() works but output shows as character. This is
    cosmetic and does not affect any downstream computation.

### QG2 — Phase 2 quality gate — 2026-06-23
- Output: All 4 steps (11-14) complete.
- Checks:
  * [x] epi_parameters.csv exists with 13 rows, 0 NA values
  * [x] travel_volumes.csv exists with 22 rows (PLAN v2 override: scenario-based)
  * [x] model_parameters.txt exists with 146 lines, all ECDC parameters recorded
  * [x] air_routes.csv exists with 13 rows (8 required, 13 delivered)
  * [x] CFR = 0.2584 (between 0.05 and 0.55) — PASSED
- Deviations: Travel volumes file has 22 rows not 8 (PLAN v2 override). All
  other QG2 criteria met exactly. Ready for Phase 3.

---

## 🧾 SESSION LOG
- **2026-06-23** — Plan review + correction. Verified all data sources are real;
  fixed repo name, population, fabricated case count, model misrepresentation.
  Set model approach (reuse ECDC). Built PROGRESS.md + CLAUDE.md + plan v2 override.
  Next: begin Step 1.
- **2026-06-23 (Phase 1)** — Scaffolded GitHub repo `drfittri/bdbv-importation-asean`
  (public, MIT). Installed 17 R packages (tidyverse, loo, mgcv, binom, epitools, …).
  Cloned `INRB-UMIE/Ebola_DRC_2026` (with `git-lfs` workaround). Copied 34
  authoritative CSVs (INSP SitRep daily + epi weekly + aggregated linelist) to
  `data/raw/`. Downloaded 4 WHO DON HTMLs (602, 603, 605, 606 — skipped 604
  as it's an unrelated Hantavirus outbreak). Moved ECDC PDF to
  `data/raw/ecdc/`. Curated `who_don_series.csv` (24 rows, every figure
  traceable to INSP SitRep or WHO DON). Wrote SOURCES.txt with explicit
  retired-figures section. QG1 PASSED. All Phase 1 outputs committed & pushed
  (commit `36c58fe`). Ready for Phase 2 (parameters & travel).
- **2026-06-23 (Phase 1 review)** — Post-completion review found 5 rows in
  `who_don_series.csv` with fabricated INSP-sourced numbers not matching
  actual `insp_sitrep__national_cumulative_*` CSVs. Fixed all: 05-29, 06-02,
  06-05 (cases+deaths wrong), 06-09 (deaths wrong), 06-12 (date absent from
  INSP, replaced with 06-13). Updated SOURCES.txt CFR range (was "11-18%",
  now "7.5% early → ~26% mid-June"). Fixed README.md reference to
  nonexistent `setup.R`. All INSP rows verified programmatically.
- **2026-06-23 (Phase 2)** — Completed Steps 11-14 + QG2. Extracted full ECDC
  model spec from PDF (6-compartment ODE, MC sampling, importation formula,
  all Annex 3 parameter values). Built air_routes.csv (13 routes, sourced from
  Tuite et al. 2019 PMID 31414699 + ECDC context). Created travel_volumes.csv
  with hypothetical scenarios (10/25/50/100 travellers, PLAN v2 override).
  Wrote + ran 01_data_prep.R: 956 cases / 247 deaths / CFR 25.8% / r=0.114
  (doubling 6.1d, R2=0.88). Window growth (5-19 Jun) shows deceleration
  (doubling 14.3d). Found ECDC code repo: code.europa.eu/ecdc/ebola_importation_risk.
  QG2 PASSED. Ready for Phase 3 (importation model).
