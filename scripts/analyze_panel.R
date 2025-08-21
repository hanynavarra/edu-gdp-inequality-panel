# analyze_panel.R
library(readr)
library(ggplot2)

# Load cleaned data
data <- read_csv("data/clean_data.csv")

# Example plot
p <- ggplot(data, aes(x = year, y = value)) +
  geom_line() +
  theme_minimal()

ggsave("outputs/sample_plot.png", p, width = 6, height = 4)

message("📊 Plot saved to outputs/sample_plot.png")
# scripts/analyze_panel.R
library(readr)
library(dplyr)
library(ggplot2)

df <- read_csv("data/processed/panel_imputed.csv", show_col_types = FALSE)

dir.create("outputs", showWarnings = FALSE)

p1 <- ggplot(df, aes(year, gdp_pc_const_usd, color = iso2c, group = iso2c)) +
  geom_line(linewidth = 0.9) +
  labs(title = "GDP per capita (constant USD), ASEAN-6",
       x = NULL, y = "USD (2015 constant)") +
  theme_minimal()

p2 <- ggplot(df, aes(year, sec_enroll_gross, color = iso2c, group = iso2c)) +
  geom_line(linewidth = 0.9) +
  labs(title = "Secondary school enrollment (gross %)",
       x = NULL, y = "%") +
  theme_minimal()

p3 <- ggplot(df, aes(year, gini, color = iso2c, group = iso2c)) +
  geom_line(linewidth = 0.9) +
  labs(title = "Gini index (income inequality)",
       x = NULL, y = "Gini") +
  theme_minimal()

ggsave("outputs/gdp_pc_lines.png", p1, width = 8, height = 5, dpi = 120)
ggsave("outputs/sec_enroll_lines.png", p2, width = 8, height = 5, dpi = 120)
ggsave("outputs/gini_lines.png", p3, width = 8, height = 5, dpi = 120)

message("📊 Saved plots to outputs/: gdp_pc_lines.png, sec_enroll_lines.png, gini_lines.png")
