# R/02_clean_panel.R
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
  library(stringr)
})

inp <- "data/raw/asean6_wdi_2000_2024.csv"
if (!file.exists(inp)) stop("Input not found: ", inp)

raw <- read_csv(inp, show_col_types = FALSE)

# Keep core vars & tidy types
panel <- raw %>%
  transmute(
    iso2c = as.character(iso2c),
    country = as.character(country),
    year = as.integer(year),
    gdp_pc_const_usd = as.numeric(gdp_pc_const_usd),
    sec_enroll_gross = as.numeric(sec_enroll_gross),
    gini = as.numeric(gini)
  ) %>%
  arrange(iso2c, year)

# ---- Impute gently for display only ----
# Rule: LOCF then NOCB (within country), no cross-country borrowing.
panel_imputed <- panel %>%
  group_by(iso2c) %>%
  tidyr::fill(gdp_pc_const_usd, sec_enroll_gross, gini, .direction = "downup") %>%
  ungroup()

# ---- Balanced subset (optional) ----
# Years where ALL three vars are non-missing for EVERY country.
years_ok <- panel %>%
  group_by(year) %>%
  summarize(n_c_complete = sum(!is.na(gdp_pc_const_usd) &
                               !is.na(sec_enroll_gross) &
                               !is.na(gini))) %>%
  filter(n_c_complete == n_distinct(panel$iso2c)) %>%
  pull(year)

panel_balanced <- panel %>% filter(year %in% years_ok)

# ---- Summary table for README/reports ----
missing_tbl <- panel %>%
  summarize(
    n = n(),
    miss_gdp = sum(is.na(gdp_pc_const_usd)),
    miss_sec = sum(is.na(sec_enroll_gross)),
    miss_gini = sum(is.na(gini))
  )

by_country_missing <- panel %>%
  group_by(iso2c) %>%
  summarize(
    obs = n(),
    miss_gdp = sum(is.na(gdp_pc_const_usd)),
    miss_sec = sum(is.na(sec_enroll_gross)),
    miss_gini = sum(is.na(gini)),
    .groups = "drop"
  ) %>%
  arrange(iso2c)

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
write_csv(panel,          "data/processed/panel_raw.csv")
write_csv(panel_imputed,  "data/processed/panel_imputed.csv")
write_csv(panel_balanced, "data/processed/panel_balanced.csv")
write_csv(by_country_missing, "data/processed/missing_by_country.csv")

# Write a tiny markdown summary for GitHub
dir.create("reports", showWarnings = FALSE)
md <- c(
  "# Panel construction summary",
  "",
  sprintf("- Input: `%s`", inp),
  sprintf("- Countries: %s", paste(sort(unique(panel$iso2c)), collapse = ", ")),
  sprintf("- Years: %d–%d", min(panel$year, na.rm=TRUE), max(panel$year, na.rm=TRUE)),
  sprintf("- Balanced years (all vars, all countries): %s",
          ifelse(length(years_ok)==0, "None", paste(range(years_ok), collapse="–"))),
  "",
  "## Missingness by country (counts)",
  knitr::kable(by_country_missing)
)
writeLines(md, "reports/panel_summary.md")

message("✅ Wrote: ",
        "data/processed/{panel_raw.csv, panel_imputed.csv, panel_balanced.csv, missing_by_country.csv} ",
        "and reports/panel_summary.md")
