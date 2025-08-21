#!/usr/bin/env bash
set -euo pipefail

# -------------------------------
# Reproducible runner for the repo
# Steps:
#  0) install packages
#  1) fetch WDI (GDP pc, secondary enrollment, Gini)
#  2) clean/harmonize panel
#  3) EDA figs
#  4) diagnostics
#  5) FE model (clustered/Arellano/DK SEs)
#  6) robustness (Pooled vs FE vs 2-way FE vs RE + tests)
# -------------------------------

# Usage:
#   ./run_all.sh             # full pipeline
#   ./run_all.sh --skip-fetch  # reuse existing raw CSV
#   ./run_all.sh --clean       # wipe outputs + processed first
#
# Notes:
#  - Requires R 4.x and internet (for package install and WDI fetch)
#  - Idempotent: safe to re-run

SKIP_FETCH=0
DO_CLEAN=0

for arg in "$@"; do
  case "$arg" in
    --skip-fetch) SKIP_FETCH=1 ;;
    --clean) DO_CLEAN=1 ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

if ! command -v Rscript >/dev/null 2>&1; then
  echo "ERROR: Rscript not found in PATH"; exit 1
fi

echo "▶ Runner starting…"
mkdir -p data/raw data/processed outputs reports R

if [[ $DO_CLEAN -eq 1 ]]; then
  echo "🧹 Cleaning data/processed and outputs…"
  rm -rf data/processed/* outputs/*
fi

echo "0) Installing R packages (idempotent)…"
Rscript R/install.R

if [[ $SKIP_FETCH -eq 1 ]]; then
  echo "1) Skipping fetch (using existing data/raw/asean6_wdi_2000_2024.csv)…"
  if [[ ! -f data/raw/asean6_wdi_2000_2024.csv ]]; then
    echo "ERROR: --skip-fetch used, but raw CSV not found at data/raw/asean6_wdi_2000_2024.csv"
    exit 1
  fi
else
  echo "1) Fetching WDI data…"
  Rscript R/01_fetch_wdi.R
fi

echo "2) Cleaning & harmonizing panel…"
Rscript R/02_clean_panel.R

echo "3) Generating EDA figures…"
Rscript R/03_eda.R

echo "4) Running diagnostics…"
Rscript R/04_diagnostics.R

echo "5) Estimating FE model…"
Rscript R/05_fe_model.R

echo "6) Model robustness comparisons…"
Rscript R/06_model_robustness.R

echo "✅ Done. Artifacts:"
echo " - data/raw/asean6_wdi_2000_2024.csv"
echo " - data/processed/{panel_raw.csv,panel_imputed.csv,panel_balanced.csv,missing_by_country.csv}"
echo " - outputs/{gdp_pc_lines.png,sec_enroll_lines.png,gini_lines.png,corr_heatmap.png,scatter_*.png,fe_resid_vs_fitted.png,fe_model_coefs.png}"
echo " - reports/{panel_summary.md,diagnostics.md,fe_model.md,model_robustness.md}"
