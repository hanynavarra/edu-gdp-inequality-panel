# R/install.R
pkgs <- c("WDI","dplyr","tidyr","readr","janitor","ggplot2","stringr")
to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")
message("Packages ready: ", paste(pkgs, collapse=", "))
