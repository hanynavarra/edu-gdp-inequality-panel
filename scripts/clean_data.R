# scripts/clean_data.R
library(readr)
library(dplyr)

inp <- "data/raw/asean6_wdi_2000_2024.csv"
if (!file.exists(inp)) stop("Input not found: ", inp)

raw <- read_csv(inp, show_col_types = FALSE)

# Basic cleaning: keep ASEAN-6 rows & years, drop all-missing rows, simple sort
clean <- raw %>%
  filter(year >= 2000, year <= 2024) %>%
  arrange(iso2c, year)

# (Optional) very light imputation for plotting: country-wise LOCF then NOCB
clean_impute <- clean %>%
  group_by(iso2c) %>%
  tidyr::fill(gdp_pc_const_usd, sec_enroll_gross, gini, .direction = "downup") %>%
  ungroup()

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
write_csv(clean, "data/processed/panel_raw.csv")
write_csv(clean_impute, "data/processed/panel_imputed.csv")

message("✅ Wrote data/processed/panel_raw.csv and panel_imputed.csv")
