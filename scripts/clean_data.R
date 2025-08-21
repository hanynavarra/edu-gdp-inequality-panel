# clean_data.R
library(readr)
library(dplyr)

# Example: load raw dataset
raw <- read_csv("data/raw_data.csv")

# Example cleaning steps
clean <- raw %>%
  rename(year = Year, value = Value) %>%
  filter(!is.na(value))

# Save cleaned version
write_csv(clean, "data/clean_data.csv")

message("✅ Data cleaned and saved to data/clean_data.csv")
