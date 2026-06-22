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
| Phase | 0 — Planning / scaffolding |
| Current step | Pre-Step 1 (scaffolding complete; ready to start Phase 1) |
| Status | Plan corrected (v2). Awaiting execution start. |
| Last updated | 2026-06-23 |
| Last session summary | Reviewed plan, verified data sources real, fixed critical errors, set model approach, built tracker. |

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
- Outbreak-size (McCabe, 20 May): ~400–900 cases. Get latest from repo at run time.
- ⚠ The plan's "837 cases / 196 deaths / 17 June" is UNVERIFIED — do not use unless sourced.

---

## 🗺 STEP CHECKLIST  ( [ ]=todo  [~]=in progress  [x]=done  [!]=blocked )

### Phase 1 — Setup & data acquisition
- [ ] 1. Create R project + GitHub repo `bdbv-importation-asean` (MIT, public)
- [ ] 2. README.md (use BDBV, correct sources)
- [ ] 3. Install R packages
- [ ] 4. Clone **`INRB-UMIE/Ebola_DRC_2026`** (CORRECTED name)
- [ ] 5. Copy INSP SitRep CSVs → data/raw/
- [ ] 6. Copy epi/linelist CSVs → data/raw/
- [ ] 7. Download WHO DON PDFs (DON602 + later)
- [ ] 8. Structured CSV of case/death counts — use SOURCED figures only
- [ ] 9. Download ECDC importation PDF (already have local copy)
- [ ] 10. SOURCES.txt provenance
- [ ] **QG1 — data acquisition complete**

### Phase 2 — Parameters & travel
- [ ] 11. Extract ECDC params (N=13,392,200; state-travel multipliers 1/1/0.9/0.1)
- [ ] 12. Air routes DRC/Uganda → ASEAN (transit hubs DXB/DOH/NBO/SIN)
- [ ] 13. Travel volumes → **hypothetical scenarios** (10–100 travellers), proxy-scaled
- [ ] 14. Epi params from INRB data (cases, deaths, CFR, growth) — `01_data_prep.R`
- [ ] **QG2 — parameters ready**

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

_(empty — first entry goes here when Step 1 is done)_

---

## 🧾 SESSION LOG
- **2026-06-23** — Plan review + correction. Verified all data sources are real;
  fixed repo name, population, fabricated case count, model misrepresentation.
  Set model approach (reuse ECDC). Built PROGRESS.md + CLAUDE.md + plan v2 override.
  Next: begin Step 1.
