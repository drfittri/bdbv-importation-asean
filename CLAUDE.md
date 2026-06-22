# PROJECT: BDBV Importation Risk — Malaysia / ASEAN

This directory is a research project to estimate the probability of importing
**Bundibugyo virus (BDBV, an *Ebolavirus*)** into Malaysia and ASEAN hub countries
during the 2026 PHEIC, by adapting the published ECDC EU/EEA importation model.
Goal: a publishable short report + reproducible R code + preprint.

## ⚙️ SESSION PROTOCOL (do this automatically)

1. **On "continue" / "continue progress" / "resume":** open `PROGRESS.md`, follow its
   "HOW TO RESUME" section, and pick up at the first unfinished step. Do not re-ask
   what's already decided there.
2. **After completing ANY step:** update `PROGRESS.md` — flip the checklist box, add a
   Completion Log entry (outputs, key numbers, deviations), update Current State, append
   to Session Log. This is mandatory; the tracker is the project's memory across sessions.
3. **Authoritative spec:** `research plan.md` → section **"PLAN v2 — CORRECTIONS &
   EXECUTION PROTOCOL"** (top of file) overrides any conflicting detail later in that file.

## 🚫 RESEARCH-INTEGRITY RULES (non-negotiable)

- **Never fabricate a number.** Every figure in code, results, or manuscript must be
  either (a) computed from data in `data/` / `output/`, or (b) quoted from a verified
  source in PROGRESS.md's Data Registry with a citation. If unsure, mark `[VERIFY]`.
- **Pathogen is BDBV.** Never write "IOP" or "outbreak pathogen" placeholder.
- **Use corrected identifiers** from PROGRESS.md Data Registry (repo is
  `INRB-UMIE/Ebola_DRC_2026`; outbreak population N = 13,392,200; etc.).
- **Verify every DOI/URL** at run time before putting it in the manuscript.
- **Do not claim to "replicate ECDC"** with the old homebrew model. The agreed approach
  is to reuse ECDC/epiforecasts released model output (see PROGRESS.md Resolved Decisions).
- Do not commit copyrighted source PDFs to git (`.gitignore` `data/raw/*.pdf`); script or
  document their download instead so the analysis stays reproducible.

## 📂 EXPECTED LAYOUT
```
01_data_prep.R  02_model.R  03_figures.R
data/raw/  data/processed/  output/  figures/  manuscript/
PROGRESS.md  CLAUDE.md  research plan.md
```

## STYLE
- No em-dashes in the manuscript. Active voice. Vancouver references.
- R: `set.seed(20260622)`, `here::here()` for paths, tidyverse idiom.
