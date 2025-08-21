.PHONY: all fetch clean eda diagnostics fe robustness reset

all: fetch clean eda diagnostics fe robustness

fetch:
	Rscript R/install.R
	Rscript R/01_fetch_wdi.R

clean:
	Rscript R/02_clean_panel.R

eda:
	Rscript R/03_eda.R

diagnostics:
	Rscript R/04_diagnostics.R

fe:
	Rscript R/05_fe_model.R

robustness:
	Rscript R/06_model_robustness.R

reset:
	rm -rf data/processed/* outputs/*
