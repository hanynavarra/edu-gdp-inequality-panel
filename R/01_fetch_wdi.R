# R/01_fetch_wdi.R
suppressPackageStartupMessages({
  library(WDI); library(dplyr); library(readr); library(janitor)
})

asean6_iso2 <- c("PH","ID","MY","TH","VN","SG")
ind_codes <- c("NY.GDP.PCAP.KD","SE.SEC.ENRR","SI.POV.GINI") # GDP pc (const USD), Secondary enroll %, Gini

raw <- WDI(country = asean6_iso2, indicator = ind_codes,
           start = 2000, end = 2024, extra = FALSE)
raw <- janitor::clean_names(raw)  # -> ny_gdp_pcap_kd, se_sec_enrr, si_pov_gini

need <- c("iso2c","country","year","ny_gdp_pcap_kd","se_sec_enrr","si_pov_gini")
miss <- setdiff(need, names(raw))
if (length(miss)) stop("Missing expected columns: ", paste(miss, collapse=", "))

df <- raw %>%
  transmute(
    iso2c, country, year,
    gdp_pc_const_usd = ny_gdp_pcap_kd,
    sec_enroll_gross = se_sec_enrr,
    gini = si_pov_gini
  ) %>%
  arrange(iso2c, year)

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
out <- "data/raw/asean6_wdi_2000_2024.csv"
readr::write_csv(df, out)
message("Wrote: ", out)
print(dplyr::slice_head(df, n = 12))
