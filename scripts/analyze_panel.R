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
