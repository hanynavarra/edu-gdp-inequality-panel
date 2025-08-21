# R/06_model_robustness.R
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(plm)
  library(lmtest)
  library(sandwich)
  library(broom)
})

# ---------- Load data ----------
inp <- "data/processed/panel_imputed.csv"
if (!file.exists(inp)) stop("Input not found: ", inp)
df0 <- read_csv(inp, show_col_types = FALSE)

df <- df0 %>%
  transmute(
    iso2c = as.factor(iso2c),
    year = as.integer(year),
    gdp_pc_const_usd = as.numeric(gdp_pc_const_usd),
    sec_enroll_gross = as.numeric(sec_enroll_gross),
    gini = as.numeric(gini),
    log_gdp_pc = log(pmax(gdp_pc_const_usd, 1))
  ) %>% arrange(iso2c, year)

pdf <- pdata.frame(df, index = c("iso2c","year"))

# ---------- Models ----------
pool_mod <- plm(log_gdp_pc ~ sec_enroll_gross + gini, data = pdf, model = "pooling")
fe_i     <- plm(log_gdp_pc ~ sec_enroll_gross + gini, data = pdf, model = "within", effect = "individual")
fe_tw    <- plm(log_gdp_pc ~ sec_enroll_gross + gini, data = pdf, model = "within", effect = "twoways")
re_mod   <- plm(log_gdp_pc ~ sec_enroll_gross + gini, data = pdf, model = "random",  effect = "individual")

# ---------- SE corrections ----------
pool_se_cl <- vcovHC(pool_mod, type = "HC1", cluster = "group")
fe_i_se_cl <- vcovHC(fe_i,     type = "HC1", cluster = "group")
fe_i_se_dk <- vcovSCC(fe_i,    type = "HC1", maxlag = 2)
fe_tw_se_dk<- vcovSCC(fe_tw,   type = "HC1", maxlag = 2)
re_se_cl   <- vcovHC(re_mod,   type = "HC1", cluster = "group")

tidy_ct <- function(model, vc, label) {
  broom::tidy(coeftest(model, vcov = vc)) %>% mutate(model = label)
}

tab <- bind_rows(
  tidy_ct(pool_mod, pool_se_cl, "Pooled OLS (clustered)"),
  tidy_ct(fe_i,     fe_i_se_cl, "FE (country) clustered"),
  tidy_ct(fe_i,     fe_i_se_dk, "FE (country) Driscoll-Kraay"),
  tidy_ct(fe_tw,    fe_tw_se_dk,"FE (two-way) Driscoll-Kraay"),
  tidy_ct(re_mod,   re_se_cl,   "RE (clustered)")
) %>%
  filter(term != "(Intercept)") %>%
  rename(se = std.error, t = statistic, p = p.value) %>%
  select(model, term, estimate, se, t, p)

# ---------- Specification tests ----------
# LM test: RE vs pooled
lm_bp   <- tryCatch(plmtest(pool_mod, type = "bp"), error = identity)
# Hausman: FE vs RE
hausman <- tryCatch(phtest(fe_i, re_mod), error = identity)
# F-tests for FE necessity
fe_time <- plm(log_gdp_pc ~ sec_enroll_gross + gini, data = pdf, model = "within", effect = "time")
F_indiv <- tryCatch(pFtest(fe_i,  pool_mod), error = identity)
F_time  <- tryCatch(pFtest(fe_time, pool_mod), error = identity)

# ---------- Write markdown ----------
dir.create("reports", showWarnings = FALSE)
out <- "reports/model_robustness.md"
if (file.exists(out)) file.remove(out)

cat("# Model robustness & comparisons\n\n", file = out)
cat("Models: Pooled OLS, FE (country), FE (two-way), RE.\n\n", file = out, append = TRUE)

cat("## Coefficients under different SE corrections\n\n", file = out, append = TRUE)
cat("term = predictor; estimate = coefficient; se = standard error; p = p-value.\n\n", file = out, append = TRUE)
cat("```text\n", file = out, append = TRUE)
write.table(tab, file = out, append = TRUE, row.names = FALSE, quote = FALSE)
cat("```\n\n", file = out, append = TRUE)

fmt_test <- function(obj, title) {
  cap <- capture.output(print(obj))
  paste0("### ", title, "\n\n```text\n", paste(cap, collapse = "\n"), "\n```\n\n")
}

cat("## Specification tests\n\n", file = out, append = TRUE)
cat(fmt_test(lm_bp,   "LM test (RE vs pooled)"),   file = out, append = TRUE)
cat(fmt_test(hausman, "Hausman test (FE vs RE)"),  file = out, append = TRUE)
cat(fmt_test(F_indiv, "F-test: need country FE"),  file = out, append = TRUE)
cat(fmt_test(F_time,  "F-test: need time FE"),     file = out, append = TRUE)

cat("✅ Wrote ", out, "\n", sep = "")
message("✅ Wrote ", out)
