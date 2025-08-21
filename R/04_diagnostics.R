# R/04_diagnostics.R
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(plm)
  library(lmtest)
  library(sandwich)
  library(tseries)
  library(car)
  library(ggplot2)
})

# ---------- Load data ----------
inp <- "data/processed/panel_imputed.csv"
if (!file.exists(inp)) stop("Input not found: ", inp)
df0 <- read_csv(inp, show_col_types = FALSE)

# Keep needed columns & create logs
df <- df0 %>%
  transmute(
    iso2c = as.factor(iso2c),
    year = as.integer(year),
    gdp_pc_const_usd = as.numeric(gdp_pc_const_usd),
    sec_enroll_gross = as.numeric(sec_enroll_gross),
    gini = as.numeric(gini),
    log_gdp_pc = log(pmax(gdp_pc_const_usd, 1))  # safe log
  ) %>%
  arrange(iso2c, year)

# Panel frame
pdf <- pdata.frame(df, index = c("iso2c","year"))

dir.create("reports", showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)
sink_file <- "reports/diagnostics.md"

# helper to append section titles to md
cat_md <- function(...) cat(..., "\n", file = sink_file, append = TRUE)

# start fresh
if (file.exists(sink_file)) file.remove(sink_file)
cat_md("# Panel Diagnostics\n")

# ---------- 1) Panel unit root tests (IPS) ----------
cat_md("## Unit root tests (IPS / `plm::purtest`)\n")
vars_to_test <- c("log_gdp_pc", "sec_enroll_gross", "gini")
for (v in vars_to_test) {
  try({
    tst <- purtest(pdf[[v]], test = "ips", lags = "AIC", exo = "trend")
    cat_md(paste0("### ", v))
    cat_md("```")
    cat_md(capture.output(print(tst)))
    cat_md("```\n")
  }, silent = TRUE)
}

# ---------- 2) Multicollinearity (VIF) ----------
cat_md("## Multicollinearity (VIF)\n")
# pooled OLS for VIF (simple and standard)
vif_df <- na.omit(df[, c("log_gdp_pc","sec_enroll_gross","gini")])
vif_mod <- lm(log_gdp_pc ~ sec_enroll_gross + gini, data = vif_df)
vif_vals <- tryCatch(car::vif(vif_mod), error = function(e) NA)
cat_md("VIF from pooled OLS:")
cat_md("```")
cat_md(capture.output(print(vif_vals)))
cat_md("```\n")

# ---------- 3) FE model (for dependence/serial/hetero tests) ----------
fe_mod <- plm(log_gdp_pc ~ sec_enroll_gross + gini, data = pdf,
              model = "within", effect = "individual")

# ---------- 3a) Cross-sectional dependence ----------
cat_md("## Cross-sectional dependence (`plm::pcdtest`)\n")
# Pesaran CD test
cd_res <- tryCatch(pcdtest(fe_mod, test = "cd"), error = function(e) e)
cat_md("```")
cat_md(capture.output(print(cd_res)))
cat_md("```\n")

# ---------- 3b) Serial correlation (panel BG test) ----------
cat_md("## Serial correlation (`plm::pbgtest`)\n")
bg_res <- tryCatch(pbgtest(fe_mod), error = function(e) e)
cat_md("```")
cat_md(capture.output(print(bg_res)))
cat_md("```\n")

# ---------- 3c) Heteroskedasticity (Breusch-Pagan) ----------
cat_md("## Heteroskedasticity (`lmtest::bptest`)\n")
# Use a pooled LM with country & year fixed effects absorbed via factors
pool_mod <- lm(log_gdp_pc ~ sec_enroll_gross + gini + factor(iso2c) + factor(year), data = df)
bp_res <- tryCatch(bptest(pool_mod), error = function(e) e)
cat_md("```")
cat_md(capture.output(print(bp_res)))
cat_md("```\n")

# ---------- 4) Residual diagnostics plot ----------
cat_md("## Residual vs Fitted (FE model)\n")
fe_fit <- as.numeric(fitted(fe_mod))
fe_res <- as.numeric(residuals(fe_mod))
res_df <- data.frame(fitted = fe_fit, resid = fe_res)

p <- ggplot(res_df, aes(fitted, resid)) +
  geom_point(alpha = 0.7) +
  geom_hline(yintercept = 0, linetype = 2) +
  labs(title = "FE model: Residuals vs Fitted", x = "Fitted", y = "Residuals") +
  theme_minimal(base_size = 12)

ggsave("outputs/fe_resid_vs_fitted.png", p, width = 6.5, height = 4.6, dpi = 120)
cat_md("Saved: `outputs/fe_resid_vs_fitted.png`\n")

cat("✅ Wrote diagnostics to ", sink_file, " and residual plot to outputs/fe_resid_vs_fitted.png\n", sep = "")
