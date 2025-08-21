# R/05_fe_model.R
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(plm)
  library(lmtest)
  library(sandwich)
  library(ggplot2)
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
  ) %>%
  arrange(iso2c, year)

pdf <- pdata.frame(df, index = c("iso2c","year"))

# ---------- FE model ----------
fe_mod <- plm(log_gdp_pc ~ sec_enroll_gross + gini,
              data = pdf, model = "within", effect = "individual")

# SE variants
se_cluster <- vcovHC(fe_mod, type = "HC1", cluster = "group")
se_arellano <- vcovHC(fe_mod, method = "arellano", type = "HC1")
se_dk <- vcovSCC(fe_mod, type = "HC1", maxlag = 2)

# tidy output
tab <- bind_rows(
  tidy(coeftest(fe_mod, vcov = se_cluster)) %>% mutate(se_type = "Cluster (country)"),
  tidy(coeftest(fe_mod, vcov = se_arellano)) %>% mutate(se_type = "Arellano robust"),
  tidy(coeftest(fe_mod, vcov = se_dk)) %>% mutate(se_type = "Driscoll-Kraay")
)

dir.create("reports", showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)
out_md <- "reports/fe_model.md"

# write to markdown
if (file.exists(out_md)) file.remove(out_md)
cat("# Fixed-Effects Model\n", file = out_md)
cat("Equation: log(GDP per capita) ~ Secondary enrollment + Gini\n\n", file = out_md, append = TRUE)

for (s in unique(tab$se_type)) {
  cat("## ", s, "\n", file = out_md, append = TRUE)
  subt <- filter(tab, se_type == s)
  cat("```", file = out_md, append = TRUE)
  write.table(subt[,c("term","estimate","std.error","statistic","p.value")],
              file = out_md, append = TRUE, row.names = FALSE, quote = FALSE)
  cat("```\n\n", file = out_md, append = TRUE)
}

# ---------- Coefficient plot ----------
plot_df <- tab %>% 
  filter(term != "(Intercept)") %>%
  mutate(sig = p.value < 0.05)

p <- ggplot(plot_df, aes(x = term, y = estimate, color = se_type, shape = sig)) +
  geom_point(position = position_dodge(width = 0.6), size = 3) +
  geom_errorbar(aes(ymin = estimate - 1.96*std.error,
                    ymax = estimate + 1.96*std.error),
                position = position_dodge(width = 0.6), width = 0.2) +
  geom_hline(yintercept = 0, linetype = 2) +
  coord_flip() +
  labs(title = "FE model coefficients under different SE corrections",
       y = "Coefficient (log GDP per capita)", x = "") +
  theme_minimal(base_size = 12)

ggsave("outputs/fe_model_coefs.png", p, width = 7, height = 4.5, dpi = 120)

cat("✅ Wrote FE model results to ", out_md, " and plot to outputs/fe_model_coefs.png\n", sep = "")
