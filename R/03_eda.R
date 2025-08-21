# R/03_eda.R
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(tidyr)
  library(scales)
  library(GGally)   # for ggcorr
})

inp <- "data/processed/panel_imputed.csv"
if (!file.exists(inp)) stop("Input not found: ", inp)
df <- read_csv(inp, show_col_types = FALSE)

dir.create("outputs", showWarnings = FALSE)

theme_min <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.major = element_line(color="#E6E6E6"),
    panel.grid.minor = element_blank(),
    axis.title = element_text(color="#222222"),
    plot.title = element_text(face="bold")
  )

# 1) Lines by country
p_gdp <- ggplot(df, aes(year, gdp_pc_const_usd, color = iso2c)) +
  geom_line(linewidth=0.9) +
  labs(title="GDP per capita (constant 2015 USD)", x=NULL, y="USD") +
  theme_min

p_sec <- ggplot(df, aes(year, sec_enroll_gross, color = iso2c)) +
  geom_line(linewidth=0.9) +
  labs(title="Secondary enrollment (gross %)", x=NULL, y="%") +
  theme_min

p_gini <- ggplot(df, aes(year, gini, color = iso2c)) +
  geom_line(linewidth=0.9) +
  labs(title="Gini index", x=NULL, y="Gini") +
  theme_min

ggsave("outputs/gdp_pc_lines.png", p_gdp, width=8, height=5, dpi=120)
ggsave("outputs/sec_enroll_lines.png", p_sec, width=8, height=5, dpi=120)
ggsave("outputs/gini_lines.png", p_gini, width=8, height=5, dpi=120)

# 2) Correlation heatmap (pooled across countries/years)
corr_df <- df %>% select(gdp_pc_const_usd, sec_enroll_gross, gini) %>% na.omit()
p_corr <- GGally::ggcorr(corr_df, label=TRUE, hjust=0.9, size=3) +
  ggtitle("Correlation: GDP pc, Secondary enrollment, Gini")
ggsave("outputs/corr_heatmap.png", p_corr, width=6, height=5, dpi=120)

# 3) Scatter + trend lines (pooled)
p_sc1 <- ggplot(df, aes(sec_enroll_gross, gdp_pc_const_usd)) +
  geom_point(alpha=0.6) + geom_smooth(method="lm", se=FALSE) +
  labs(title="GDP pc vs Secondary enrollment", x="Secondary enrollment (%)", y="GDP pc (USD)") +
  theme_min

p_sc2 <- ggplot(df, aes(gini, gdp_pc_const_usd)) +
  geom_point(alpha=0.6) + geom_smooth(method="lm", se=FALSE) +
  labs(title="GDP pc vs Gini", x="Gini", y="GDP pc (USD)") +
  theme_min

ggsave("outputs/scatter_gdp_vs_enroll.png", p_sc1, width=6.8, height=5, dpi=120)
ggsave("outputs/scatter_gdp_vs_gini.png", p_sc2, width=6.8, height=5, dpi=120)

message("📊 Saved: outputs/{gdp_pc_lines.png, sec_enroll_lines.png, gini_lines.png, corr_heatmap.png, scatter_*}.")
```
Rscript -e 'if (!requireNamespace("GGally", quietly=TRUE)) install.packages("GGally", repos="https://cloud.r-project.org")'
